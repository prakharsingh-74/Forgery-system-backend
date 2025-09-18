const hashService = require('../services/hashService');

exports.getHash = async (req, res, next) => {
  try {
    const result = await hashService.getHash(req.params.certificate_id);
    res.json(result);
  } catch (err) {
    next(err);
  }
};

exports.setHash = async (req, res, next) => {
  try {
    const result = await hashService.setHash(req.params.certificate_id, req.body);
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
};
