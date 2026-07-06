@echo off
REM ============================================================================
REM  respaldar_datos.bat
REM  Genera un respaldo completo (esquema + datos) de la base de datos local,
REM  listo para usarse como init.sql en otra maquina al migrar el sistema.
REM
REM  IMPORTANTE sobre el metodo usado: NO se genera el respaldo con
REM  "docker exec ... pg_dump ... > archivo.sql" (redireccion de shell). En
REM  este proyecto esa clase de redireccion corrompio tildes/enes mas de una
REM  vez (ver INSTRUCCIONES_DESPLIEGUE.md, seccion 4). En su lugar, pg_dump
REM  escribe el archivo el mismo, dentro del contenedor, con su propio flag
REM  -f -- sin pasar el contenido por ninguna consola -- y luego se copia
REM  hacia el host con "docker cp" (copia binaria exacta).
REM ============================================================================
setlocal EnableDelayedExpansion
title Sistema de Inventario TI - Respaldar Datos
cd /d "%~dp0"

echo ============================================================
echo   SISTEMA DE INVENTARIO TI - UTS
echo   Respaldo de Base de Datos
echo ============================================================
echo.

REM ----------------------------------------------------------------------
REM PASO 1 de 3: Crear la carpeta de respaldos si no existe.
REM ----------------------------------------------------------------------
if not exist "backups" mkdir "backups"

REM ----------------------------------------------------------------------
REM PASO 2 de 3: Verificar que el contenedor de base de datos este encendido.
REM "docker inspect -f {{.State.Running}}" cubre tanto el caso de que el
REM contenedor no exista como el de que exista pero este detenido.
REM ----------------------------------------------------------------------
echo [1/3] Verificando que el sistema este iniciado...
for /f "delims=" %%r in ('docker inspect -f "{{.State.Running}}" inventario_db 2^>nul') do set DB_RUNNING=%%r

if not "%DB_RUNNING%"=="true" (
    echo.
    echo ============================================================
    echo   ATENCION: El sistema no esta iniciado ^(el contenedor
    echo   "inventario_db" no esta encendido^).
    echo   Ejecuta primero iniciar_sistema.bat y vuelve a intentar
    echo   el respaldo.
    echo ============================================================
    pause
    exit /b 1
)
echo       Sistema activo, continuando...
echo.

REM ----------------------------------------------------------------------
REM PASO 3 de 3: Generar el respaldo con fecha en el nombre del archivo.
REM La fecha se obtiene via PowerShell (Get-Date -Format), independiente
REM del formato regional configurado en el sistema operativo.
REM ----------------------------------------------------------------------
echo [2/3] Generando el respaldo...

for /f "delims=" %%d in ('powershell -NoProfile -Command "Get-Date -Format yyyy_MM_dd"') do set BACKUP_DATE=%%d
set BACKUP_FILE=backup_%BACKUP_DATE%.sql

docker exec inventario_db pg_dump -U postgres -d inventario_uts --no-owner --no-privileges -f /tmp/%BACKUP_FILE%
if errorlevel 1 (
    echo.
    echo ============================================================
    echo   ERROR: no se pudo generar el respaldo. Revisa el mensaje
    echo   de error mostrado arriba ^(el contenedor debe seguir
    echo   encendido y la base de datos accesible^).
    echo ============================================================
    pause
    exit /b 1
)

docker cp inventario_db:/tmp/%BACKUP_FILE% "backups\%BACKUP_FILE%"
docker exec inventario_db rm -f /tmp/%BACKUP_FILE%
echo.

echo [3/3] Respaldo completado.
echo.
echo ============================================================
echo   RESPALDO GENERADO: backups\%BACKUP_FILE%
echo.
echo   Para migrar el sistema a otra computadora:
echo     1. Copia todo el proyecto a la nueva PC.
echo     2. Copia "backups\%BACKUP_FILE%" a la raiz del proyecto en
echo        la nueva PC y renombralo como "init.sql" (reemplazando
echo        el que exista).
echo     3. Asegurate de que el volumen de Docker este vacio en la
echo        nueva PC (primera vez, o tras "docker compose down -v").
echo     4. Ejecuta iniciar_sistema.bat en la nueva PC: el sistema
echo        arrancara ya con estos datos precargados.
echo ============================================================
echo.
pause
endlocal
