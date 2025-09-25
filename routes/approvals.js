const express = require('express');
const router = express.Router();
const approvalController = require('../controllers/approvalController');
const authMiddleware = require('../middleware/auth');
const roleAuth = require('../middleware/roleAuth');

// Pending approval requests
router.get('/pending', authMiddleware, roleAuth(['admin', 'institution']), approvalController.getPendingApprovals);

// Approval granting
router.post('/:id/approve', authMiddleware, roleAuth(['admin']), approvalController.approveRequest);

// Approval rejection
router.post('/:id/reject', authMiddleware, roleAuth(['admin']), approvalController.rejectRequest);

// Approval history
router.get('/history', authMiddleware, roleAuth(['admin', 'institution']), approvalController.getApprovalHistory);

// New approval request
router.post('/request', authMiddleware, roleAuth(['institution']), approvalController.createApprovalRequest);

module.exports = router;