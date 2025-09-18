const auditService = require('../services/auditService');

exports.listAuditLogs = async (req, res, next) => {
  try {
    const result = await auditService.listAuditLogs(req.query);
    res.json(result);
  } catch (err) {
    next(err);
  }
};

exports.listAuditLogsByTable = async (req, res, next) => {
  try {
    const result = await auditService.listAuditLogsByTable(req.params.table, req.query);
    res.json(result);
  } catch (err) {
    next(err);
  }
};
