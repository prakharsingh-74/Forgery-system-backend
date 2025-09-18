const express = require('express');
const router = express.Router();
const certificateController = require('../controllers/certificateController');
const authMiddleware = require('../middleware/auth');
const roleAuth = require('../middleware/roleAuth');

// POST /certificates/:id/subjects (nested)
router.post('/certificates/:id/subjects', authMiddleware, roleAuth(['institution']), certificateController.addSubjects);
// GET /certificates/:id/subjects (nested)
router.get('/certificates/:id/subjects', authMiddleware, certificateController.listSubjects);
// PUT /subjects/:id (root)
router.put('/:id', authMiddleware, roleAuth(['institution']), certificateController.updateSubject);
// GET /subjects/:certificate_id (root)
router.get('/:certificate_id', authMiddleware, certificateController.listSubjects);

module.exports = router;
