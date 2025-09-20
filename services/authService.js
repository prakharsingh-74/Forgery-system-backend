const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { supabaseAdmin } = require('../config/supabase');
const Joi = require('joi');
const { registrationSchema, loginSchema, mapAccountTypeToRole } = require('../utils/validation');

exports.signup = async (payload) => {
  const { error, value } = registrationSchema.validate(payload, { abortEarly: false, stripUnknown: true });
  if (error) throw new Error(error.details[0].message);

  const role = mapAccountTypeToRole(value.accountType);
  if (!role) throw new Error('Invalid account type');

  const email = value.email.trim().toLowerCase();
  const hashedPassword = await bcrypt.hash(value.password, 10);

  const insert = {
    email,
    password: hashedPassword,
    name: value.name || value.fullName,
    role,
    organization: value.organization || null,
    phone_number: value.phone_number || value.phoneNumber || null,
    address: value.address || null,
  };

  const { data: user, error: dbError } = await supabaseAdmin
    .from('users').insert(insert).select().single();
  if (dbError) throw new Error(dbError.message);
  delete user.password;
  return { user };
};

exports.login = async (creds) => {
  const { error, value } = loginSchema.validate(creds);
  if (error) throw new Error('Invalid credentials');
  const email = value.email.trim().toLowerCase();
  const { data: user, error: qErr } = await supabaseAdmin
    .from('users').select('*').eq('email', email).single();
  if (qErr || !user) throw new Error('Invalid credentials');
  const valid = await bcrypt.compare(value.password, user.password);
  if (!valid) throw new Error('Invalid credentials');
  const token = jwt.sign({ id: user.id, role: user.role, email: user.email, institution_id: user.institution_id }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '1d' });
  const { password, ...profile } = user;
  return { token, user: profile };
};

exports.getMe = async (user) => {
  const { data, error } = await supabaseAdmin
    .from('users')
    .select('id, email, name, role, verified, institution_id, organization, phone_number, address')
    .eq('id', user.id)
    .single();
  if (error) throw new Error(error.message);
  return data;
};
