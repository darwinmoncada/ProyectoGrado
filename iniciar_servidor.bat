@echo off
setlocal
title Sistema de Inventario TI - Servidor

echo ============================================================
echo   Sistema de Inventario TI - Iniciar Servidor
echo ============================================================
echo.
echo Detectando IP de este equipo en la red local...

for /f "delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0detectar_ip.ps1" 2^>nul') do set HOST_LAN_IP=%%i

if "%HOST_LAN_IP%"=="" (
    echo No se pudo detectar una IP de red local. Se usara 127.0.0.1 como respaldo.
    set HOST_LAN_IP=127.0.0.1
) else (
    echo IP detectada: %HOST_LAN_IP%
)

echo.
echo Construyendo e iniciando los contenedores Docker...
echo (la primera vez puede tardar varios minutos)
echo.

docker compose up --build -d

if errorlevel 1 (
    echo.
    echo ERROR: no se pudo iniciar Docker Compose.
    echo Verifica que Docker Desktop este abierto y corriendo, luego intenta de nuevo.
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo   Servidor iniciado correctamente
echo ============================================================
echo   Acceso local (este equipo):        http://localhost
echo   Acceso desde la red universitaria: http://%HOST_LAN_IP%
echo ============================================================
echo.

timeout /t 3 /nobreak >nul
start "" "http://localhost"

endlocal
