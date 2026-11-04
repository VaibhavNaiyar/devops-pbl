const test = require('node:test');
const assert = require('node:assert');
const app = require('../src/app');

let server, base;
test.before(() => new Promise((r) => { server = app.listen(0, () => { base = `http://localhost:${server.address().port}`; r(); }); }));
test.after(() => server.close());

test('health is UP', async () => {
  const res = await fetch(`${base}/health`);
  assert.strictEqual(res.status, 200);
  assert.strictEqual((await res.json()).status, 'UP');
});
test('lists products', async () => {
  const res = await fetch(`${base}/api/products`);
  assert.ok((await res.json()).length >= 3);
});
test('creates valid order', async () => {
  const res = await fetch(`${base}/api/orders`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ productId: 2, qty: 2 }) });
  assert.strictEqual(res.status, 201);
  assert.strictEqual((await res.json()).total, 5000);
});
test('rejects invalid order', async () => {
  const res = await fetch(`${base}/api/orders`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ productId: 99, qty: 1 }) });
  assert.strictEqual(res.status, 400);
});
test('exposes prometheus metrics', async () => {
  const txt = await (await fetch(`${base}/metrics`)).text();
  assert.match(txt, /http_requests_total/);
});
