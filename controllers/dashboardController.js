const dashboardService = require('../services/dashboardService');

exports.getDashboardStats = async (req, res, next) => {
  try {
    // Only allow verifiers to access dashboard
    if (req.user.role !== 'verifier') {
      return res.status(403).json({ error: 'Forbidden' });
    }
    const stats = await dashboardService.getDashboardStats(req.user.id);
    res.json(stats);
  } catch (err) {
    next(err);
  }
};

exports.getRecentActivity = async (req, res, next) => {
  try {
    if (req.user.role !== 'verifier') {
      return res.status(403).json({ error: 'Forbidden' });
    }
    const limit = parseInt(req.query.limit, 10) || 10;
    const activity = await dashboardService.getRecentActivity(req.user.id, limit);
    res.json(activity);
  } catch (err) {
    next(err);
  }
};
