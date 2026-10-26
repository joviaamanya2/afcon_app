import cors from '@fastify/cors';
import Fastify from 'fastify';
import { registerAuthRoutes } from './auth.js';
import { closeDatabase } from './db.js';
import { registerAdminRoutes } from './routes/admin.js';
import { registerPublicRoutes } from './routes/public.js';

const app = Fastify({ logger: true, bodyLimit: 1_048_576 });
app.setErrorHandler((error, request, reply) => {
  app.log.error({ err: error, url: request.url }, 'Request failed');
  if (error instanceof Error && error.message === 'database_not_configured') {
    return reply.code(503).send({
      error: 'database_not_configured',
      message: 'Set DATABASE_URL and run the database migrations to enable this feature.',
    });
  }
  return reply.code(500).send({
    error: 'internal_error',
    message: 'The server could not complete this request.',
  });
});
const origins = (process.env.ALLOWED_ORIGINS ?? '')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

await app.register(cors, {
  origin: origins.length === 0 ? true : origins,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
});

app.get('/health', async () => ({ status: 'ok', service: 'afcon-fan-api' }));
await registerAuthRoutes(app);
await registerPublicRoutes(app);
await registerAdminRoutes(app);

const port = Number.parseInt(process.env.PORT ?? '8080', 10);
const host = process.env.HOST ?? '0.0.0.0';

try {
  await app.listen({ port, host });
} catch (error) {
  app.log.error(error);
  process.exitCode = 1;
}

const shutdown = async () => {
  await app.close();
  await closeDatabase();
};

process.once('SIGINT', () => void shutdown());
process.once('SIGTERM', () => void shutdown());
