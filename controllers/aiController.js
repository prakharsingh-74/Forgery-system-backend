const aiService = require('../services/aiService');

exports.extractData = async (req, res, next) => {
  try {
    const result = await aiService.extractData(req.query.fileUrl);
    res.json(result);
  } catch (err) {
    next(err);
  }
};
