const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const authMiddleware = require('../middleware/auth');

// Canonical routes (as per README)
router.post('/register', authController.signup);
router.post('/login', authController.login);
router.get('/profile', authMiddleware, authController.getProfile);
router.put('/profile', authMiddleware, authController.updateProfile);
router.post('/logout', authMiddleware, authController.logout);
router.post('/refresh', authController.refresh);

// Legacy routes for backward compatibility
// TODO: deprecate /signup and /me in next major
router.post('/signup', authController.signup);
router.get('/me', authMiddleware, authController.getMe);

module.exports = router;
