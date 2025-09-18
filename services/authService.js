const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { supabaseAdmin } = require('../config/supabase');
const Joi = require('joi');
const userSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  name: Joi.string().required(),
  role: Joi.string().valid('admin', 'institution', 'verifier').required(),
  institution_id: Joi.string().uuid().optional()
});

exports.signup = async (data) => {
  const { error } = userSchema.validate(data);
  if (error) throw new Error(error.details[0].message);
  const hashedPassword = await bcrypt.hash(data.password, 10);
  const { data: user, error: dbError } = await supabaseAdmin
    .from('users')
    .insert({ ...data, password: hashedPassword })
    .select()
    .single();
  if (dbError) throw new Error(dbError.message);
  return { user };
};

exports.login = async ({ email, password }) => {
  const { data: user, error } = await supabaseAdmin
    .from('users')
    .select('*')
    .eq('email', email)
    .single();
  if (error || !user) throw new Error('Invalid credentials');
  const valid = await bcrypt.compare(password, user.password);
  if (!valid) throw new Error('Invalid credentials');
  const token = jwt.sign({ id: user.id, role: user.role, email: user.email, institution_id: user.institution_id }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '1d' });
  return { token, user: { id: user.id, email: user.email, name: user.name, role: user.role, verified: user.verified, institution_id: user.institution_id } };
};

exports.getMe = async (user) => {
  const { data, error } = await supabaseAdmin
    .from('users')
    .select('id, email, name, role, verified, institution_id')
    .eq('id', user.id)
    .single();
  if (error) throw new Error(error.message);
  return data;
};
