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
  // Simulate matching and update status to VERIFIED
  const { data: updated, error: updateError } = await supabaseAdmin
    .from('verification_requests')
    .update({ status: 'VERIFIED' })
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
  let q = supabaseAdmin.from('verification_requests').select('*');
  if (user.role === 'verifier') q = q.eq('requested_by', user.id);
  const { data, error } = await q;
  if (error) throw new Error(error.message);
  return data;
};
