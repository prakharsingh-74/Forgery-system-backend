const { supabaseAdmin } = require('../config/supabase');
const Joi = require('joi');
const { v4: uuidv4 } = require('uuid');
const certificateSchema = Joi.object({
  certificate_number: Joi.string().required(),
  student_name: Joi.string().required(),
  roll_number: Joi.string().optional(),
  course: Joi.string().optional(),
  issued_date: Joi.date().optional()
});

exports.createCertificate = async (user, data, file) => {
  const { error } = certificateSchema.validate(data);
  if (error) throw new Error(error.details[0].message);
  // File upload to Supabase storage should be implemented here
  const file_url = file ? `/uploads/${file.filename}` : null;
  const { data: cert, error: dbError } = await supabaseAdmin
    .from('certificates')
    .insert({ ...data, institution_id: user.institution_id, file_url, status: 'PENDING' })
    .select()
    .single();
  if (dbError) throw new Error(dbError.message);
  return cert;
};

exports.updateCertificate = async (user, id, data) => {
  const { certificateUpdateSchema } = require('../utils/validation');
  const { error } = certificateUpdateSchema.validate(data);
  if (error) throw new Error(error.details[0].message);
  const { data: cert, error: dbError } = await supabaseAdmin
    .from('certificates')
    .update(data)
    .eq('id', id)
    .eq('institution_id', user.institution_id)
    .select()
    .single();
  if (dbError) throw new Error(dbError.message);
  return cert;
};

exports.getCertificate = async (id) => {
  const { data, error } = await supabaseAdmin
    .from('certificates')
    .select('*')
    .eq('id', id)
    .single();
  if (error) throw new Error(error.message);
  return data;
};

exports.listCertificates = async (query) => {
  let q = supabaseAdmin.from('certificates').select('*');
  if (query.institution_id) q = q.eq('institution_id', query.institution_id);
  if (query.status) q = q.eq('status', query.status);
  const { data, error } = await q;
  if (error) throw new Error(error.message);
  return data;
};

exports.addSubjects = async (certificate_id, subjects) => {
  // subjects: [{ subject, marks }]
  const { data, error } = await supabaseAdmin
    .from('certificate_subjects')
    .insert(subjects.map(s => ({ ...s, certificate_id })))
    .select();
  if (error) throw new Error(error.message);
  return data;
};

exports.updateSubject = async (subjectId, data) => {
  const { data: subject, error } = await supabaseAdmin
    .from('certificate_subjects')
    .update(data)
    .eq('id', subjectId)
    .select()
    .single();
  if (error) throw new Error(error.message);
  return subject;
};

exports.listSubjects = async (certificate_id) => {
  const { data, error } = await supabaseAdmin
    .from('certificate_subjects')
    .select('*')
    .eq('certificate_id', certificate_id);
  if (error) throw new Error(error.message);
  return data;
};
