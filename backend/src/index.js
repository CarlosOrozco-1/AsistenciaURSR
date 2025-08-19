// 1. Importar las dependencias
const express = require('express');
const { testConnection } = require('./database');

// 2. Crear una instancia de la aplicación Express
const app = express();

// 3. Definir el puerto
const PORT = process.env.PORT || 3000;

//funcion de prueba de conexión
testConnection();

// 4. Definir una ruta de prueba
app.get('/', (req, res) => {
  res.send('¡La API está funcionando');
});

// 5. Iniciar el servidor
app.listen(PORT, () => {
  console.log(`Servidor escuchando en el puerto ${PORT}`);
});