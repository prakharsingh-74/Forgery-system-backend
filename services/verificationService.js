const { supabaseAdmin } = require('../config/supabase');
const axios = require('axios');

exports.verifyCertificate = async (user, file) => {
  // Upload file to Supabase storage and get URL
  const file_url = file ? `/uploads/${file.filename}` : null;
  // Call AI service for OCR extraction
  const aiRes = await axios.get(`${process.env.AI_SERVICE_URL}/ai/extract`, { params: { fileUrl: file_url } });
  // Create verification request with status PROCESSING
  const { data: verification, error } = await supabaseAdmin
    .from('verification_requests')
    .insert({ certificate_id: null, requested_by: user.id, status: 'PROCESSING', result: aiRes.data })
    .select()
    .single();
  if (error) throw new Error(error.message);

  // Improved status logic based on AI confidence
  const confidence = aiRes.data.confidence || 0;
  let status = 'REJECTED';
  let reason = 'Low confidence';
  if (confidence >= 0.95 && aiRes.data.validation_passed) {
    status = 'VERIFIED';
    reason = 'High confidence and validation passed';
  } else if (confidence >= 0.7) {
    status = 'FLAGGED';
    reason = 'Medium confidence or partial validation';
  }

  const { data: updated, error: updateError } = await supabaseAdmin
    .from('verification_requests')
    .update({ status, result: { ...aiRes.data, confidence, reason } })
    .eq('id', verification.id)
    .select()
    .single();
  if (updateError) throw new Error(updateError.message);
  return updated;
};

exports.getVerificationStatus = async (id) => {
  const { data, error } = await supabaseAdmin
    .from('verification_requests')
    .select('*')
    .eq('id', id)
    .single();
  if (error) throw new Error(error.message);
  return data;
};

exports.listVerifications = async (user, query) => {
  // Filtering, pagination, and search
  let q = supabaseAdmin.from('verification_requests')
    .select('id, status, created_at, result, certificate:certificates(certificate_number, student_name, course, institution_id)', { count: 'exact' });
  if (user.role === 'verifier') q = q.eq('requested_by', user.id);
  if (query.status) {
    if (Array.isArray(query.status)) q = q.in('status', query.status);
    else q = q.eq('status', query.status);
  }
  if (query.dateFrom) q = q.gte('created_at', new Date(query.dateFrom).toISOString());
  if (query.dateTo) q = q.lte('created_at', new Date(query.dateTo).toISOString());
  if (query.search) {
    q = q.ilike('certificate.certificate_number', `%${query.search}%`);
  }
  const page = query.page || 1;
  const limit = query.limit || 10;
  q = q.range((page-1)*limit, page*limit-1);
  const { data, error, count } = await q;
  if (error) throw new Error(error.message);
  return { data, page, limit, total: count };
};

exports.exportVerifications = async (user, query) => {
  // Same filtering as listVerifications, but return all rows for export
  let q = supabaseAdmin.from('verification_requests')
    .select('id, status, created_at, certificate:certificates(certificate_number, student_name)', { count: 'exact' });
  if (user.role === 'verifier') q = q.eq('requested_by', user.id);
  if (query.status) {
    if (Array.isArray(query.status)) q = q.in('status', query.status);
    else q = q.eq('status', query.status);
  }
  if (query.dateFrom) q = q.gte('created_at', new Date(query.dateFrom).toISOString());
  if (query.dateTo) q = q.lte('created_at', new Date(query.dateTo).toISOString());
  if (query.search) {
    q = q.ilike('certificate.certificate_number', `%${query.search}%`);
  }
  const { data, error } = await q;
  if (error) throw new Error(error.message);
  // Format for CSV
  const rows = require('../utils/helpers').formatVerificationDataForExport(data);
  const headers = ['id','status','created_at','certificate_number','student_name'];
  const csv = [headers.join(',')].concat(rows.map(r => headers.map(h => r[h]).join(','))).join('\n');
  return csv;
};
