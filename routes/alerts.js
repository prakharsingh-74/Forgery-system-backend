const express = require('express');
const router = express.Router();
const alertController = require('../controllers/alertController');
const authMiddleware = require('../middleware/auth');
const roleAuth = require('../middleware/roleAuth');

router.get('/', authMiddleware, roleAuth(['admin']), alertController.listAlerts);

module.exports = router;
