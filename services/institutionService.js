const { supabaseAdmin } = require('../config/supabase');
const Joi = require('joi');
const institutionSchema = Joi.object({
  name: Joi.string().required(),
  address: Joi.string().optional(),
  contact_email: Joi.string().email().optional()
});

exports.createInstitution = async (data) => {
  const { error } = institutionSchema.validate(data);
  if (error) throw new Error(error.details[0].message);
  const { data: inst, error: dbError } = await supabaseAdmin
    .from('institutions')
    .insert(data)
    .select()
    .single();
  if (dbError) throw new Error(dbError.message);
  return inst;
};

exports.getInstitution = async (id) => {
  const { data, error } = await supabaseAdmin
    .from('institutions')
    .select('*')
    .eq('id', id)
    .single();
  if (error) throw new Error(error.message);
  return data;
};

exports.listInstitutions = async (query) => {
  let q = supabaseAdmin.from('institutions').select('*');
  if (query.name) q = q.ilike('name', `%${query.name}%`);
  const { data, error } = await q;
  if (error) throw new Error(error.message);
  return data;
};
