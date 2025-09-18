const Joi = require('joi');

exports.userSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  name: Joi.string().required(),
  role: Joi.string().valid('admin', 'institution', 'verifier').required(),
  institution_id: Joi.string().uuid().optional()
});

exports.institutionSchema = Joi.object({
  name: Joi.string().required(),
  address: Joi.string().optional(),
  contact_email: Joi.string().email().optional()
});

exports.certificateSchema = Joi.object({
  certificate_number: Joi.string().required(),
  student_name: Joi.string().required(),
  roll_number: Joi.string().optional(),
  course: Joi.string().optional(),
  issued_date: Joi.date().optional()
});

exports.certificateUpdateSchema = Joi.object({
  certificate_number: Joi.string(),
  student_name: Joi.string(),
  roll_number: Joi.string(),
  course: Joi.string(),
  issued_date: Joi.date()
}).min(1);
