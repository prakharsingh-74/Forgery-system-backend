const express = require('express');
const router = express.Router();
const verificationController = require('../controllers/verificationController');
const authMiddleware = require('../middleware/auth');
const upload = require('../middleware/upload');


router.post('/', authMiddleware, upload.single('file'), verificationController.verifyCertificate);
router.get('/:id', authMiddleware, verificationController.getVerificationStatus);
router.get('/', authMiddleware, verificationController.listVerifications);
router.get('/export', authMiddleware, verificationController.exportVerifications);

module.exports = router;
