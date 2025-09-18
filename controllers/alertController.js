const alertService = require('../services/alertService');

exports.listAlerts = async (req, res, next) => {
  try {
    const result = await alertService.listAlerts(req.query);
    res.json(result);
  } catch (err) {
    next(err);
  }
};
