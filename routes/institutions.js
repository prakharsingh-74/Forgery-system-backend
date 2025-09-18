const express = require('express');
const router = express.Router();
const institutionController = require('../controllers/institutionController');
const authMiddleware = require('../middleware/auth');
const roleAuth = require('../middleware/roleAuth');

router.post('/', authMiddleware, roleAuth(['admin']), institutionController.createInstitution);
router.get('/:id', authMiddleware, institutionController.getInstitution);
router.get('/', authMiddleware, institutionController.listInstitutions);

module.exports = router;
