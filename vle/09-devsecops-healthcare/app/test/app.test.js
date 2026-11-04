process.env.API_KEY = 'test-key-only-for-unit-tests';
const test = require('node:test');
const assert = require('node:assert');
const app = require('../src/app');

let server, base;
const H = { 'x-api-key': process.env.API_KEY, 'content-type': 'application/json' };
test.before(() => new Promise((r) => { server = app.listen(0, () => { base = `http://localhost:${server.address().port}`; r(); }); }));
test.after(() => server.close());

test('health is public', async () => assert.strictEqual((await fetch(`${base}/health`)).status, 200));
test('rejects missing API key', async () => assert.strictEqual((await fetch(`${base}/api/patients/P1001`)).status, 401));
test('rejects wrong API key', async () =>
  assert.strictEqual((await fetch(`${base}/api/patients/P1001`, { headers: { 'x-api-key': 'nope' } })).status, 401));
test('returns patient with masked phone', async () => {
  const body = await (await fetch(`${base}/api/patients/P1001`, { headers: H })).json();
  assert.strictEqual(body.name, 'Asha Verma');
  assert.ok(body.phone.includes('*') && !body.phone.includes('765432'));
});
test('rejects injection-style id', async () =>
  assert.strictEqual((await fetch(`${base}/api/patients/P1001'%20OR%201=1`, { headers: H })).status, 400));
test('validates new patient', async () => {
  const bad = await fetch(`${base}/api/patients`, { method: 'POST', headers: H, body: JSON.stringify({ name: '<script>', dob: 'x', phone: '1', condition: 'y' }) });
  assert.strictEqual(bad.status, 400);
  const ok = await fetch(`${base}/api/patients`, { method: 'POST', headers: H, body: JSON.stringify({ name: 'Neha Das', dob: '2000-01-01', phone: '9000000000', condition: 'Asthma' }) });
  assert.strictEqual(ok.status, 201);
});
test('sets security headers and hides framework', async () => {
  const res = await fetch(`${base}/health`);
  assert.ok(res.headers.get('content-security-policy'));
  assert.strictEqual(res.headers.get('x-content-type-options'), 'nosniff');
  assert.strictEqual(res.headers.get('x-powered-by'), null);
});
