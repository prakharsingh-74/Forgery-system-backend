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
    const result = await verificationService.listVerifications(req.user, req.query);
    res.json(result);
  } catch (err) {
    next(err);
  }
};
