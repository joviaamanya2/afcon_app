import type { FastifyInstance } from 'fastify';
import { sessionUser } from '../auth.js';
import { query } from '../db.js';

const resources = {
  competitions: { table: 'competitions', columns: ['name','season','format','starts_on','ends_on','source','metadata','published'] },
  teams: { table: 'teams', columns: ['competition_id','name','short_name','region','country_code','coach','crest_url','source','published'] },
  players: { table: 'players', columns: ['team_id','competition_id','name','position','shirt_number','date_of_birth','club','caps','photo_url','statistics','source','published'] },
  matches: { table: 'matches', columns: ['competition_id','home_team_id','away_team_id','venue_id','kickoff_at','status','home_score','away_score','halftime_home_score','halftime_away_score','extra_time_home_score','extra_time_away_score','penalties_home_score','penalties_away_score','stage','group_code','source','last_updated','published'] },
  standings: { table: 'standings', columns: ['competition_id','group_code','team_id','position','played','won','drawn','lost','goals_for','goals_against','goal_difference','points','source','published'] },
  venues: { table: 'venues', columns: ['name','city','country','capacity','latitude','longitude','address','accessibility','transport','source','published'] },
  news: { table: 'news_articles', columns: ['title','category','summary','body','author','source','source_url','image_url','image_rights','region','published_at','published'] },
  events: { table: 'events', columns: ['title','description','city','region','starts_at','ends_at','venue_name','booking_url','organizer','source','published'] },
  media: { table: 'media_assets', columns: ['team_id','title','description','media_type','image_url','playback_url','language','captions_url','rights_territory','rights_ends_at','source','published'] },
  'match-events': { table: 'match_events', columns: ['match_id','team_id','player_id','event_type','minute','added_time','detail','published'] },
  lineups: { table: 'lineups', columns: ['match_id','team_id','player_id','position','shirt_number','is_starting','published'] },
  'match-statistics': { table: 'match_statistics', columns: ['match_id','statistic','home_value','away_value','published'] },
  qualifiers: { table: 'qualifier_content', columns: ['id','payload','published'] },
} as const;

type ResourceName = keyof typeof resources;
type Params = { resource: string; id?: string };

function cleanBody(body: unknown, columns: readonly string[]) {
  if (!body || typeof body !== 'object' || Array.isArray(body)) return null;
  const entries = Object.entries(body).filter(([key, value]) => columns.includes(key) && value !== undefined);
  return entries.length ? entries : null;
}

export async function registerAdminRoutes(app: FastifyInstance) {
  app.addHook('preHandler', async (request, reply) => {
    if (!request.url.startsWith('/api/v1/admin/')) return;
    const user = await sessionUser(request);
    if (!user) {
      return reply.code(401).send({ error: 'unauthorized', message: 'Sign in to manage dashboard records.' });
    }
  });

  app.get<{ Params: Params }>('/api/v1/admin/:resource', async (request, reply) => {
    const key = request.params.resource as ResourceName;
    const resource = resources[key];
    if (!resource) return reply.code(404).send({ error: 'resource_not_found' });
    const result = await query(`SELECT * FROM ${resource.table} ORDER BY updated_at DESC NULLS LAST LIMIT 500`);
    return { data: result.rows };
  });

  app.post<{ Params: Params; Body: Record<string, unknown> }>('/api/v1/admin/:resource', async (request, reply) => {
    const resource = resources[request.params.resource as ResourceName];
    if (!resource) return reply.code(404).send({ error: 'resource_not_found' });
    const entries = cleanBody(request.body, resource.columns);
    if (!entries) return reply.code(400).send({ error: 'valid_fields_required' });
    const columns = entries.map(([key]) => key);
    const values = entries.map(([, value]) => value);
    const result = await query(
      `INSERT INTO ${resource.table} (${columns.join(', ')}) VALUES (${values.map((_, i) => `$${i + 1}`).join(', ')}) RETURNING *`,
      values,
    );
    return reply.code(201).send({ data: result.rows[0] });
  });

  app.patch<{ Params: Params; Body: Record<string, unknown> }>('/api/v1/admin/:resource/:id', async (request, reply) => {
    const resource = resources[request.params.resource as ResourceName];
    if (!resource) return reply.code(404).send({ error: 'resource_not_found' });
    const entries = cleanBody(request.body, resource.columns);
    if (!entries) return reply.code(400).send({ error: 'valid_fields_required' });
    const values = entries.map(([, value]) => value);
    values.push(request.params.id);
    const assignments = entries.map(([key], i) => `${key} = $${i + 1}`);
    assignments.push('updated_at = now()');
    const result = await query(
      `UPDATE ${resource.table} SET ${assignments.join(', ')} WHERE id::text = $${values.length} RETURNING *`,
      values,
    );
    if (!result.rows[0]) return reply.code(404).send({ error: 'record_not_found' });
    return { data: result.rows[0] };
  });

  app.delete<{ Params: Params }>('/api/v1/admin/:resource/:id', async (request, reply) => {
    const resource = resources[request.params.resource as ResourceName];
    if (!resource) return reply.code(404).send({ error: 'resource_not_found' });
    const result = await query(`DELETE FROM ${resource.table} WHERE id::text = $1 RETURNING id`, [request.params.id]);
    if (!result.rows[0]) return reply.code(404).send({ error: 'record_not_found' });
    return { data: { id: result.rows[0].id, deleted: true } };
  });
}
