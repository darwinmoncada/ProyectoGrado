# Despliegue local y migración de datos desde Neon

Esta guía explica cómo levantar el sistema completamente en local (sin depender de Neon)
y cómo traer los datos que ya tienes registrados en la nube antes del primer arranque.

## Requisitos

- **Docker Desktop** instalado y corriendo (ícono de la ballena visible en la bandeja del sistema).
- Los archivos `iniciar_servidor.bat` y `detener_servidor.bat` en la raíz del proyecto.

## ⚠️ Importante: el orden importa

Si ya ejecutaste `iniciar_servidor.bat` alguna vez, el contenedor de la base de datos
**ya tiene un esquema vacío** creado por las migraciones del backend (Flyway). Si intentas
importar el respaldo de Neon sobre ese esquema existente, obtendrás errores de
"la tabla ya existe". Por eso, la secuencia correcta es:

1. Levantar **solo** la base de datos (vacía).
2. Importar el respaldo de Neon en esa base vacía.
3. Recién ahí iniciar el backend y el frontend.

Si ya arrancaste el sistema antes y quieres empezar de cero, borra el volumen local primero:

```powershell
docker compose down -v
```

(`-v` borra el volumen `postgres_data`; tus datos de Neon siguen intactos en la nube, así que
esto es seguro).

## Paso 1 — Levantar solo la base de datos local

Desde la raíz del proyecto:

```powershell
docker compose up -d postgres
```

Espera unos segundos y confirma que esté saludable:

```powershell
docker ps --filter "name=inventario_db"
```

Debe mostrar `(healthy)` en la columna STATUS.

## Paso 2 — Exportar el respaldo desde Neon

Tu cadena de conexión a Neon ya está guardada en el archivo `env.txt` (en la raíz del
proyecto, variable `DATABASE_URL`). **No necesitas instalar PostgreSQL en tu equipo** —
puedes usar Docker para ejecutar `pg_dump` directamente:

```powershell
docker run --rm -v "${PWD}:/backup" postgres:16-alpine sh -c "pg_dump 'TU_DATABASE_URL_DE_ENV.TXT' > /backup/dump_neon.sql"
```

Reemplaza `TU_DATABASE_URL_DE_ENV.TXT` por el valor completo de `DATABASE_URL` que aparece
en `env.txt` (cópialo tal cual, entre comillas simples).

Esto genera un archivo `dump_neon.sql` en la carpeta actual con todos tus datos.

> ⚠️ **Por qué el comando escribe el archivo así y no con `> dump_neon.sql` directo en
> PowerShell**: PowerShell reinterpreta la salida de los comandos antes de redirigirla con
> `>`, y por defecto la guarda en UTF-16 en vez de UTF-8 — eso corrompe cualquier tilde o
> "ñ" del dump antes de que toque el disco (así se originó el problema de "Almac??n",
> "C??mara", etc. la primera vez). Montando la carpeta actual como `/backup` dentro del
> contenedor, la redirección `>` ocurre en el `sh` de Linux del contenedor, que sí preserva
> UTF-8 correctamente — PowerShell nunca toca el contenido del archivo.

### Alternativa con interfaz gráfica (pgAdmin o DBeaver)

Si prefieres no usar la terminal:

- **pgAdmin**: conéctate a tu servidor Neon con los datos de `env.txt`, clic derecho sobre
  la base `inventario_uts` → **Backup...** → formato **Plain** → guarda el archivo `.sql`.
- **DBeaver**: clic derecho sobre la conexión a Neon → **Herramientas (Tools) → Backup**
  (dump), formato plano. DBeaver también permite **Transferencia de datos** directa entre
  dos conexiones activas (Neon → local) sin pasar por un archivo intermedio, si ya tienes
  ambas conexiones configuradas.

## Paso 3 — Importar el respaldo en la base de datos local

Con el contenedor `inventario_db` corriendo (Paso 1), copia el archivo **directamente
dentro del contenedor** con `docker cp` y ejecútalo desde ahí con `psql -f`:

```powershell
docker cp dump_neon.sql inventario_db:/tmp/dump_neon.sql
docker exec inventario_db psql -U postgres -d inventario_uts -f /tmp/dump_neon.sql
```

> ⚠️ **No uses `docker exec -i ... < dump_neon.sql`**: esa redirección hace que PowerShell
> lea el archivo y lo reenvíe por la tubería del proceso, reinterpretando su codificación en
> el camino — es la otra mitad de la causa de la corrupción de tildes/eñes ("Almac??n",
> "C??mara IP", etc.) que tuvimos que reparar manualmente la primera vez. `docker cp` copia
> los bytes del archivo tal cual al filesystem del contenedor (sin pasar por PowerShell), y
> `psql -f` lo lee directamente desde ahí — así se preserva UTF-8 de punta a punta.

Si usaste pgAdmin/DBeaver para generar el `.sql`, el mismo par de comandos funciona
apuntando al nombre de ese archivo.

### Si los datos ya quedaron con tildes corruptas (`Almac??n`, `C??mara`, etc.)

Si importaste un dump con el método antiguo (con `<` en PowerShell) antes de esta guía, usa
el script de reparación `reparar_tildes.sql` incluido en la raíz del proyecto — corrige por
diccionario los patrones de corrupción conocidos sin necesidad de reimportar nada:

```powershell
docker cp reparar_tildes.sql inventario_db:/tmp/reparar_tildes.sql
docker exec inventario_db psql -U postgres -d inventario_uts -f /tmp/reparar_tildes.sql
```

Es idempotente: puedes ejecutarlo más de una vez sin efectos secundarios. Al final imprime
una consulta de verificación — si no devuelve filas, ya no queda ningún `?` corrupto en
`areas`, `asset_types` ni `assets`.

## Paso 4 — Iniciar el sistema completo

Ahora sí, ejecuta:

```powershell
.\iniciar_servidor.bat
```

Esto:
- Detecta la IP de tu equipo en la red local (la misma que verás luego en el pie del menú
  lateral de la aplicación).
- Construye e inicia los 3 contenedores (`postgres`, `backend`, `frontend`).
- Abre automáticamente `http://localhost` en tu navegador.

El backend arrancará contra la base de datos **ya poblada** con tus datos de Neon — Flyway
detecta que las migraciones ya se aplicaron (vienen incluidas en el respaldo) y no las
vuelve a ejecutar, y `ddl-auto: update` respeta las tablas existentes sin tocarlas.

## Verificar que la migración funcionó

- Inicia sesión con tus credenciales existentes (las que ya usabas contra Neon).
- Revisa que tus activos, usuarios y áreas aparezcan en el sistema.
- Revisa **Administración → Auditoría**: los registros históricos de Neon deben seguir ahí.

## Detener el servidor

```powershell
.\detener_servidor.bat
```

Esto apaga los 3 contenedores. Tus datos **no se pierden**: quedan guardados en el volumen
Docker `postgres_data`, que persiste aunque apagues el PC.

## Acceso desde otros equipos

- **Dentro de la red de la universidad**: cualquier equipo conectado a la misma red
  (cableada o Wi-Fi institucional) puede entrar a `http://<IP-detectada>` — esa IP se
  muestra tanto al final de `iniciar_servidor.bat` como en el pie del menú lateral de la
  aplicación (ícono ⓘ para más detalles).
- **Desde fuera de la universidad**:
  1. **IP pública + reenvío de puertos**: pide al área de TI que redirija el puerto 80 de
     la IP pública de la institución hacia este equipo.
  2. **Ngrok** (más simple, sin tocar el router): instala [ngrok](https://ngrok.com/download),
     ejecuta `ngrok http 80` en este equipo y comparte la URL temporal que te entregue
     (ej. `https://xxxx.ngrok-free.app`).

## Notas de seguridad

- `env.txt` contiene la contraseña de tu base de datos en Neon. No lo compartas ni lo subas
  a repositorios públicos (ya está excluido en `.gitignore`).
- Una vez migrados y verificados tus datos, puedes conservar `env.txt` como respaldo de las
  credenciales de Neon o eliminarlo si ya no vas a usar la nube.
