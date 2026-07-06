# Sistema de Inventario TI — Unidades Tecnológicas de Santander (UTS)

Sistema web para la gestión integral de activos tecnológicos institucionales: control de
inventario, hojas de vida de equipos, infraestructura de red y auditoría, con un modelo
de seguridad basado en roles. Diseñado para operar **100% en local**, sin depender de
ningún servicio en la nube para funcionar.

## Descripción general

El sistema centraliza la administración del inventario TI de la institución, permitiendo:

- **Gestión de activos tecnológicos**: registro, edición, baja y trazabilidad completa de
  equipos (computadores, cámaras, switches, mobiliario técnico, etc.), incluyendo marca,
  modelo, número de serie, especificaciones y estado.
- **Hojas de vida de equipo**: ficha técnica individual por activo, con su historial de
  movimientos, asignación y configuración de red, exportable a PDF con diseño
  corporativo (logo institucional, encabezado, paginación).
- **Control de inventario y movimientos**: entradas, salidas, traslados y préstamos de
  equipos entre áreas y usuarios, con KPIs y filtros avanzados.
- **Infraestructura de red**: inventario de dispositivos de red (IP, MAC, VLAN, estado de
  conexión) y su topología.
- **Módulo de auditoría integral**: registro inmutable de quién hizo qué, cuándo y desde
  qué IP — incluyendo inicios de sesión, creaciones, modificaciones y eliminaciones —
  con filtros por usuario, acción, entidad y rango de fechas.
- **Gestión de usuarios y áreas** con control de acceso jerárquico por rol.
- **Modo oscuro** ejecutivo, con persistencia de preferencia por usuario.

## Arquitectura del sistema (stack tecnológico)

| Capa               | Tecnología                                                                 |
|---------------------|-----------------------------------------------------------------------------|
| **Backend**         | Java 17 · Spring Boot 3 · Spring Data JPA · Flyway (migraciones versionadas) |
| **Seguridad**       | Spring Security 6 · JWT sin estado (*stateless*) · autorización por roles (RBAC) en dos capas (filtro HTTP + `@PreAuthorize` a nivel de método) |
| **Frontend**        | React 18 · Material-UI (MUI) v5 · React Query · React Router                |
| **Base de datos**   | PostgreSQL 16                                                               |
| **Generación de PDF** | OpenPDF (reportes con identidad corporativa institucional)                 |
| **Orquestación**    | Docker + Docker Compose (3 contenedores: frontend, backend, base de datos)  |

El sistema corre como 3 contenedores sobre una red Docker privada (`inventario_net`):
Nginx sirve el build de React y hace *reverse proxy* de `/api/*` hacia el backend Spring
Boot, que a su vez se conecta a PostgreSQL por el nombre de servicio interno de Docker.
No hay ninguna dependencia de servicios externos en tiempo de ejecución — el sistema fue
migrado deliberadamente de una base de datos en la nube (Neon) a un despliegue
completamente local, ver `INSTRUCCIONES_DESPLIEGUE.md` para el detalle de esa migración y
las lecciones aprendidas sobre integridad de codificación (UTF-8) en el camino.

> El detalle completo de la arquitectura, el modelo de seguridad por roles y las
> decisiones de diseño (por qué Spring Boot, por qué este esquema de eliminación segura,
> etc.) está documentado en **[`MANUAL_TECNICO.md`](MANUAL_TECNICO.md)**.

## Estrategia de inicialización offline

El proyecto incluye [`init.sql`](init.sql) en la raíz: un volcado completo (esquema +
datos reales) de las **11 tablas** del sistema, con todos los catálogos y datos maestros
ya cargados (áreas, tipos de activo, activos, usuarios, roles, movimientos de inventario,
dispositivos de red y el historial de auditoría).

Este archivo está mapeado en `docker-compose.yml` al directorio de inicialización nativo
de PostgreSQL:

```yaml
volumes:
  - ./init.sql:/docker-entrypoint-initdb.d/init.sql
```

Como resultado, **la primera vez** que se levanta el sistema sobre un volumen de Docker
vacío, PostgreSQL ejecuta `init.sql` automáticamente antes de aceptar conexiones — sin
ninguna acción manual, sin conexión a internet y sin depender de Neon ni de ningún otro
servicio en la nube. El sistema queda operativo con datos reales desde el primer
arranque. (En arranques posteriores, con el volumen ya poblado, PostgreSQL omite este
paso automáticamente — es el comportamiento nativo de la imagen oficial, no una
particularidad de este proyecto).

## Índice de scripts de automatización

Todos los scripts viven en la raíz del proyecto y no requieren conocimientos de terminal
para usarse (doble clic):

| Script                   | Qué hace |
|--------------------------|----------|
| **`iniciar_sistema.bat`**   | Flujo automatizado de 5 pasos: (1) verifica que Docker Desktop esté corriendo — y lo abre si no lo está; (2) detecta la IP de este equipo en la red local; (3) ejecuta `docker compose up -d` (construye las imágenes la primera vez); (4) espera a que el backend responda (*health check*) antes de continuar; (5) abre el navegador en la pantalla de Login. |
| **`detener_sistema.bat`**   | Apagado limpio de los 3 contenedores (`docker compose down`). Los datos no se pierden: quedan en el volumen Docker persistente. |
| **`respaldar_datos.bat`**   | Genera un respaldo completo de la base de datos (`backups/backup_AAAA_MM_DD.sql`) usando `pg_dump` de forma nativa dentro del contenedor — sin redirección de shell — para migrar el sistema a otra computadora sin perder datos ni corromper tildes/eñes. |
| `detectar_ip.ps1`          | Utilitario interno usado por `iniciar_sistema.bat` para detectar la IP LAN real del equipo. |

> Ver **[`INSTRUCCIONES_DESPLIEGUE.md`](INSTRUCCIONES_DESPLIEGUE.md)** para la guía
> completa de despliegue, arquitectura detallada y el procedimiento de sincronización de
> datos; y **[`MANUAL_TECNICO.md`](MANUAL_TECNICO.md)** para el respaldo técnico de
> sustentación (justificación de stack, modelo de seguridad y estrategias de eliminación
> segura de datos).

## Requisitos previos

- **Docker Desktop** (incluye Docker Compose v2).
- **Conexión a internet** — únicamente para el primer arranque (descarga de las imágenes
  base de Docker y de las dependencias de Maven/npm). Una vez construidas las imágenes,
  el sistema opera completamente offline.

No es necesario instalar Java, Node.js ni PostgreSQL de forma local: todo corre en
contenedores.

## Inicio rápido

```
Doble clic en: iniciar_sistema.bat
```

Eso es todo — el sistema construye las imágenes (solo la primera vez), levanta los 3
contenedores con los datos ya precargados, y abre el navegador en `http://localhost`.

## Estructura del proyecto

```
├── backend/          API Spring Boot (Java 17, Maven)
├── frontend/          Aplicación React + Material-UI
├── scripts/           Utilitario de sincronización de datos (Node.js)
├── docker-compose.yml Orquestación de los 3 contenedores
├── init.sql            Precarga offline de datos (11 tablas)
├── iniciar_sistema.bat  Arranque automatizado (one-click)
├── detener_sistema.bat  Apagado limpio
├── respaldar_datos.bat  Respaldo / migración de datos
├── backups/            Respaldos generados (vacía por defecto)
├── INSTRUCCIONES_DESPLIEGUE.md
└── MANUAL_TECNICO.md
```

## Despliegue alternativo en la nube

El backend también puede construirse como una única imagen combinada (`Dockerfile` en la
raíz, que empaqueta el build del frontend dentro de los recursos estáticos del backend),
apta para plataformas de despliegue en la nube como Railway. Este proyecto, sin embargo,
está pensado y verificado para operar de forma autónoma y local mediante Docker Compose,
como se describe en las secciones anteriores.
