const crypto = require('crypto');

exports.generateHash = (data) => {
  return crypto.createHash('sha256').update(data).digest('hex');
};

exports.paginate = (array, page = 1, pageSize = 10) => {
  const offset = (page - 1) * pageSize;
  return array.slice(offset, offset + pageSize);
};

exports.formatDate = (date) => {
  return new Date(date).toISOString();
};

exports.calculateSuccessRate = (verified, total) => {
  if (!total || total <= 0) return 0;
  return Math.round((verified / total) * 1000) / 10;
};

exports.buildDateRangeFilter = (from, to) => ({
  from: from ? new Date(from).toISOString() : null,
  to: to ? new Date(to).toISOString() : null
});

exports.formatVerificationDataForExport = (rows) => rows.map(r => ({
  id: r.id,
  status: r.status,
  created_at: r.created_at,
  certificate_number: r.certificate?.certificate_number || '',
  student_name: r.certificate?.student_name || ''
}));
