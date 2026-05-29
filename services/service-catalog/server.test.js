import test from 'node:test';
import assert from 'node:assert/strict';
import http from 'node:http';
import { createApp } from './src/server.js';

test('health endpoint returns ok', async () => {
  const app = createApp();
  const server = http.createServer(app);
  await new Promise(resolve => server.listen(0, resolve));

  const address = server.address();
  if (!address || typeof address === 'string') {
    throw new Error('No ephemeral port allocated');
  }

  const response = await fetch(`http://127.0.0.1:${address.port}/health`);
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(body.status, 'ok');

  await new Promise(resolve => server.close(resolve));
});
