const institutionService = require('../services/institutionService');

exports.createInstitution = async (req, res, next) => {
  try {
    const result = await institutionService.createInstitution(req.body);
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
};

exports.getInstitution = async (req, res, next) => {
  try {
    const result = await institutionService.getInstitution(req.params.id);
    res.json(result);
  } catch (err) {
    next(err);
  }
};

exports.listInstitutions = async (req, res, next) => {
  try {
    const result = await institutionService.listInstitutions(req.query);
    res.json(result);
  } catch (err) {
    next(err);
  }
};
