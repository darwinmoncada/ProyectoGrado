@echo off
title Sistema de Inventario TI - Detener Servidor

echo ============================================================
echo   Sistema de Inventario TI - Detener Servidor
echo ============================================================
echo.
echo Deteniendo los contenedores Docker...
echo (los datos de la base de datos NO se borran; quedan en el volumen persistente)
echo.

docker compose down

echo.
echo Servidor detenido correctamente.
echo.
pause
