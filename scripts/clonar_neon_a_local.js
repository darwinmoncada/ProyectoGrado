// clonar_neon_a_local.js
// ============================================================================
// Sincroniza el contenido completo de la base de datos de Neon (producción)
// hacia el Postgres local en Docker, tabla por tabla, usando el protocolo
// binario nativo de Postgres a través del driver "pg" (node-postgres).
//
// POR QUÉ EXISTE ESTE SCRIPT (lección aprendida — ver INSTRUCCIONES_DESPLIEGUE.md):
// Los métodos tradicionales de copiar datos entre instancias de Postgres
// (pg_dump a un archivo .sql, seguido de psql -f o de una redirección de shell)
// pasan el contenido por una capa de texto de terminal/consola en algún punto
// del camino. En este proyecto, esa capa de texto reinterpretó more de una vez
// los bytes UTF-8 de las tildes/eñes bajo una codificación distinta (primero
// UTF-16 vía PowerShell, luego una codepage de 8 bits tipo CP850 vía psql),
// dejando literal mojibake en los datos ("Almacén" -> "Almac??n" o
// "Almac├®n" según el caso). Cada vez que ocurrió, fue en un punto distinto de
// la tubería, lo que la hace difícil de prevenir por completo con SQL de texto.
//
// Este script evita el problema de raíz: usa SELECT/INSERT parametrizados,
// donde cada valor viaja como un parámetro tipado del protocolo binario de
// Postgres — nunca como texto SQL interpolado ni pasa por psql/shell en
// ningún punto. No hay capa de texto que pueda reinterpretar la codificación.
// ============================================================================

const { Client } = require('pg');

const NEON_URL = process.env.NEON_URL;
if (!NEON_URL) {
  console.error('Falta la variable de entorno NEON_URL con la cadena de conexión de Neon.');
  console.error('Ejemplo: NEON_URL="postgresql://usuario:password@host/basededatos?sslmode=require"');
  process.exit(1);
}

const LOCAL_CONFIG = {
  host: process.env.PGHOST || 'localhost',
  port: Number(process.env.PGPORT || 5432),
  user: process.env.PGUSER || 'postgres',
  password: process.env.PGPASSWORD || 'postgres',
  database: process.env.PGDATABASE || 'inventario_uts',
};

async function main() {
  const neon = new Client({ connectionString: NEON_URL, ssl: { rejectUnauthorized: false } });
  const local = new Client(LOCAL_CONFIG);

  await neon.connect();
  console.log('Conectado a Neon (origen).');
  await local.connect();
  console.log(`Conectado a Postgres local (destino: ${LOCAL_CONFIG.host}:${LOCAL_CONFIG.port}).`);

  const { rows: neonEnc } = await neon.query('SHOW server_encoding');
  const { rows: localEnc } = await local.query('SHOW server_encoding');
  console.log(`Encoding Neon: ${neonEnc[0].server_encoding} | Encoding local: ${localEnc[0].server_encoding}`);

  const { rows: tableRows } = await neon.query(`
    SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename
  `);
  const tableNames = tableRows.map((r) => r.tablename);
  console.log('Tablas encontradas en Neon:', tableNames.join(', '));

  console.log('\n--- Limpiando tablas locales (TRUNCATE ... RESTART IDENTITY CASCADE) ---');
  const quotedList = tableNames.map((t) => `"${t}"`).join(', ');
  await local.query(`TRUNCATE TABLE ${quotedList} RESTART IDENTITY CASCADE`);
  console.log('Tablas locales limpiadas.');

  // Desactiva temporalmente los triggers de FK en el destino para poder insertar
  // en cualquier orden sin calcular manualmente el orden de dependencias entre tablas.
  await local.query('SET session_replication_role = replica;');

  let totalRows = 0;
  const summary = [];
  try {
    for (const table of tableNames) {
      const { rows } = await neon.query(`SELECT * FROM "${table}"`);
      if (rows.length === 0) {
        summary.push(`${table}: 0 filas`);
        continue;
      }

      const columns = Object.keys(rows[0]);
      const colList = columns.map((c) => `"${c}"`).join(', ');
      const placeholders = columns.map((_, i) => `$${i + 1}`).join(', ');

      for (const row of rows) {
        const values = columns.map((c) => row[c]);
        await local.query(`INSERT INTO "${table}" (${colList}) VALUES (${placeholders})`, values);
      }
      summary.push(`${table}: ${rows.length} filas copiadas`);
      totalRows += rows.length;
    }
  } finally {
    await local.query('SET session_replication_role = origin;');
  }

  console.log('\n--- Resumen de copia ---');
  summary.forEach((s) => console.log(s));
  console.log(`Total de filas migradas: ${totalRows}`);

  console.log('\n--- Reajustando secuencias (auto-increment) ---');
  for (const table of tableNames) {
    const { rows: idCols } = await local.query(`
      SELECT column_name FROM information_schema.columns
      WHERE table_schema = 'public' AND table_name = $1 AND column_name = 'id'
    `, [table]);
    if (idCols.length === 0) continue;

    const { rows: seqRows } = await local.query(`SELECT pg_get_serial_sequence($1, 'id') AS seq`, [table]);
    const seq = seqRows[0]?.seq;
    if (!seq) continue;

    await local.query(`
      SELECT setval($1, COALESCE((SELECT MAX(id) FROM "${table}"), 1), (SELECT MAX(id) IS NOT NULL FROM "${table}"))
    `, [seq]);
    console.log(`Secuencia de ${table} reajustada.`);
  }

  console.log('\n--- Verificación de codificación (debe imprimir 0 en cada línea) ---');
  for (const col of ['name', 'description']) {
    for (const table of ['areas', 'asset_types', 'assets']) {
      const { rows: colExists } = await local.query(`
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = $1 AND column_name = $2
      `, [table, col]);
      if (colExists.length === 0) continue;
      const { rows: badRows } = await local.query(
        `SELECT count(*) AS c FROM "${table}" WHERE "${col}" LIKE '%?%' OR "${col}" LIKE '%├%' OR "${col}" LIKE '%┬%'`
      );
      console.log(`${table}.${col}: ${badRows[0].c} filas con posible corrupción`);
    }
  }

  await neon.end();
  await local.end();
  console.log('\nClonación completada exitosamente.');
}

main().catch((err) => {
  console.error('ERROR:', err);
  process.exit(1);
});
