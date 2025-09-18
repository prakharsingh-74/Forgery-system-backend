const { supabaseAdmin } = require('../config/supabase');

exports.getHash = async (certificate_id) => {
  const { data, error } = await supabaseAdmin
    .from('certificate_hashes')
    .select('*')
    .eq('certificate_id', certificate_id)
    .single();
  if (error) throw new Error(error.message);
  return data;
};

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

exports.setHash = async (certificate_id, body) => {
  let hash = body.hash;
  let metadata = body.metadata || {};
  if (!hash && body.filePath) {
    // Compute SHA-256 from file
    const fileBuffer = fs.readFileSync(path.resolve(body.filePath));
    hash = crypto.createHash('sha256').update(fileBuffer).digest('hex');
  }
  const { data, error } = await supabaseAdmin
    .from('certificate_hashes')
    .upsert({ certificate_id, hash, metadata })
    .select()
    .single();
  if (error) throw new Error(error.message);
  return data;
};
