@echo off
REM ============================================================================
REM  detener_sistema.bat
REM  Apaga los 3 contenedores del Sistema de Inventario TI (contraparte de
REM  iniciar_sistema.bat). Los datos de la base de datos NO se borran: quedan
REM  guardados en el volumen Docker persistente hasta la proxima vez que se
REM  inicie el sistema.
REM ============================================================================
setlocal
title Sistema de Inventario TI - Detener Sistema
cd /d "%~dp0"

echo ============================================================
echo   SISTEMA DE INVENTARIO TI - UTS
echo   Deteniendo los contenedores...
echo ============================================================
echo.

docker compose down

if errorlevel 1 (
    echo.
    echo ============================================================
    echo   ERROR: no se pudo detener docker compose correctamente.
    echo   Revisa el mensaje de error mostrado arriba.
    echo ============================================================
    pause
    exit /b 1
)

echo.
echo ============================================================
echo   Sistema detenido correctamente.
echo   Tus datos siguen intactos y listos para la proxima vez que
echo   ejecutes iniciar_sistema.bat.
echo ============================================================
echo.
pause
endlocal
