# To-Do List Application (MVP)

Este es un proyecto de Prototipo Mínimo Viable (MVP) de una aplicación de lista de tareas (To-Do List) full-stack. Consiste en una aplicación móvil desarrollada en Flutter y un servidor backend desarrollado en Go.

## Estructura del Proyecto

El repositorio está organizado en los siguientes directorios principales:

-   `todolist_app/`: El código fuente de la aplicación móvil cliente (Flutter).
-   `todolist_server/`: El código fuente del servidor backend (Go).
-   `schema/`: Archivos de esquema que definen la arquitectura, modelos de datos y requisitos del proyecto.
-   `reporte/`: Documentación técnica detallada sobre la implementación de la aplicación móvil.

---

### 1. Backend (`todolist_server/`)

El backend es una API RESTful construida en Go que gestiona la lógica de negocio, la autenticación de usuarios y la persistencia de datos.

**Características:**
-   **Autenticación:** Registro e inicio de sesión de usuarios mediante tokens JWT.
-   **API de Tareas:** Operaciones CRUD (Crear, Leer, Actualizar, Eliminar) para las tareas de los usuarios.
-   **Base de Datos:** Utiliza PostgreSQL para el almacenamiento de datos.
-   **Migraciones:** Gestiona la evolución del esquema de la base de datos con `golang-migrate`.

**Cómo ejecutar el servidor:**
1.  Asegúrate de tener **Go** y **PostgreSQL** instalados.
2.  Navega al directorio `todolist_server/`.
3.  Ejecuta el script de configuración. Este script instalará dependencias, configurará la base de datos y creará un archivo `.env` con las credenciales necesarias.
    ```bash
    chmod +x setup.sh
    ./setup.sh
    ```
4.  Una vez que la configuración sea exitosa, inicia el servidor:
    ```bash
    ./todolist_server
    ```
El servidor se ejecutará en el puerto `8080` por defecto.

### 2. Frontend (`todolist_app/`)

La aplicación móvil, desarrollada con Flutter, sirve como cliente para el backend. Permite a los usuarios gestionar sus tareas de forma intuitiva.

**Características:**
-   **Arquitectura:** Sigue el patrón MVVM (Model-View-ViewModel) con `provider` para la gestión de estado.
-   **Seguridad:** Implementa un bloqueo de capturas de pantalla en vistas sensibles (`SignUp`, `Dashboard`, `Progress`) para proteger la información del usuario, utilizando el paquete `secure_application`.
-   **Interfaz de Usuario:** Ofrece una experiencia de usuario limpia para registrarse, iniciar sesión y gestionar tareas.

**Cómo ejecutar la aplicación:**
1.  Asegúrate de tener el **SDK de Flutter** instalado.
2.  Navega al directorio `todolist_app/`.
3.  Instala las dependencias:
    ```bash
    flutter pub get
    ```
4.  Ejecuta la aplicación en un emulador o dispositivo físico:
    ```bash
    flutter run
    ```

### 3. Esquemas (`schema/`)

Este directorio contiene los documentos de diseño y planificación del proyecto, incluyendo el esquema de la arquitectura (`main_schema.json`) y los requisitos académicos (`HW/`).

### 4. Reporte (`reporte/`)

Contiene el informe técnico (`reporte.md`) que detalla la arquitectura, decisiones de diseño y la implementación de la capa de seguridad en la aplicación móvil Flutter, cumpliendo con los requisitos de la rúbrica del proyecto.
