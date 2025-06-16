@echo off
setlocal
TITLE Limpiador de Repositorio - Version Segura

REM --- Mensaje inicial ---
echo.
echo ======================================================
echo      INICIANDO LIMPIEZA COMPLETA DEL REPOSITORIO
echo ======================================================
echo.
echo Este script solo eliminara archivos y carpetas.
echo.
pause
echo.

REM --- 1. Limpieza del Backend (Todos los modulos Maven) ---
echo [1/3] Limpiando proyectos de backend (Maven)...
echo.

REM Se mueve temporalmente a un submodulo para usar su wrapper
cd circuits-service

REM Llama al wrapper para limpiar el proyecto raiz. Maven mostrara su progreso.
call mvnw.cmd -f ../pom.xml clean
if %errorlevel% neq 0 (
    cd ..
    echo.
    echo ERROR: El comando 'mvnw.cmd clean' fallo.
    goto :error
)

REM Vuelve al directorio raiz
cd ..


REM --- 2. Limpieza del Frontend (Angular/npm) ---
echo [2/3] Limpiando proyecto de frontend (Angular)...
echo.
cd frontend

if exist "node_modules" (
    echo  - Eliminando 'node_modules'...
    rmdir /s /q "node_modules"
)
if exist ".angular" (
    echo  - Eliminando cache de Angular '.angular'...
    rmdir /s /q ".angular"
)
if exist "dist" (
    echo  - Eliminando directorio de compilacion 'dist'...
    rmdir /s /q "dist"
)

echo  - Limpiando cache de npm...
call npm cache clean --force >nul 2>&1



REM --- Mensaje final ---
echo ======================================================
echo              LIMPIEZA COMPLETADA
echo ======================================================
echo.
echo El repositorio esta ahora mucho mas ligero.
echo.
goto :end

:error
echo.
echo X-- La limpieza fallo. Por favor, revisa los errores. --X
echo.

:end
pause
endlocal