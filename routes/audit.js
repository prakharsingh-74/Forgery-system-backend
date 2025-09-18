const express = require('express');
const router = express.Router();
const auditController = require('../controllers/auditController');
const authMiddleware = require('../middleware/auth');
const roleAuth = require('../middleware/roleAuth');

router.get('/', authMiddleware, roleAuth(['admin']), auditController.listAuditLogs);
router.get('/:table', authMiddleware, roleAuth(['admin']), auditController.listAuditLogsByTable);

module.exports = router;
