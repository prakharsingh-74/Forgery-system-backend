const express = require('express');
const router = express.Router();
const certificateController = require('../controllers/certificateController');
const authMiddleware = require('../middleware/auth');
const roleAuth = require('../middleware/roleAuth');
const upload = require('../middleware/upload');

router.post('/', authMiddleware, roleAuth(['institution']), upload.single('file'), certificateController.createCertificate);
router.put('/:id', authMiddleware, roleAuth(['institution']), certificateController.updateCertificate);
router.get('/:id', authMiddleware, certificateController.getCertificate);
router.get('/', authMiddleware, certificateController.listCertificates);

module.exports = router;
