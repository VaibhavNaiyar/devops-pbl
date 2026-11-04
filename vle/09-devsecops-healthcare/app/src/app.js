// Healthcare patient API - security controls mapped to HIPAA technical safeguards
const crypto = require('crypto');
const express = require('express');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const API_KEY = process.env.API_KEY; // injected from Kubernetes Secret, never hard-coded

// In-memory demo store (a real system would use an encrypted database)
const patients = new Map([
  ['P1001', { id: 'P1001', name: 'Asha Verma', dob: '1990-04-12', phone: '9876543210', condition: 'Hypertension' }],
  ['P1002', { id: 'P1002', name: 'Rohan Iyer', dob: '1985-11-02', phone: '9123456780', condition: 'Diabetes Type 2' }],
]);

const mask = (s) => (s ? s.slice(0, 2) + '*'.repeat(Math.max(s.length - 4, 0)) + s.slice(-2) : s);
const audit = (req, action, patientId) =>
  // audit log contains NO PHI - only ids, action and hashed client
  console.log(JSON.stringify({ ts: new Date().toISOString(), action, patientId,
    client: crypto.createHash('sha256').update(req.ip || '').digest('hex').slice(0, 12) }));

function safeEqual(a, b) {
  const x = Buffer.from(String(a)); const y = Buffer.from(String(b));
  return x.length === y.length && crypto.timingSafeEqual(x, y);
}

function auth(req, res, next) {
  const key = req.get('x-api-key');
  if (!API_KEY || !key || !safeEqual(key, API_KEY)) return res.status(401).json({ error: 'unauthorized' });
  return next();
}

const app = express();
app.disable('x-powered-by');
app.use(helmet());                                          // security headers (CSP, HSTS, nosniff...)
app.use(express.json({ limit: '10kb' }));                   // body size limit
app.use(rateLimit({ windowMs: 60_000, limit: 100, standardHeaders: 'draft-7', legacyHeaders: false }));

app.get('/health', (req, res) => res.json({ status: 'UP' }));

app.get('/api/patients/:id', auth, (req, res) => {
  const id = req.params.id;
  if (!/^P\d{4}$/.test(id)) return res.status(400).json({ error: 'invalid id' }); // input validation
  const p = patients.get(id);
  if (!p) return res.status(404).json({ error: 'not found' });
  audit(req, 'READ_PATIENT', id);
  return res.json({ ...p, phone: mask(p.phone) });          // minimum-necessary disclosure
});

app.post('/api/patients', auth, (req, res) => {
  const { name, dob, phone, condition } = req.body || {};
  const valid = typeof name === 'string' && /^[A-Za-z .'-]{2,60}$/.test(name)
    && /^\d{4}-\d{2}-\d{2}$/.test(dob || '') && /^\d{10}$/.test(phone || '')
    && typeof condition === 'string' && condition.length <= 100;
  if (!valid) return res.status(400).json({ error: 'validation failed' });
  const id = `P${1000 + patients.size + 1}`;
  patients.set(id, { id, name, dob, phone, condition });
  audit(req, 'CREATE_PATIENT', id);
  return res.status(201).json({ id });
});

// Generic error handler - never leak stack traces
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => res.status(500).json({ error: 'internal error' }));

module.exports = app;
const AWS_SECRET_KEY = "AKIA4QWERTY7PBL2LEAK"; // leaked by mistake (demo)
