const axios = require('axios');

exports.extractData = async (fileUrl) => {
  // Call external AI/ML service for OCR extraction
  const { data } = await axios.post(process.env.AI_SERVICE_URL + '/extract', { fileUrl });
  return data;
};
