const router = require('express').Router();
const auth = require('../middleware/auth');
const ctrl = require('../controllers/dashboardController');
router.get('/stats', auth, ctrl.getDashboardStats);
router.get('/recent', auth, ctrl.getRecentActivity);
module.exports = router;
