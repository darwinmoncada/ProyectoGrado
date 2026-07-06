@echo off
REM ============================================================================
REM  iniciar_sistema.bat
REM  Entregable "one-click" para la sustentacion del proyecto de grado.
REM  Pensado para que un jurado, sin conocimientos tecnicos ni terminal, pueda
REM  levantar todo el ecosistema (frontend + backend + base de datos) con un
REM  solo doble clic y quedar viendo la pantalla de Login del sistema.
REM ============================================================================
setlocal EnableDelayedExpansion
title Sistema de Inventario TI - Inicio Automatico
cd /d "%~dp0"

echo ============================================================
echo   SISTEMA DE INVENTARIO TI - UTS
echo   Iniciando Frontend + Backend + Base de Datos...
echo ============================================================
echo.

REM ----------------------------------------------------------------------
REM PASO 1 de 5: Verificar que Docker Desktop este corriendo.
REM "docker info" es la forma estandar de sondear si el motor de Docker
REM responde; falla de inmediato si Docker Desktop no esta activo, sin
REM necesidad de adivinar procesos o puertos.
REM ----------------------------------------------------------------------
echo [1/5] Verificando que Docker Desktop este en ejecucion...
docker info >nul 2>&1
if not errorlevel 1 goto docker_ready

echo       Docker Desktop no responde todavia. Intentando iniciarlo...
tasklist /FI "IMAGENAME eq Docker Desktop.exe" 2>nul | find /I "Docker Desktop.exe" >nul
if errorlevel 1 (
    if exist "%ProgramFiles%\Docker\Docker\Docker Desktop.exe" (
        start "" "%ProgramFiles%\Docker\Docker\Docker Desktop.exe"
    ) else (
        echo.
        echo ============================================================
        echo   ATENCION: No se encontro Docker Desktop instalado en este
        echo   equipo ^(ruta esperada: Program Files\Docker\Docker^).
        echo   Instala Docker Desktop, ejecutalo una vez, y vuelve a
        echo   abrir este archivo.
        echo ============================================================
        pause
        exit /b 1
    )
)

echo       Esperando a que Docker Desktop termine de iniciar...
echo       ^(la primera vez puede tardar 1-2 minutos, por favor espera^)
set /a docker_tries=0
:wait_docker_loop
set /a docker_tries+=1
timeout /t 3 /nobreak >nul
docker info >nul 2>&1
if not errorlevel 1 goto docker_ready
if !docker_tries! GEQ 40 (
    echo.
    echo ============================================================
    echo   ATENCION: Docker Desktop esta tardando demasiado en iniciar.
    echo   Abrelo manualmente desde el escritorio, espera a que el
    echo   icono de la ballena este listo en la barra de tareas, y
    echo   vuelve a ejecutar este archivo.
    echo ============================================================
    pause
    exit /b 1
)
goto wait_docker_loop

:docker_ready
echo       Docker Desktop esta activo.
echo.

REM ----------------------------------------------------------------------
REM PASO 2 de 5: Detectar la IP de este equipo en la red local, para que
REM otros equipos de la red universitaria puedan acceder al sistema. Se
REM delega en un script .ps1 separado (en vez de un -Command inline) porque
REM anidar PowerShell dentro de un .bat con comillas y pipes es fragil.
REM ----------------------------------------------------------------------
echo [2/5] Detectando IP de este equipo en la red local...
set HOST_LAN_IP=
for /f "delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0detectar_ip.ps1" 2^>nul') do set HOST_LAN_IP=%%i

if "%HOST_LAN_IP%"=="" (
    echo       No se pudo detectar una IP de red local. Se usara 127.0.0.1 como respaldo.
    set HOST_LAN_IP=127.0.0.1
) else (
    echo       IP detectada: %HOST_LAN_IP%
)
echo.

REM ----------------------------------------------------------------------
REM PASO 3 de 5: Levantar los 3 contenedores del sistema.
REM "docker compose up -d" construye las imagenes automaticamente la
REM primera vez (si no existen) y en ejecuciones posteriores solo arranca
REM los contenedores ya existentes, de forma rapida.
REM ----------------------------------------------------------------------
echo [3/5] Iniciando los contenedores (frontend, backend, base de datos)...
docker compose up -d
if errorlevel 1 (
    echo.
    echo ============================================================
    echo   ERROR: docker compose no pudo iniciar los contenedores.
    echo   Revisa el mensaje de error mostrado arriba.
    echo ============================================================
    pause
    exit /b 1
)
echo.

REM ----------------------------------------------------------------------
REM PASO 4 de 5: Esperar a que el backend responda antes de abrir el
REM navegador, para no mostrarle al jurado una pantalla en blanco o de
REM error mientras el sistema todavia esta arrancando.
REM ----------------------------------------------------------------------
echo [4/5] Esperando a que el sistema este completamente listo...

where curl >nul 2>&1
if errorlevel 1 (
    REM Si por alguna razon curl no esta disponible, se usa una espera fija
    REM en vez de sondear el backend (curl viene incluido desde Windows 10).
    timeout /t 20 /nobreak >nul
    goto backend_ready
)

set /a backend_tries=0
:wait_backend_loop
set /a backend_tries+=1
curl -s -f -o nul http://localhost:8080/actuator/health
if not errorlevel 1 goto backend_ready
if !backend_tries! GEQ 60 (
    echo.
    echo       El backend esta tardando mas de lo normal en responder.
    echo       Ultimas lineas de su registro:
    echo       ------------------------------------------------------
    docker compose logs --tail 20 backend
    echo       ------------------------------------------------------
    echo       Se abrira el navegador de todas formas; si ves un error,
    echo       espera unos segundos y actualiza la pagina.
    goto backend_ready
)
timeout /t 2 /nobreak >nul
goto wait_backend_loop

:backend_ready
echo       Sistema listo.
echo.

REM ----------------------------------------------------------------------
REM PASO 5 de 5: Abrir el navegador predeterminado en la pantalla de Login.
REM ----------------------------------------------------------------------
echo [5/5] Abriendo el sistema en el navegador...
start "" "http://localhost"

echo.
echo ============================================================
echo   SISTEMA LISTO PARA USAR
echo   Acceso local (este equipo):        http://localhost
echo   Acceso desde la red universitaria: http://%HOST_LAN_IP%
echo ============================================================
echo.
echo   Para apagar el sistema, usa: detener_sistema.bat
echo.
pause
endlocal
