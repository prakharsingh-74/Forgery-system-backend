const verificationService = require('../services/verificationService');

exports.verifyCertificate = async (req, res, next) => {
  try {
    const result = await verificationService.verifyCertificate(req.user, req.file);
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
};

exports.getVerificationStatus = async (req, res, next) => {
  try {
    const result = await verificationService.getVerificationStatus(req.params.id);
    res.json(result);
  } catch (err) {
    next(err);
  }
};

exports.listVerifications = async (req, res, next) => {
  try {
    const { error, value } = require('../utils/validation').verificationListQuery.validate(req.query);
    if (error) return res.status(400).json({ error: error.details[0].message });
    const result = await verificationService.listVerifications(req.user, value);
    res.json(result);
  } catch (err) {
    next(err);
  }
};

exports.exportVerifications = async (req, res, next) => {
  try {
    const { error, value } = require('../utils/validation').verificationListQuery.validate(req.query);
    if (error) return res.status(400).json({ error: error.details[0].message });
    const csv = await verificationService.exportVerifications(req.user, value);
    res.setHeader('Content-Type','text/csv');
    res.setHeader('Content-Disposition','attachment; filename="verification_history.csv"');
    res.send(csv);
  } catch (err) {
    next(err);
  }
};
