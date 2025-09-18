const express = require('express');
const router = express.Router();
const hashController = require('../controllers/hashController');
const authMiddleware = require('../middleware/auth');

router.get('/:certificate_id', authMiddleware, hashController.getHash);
router.post('/:certificate_id', authMiddleware, hashController.setHash);

module.exports = router;
