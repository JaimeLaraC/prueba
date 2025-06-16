# Guía de Despliegue (Windows)

Esta guía proporciona instrucciones sobre cómo configurar las bases de datos y desplegar los microservicios backend (`users-service`, `circuits-service`, `payments-service`) en un entorno Windows.

## 1. Prerrequisitos

Asegúrate de tener instalado el siguiente software en tu máquina Windows:

* **Java Development Kit (JDK):** Versión 17 o superior.
  * Descarga: [Oracle JDK](https://www.oracle.com/java/technologies/javase-jdk17-downloads.html) o [OpenJDK (p. ej. Adoptium Temurin)](https://adoptium.net/)
  * Verifica que el directorio `bin` del JDK esté en la variable de entorno `PATH`.
* **Apache Maven:** Versión 3.6 o superior (si no usas el Maven Wrapper `mvnw`).
  * Descarga: [Apache Maven](https://maven.apache.org/download.cgi)
  * Verifica que el directorio `bin` de Maven esté en tu `PATH`.
* **Git:** Para clonar el repositorio.
  * Descarga: [Git for Windows](https://git-scm.com/download/win)
* **SQL Server:** Para la base de datos de `users-service` (p. ej. SQL Server Express Edition o Developer Edition).
  * Descarga: [SQL Server Downloads](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
* **MySQL:** Para la base de datos de `circuits-service` (p. ej. MySQL Community Server).
  * Descarga: [MySQL Community Server](https://dev.mysql.com/downloads/mysql/) (usa el instalador de MySQL para Windows)

## 2. Configuración de Bases de Datos (Windows)

### 2.1. SQL Server (para `users-service`)

1. **Instalar SQL Server:**
   * Descarga y ejecuta el instalador de SQL Server (Express o Developer Edition).
   * Elige una instalación «Basic» o «Custom». Si es personalizada, asegúrate de seleccionar *Database Engine Services*.
   * Configura la autenticación (Windows Authentication o *Mixed Mode* —si es *Mixed Mode*, define una contraseña fuerte para `sa`).
2. **Conectarse a SQL Server:**
   * Usa SQL Server Management Studio (SSMS) o Azure Data Studio para conectarte a tu instancia de SQL Server.
   * Descarga SSMS: [SSMS Download](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
   * Descarga Azure Data Studio: [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio)
3. **Crear base de datos:**
   * En SSMS/Azure Data Studio, haz clic derecho en «Databases» y selecciona «New Database…».
   * Nombre de la BD: `users_db`
   * Haz clic en «OK».
4. **Crear inicio de sesión/usuario de SQL Server:** (opcional, pero recomendado)
   * En SSMS, expande «Security», clic derecho en «Logins», selecciona «New Login…».
   * Nombre de inicio: `users_service_user`
   * Elige «SQL Server authentication» y define una contraseña fuerte.
   * Base de datos predeterminada: `users_db`
   * En «User Mapping», asigna este login a la BD `users_db` y concédele roles como `db_owner` (o más restrictivos: `db_datareader`, `db_datawriter`).
   * Haz clic en «OK».
5. **Anotar datos de conexión:**
   * Nombre/instancia del servidor (p. ej. `localhost`, `localhost\SQLEXPRESS`, o la IP/nombre de host del servidor).
   * Nombre de la BD: `users_db`
   * Usuario: `users_service_user` (o `sa` si usaste ese)
   * Contraseña: la contraseña definida.

### 2.2. MySQL (para `circuits-service`)

1. **Instalar MySQL:**
   * Descarga y ejecuta el instalador de MySQL para Windows.
   * Elige «Server only» o «Developer Default» (incluye MySQL Server).
   * Durante la configuración, define una contraseña para `root`.
   * (Opcional) Crea un usuario dedicado para el servicio ahora o más tarde.
2. **Conectarse a MySQL:**
   * Usa MySQL Workbench o el cliente de línea de comandos `mysql.exe`.
   * Descarga MySQL Workbench: [MySQL Workbench](https://dev.mysql.com/downloads/workbench/)
3. **Crear base de datos:**
   * En MySQL Workbench o CLI:

     ```sql
     CREATE DATABASE circuits_db;
     ```
4. **Crear usuario de MySQL:** (recomendado)

     ```sql
     CREATE USER 'circuits_service_user'@'localhost' IDENTIFIED BY 'tu_contraseña_segura';
     GRANT ALL PRIVILEGES ON circuits_db.* TO 'circuits_service_user'@'localhost';
     FLUSH PRIVILEGES;
     ```
   * Reemplaza `'tu_contraseña_segura'` con una contraseña fuerte.
5. **Anotar datos de conexión:**
   * Host del servidor: `localhost` (o IP/nombre de host)
   * Puerto: normalmente `3306`
   * Base de datos: `circuits_db`
   * Usuario: `circuits_service_user`
   * Contraseña: la contraseña definida.

## 3. Configuración de Propiedades de las Aplicaciones

Los microservicios usan Spring Boot. Las propiedades pueden configurarse de tres formas:

* **Editando `application.properties`** (útil para entornos de desarrollo).
* **Mediante variables de entorno** (Spring Boot las detecta automáticamente).
* **Usando argumentos en línea de comandos** al ejecutar el JAR (recomendado para datos sensibles o ajustes por entorno).

### 3.1. `users-service` (`users-service/src/main/resources/application.properties`)

```properties
# Puerto del servidor
server.port=8081

# SQL Server Datasource
spring.datasource.url=jdbc:sqlserver://localhost\SQLEXPRESS;databaseName=users_db;encrypt=true;trustServerCertificate=true;
spring.datasource.username=users_service_user
spring.datasource.password=tu_contraseña_sql_server
# spring.datasource.driver-class-name=com.microsoft.sqlserver.jdbc.SQLServerDriver (normalmente auto-detectado)

# Configuración JWT
jwt.secret=tuClaveJwtEnBase64LargaYSegura
```

### 3.2. `circuits-service` (`circuits-service/src/main/resources/application.properties`)

```properties
# Puerto del servidor
server.port=8082

# MySQL Datasource
spring.datasource.url=jdbc:mysql://localhost:3306/circuits_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
spring.datasource.username=circuits_service_user
spring.datasource.password=tu_contraseña_mysql
# spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver (normalmente auto-detectado)

# Secreto JWT Compartido (debe coincidir con users-service) y estar en Base64
jwt.shared.secret=tuClaveJwtEnBase64LargaYSegura

# URL de Users Service (comunicación entre servicios)
users.service.url=http://localhost:8081/api/users
```

### 3.3. `payments-service` (`payments-service/src/main/resources/application.properties`)

```properties
# Puerto del servidor
server.port=8083

# Secreto JWT Compartido (debe coincidir con users-service) y estar en Base64
jwt.shared.secret=tuClaveJwtEnBase64LargaYSegura

# URL de Users Service
users.service.url=http://localhost:8081/api/users
```

**Importante:** Sustituye los marcadores (`tu_contraseña_sql_server`, `tu_contraseña_mysql`, `tuClaveJwtEnBase64LargaYSegura`, etc.) por tus credenciales reales. El secreto JWT *debe* ser idéntico en todos los servicios y codificado en Base64 si tu utilería JWT lo requiere.

## 4. Ejecución de los Servicios

Abre una ventana de PowerShell o símbolo del sistema para cada servicio.

**Para ejecutar `users-service`:**

```bash
cd users-service
java -jar target/users-service-*.jar
# Ejemplo con propiedades en línea de comandos:
# java -jar target/users-service-*.jar --server.port=8081 --spring.datasource.password=tuContraseñaReal --jwt.secret=tuSecretoJwt
```

**Para ejecutar `circuits-service`:**

```bash
cd circuits-service
java -jar target/circuits-service-*.jar
# Ejemplo:
# java -jar target/circuits-service-*.jar --server.port=8082 --spring.datasource.password=tuContraseñaReal --jwt.shared.secret=tuSecretoJwt
```

**Para ejecutar `payments-service`:**

```bash
cd payments-service
java -jar target/payments-service-*.jar
# Ejemplo:
# java -jar target/payments-service-*.jar --server.port=8083 --jwt.shared.secret=tuSecretoJwt
```

Asegúrate de que cada servicio se inicie sin errores. Por defecto escucharán en los puertos 8081, 8082 y 8083 respectivamente.

## 5. Verificación

* Revisa la salida de la consola de cada servicio para mensajes de inicio satisfactorio (p. ej. "Started …Application in … seconds").
* Si tienes habilitados *health endpoints* (Spring Boot Actuator), accede a ellos:
  * `http://localhost:8081/actuator/health`
  * `http://localhost:8082/actuator/health`
  * `http://localhost:8083/actuator/health`
* Prueba la aplicación frontend para interactuar con los servicios (p. ej. registrar usuario, iniciar sesión).

---

¡Con esto concluye la configuración y despliegue básico de los microservicios backend en Windows!
