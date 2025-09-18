const express = require('express');
const router = express.Router();
const aiController = require('../controllers/aiController');
const authMiddleware = require('../middleware/auth');

router.get('/extract', authMiddleware, aiController.extractData);

module.exports = router;
