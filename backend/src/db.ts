import pg, { type QueryResultRow } from 'pg';

const { Pool } = pg;
const connectionString = process.env.DATABASE_URL;

export const pool = connectionString
  ? new Pool({
      connectionString,
      max: 10,
      idleTimeoutMillis: 30_000,
      connectionTimeoutMillis: 5_000,
    })
  : null;

export async function query<T extends QueryResultRow = QueryResultRow>(
  text: string,
  values: unknown[] = [],
) {
  if (!pool) throw new Error('database_not_configured');
  return pool.query<T>(text, values);
}

export async function closeDatabase() {
  await pool?.end();
}
