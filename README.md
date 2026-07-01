# ProyectoGrado

## Descripción

Este repositorio contiene una aplicación de inventario con backend Java/Spring Boot y frontend React/Vite. Está preparada para ejecutarse en contenedores Docker y desplegarse en plataformas como Railway.

## Arquitectura

- `backend/`: servicio Java con Dockerfile para construir y ejecutar la API.
- `frontend/`: aplicación web React con Dockerfile para construir el frontend y servirlo con Nginx.
- `docker-compose.yml`: orquesta los servicios `postgres`, `backend` y `frontend` para desarrollo local.

## Estructura del proyecto

- `backend/`
  - `Dockerfile`
  - `pom.xml`
  - `src/`
  - `entrypoint.sh`
- `frontend/`
  - `Dockerfile`
  - `package.json`
  - `vite.config.js`
  - `src/`
  - `nginx.conf`
- `docker-compose.yml`
- `.gitignore`
- `env.txt` (no se debe versionar)

## Requisitos

- Docker y Docker Compose
- Git

> No es necesario instalar Java ni Node localmente si se usa Docker.

## Configuración local

1. Clonar el repositorio:

```bash
git clone <REPO_URL>
cd ProyectoGrado
```

2. Crear o revisar `env.txt` con las variables necesarias para el backend.

3. Levantar los servicios:

```bash
docker compose up --build
```

4. Acceder a la aplicación:

- Frontend: `http://localhost`
- Backend: `http://localhost:8080`
- PostgreSQL: `localhost:5432`

## Backend

El backend usa Java 25 y Maven. El `Dockerfile` construye la aplicación en una etapa separada y luego ejecuta el JAR en un contenedor ligero.

### Comandos útiles

```bash
cd backend
mvn clean package -DskipTests
```

## Frontend

El frontend usa Vite y React. El `Dockerfile` crea una build de producción y la sirve con Nginx.

### Comandos útiles

```bash
cd frontend
npm install
npm run build
```

## Despliegue en Railway

Railway puede construir los contenedores usando los `Dockerfile` de `backend/` y `frontend/`. Asegúrate de configurar las variables de entorno en Railway en lugar de usar `env.txt` directamente.

Variables típicas:

- `POSTGRES_DB`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `JWT_SECRET`
- `FRONTEND_URL`

## Buenas prácticas Git

Se ignoran los siguientes elementos:

- `backend/target/`
- `frontend/node_modules/`
- `frontend/dist/`
- archivos de entorno locales (`.env`, `env.txt`)
- configuraciones de IDE (`.vscode/`, `.idea/`)

## Notas finales

- `inventario/` fue removido porque no forma parte del despliegue actual.
- Si agregas nuevas variables de entorno, no las subas al repositorio.
- Para cualquier cambio en la configuración de Docker o en el flujo de despliegue, actualiza también este README.
 
