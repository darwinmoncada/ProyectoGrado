# Guía de Despliegue Local — Sistema de Inventario TI (UTS)

Esta guía documenta cómo levantar el sistema completo en un entorno 100% local con
Docker, y cómo sincronizar los datos reales de producción (Neon) hacia esa base de
datos local de forma segura y sin pérdida de codificación.

## 1. Arquitectura del entorno

El sistema corre como **3 contenedores Docker** sobre una red interna privada, sin
ninguna dependencia de servicios en la nube para operar:

```
┌─────────────────────────────────────────────────────────────────────────┐
│  Red Docker: proyectogrado_inventario_net (bridge)                      │
│                                                                          │
│   ┌──────────────────────┐      ┌──────────────────────┐               │
│   │ inventario_frontend  │      │  inventario_backend  │               │
│   │ imagen:              │ ───► │  imagen:              │               │
│   │  proyectogrado-      │ /api │   proyectogrado-      │               │
│   │  frontend            │      │   backend             │               │
│   │ nginx + build React  │      │  Spring Boot (Java 17)│               │
│   │ puerto host: 80      │      │  puerto host: 8080    │               │
│   └──────────────────────┘      └──────────┬───────────┘               │
│                                             │ JDBC                      │
│                                             ▼                           │
│                                  ┌──────────────────────┐               │
│                                  │    inventario_db      │               │
│                                  │  imagen: postgres:16   │               │
│                                  │  -alpine               │               │
│                                  │  puerto host: 5432      │               │
│                                  │  volumen: postgres_data │               │
│                                  └──────────────────────┘               │
└─────────────────────────────────────────────────────────────────────────┘
```

| Contenedor             | Imagen                     | Rol                                         | Puerto host |
|------------------------|----------------------------|----------------------------------------------|-------------|
| `inventario_frontend`  | `proyectogrado-frontend`   | Nginx sirviendo el build de React + proxy `/api` | 80        |
| `inventario_backend`   | `proyectogrado-backend`    | API Spring Boot (Java 17, Maven multi-stage)  | 8080        |
| `inventario_db`        | `postgres:16-alpine`       | Base de datos PostgreSQL                      | 5432        |

Notas de la arquitectura:

- **`inventario_frontend`** no habla directamente con el backend por red pública: nginx
  hace *reverse proxy* de cualquier ruta `/api/*` hacia `http://backend:8080` usando el
  nombre de servicio interno de Docker (`frontend/nginx.conf`), por lo que no hace falta
  configurar CORS entre ellos.
- **`inventario_backend`** se conecta a Postgres usando el nombre de servicio `postgres`
  (`jdbc:postgresql://postgres:5432/inventario_uts`), no una IP fija — Docker resuelve
  ese nombre dentro de la red `proyectogrado_inventario_net`.
- El nombre del proyecto Compose está fijado explícitamente (`name: proyectogrado` en
  `docker-compose.yml`), así que los nombres de imagen y de red **no cambian** aunque la
  carpeta del proyecto se renombre o se extraiga en otra ubicación — importante para que
  esta guía y los scripts sigan funcionando igual en la máquina del jurado.
- Los datos de Postgres viven en el volumen Docker `postgres_data`, que persiste aunque
  los contenedores se detengan, se recreen o la PC se reinicie.

## 2. Requisitos

- **Docker Desktop** instalado (incluye Docker Compose v2).
- Node.js **no es obligatorio** para el uso normal del sistema — todo corre en
  contenedores. Solo se necesita si se quiere ejecutar el script de sincronización de
  datos (sección 4) sin usar el contenedor `node:20-alpine` de apoyo.

## 3. Uso rápido (entregable "one-click")

Para arrancar todo el ecosistema sin usar la terminal:

```
Doble clic en: iniciar_sistema.bat
```

Este script (raíz del proyecto):
1. Verifica que Docker Desktop esté corriendo; si no lo está, intenta abrirlo
   automáticamente y espera a que quede listo.
2. Detecta la IP de este equipo en la red local (para acceso desde otros equipos de la
   universidad — ver sección 6).
3. Ejecuta `docker compose up -d` (construye las imágenes la primera vez; en ejecuciones
   posteriores solo arranca los contenedores existentes).
4. Espera a que el backend responda en `/actuator/health` antes de continuar, para no
   mostrar una pantalla en blanco.
5. Abre el navegador predeterminado en `http://localhost`, listo en la pantalla de Login.

Para detener el sistema (sin perder datos):

```
Doble clic en: detener_sistema.bat
```

## 4. El hito de sincronización de datos (lección aprendida)

Durante el desarrollo de este proyecto, sincronizar los datos reales de producción
(Neon) hacia el Postgres local expuso un problema de codificación que vale la pena
documentar formalmente, porque su solución terminó siendo una decisión de arquitectura,
no solo un parche puntual.

### 4.1 El problema: mojibake por intermediación de la shell

El camino "de manual" para copiar datos entre dos instancias de Postgres es:

```
pg_dump (Neon) > archivo.sql   →   psql -f archivo.sql (local)
```

En la práctica, **cada flecha de ese diagrama es una capa de texto** (una consola, una
tubería del sistema operativo, un cliente `psql` interpretando un archivo) que puede
reinterpretar los bytes UTF-8 de una tilde o una "ñ" bajo una codificación distinta antes
de volver a guardarlos. En este proyecto ocurrió **dos veces, de dos formas distintas**:

1. **Redirección de PowerShell** (`pg_dump ... > archivo.sql`): PowerShell no preserva
   UTF-8 por defecto al redirigir la salida de un comando a un archivo — el resultado
   quedó en UTF-16, y al reimportarlo, cada tilde se perdió y quedó como un `?` literal
   (`"Almacén"` → `"Almac??n"`).
2. **`psql -f` sin `client_encoding` forzado**: al reparar el problema anterior con un
   script SQL de reemplazo, el propio `psql` reinterpretó los bytes UTF-8 del archivo de
   reparación como si fueran una codepage de 8 bits estilo DOS (CP850) y los volvió a
   guardar como UTF-8 — produciendo una mojibake distinta y más rara
   (`"Almacén"` → `"Almac├®n"`).

La lección: **no se puede confiar en que un método de copia por texto/shell sea seguro
solo porque "no pasa por PowerShell"** — cualquier herramienta de línea de comandos que
interprete texto (`psql` incluido) puede tener su propio supuesto de codificación por
defecto, y ese supuesto puede fallar silenciosamente sin lanzar ningún error.

### 4.2 La solución: sincronización binaria nativa (sin intermediación de texto)

La solución de fondo fue **eliminar la capa de texto por completo**: en vez de generar
un archivo `.sql` intermedio y pasarlo por un cliente de consola, se escribió
[`scripts/clonar_neon_a_local.js`](scripts/clonar_neon_a_local.js), un script Node.js que:

1. Abre una conexión simultánea a Neon (origen) y al Postgres local (destino) usando el
   driver `pg` (node-postgres).
2. Lee cada tabla del esquema `public` con `SELECT *`.
3. Inserta cada fila en el destino con **consultas parametrizadas**
   (`INSERT INTO tabla (...) VALUES ($1, $2, ...)`, con los valores pasados como
   parámetros, nunca como texto SQL interpolado).

Esto importa porque, con consultas parametrizadas, cada valor viaja codificado en el
**protocolo binario de Postgres** de extremo a extremo — nunca se serializa a texto de
consola en ningún punto intermedio, así que no existe ninguna capa que pueda
reinterpretar los bytes UTF-8 bajo otra codificación. El script además:

- Limpia las tablas locales (`TRUNCATE ... RESTART IDENTITY CASCADE`) antes de copiar,
  evitando conflictos con datos preexistentes.
- Desactiva temporalmente los triggers de llave foránea en el destino
  (`SET session_replication_role = replica`) para poder insertar las tablas en cualquier
  orden, sin tener que calcular manualmente el orden de dependencias entre ellas.
- Reajusta las secuencias de autoincremento al final, para que la aplicación pueda seguir
  insertando filas nuevas sin colisionar con los IDs recién copiados.
- Termina con una verificación automática de codificación (cuenta filas con patrones de
  corrupción conocidos; debe imprimir `0` en cada línea).

#### Cómo ejecutarlo

No hace falta instalar Node.js en el equipo: se ejecuta dentro de un contenedor temporal
`node:20-alpine` conectado a la misma red Docker del proyecto.

```powershell
# 1) Asegúrate de que los contenedores del proyecto estén corriendo
docker compose up -d

# 2) Define tu cadena de conexión de Neon (no la escribas en ningún archivo del repo)
$env:NEON_URL = "postgresql://usuario:password@host/basededatos?sslmode=require"

# 3) Ejecuta el script dentro de un contenedor conectado a la red del proyecto
docker run --rm `
  --network proyectogrado_inventario_net `
  -e PGHOST=postgres `
  -e NEON_URL=$env:NEON_URL `
  -v "${PWD}/scripts:/app" `
  -w /app `
  node:20-alpine `
  sh -c "npm install --silent && node clonar_neon_a_local.js"
```

Al terminar, reinicia el backend para que arranque con una conexión limpia sobre los
datos nuevos:

```powershell
docker restart inventario_backend
```

> ⚠️ **Si `docker run` con `-e PGHOST=postgres` no puede autenticarse contra
> `localhost:5432` al correrlo directamente en tu máquina** (sin el contenedor
> `node:20-alpine` de por medio): en algunos entornos con Docker Desktop para Windows, la
> conexión reenviada a `localhost` no llega con la IP de origen `127.0.0.1` que Postgres
> espera para autenticación de confianza, y falla con "password authentication failed".
> La solución es la misma de arriba: correr el script **dentro de un contenedor unido a
> `proyectogrado_inventario_net`**, conectando por el nombre de servicio `postgres` en vez
> de `localhost` — así se evita esa capa de NAT por completo.

### 4.3 Verificación posterior (recomendada siempre)

Sin importar qué método se use para poblar la base de datos, verifica después con esta
consulta — si devuelve `0` filas, la codificación quedó correcta:

```sql
SELECT name FROM areas WHERE name LIKE '%?%' OR name LIKE '%├%' OR name LIKE '%┬%';
```

Si en algún momento los datos quedan con tildes corruptas por haber usado un método de
texto (`pg_dump`/`psql` manual) en vez del script oficial de la sección 4.2, la forma
correcta de repararlas es la misma: un `UPDATE` por diccionario ejecutado por el mismo
canal binario (Node.js + `pg`), nunca por `psql` — por la razón explicada en la sección 4.1.

## 5. Verificar que el sistema tiene los datos esperados

- Inicia sesión con tus credenciales (`admin` / `Admin@123` si es una instalación nueva,
  o las credenciales reales si ya se sincronizaron datos de producción).
- El Dashboard debe mostrar el conteo real de activos, dispositivos de red y los últimos
  movimientos de inventario.
- Revisa **Administración → Auditoría**: el historial debe reflejar los eventos reales.
- Revisa que nombres con tildes (p. ej. un área llamada "Almacén" o un activo tipo
  "Cámara") se vean correctamente, sin `?` ni caracteres extraños.

## 6. Acceso desde otros equipos de la red

- **Dentro de la red de la universidad**: cualquier equipo conectado a la misma red
  (cableada o Wi-Fi institucional) puede entrar a `http://<IP-detectada>` — esa IP se
  detecta automáticamente al ejecutar `iniciar_sistema.bat` (paso 2 de 5) y se muestra
  tanto al final de la consola como en el pie del menú lateral de la aplicación
  (ícono ⓘ para más detalles).
- **Desde fuera de la universidad**:
  1. **IP pública + reenvío de puertos**: pide al área de TI que redirija el puerto 80 de
     la IP pública de la institución hacia este equipo.
  2. **Ngrok** (más simple, sin tocar el router): instala [ngrok](https://ngrok.com/download),
     ejecuta `ngrok http 80` en este equipo y comparte la URL temporal que te entregue
     (ej. `https://xxxx.ngrok-free.app`).

## 7. Notas de seguridad

- Nunca escribas la cadena de conexión de Neon (`NEON_URL`) directamente en un archivo
  del repositorio — pásala como variable de entorno de la sesión (`$env:NEON_URL`, como
  en el ejemplo de la sección 4.2) y no la dejes en el historial de comandos si el equipo
  es compartido.
- `env.txt`, si todavía existe en el proyecto, contiene credenciales de Neon y está
  excluido de `.gitignore`; no lo compartas ni lo subas a repositorios públicos.
- Las contraseñas por defecto de la base de datos local (`postgres` / `postgres`) y del
  usuario `admin` (`Admin@123`) son solo para el entorno de desarrollo/sustentación —
  cámbialas antes de cualquier despliegue en un entorno con acceso real de usuarios.
