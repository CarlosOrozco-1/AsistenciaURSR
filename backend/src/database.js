// Importar las dependencias necesarias
const oracledb = require('oracledb');
const dotenv = require('dotenv');

// Cargar las variables de entorno del archivo .env
dotenv.config();

// Configurar el directorio del Oracle Instant Client
try {
    oracledb.initOracleClient({
        libDir: 'C:\\OracleSoft\\instantclient-basiclite-windows\\instantclient_23_8'
    });
} catch (err) {
    console.error("Error al iniciar el cliente de Oracle:", err);
    process.exit(1);
}

// Objeto con la configuración de la conexión
const dbConfig = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    connectString: process.env.DB_CONNECT_STRING,
};

// Función genérica para ejecutar consultas SQL
async function ejecutarConsulta(sql, binds = []) {
    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        // La opción outFormat nos devuelve objetos, lo cual es muy útil
        const result = await connection.execute(sql, binds, { outFormat: oracledb.OUT_FORMAT_OBJECT });
        return result.rows;
    } catch (err)
    {
        console.error('Error en la consulta:', err);
        // Re-lanzamos el error para que el controlador que llamó a esta función lo maneje
        throw err;
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error('Error al cerrar la conexión:', err);
            }
        }
    }
}

// Exportamos la función correcta para que otros archivos puedan usarla
module.exports = {
    ejecutarConsulta
};