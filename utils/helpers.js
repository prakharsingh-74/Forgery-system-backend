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
