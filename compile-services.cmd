@echo off
REM Compila los tres microservicios Spring Boot utilizando el wrapper Maven de cada proyecto.
REM Ejecuta este script desde la raíz del repositorio.

REM Compilar users-service
cd users-service
echo Compilando users-service...
call .\mvnw.cmd clean package -DskipTests
cd ..

REM Compilar circuits-service
cd circuits-service
echo Compilando circuits-service...
call .\mvnw.cmd clean package -DskipTests
cd ..

REM Compilar payments-service
cd payments-service
echo Compilando payments-service...
call .\mvnw.cmd clean package -DskipTests
cd ..

echo ---------------------------------------
echo ¡Compilación finalizada! Los JAR se encuentran en cada carpeta target\.
