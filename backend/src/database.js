// Importar las dependencias necesarias
const oracledb = require('oracledb');
const dotenv = require('dotenv');

// Cargar las variables de entorno del archivo .env
dotenv.config();

// Configurar el directorio del Oracle Instant Client
// Asegúrate de que esta ruta sea la correcta para tu sistema
try {
    oracledb.initOracleClient({
        libDir: 'C:\\OracleSoft\\instantclient-basiclite-windows\\instantclient_23_8'
    });
} catch (err) {
    console.error("Error al iniciar el cliente de Oracle:", err);
    process.exit(1);
}

// Objeto con la configuración de la conexión, leído desde .env
const dbConfig = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    connectString: process.env.DB_CONNECT_STRING,
};

// Función asíncrona para probar la conexión
async function testConnection() {
    let connection;
    try {
        // Obtener una conexión del pool
        connection = await oracledb.getConnection(dbConfig);
        console.log('¡Conexión a la base de datos Oracle exitosa!');

    } catch (err) {
        console.error('Error al conectar a la base de datos:', err);
    } finally {
        if (connection) {
            try {
                // Cerrar la conexión
                await connection.close();
            } catch (err) {
                console.error('Error al cerrar la conexión:', err);
            }
        }
    }
}

// Exportamos la función para poder usarla en otros archivos
module.exports = {
    testConnection
};