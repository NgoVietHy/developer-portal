import express from 'express';
import client from 'prom-client';

const register = new client.Registry();
client.collectDefaultMetrics({ register });

const requestCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['service', 'method', 'route', 'status'],
  registers: [register],
});

export function createApp() {
  const app = express();
  const serviceName = process.env.SERVICE_NAME ?? 'service-catalog';

  app.use((req, res, next) => {
    const end = res.end;
    res.end = function patchedEnd(...args) {
      requestCounter.inc({
        service: serviceName,
        method: req.method,
        route: req.path,
        status: String(res.statusCode),
      });
      return end.apply(this, args);
    };
    next();
  });

  app.get('/health', (_req, res) => {
    res.status(200).json({ status: 'ok', service: serviceName });
  });

  app.get('/', (_req, res) => {
    res.json({
      name: serviceName,
      description: 'Sample catalog service for Developer Portal demo',
      version: '1.0.0',
    });
  });

  app.get('/metrics', async (_req, res) => {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  });

  return app;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const port = Number(process.env.PORT ?? 8081);
  const app = createApp();
  app.listen(port, () => {
    console.log(`service-catalog listening on ${port}`);
  });
}
