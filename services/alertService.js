const { supabaseAdmin } = require('../config/supabase');

exports.listAlerts = async (query) => {
  let q = supabaseAdmin.from('alerts').select('*');
  if (query.type) q = q.eq('type', query.type);
  if (query.severity) q = q.eq('severity', query.severity);
  if (query.resolved) q = q.eq('resolved', query.resolved === 'true');
  const { data, error } = await q;
  if (error) throw new Error(error.message);
  return data;
};
