const { supabaseAdmin } = require('../config/supabase');
const { VERIFICATION_STATUSES } = require('../utils/constants');
const { calculateSuccessRate } = require('../utils/helpers');

exports.getDashboardStats = async (userId) => {
  // Aggregate metrics for dashboard
  const { count: totalVerified } = await supabaseAdmin
    .from('verification_requests')
    .select('*', { count: 'exact', head: true })
    .eq('requested_by', userId)
    .eq('status', 'VERIFIED');

  const now = new Date();
  const monthStartUtc = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1, 0, 0, 0));
  const { count: monthlyVerified } = await supabaseAdmin
    .from('verification_requests')
    .select('*', { count: 'exact', head: true })
    .eq('requested_by', userId)
    .eq('status', 'VERIFIED')
    .gte('created_at', monthStartUtc.toISOString());

  const { count: flaggedCount } = await supabaseAdmin
    .from('verification_requests')
    .select('*', { count: 'exact', head: true })
    .eq('requested_by', userId)
    .eq('status', 'FLAGGED');

  const { count: totalRequests } = await supabaseAdmin
    .from('verification_requests')
    .select('*', { count: 'exact', head: true })
    .eq('requested_by', userId);

  const successRate = calculateSuccessRate(totalVerified, totalRequests);
  const recentActivity = await exports.getRecentActivity(userId, 5);

  return {
    totalVerified,
    monthlyVerified,
    flaggedCount,
    successRate,
    recentActivity
  };
};

exports.getRecentActivity = async (userId, limit = 10) => {
  const { data, error } = await supabaseAdmin
    .from('verification_requests')
    .select('id, status, created_at, result, certificate:certificates(certificate_number, student_name, course, institution_id)')
    .eq('requested_by', userId)
    .order('created_at', { ascending: false })
    .limit(limit);
  if (error) throw new Error(error.message);
  return data;
};
