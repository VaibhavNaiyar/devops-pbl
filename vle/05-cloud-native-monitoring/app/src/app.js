const express = require('express');
const client = require('prom-client');

const VERSION = process.env.APP_VERSION || '1.0.0';
const COLOR = process.env.APP_COLOR || 'blue';

const register = new client.Registry();
client.collectDefaultMetrics({ register });
const httpRequests = new client.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
});
const httpDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Request latency',
  labelNames: ['route'],
  buckets: [0.01, 0.05, 0.1, 0.3, 0.5, 1, 2],
  registers: [register],
});
const orders = new client.Counter({ name: 'shop_orders_total', help: 'Orders placed', registers: [register] });

const products = [
  { id: 1, name: 'Laptop', price: 55000 },
  { id: 2, name: 'Headphones', price: 2500 },
  { id: 3, name: 'Keyboard', price: 1800 },
];

const app = express();
app.use(express.json());
app.disable('x-powered-by');

app.use((req, res, next) => {
  const end = httpDuration.startTimer({ route: req.path });
  res.on('finish', () => {
    httpRequests.inc({ method: req.method, route: req.path, status: res.statusCode });
    end();
  });
  next();
});

app.get('/', (req, res) => {
  res.send(`<!doctype html><html><body style="font-family:system-ui;background:${COLOR === 'green' ? '#14532d' : '#1e3a8a'};color:#fff;display:grid;place-items:center;height:100vh;margin:0">
  <div style="text-align:center"><h1>PBL Shop</h1><h2>Version ${VERSION} &middot; ${COLOR.toUpperCase()}</h2><p>Pod: ${require('os').hostname()}</p></div></body></html>`);
});
app.get('/api/products', (req, res) => res.json(products));
app.post('/api/orders', (req, res) => {
  const { productId, qty } = req.body || {};
  const p = products.find((x) => x.id === Number(productId));
  if (!p || !Number.isInteger(qty) || qty < 1) return res.status(400).json({ error: 'invalid order' });
  orders.inc();
  return res.status(201).json({ orderId: Date.now(), product: p.name, total: p.price * qty });
});
app.get('/health', (req, res) => res.json({ status: 'UP', version: VERSION, color: COLOR }));
app.get('/ready', (req, res) => res.json({ ready: true }));
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

module.exports = app;
