require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { errorHandler } = require('./middleware/errorHandler');
const auditMiddleware = require('./middleware/audit');
const authRoutes = require('./routes/auth');
const institutionRoutes = require('./routes/institutions');
const certificateRoutes = require('./routes/certificates');
const subjectRoutes = require('./routes/subjects');
const verifyRoutes = require('./routes/verify');
const auditRoutes = require('./routes/audit');
const aiRoutes = require('./routes/ai');
const hashRoutes = require('./routes/hash');
const alertRoutes = require('./routes/alerts');
const dashboardRoutes = require('./routes/dashboard');



const app = express();

app.use(cors({ origin: process.env.CORS_ORIGIN, credentials: true }));
app.use(express.json());
app.use(helmet());
app.use(rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }));
app.use(auditMiddleware);

app.use('/auth', authRoutes);
app.use('/institution', institutionRoutes);
app.use('/certificates', certificateRoutes);
// Remove nested subject route
// Add root subjects route
const subjectRoutesRoot = require('./routes/subjects');
app.use('/subjects', subjectRoutesRoot);
app.use('/verify', verifyRoutes);
app.use('/audit', auditRoutes);
app.use('/ai', aiRoutes);

app.use('/dashboard', dashboardRoutes);
app.use('/hash', hashRoutes);
app.use('/alerts', alertRoutes);

app.use(errorHandler);

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
