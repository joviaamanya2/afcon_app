CREATE TABLE IF NOT EXISTS competitions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  season text,
  format text,
  starts_on date,
  ends_on date,
  source text,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  published boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS teams (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  competition_id uuid REFERENCES competitions(id) ON DELETE SET NULL,
  name text NOT NULL,
  short_name text,
  region text,
  country_code char(3),
  coach text,
  crest_url text,
  source text,
  published boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS players (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id uuid REFERENCES teams(id) ON DELETE SET NULL,
  competition_id uuid REFERENCES competitions(id) ON DELETE SET NULL,
  name text NOT NULL,
  position text,
  shirt_number integer,
  date_of_birth date,
  club text,
  caps integer,
  photo_url text,
  statistics jsonb NOT NULL DEFAULT '{}'::jsonb,
  source text,
  published boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS venues (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  city text,
  country text,
  capacity integer,
  latitude double precision,
  longitude double precision,
  address text,
  accessibility text,
  transport text,
  source text,
  published boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS matches (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  competition_id uuid REFERENCES competitions(id) ON DELETE SET NULL,
  home_team_id uuid REFERENCES teams(id) ON DELETE SET NULL,
  away_team_id uuid REFERENCES teams(id) ON DELETE SET NULL,
  venue_id uuid REFERENCES venues(id) ON DELETE SET NULL,
  kickoff_at timestamptz,
  status text NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled','live','finished','postponed','cancelled')),
  home_score integer,
  away_score integer,
  halftime_home_score integer,
  halftime_away_score integer,
  extra_time_home_score integer,
  extra_time_away_score integer,
  penalties_home_score integer,
  penalties_away_score integer,
  stage text,
  group_code text,
  source text,
  last_updated timestamptz,
  published boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS standings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  competition_id uuid NOT NULL REFERENCES competitions(id) ON DELETE CASCADE,
  group_code text NOT NULL,
  team_id uuid NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  position integer NOT NULL,
  played integer NOT NULL DEFAULT 0,
  won integer NOT NULL DEFAULT 0,
  drawn integer NOT NULL DEFAULT 0,
  lost integer NOT NULL DEFAULT 0,
  goals_for integer NOT NULL DEFAULT 0,
  goals_against integer NOT NULL DEFAULT 0,
  goal_difference integer NOT NULL DEFAULT 0,
  points integer NOT NULL DEFAULT 0,
  source text,
  published boolean NOT NULL DEFAULT false,
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (competition_id, group_code, team_id)
);

CREATE TABLE IF NOT EXISTS news_articles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  category text,
  summary text,
  body text,
  author text,
  source text,
  source_url text,
  image_url text,
  image_rights text,
  region text,
  published_at timestamptz,
  published boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  city text,
  region text,
  starts_at timestamptz,
  ends_at timestamptz,
  venue_name text,
  booking_url text,
  organizer text,
  source text,
  published boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS media_assets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id uuid REFERENCES teams(id) ON DELETE SET NULL,
  title text NOT NULL,
  description text,
  media_type text NOT NULL DEFAULT 'image',
  image_url text,
  playback_url text,
  language text,
  captions_url text,
  rights_territory text,
  rights_ends_at timestamptz,
  source text,
  published boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS match_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id uuid NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  team_id uuid REFERENCES teams(id) ON DELETE SET NULL,
  player_id uuid REFERENCES players(id) ON DELETE SET NULL,
  event_type text NOT NULL,
  minute integer,
  added_time integer,
  detail text,
  published boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS lineups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id uuid NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  team_id uuid NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  player_id uuid NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  position text,
  shirt_number integer,
  is_starting boolean NOT NULL DEFAULT false,
  published boolean NOT NULL DEFAULT false,
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (match_id, player_id)
);

CREATE TABLE IF NOT EXISTS match_statistics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id uuid NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  statistic text NOT NULL,
  home_value numeric,
  away_value numeric,
  published boolean NOT NULL DEFAULT false,
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (match_id, statistic)
);

CREATE TABLE IF NOT EXISTS qualifier_content (
  id text PRIMARY KEY,
  payload jsonb NOT NULL,
  published boolean NOT NULL DEFAULT false,
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS matches_kickoff_idx ON matches (kickoff_at);
CREATE INDEX IF NOT EXISTS matches_status_idx ON matches (status);
CREATE INDEX IF NOT EXISTS standings_group_idx ON standings (competition_id, group_code, position);
CREATE INDEX IF NOT EXISTS news_published_idx ON news_articles (published, published_at DESC);
CREATE INDEX IF NOT EXISTS events_start_idx ON events (starts_at);

