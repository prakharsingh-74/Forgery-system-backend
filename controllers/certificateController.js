const certificateService = require('../services/certificateService');

exports.createCertificate = async (req, res, next) => {
  try {
    const result = await certificateService.createCertificate(req.user, req.body, req.file);
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
};

exports.updateCertificate = async (req, res, next) => {
  try {
    const result = await certificateService.updateCertificate(req.user, req.params.id, req.body);
    res.json(result);
  } catch (err) {
    next(err);
  }
};

exports.getCertificate = async (req, res, next) => {
  try {
    const result = await certificateService.getCertificate(req.params.id);
    res.json(result);
  } catch (err) {
    next(err);
  }
};

exports.listCertificates = async (req, res, next) => {
  try {
    const result = await certificateService.listCertificates(req.query);
    res.json(result);
  } catch (err) {
    next(err);
  }
};

exports.addSubjects = async (req, res, next) => {
  try {
    const result = await certificateService.addSubjects(req.params.id, req.body);
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
};

exports.updateSubject = async (req, res, next) => {
  try {
    const result = await certificateService.updateSubject(req.params.subjectId, req.body);
    res.json(result);
  } catch (err) {
    next(err);
  }
};

exports.listSubjects = async (req, res, next) => {
  try {
    const result = await certificateService.listSubjects(req.params.id);
    res.json(result);
  } catch (err) {
    next(err);
  }
};
