const Joi = require('joi');


const accountTypeEnum = [
  'Certificate Verifier (HR/Employer)',
  'Educational Institution',
  'System Administrator'
];

exports.registrationSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(8).required(),
  confirmPassword: Joi.string().valid(Joi.ref('password')).required()
    .messages({'any.only':'Passwords must match'}),
  fullName: Joi.string().required(),
  accountType: Joi.string().valid(...accountTypeEnum).required(),
  organization: Joi.string().allow('', null),
  phoneNumber: Joi.string().pattern(/^\+?[0-9]{10,15}$/).allow('', null),
  address: Joi.string().allow('', null)
});

exports.loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required()
});

exports.mapAccountTypeToRole = (t) => ({
  'Certificate Verifier (HR/Employer)': 'verifier',
  'Educational Institution': 'institution',
  'System Administrator': 'admin'
})[t]; // returns undefined if not mapped

// keep existing schemas for backward compatibility

// Registration schema for enhanced signup
exports.registrationSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  confirmPassword: Joi.string().valid(Joi.ref('password')).required().messages({
    'any.only': 'Passwords do not match'
  }),
  name: Joi.string().required(),
  accountType: Joi.string().valid(
    'Certificate Verifier (HR/Employer)',
    'Educational Institution',
    'System Administrator'
  ).required(),
  organization: Joi.string().optional(),
  phone_number: Joi.string().pattern(/^\+?\d{10,15}$/).optional().messages({
    'string.pattern.base': 'Phone number must be 10-15 digits, optional + prefix'
  }),
  address: Joi.string().optional(),
  institution_id: Joi.string().uuid().optional()
});

// Login schema for simple login
exports.loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required()
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
