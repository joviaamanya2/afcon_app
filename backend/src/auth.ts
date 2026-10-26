import {
  createHash,
  randomBytes,
  scrypt as scryptCallback,
  timingSafeEqual,
} from 'node:crypto';
import { promisify } from 'node:util';
import type { FastifyInstance, FastifyRequest } from 'fastify';
import { pool, query } from './db.js';

const scrypt = promisify(scryptCallback);
const sessionTtl = '7 days';

function hashToken(token: string) {
  return createHash('sha256').update(token).digest('hex');
}

async function hashPassword(password: string) {
  const salt = randomBytes(16);
  const key = (await scrypt(password, salt, 64)) as Buffer;
  return `${salt.toString('hex')}:${key.toString('hex')}`;
}

async function passwordMatches(password: string, stored: string) {
  const [saltHex, keyHex] = stored.split(':');
  if (!saltHex || !keyHex) return false;
  const expected = Buffer.from(keyHex, 'hex');
  const actual = (await scrypt(password, Buffer.from(saltHex, 'hex'), expected.length)) as Buffer;
  return expected.length === actual.length && timingSafeEqual(expected, actual);
}

async function issueSession(userId: string) {
  const token = randomBytes(32).toString('base64url');
  await query(
    `INSERT INTO dashboard_sessions (user_id, token_hash, expires_at)
     VALUES ($1, $2, now() + interval '${sessionTtl}')`,
    [userId, hashToken(token)],
  );
  return token;
}

export async function sessionUser(request: FastifyRequest) {
  const token = request.headers.authorization?.match(/^Bearer\s+(.+)$/i)?.[1];
  if (!token) return null;
  const result = await query<{
    id: string;
    email: string;
    display_name: string;
    role: string;
  }>(
    `SELECT u.id, u.email, u.display_name, u.role
     FROM dashboard_sessions s
     JOIN dashboard_users u ON u.id = s.user_id
     WHERE s.token_hash = $1 AND s.expires_at > now()
     LIMIT 1`,
    [hashToken(token)],
  );
  return result.rows[0] ?? null;
}

export async function registerAuthRoutes(app: FastifyInstance) {
  app.get('/api/v1/auth/status', async (_request, reply) => {
    const result = await query<{ count: string }>(
      'SELECT count(*)::text AS count FROM dashboard_users',
    );
    return reply.send({ data: { registrationOpen: result.rows[0]?.count === '0' } });
  });

  app.post<{
    Body: { name?: string; email?: string; password?: string };
  }>('/api/v1/auth/register', async (request, reply) => {
    const name = request.body?.name?.trim();
    const email = request.body?.email?.trim().toLowerCase();
    const password = request.body?.password ?? '';
    if (!name || !email || !/^\S+@\S+\.\S+$/.test(email) || password.length < 12) {
      return reply.code(400).send({
        error: 'invalid_registration',
        message: 'Enter a valid name and email, and use a password with at least 12 characters.',
      });
    }
    if (!pool) throw new Error('database_not_configured');

    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      await client.query('LOCK TABLE dashboard_users IN EXCLUSIVE MODE');
      const count = await client.query<{ count: string }>(
        'SELECT count(*)::text AS count FROM dashboard_users',
      );
      if (count.rows[0]?.count !== '0') {
        await client.query('ROLLBACK');
        return reply.code(403).send({
          error: 'registration_closed',
          message: 'The owner account is already set up. Ask the dashboard owner to create an account for you.',
        });
      }
      const passwordHash = await hashPassword(password);
      const inserted = await client.query<{ id: string; email: string; display_name: string; role: string }>(
        `INSERT INTO dashboard_users (email, display_name, password_hash, role)
         VALUES ($1, $2, $3, 'owner')
         RETURNING id, email, display_name, role`,
        [email, name, passwordHash],
      );
      const user = inserted.rows[0];
      const rawToken = randomBytes(32).toString('base64url');
      await client.query(
        `INSERT INTO dashboard_sessions (user_id, token_hash, expires_at)
         VALUES ($1, $2, now() + interval '7 days')`,
        [user.id, hashToken(rawToken)],
      );
      await client.query('COMMIT');
      return reply.code(201).send({ data: { user, token: rawToken } });
    } catch (error) {
      await client.query('ROLLBACK').catch(() => undefined);
      throw error;
    } finally {
      client.release();
    }
  });

  app.post<{
    Body: { email?: string; password?: string };
  }>('/api/v1/auth/login', async (request, reply) => {
    const email = request.body?.email?.trim().toLowerCase();
    const password = request.body?.password ?? '';
    if (!email || !password) {
      return reply.code(400).send({ error: 'credentials_required', message: 'Enter your email and password.' });
    }
    const result = await query<{
      id: string;
      email: string;
      display_name: string;
      role: string;
      password_hash: string;
    }>(
      `SELECT id, email, display_name, role, password_hash
       FROM dashboard_users WHERE email = $1 LIMIT 1`,
      [email],
    );
    const user = result.rows[0];
    if (!user || !(await passwordMatches(password, user.password_hash))) {
      return reply.code(401).send({ error: 'invalid_credentials', message: 'Email or password is incorrect.' });
    }
    const token = await issueSession(user.id);
    return reply.send({
      data: {
        token,
        user: { id: user.id, email: user.email, display_name: user.display_name, role: user.role },
      },
    });
  });

  app.get('/api/v1/auth/me', async (request, reply) => {
    const user = await sessionUser(request);
    if (!user) return reply.code(401).send({ error: 'session_expired', message: 'Sign in again to continue.' });
    return { data: user };
  });

  app.post('/api/v1/auth/logout', async (request, reply) => {
    const token = request.headers.authorization?.match(/^Bearer\s+(.+)$/i)?.[1];
    if (token) {
      await query('DELETE FROM dashboard_sessions WHERE token_hash = $1', [hashToken(token)]);
    }
    return reply.send({ data: { loggedOut: true } });
  });
}
