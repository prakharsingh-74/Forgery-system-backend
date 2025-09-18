const { supabaseAdmin } = require('../config/supabase');

exports.uploadFile = async (buffer, filename, mimetype) => {
  const { data, error } = await supabaseAdmin.storage
    .from('certificates')
    .upload(filename, buffer, { contentType: mimetype, upsert: true });
  if (error) throw new Error(error.message);
  // Get public URL
  const { publicURL } = supabaseAdmin.storage.from('certificates').getPublicUrl(filename).data;
  return publicURL;
};

exports.getFileUrl = (filename) => {
  const { publicURL } = supabaseAdmin.storage.from('certificates').getPublicUrl(filename).data;
  return publicURL;
};
