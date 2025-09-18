const { createClient } = require('@supabase/supabase-js');
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
  throw new Error('Supabase configuration missing in environment variables');
}


let supabaseAdmin, supabase;
try {
  supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
  supabase = createClient(SUPABASE_URL, process.env.SUPABASE_ANON_KEY);
  console.log('Supabase client connected successfully');
} catch (err) {
  console.error('Supabase connection failed:', err.message);
  throw err;
}

module.exports = { supabaseAdmin, supabase };
