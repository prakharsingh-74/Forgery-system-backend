const { supabaseAdmin } = require('../config/supabase');

exports.listAuditLogs = async (query) => {
  let q = supabaseAdmin.from('audit_logs').select('*');
  if (query.user_id) q = q.eq('user_id', query.user_id);
  if (query.action) q = q.eq('action', query.action);
  if (query.table_name) q = q.eq('table_name', query.table_name);
  if (query.start_date) q = q.gte('created_at', query.start_date);
  if (query.end_date) q = q.lte('created_at', query.end_date);
  const { data, error } = await q;
  if (error) throw new Error(error.message);
  return data;
};

exports.listAuditLogsByTable = async (table, query) => {
  let q = supabaseAdmin.from('audit_logs').select('*').eq('table_name', table);
  if (query.user_id) q = q.eq('user_id', query.user_id);
  if (query.action) q = q.eq('action', query.action);
  if (query.start_date) q = q.gte('created_at', query.start_date);
  if (query.end_date) q = q.lte('created_at', query.end_date);
  const { data, error } = await q;
  if (error) throw new Error(error.message);
  return data;
};
