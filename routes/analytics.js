const express = require('express');
const router = express.Router();
const analyticsController = require('../controllers/analyticsController');
const authMiddleware = require('../middleware/auth');
const roleAuth = require('../middleware/roleAuth');

// Dashboard statistics
router.get('/dashboard', authMiddleware, roleAuth(['admin', 'institution']), analyticsController.getDashboardAnalytics);

// Verification trends
router.get('/verification-trends', authMiddleware, roleAuth(['admin', 'institution']), analyticsController.getVerificationTrends);

// Fraud detection patterns
router.get('/fraud-patterns', authMiddleware, roleAuth(['admin']), analyticsController.getFraudPatterns);

// Institution metrics
router.get('/institution-performance', authMiddleware, roleAuth(['admin', 'institution']), analyticsController.getInstitutionPerformance);

// Custom report generation
router.post('/generate-report', authMiddleware, roleAuth(['admin']), analyticsController.generateReport);

// Report download
router.get('/reports/:id', authMiddleware, roleAuth(['admin']), analyticsController.downloadReport);

module.exports = router;