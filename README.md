# Sistema de Registro de Asistencia Estudiantil 🎓

Este proyecto es un sistema full-stack diseñado para modernizar y simplificar el proceso de registro de asistencia en entornos académicos. La aplicación permite a los estudiantes registrar su asistencia de manera rápida y segura mediante el escaneo de códigos QR.

---

## ✨ Características Principales

* **Gestión de Estudiantes:** Sistema CRUD (Crear, Leer, Actualizar, Eliminar) completo para la administración de estudiantes.
* **Códigos QR Únicos:** Generación de un código QR único para cada estudiante, garantizando un registro seguro.
* **Registro de Asistencia:** Funcionalidad para escanear el código QR y registrar la asistencia a un curso o evento específico.
* **API RESTful:** Un backend robusto que expone endpoints seguros para la gestión de todos los datos.
* **Interfaz Moderna:** Un frontend reactivo y amigable desarrollado con Angular y Angular Material.

---

## 🚀 Tecnologías Utilizadas

| Área          | Tecnología                                     |
|---------------|------------------------------------------------|
| **Backend** | Node.js, Express.js, node-oracledb             |
| **Frontend** | Angular, Angular Material, TypeScript          |
| **Base de Datos** | Oracle Database (Autonomous Cloud Database)    |
| **Control de Versiones** | Git & GitHub                                   |

---

## 📂 Estructura del Proyecto

El proyecto sigue una estructura de monorepo para facilitar la gestión y el desarrollo:

|-- backend/          # API RESTful en Node.js
|-- frontend/         # Aplicación SPA en Angular
|-- database/         # Scripts de creación de la base de datos
|-- .gitignore        # Archivos y carpetas ignorados por Git
`-- README.md         # Esta documentación


---

## 🛠️ Instalación y Puesta en Marcha

Sigue estos pasos para levantar el entorno de desarrollo en tu máquina local.

### **Prerrequisitos**

* Node.js (v18 o superior)
* Angular CLI (`npm install -g @angular/cli`)
* Git
* Oracle Instant Client (necesario para la conexión del backend)
* Un editor de código como Visual Studio Code

### **Pasos**

1.  **Clonar el repositorio:**
    ```bash
    git clone [URL-DE-TU-REPOSITORIO-EN-GITHUB]
    cd sistema-asistencia
    ```

2.  **Configurar el Backend:**
    ```bash
    cd backend
    npm install
    ```
    Crea un archivo `.env` en la raíz de la carpeta `/backend` y añade las credenciales de tu base de datos Oracle.

3.  **Configurar el Frontend:**
    ```bash
    cd ../frontend
    npm install
    ```

4.  **Configurar la Base de Datos:**
    * Conéctate a tu instancia de Oracle Cloud usando SQL Developer.
    * Ejecuta el script que se encuentra en `/database/schema.sql` para crear las tablas necesarias.

### **Ejecución**

* **Para iniciar el servidor del backend:**
    ```bash
    cd backend
    npm start
    ```
    El servidor se ejecutará en `http://localhost:3000` (o el puerto que configures).

* **Para iniciar la aplicación del frontend:**
    ```bash
    cd frontend
    ng serve -o
    ```
    La aplicación se abrirá automáticamente en `http://localhost:4200`.

---

## 👤 Autores

* **[Carlos Enrique Orozco Menéndez]** - [Carnet], [2349077];