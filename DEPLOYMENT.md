# Deployment Guide (Windows)

This guide provides instructions on how to set up the databases and deploy the backend microservices (users-service, circuits-service, payments-service) on a Windows environment.

## 1. Prerequisites

Ensure you have the following software installed on your Windows machine:

*   **Java Development Kit (JDK):** Version 17 or later.
    *   Download: [Oracle JDK](https://www.oracle.com/java/technologies/javase-jdk17-downloads.html) or [OpenJDK (e.g., Adoptium Temurin)](https://adoptium.net/)
    *   Ensure JDK's `bin` directory is in your system's PATH environment variable.
*   **Apache Maven:** Version 3.6 or later (if not using the Maven Wrapper `mvnw`).
    *   Download: [Apache Maven](https://maven.apache.org/download.cgi)
    *   Ensure Maven's `bin` directory is in your system's PATH.
*   **Git:** For cloning the repository.
    *   Download: [Git for Windows](https://git-scm.com/download/win)
*   **SQL Server:** For the `users-service` database (e.g., SQL Server Express Edition or Developer Edition).
    *   Download: [SQL Server Downloads](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
*   **MySQL:** For the `circuits-service` database (e.g., MySQL Community Server).
    *   Download: [MySQL Community Server](https://dev.mysql.com/downloads/mysql/) (use the MySQL Installer for Windows)

## 2. Database Setup (Windows)

### 2.1. SQL Server (for `users-service`)

1.  **Install SQL Server:**
    *   Download and run the SQL Server installer (Express or Developer Edition).
    *   Choose a "Basic" or "Custom" installation. If custom, ensure the Database Engine Services are selected.
    *   Set up authentication (Windows Authentication or Mixed Mode - if Mixed Mode, set a strong 'sa' password).
2.  **Connect to SQL Server:**
    *   Use SQL Server Management Studio (SSMS) or Azure Data Studio to connect to your SQL Server instance.
    *   Download SSMS: [SSMS Download](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
    *   Download Azure Data Studio: [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio)
3.  **Create Database:**
    *   In SSMS/Azure Data Studio, right-click on "Databases" and select "New Database...".
    *   Enter database name: `users_db`
    *   Click "OK".
4.  **Create SQL Server Login/User:**
    *   (Optional, but recommended) Create a dedicated login for the service.
    *   In SSMS, expand "Security", right-click "Logins", select "New Login...".
    *   Login name: `users_service_user`
    *   Choose "SQL Server authentication" and set a strong password.
    *   Default database: `users_db`
    *   Go to "User Mapping" page, map this login to the `users_db` database, and grant it roles like `db_owner` (or more restrictive: `db_datareader`, `db_datawriter`).
    *   Click "OK".
5.  **Note Connection Details:**
    *   Server Name/Instance Name (e.g., `localhost`, `localhost\SQLEXPRESS`, or your server's IP/hostname).
    *   Database Name: `users_db`
    *   Username: `users_service_user` (or 'sa' if you used that)
    *   Password: The password you set.

### 2.2. MySQL (for `circuits-service`)

1.  **Install MySQL:**
    *   Download and run the MySQL Installer for Windows.
    *   Choose "Server only" or "Developer Default" (which includes MySQL Server).
    *   During configuration, set a root password.
    *   You can also create a dedicated user for the service during this setup or later.
2.  **Connect to MySQL:**
    *   Use MySQL Workbench or a command-line client (like `mysql.exe`) to connect.
    *   MySQL Workbench Download: [MySQL Workbench](https://dev.mysql.com/downloads/workbench/)
3.  **Create Database:**
    *   In MySQL Workbench or command line:
        ```sql
        CREATE DATABASE circuits_db;
        ```
4.  **Create MySQL User:**
    *   (Recommended) Create a dedicated user:
        ```sql
        CREATE USER 'circuits_service_user'@'localhost' IDENTIFIED BY 'your_strong_password';
        GRANT ALL PRIVILEGES ON circuits_db.* TO 'circuits_service_user'@'localhost';
        FLUSH PRIVILEGES;
        ```
    *   Replace `'your_strong_password'` with a strong password.
5.  **Note Connection Details:**
    *   Server Host: `localhost` (or your server's IP/hostname)
    *   Port: Usually `3306`
    *   Database Name: `circuits_db`
    *   Username: `circuits_service_user`
    *   Password: The password you set.

## 3. Backend Service Deployment (Windows)

### 3.1. Clone the Repository

If you haven't already, clone the project repository:
```bash
git clone <repository_url>
cd <repository_directory>
```

### 3.2. Building the Services

For each service (`users-service`, `circuits-service`, `payments-service`):

1.  Open a command prompt or PowerShell.
2.  Navigate to the service's root directory (e.g., `cd users-service`).
3.  Build the executable JAR file using the Maven Wrapper:
    ```bash
    ./mvnw clean package
    ```
    (If you have Maven installed globally and configured in PATH, you can use `mvn clean package`)
4.  The JAR file will be created in the `target` subdirectory (e.g., `target/users-service-0.0.1-SNAPSHOT.jar`).

### 3.3. Configuring the Services

Before running each service, you need to configure its database connection, JWT secrets, and any other required properties. You can do this by:

*   **Modifying `application.properties`** in `src/main/resources` for each service *before* building the JAR. This is suitable for default development values.
*   **Using command-line arguments** when running the JAR (recommended for sensitive data or environment-specific settings).
*   **Using environment variables.** Spring Boot can pick these up.

**Key properties to configure:**

**For `users-service` (`users-service/src/main/resources/application.properties`):**
```properties
# Server Port
server.port=8081

# SQL Server Datasource
spring.datasource.url=jdbc:sqlserver://localhost\SQLEXPRESS;databaseName=users_db;encrypt=true;trustServerCertificate=true;
spring.datasource.username=users_service_user
spring.datasource.password=your_sql_server_password
# spring.datasource.driver-class-name=com.microsoft.sqlserver.jdbc.SQLServerDriver (usually auto-detected)

# JWT Configuration
jwt.secret=yourBase64EncodedJwtSecretKeyWhichIsVeryLongAndSecure # MUST BE BASE64 ENCODED

# Email Configuration (if used)
# spring.mail.host=...
# ...
```

**For `circuits-service` (`circuits-service/src/main/resources/application.properties`):**
```properties
# Server Port
server.port=8082

# MySQL Datasource
spring.datasource.url=jdbc:mysql://localhost:3306/circuits_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
spring.datasource.username=circuits_service_user
spring.datasource.password=your_mysql_password
# spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver (usually auto-detected)

# JWT Shared Secret (must match users-service's jwt.secret and be Base64 encoded)
jwt.shared.secret=yourBase64EncodedJwtSecretKeyWhichIsVeryLongAndSecure

# Users Service URL (for inter-service communication)
users.service.url=http://localhost:8081/api/users
```

**For `payments-service` (`payments-service/src/main/resources/application.properties`):**
```properties
# Server Port
server.port=8083

# JWT Shared Secret (must match users-service's jwt.secret and be Base64 encoded)
jwt.shared.secret=yourBase64EncodedJwtSecretKeyWhichIsVeryLongAndSecure

# Users Service URL (for inter-service communication)
users.service.url=http://localhost:8081/api/users

# Payment Gateway Configuration (Placeholders)
# payment.gateway.apiKey=...
# ...
```
**Important:** Replace placeholder values (like `your_sql_server_password`, `your_mysql_password`, `yourBase64EncodedJwtSecretKey...`) with your actual credentials and secrets. The JWT secret *must* be the same across all services and Base64 encoded if your JWT utilities expect that.

### 3.4. Running the Services

Open a separate command prompt or PowerShell window for each service.

**To run `users-service`:**
```bash
cd users-service
java -jar target/users-service-*.jar
# Example with command-line properties (override application.properties):
# java -jar target/users-service-*.jar --server.port=8081 --spring.datasource.password=yourActualPassword --jwt.secret=yourActualSecret
```

**To run `circuits-service`:**
```bash
cd circuits-service
java -jar target/circuits-service-*.jar
# Example:
# java -jar target/circuits-service-*.jar --server.port=8082 --spring.datasource.password=yourActualPassword --jwt.shared.secret=yourActualSecret
```

**To run `payments-service`:**
```bash
cd payments-service
java -jar target/payments-service-*.jar
# Example:
# java -jar target/payments-service-*.jar --server.port=8083 --jwt.shared.secret=yourActualSecret
```

Ensure the services start up without errors. They will run on ports 8081, 8082, and 8083 respectively by default.

## 4. Verification

*   Check the console output of each service for successful startup messages (e.g., "Started ...Application in ... seconds").
*   If health check endpoints are configured (e.g., via Spring Boot Actuator), you can try accessing them:
    *   `http://localhost:8081/actuator/health`
    *   `http://localhost:8082/actuator/health`
    *   `http://localhost:8083/actuator/health`
*   Attempt to use the application frontend to interact with the services (e.g., register a user, log in).

This completes the basic deployment and setup for the backend services on Windows.
