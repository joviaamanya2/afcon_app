import type { FastifyInstance } from 'fastify';
import { query } from '../db.js';
import { defaultQualifiers } from '../qualifiers.js';

type QueryString = Record<string, string | undefined>;
type FilterDefinition = {
  parameter: string;
  sql: (placeholder: string) => string;
};
type CollectionDefinition = {
  from: string;
  select: string;
  orderBy: string;
  publishedColumn: string;
  filters?: FilterDefinition[];
};

const collections: Record<string, CollectionDefinition> = {
  competitions: {
    from: 'competitions c',
    select: 'c.*',
    orderBy: 'c.name ASC',
    publishedColumn: 'c.published',
  },
  matches: {
    from: `matches m
      LEFT JOIN competitions c ON c.id = m.competition_id
      LEFT JOIN teams home ON home.id = m.home_team_id
      LEFT JOIN teams away ON away.id = m.away_team_id
      LEFT JOIN venues v ON v.id = m.venue_id`,
    select: `m.*,
      c.name AS competition_name,
      home.name AS home_team,
      away.name AS away_team,
      v.name AS venue_name`,
    orderBy: 'm.kickoff_at ASC NULLS LAST',
    publishedColumn: 'm.published',
    filters: [
      {
        parameter: 'date',
        sql: (p) => `m.kickoff_at::date = ${p}::date`,
      },
      { parameter: 'status', sql: (p) => `m.status = ${p}` },
      {
        parameter: 'competitionId',
        sql: (p) => `m.competition_id::text = ${p}`,
      },
      {
        parameter: 'teamId',
        sql: (p) => `(m.home_team_id::text = ${p} OR m.away_team_id::text = ${p})`,
      },
    ],
  },
  teams: {
    from: 'teams t',
    select: 't.*',
    orderBy: 't.name ASC',
    publishedColumn: 't.published',
    filters: [
      {
        parameter: 'competitionId',
        sql: (p) => `t.competition_id::text = ${p}`,
      },
      { parameter: 'region', sql: (p) => `t.region ILIKE ${p}` },
    ],
  },
  players: {
    from: 'players p',
    select: 'p.*',
    orderBy: 'p.name ASC',
    publishedColumn: 'p.published',
    filters: [
      { parameter: 'teamId', sql: (p) => `p.team_id::text = ${p}` },
      {
        parameter: 'competitionId',
        sql: (p) => `p.competition_id::text = ${p}`,
      },
    ],
  },
  standings: {
    from: 'standings s LEFT JOIN teams t ON t.id = s.team_id',
    select: 's.*, t.name AS team_name',
    orderBy: 's.group_code ASC, s.position ASC',
    publishedColumn: 's.published',
    filters: [
      {
        parameter: 'competitionId',
        sql: (p) => `s.competition_id::text = ${p}`,
      },
      { parameter: 'group', sql: (p) => `s.group_code = ${p}` },
    ],
  },
  venues: {
    from: 'venues v',
    select: 'v.*',
    orderBy: 'v.name ASC',
    publishedColumn: 'v.published',
    filters: [{ parameter: 'city', sql: (p) => `v.city ILIKE ${p}` }],
  },
  news: {
    from: 'news_articles n',
    select: 'n.*',
    orderBy: 'n.published_at DESC NULLS LAST, n.updated_at DESC',
    publishedColumn: 'n.published',
    filters: [
      { parameter: 'category', sql: (p) => `n.category ILIKE ${p}` },
      { parameter: 'region', sql: (p) => `n.region ILIKE ${p}` },
    ],
  },
  events: {
    from: 'events e',
    select: 'e.*',
    orderBy: 'e.starts_at ASC NULLS LAST',
    publishedColumn: 'e.published',
    filters: [
      { parameter: 'city', sql: (p) => `e.city ILIKE ${p}` },
      { parameter: 'region', sql: (p) => `e.region ILIKE ${p}` },
    ],
  },
  media: {
    from: 'media_assets ma',
    select: 'ma.*',
    orderBy: 'ma.created_at DESC',
    publishedColumn: 'ma.published',
    filters: [
      { parameter: 'type', sql: (p) => `ma.media_type = ${p}` },
      { parameter: 'teamId', sql: (p) => `ma.team_id::text = ${p}` },
    ],
  },
  'match-events': {
    from: `match_events me
      LEFT JOIN teams t ON t.id = me.team_id
      LEFT JOIN players p ON p.id = me.player_id`,
    select: 'me.*, t.name AS team_name, p.name AS player_name',
    orderBy: 'me.minute ASC, me.added_time ASC',
    publishedColumn: 'me.published',
    filters: [{ parameter: 'matchId', sql: (p) => `me.match_id::text = ${p}` }],
  },
  lineups: {
    from: `lineups l
      LEFT JOIN teams t ON t.id = l.team_id
      LEFT JOIN players p ON p.id = l.player_id`,
    select: 'l.*, t.name AS team_name, p.name AS player_name',
    orderBy: 'l.team_id ASC, l.is_starting DESC, l.shirt_number ASC NULLS LAST',
    publishedColumn: 'l.published',
    filters: [
      { parameter: 'matchId', sql: (p) => `l.match_id::text = ${p}` },
      { parameter: 'teamId', sql: (p) => `l.team_id::text = ${p}` },
    ],
  },
  'match-statistics': {
    from: 'match_statistics ms',
    select: 'ms.*',
    orderBy: 'ms.statistic ASC',
    publishedColumn: 'ms.published',
    filters: [
      { parameter: 'matchId', sql: (p) => `ms.match_id::text = ${p}` },
    ],
  },
};

function likeValue(value: string) {
  return `%${value.trim()}%`;
}

export async function registerPublicRoutes(app: FastifyInstance) {
  app.get('/api/v1/qualifiers', async (_request, reply) => {
    try {
      const result = await query<{ payload: Record<string, unknown> }>(
        'SELECT payload FROM qualifier_content WHERE id = $1 AND published = TRUE LIMIT 1',
        ['afcon-pamoja-2027'],
      );
      const stored = result.rows[0]?.payload;
      return reply.send({ data: stored ?? defaultQualifiers });
    } catch (error) {
      if (error instanceof Error && error.message === 'database_not_configured') {
        return reply.send({ data: defaultQualifiers, source: 'bundled_default' });
      }
      app.log.error({ err: error }, 'Unable to load qualifiers');
      return reply.code(503).send({
        error: 'qualifiers_unavailable',
        message: 'Qualifying information is temporarily unavailable.',
      });
    }
  });

  app.get<{
    Params: { resource: string };
    Querystring: QueryString;
  }>('/api/v1/:resource', async (request, reply) => {
    const definition = collections[request.params.resource];
    if (!definition) {
      return reply.code(404).send({
        error: 'resource_not_found',
        message: 'This AFCON data collection does not exist.',
      });
    }

    if (!process.env.DATABASE_URL) return reply.send({ data: [] });

    const where = [`${definition.publishedColumn} = TRUE`];
    const values: unknown[] = [];
    for (const filter of definition.filters ?? []) {
      const raw = request.query[filter.parameter];
      if (!raw?.trim()) continue;
      if (filter.parameter === 'date' && !/^\d{4}-\d{2}-\d{2}$/.test(raw)) {
        return reply.code(400).send({
          error: 'invalid_date',
          message: 'Use YYYY-MM-DD for the match date.',
        });
      }
      const value = ['city', 'region', 'category'].includes(filter.parameter)
        ? likeValue(raw)
        : raw.trim();
      values.push(value);
      where.push(filter.sql(`$${values.length}`));
    }

    const parsedLimit = Number.parseInt(request.query.limit ?? '100', 10);
    const limit = Number.isFinite(parsedLimit)
      ? Math.min(Math.max(parsedLimit, 1), 200)
      : 100;
    values.push(limit);

    try {
      const result = await query(
        `SELECT ${definition.select}
         FROM ${definition.from}
         WHERE ${where.join(' AND ')}
         ORDER BY ${definition.orderBy}
         LIMIT $${values.length}`,
        values,
      );
      return reply.send({ data: result.rows });
    } catch (error) {
      app.log.error({ err: error, resource: request.params.resource }, 'Collection query failed');
      return reply.code(503).send({
        error: 'data_unavailable',
        message: 'AFCON data is temporarily unavailable.',
      });
    }
  });

  app.post<{ Body: { question?: string; language?: string } }>(
    '/api/v1/assistant/ask',
    async (request, reply) => {
      const question = request.body?.question?.trim();
      if (!question) {
        return reply.code(400).send({
          error: 'question_required',
          message: 'Enter a question for the AFCON assistant.',
        });
      }
      return reply.code(503).send({
        error: 'assistant_not_configured',
        message:
          'The AFCON assistant provider is not configured on this server yet.',
        language: request.body?.language ?? 'en',
      });
    },
  );

  app.post<{
    Body: {
      sourceLanguage?: string;
      targetLanguage?: string;
      audioFormat?: string;
    };
  }>('/api/v1/translation/sessions', async (request, reply) => {
    const { sourceLanguage = 'en', targetLanguage = 'lg' } = request.body ?? {};
    return reply.code(503).send({
      error: 'translation_not_configured',
      message:
        'Live voice translation is not configured. Add an approved speech provider to enable it.',
      sourceLanguage,
      targetLanguage,
    });
  });
}
