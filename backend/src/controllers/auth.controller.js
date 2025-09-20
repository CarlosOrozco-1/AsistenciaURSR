// src/controllers/authController.js
const { validarCredenciales } = require('../services/auth.service');

/**
 * Este endpoint maneja el login de usuarios.
 * Aunque el campo se llama 'email', internamente se usa como 'NOMBRE_USUARIO' en Oracle.
 * En la base de datos, el correo electrónico es el nombre de usuario.
 */
const login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({
      status: 'error',
      message: 'Email y contraseña son requeridos.',
    });
  }

  try {
    const resultado = await validarCredenciales(email, password);

    if (!resultado) {
      return res.status(401).json({
        status: 'error',
        message: 'Credenciales inválidas o usuario inactivo.',
      });
    }

    return res.status(200).json({
      status: 'success',
      token: resultado.token,
      perfil: resultado.perfil,
    });
  } catch (error) {
    console.error('Error en login:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Error interno del servidor.',
    });
  }
};

module.exports = { login };
