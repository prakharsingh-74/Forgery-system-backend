require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { errorHandler } = require('./middleware/errorHandler');
const auditMiddleware = require('./middleware/audit');

const app = express();

app.use(cors({ origin: process.env.CORS_ORIGIN, credentials: true }));
app.use(express.json());
app.use(helmet());
app.use(rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }));
app.use(auditMiddleware);

// Use centralized routing
app.use('/api', require('./routes/index'));

app.use(errorHandler);

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
