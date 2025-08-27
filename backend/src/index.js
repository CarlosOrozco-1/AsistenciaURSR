const express = require('express');
// 1. Importamos nuestras rutas de estudiantes
const estudianteRoutes = require('./routes/estudiante.routes');

const app = express();
const PORT = process.env.PORT || 3000;

// 2. Middlewares: Le decimos a Express que puede entender JSON
app.use(express.json());

// 3. Rutas: Le decimos a la app que use nuestras rutas de estudiantes
// Todo lo que empiece con '/api/estudiantes' será manejado por estudianteRoutes
app.use('/api/estudiantes', estudianteRoutes);

app.listen(PORT, () => {
  console.log(`Servidor escuchando en el puerto ${PORT}`);
});

// src/index.js
const healthRoutes = require('./routes/health.routes');
app.use('/health', healthRoutes);
