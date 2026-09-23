-- ============================================================
-- Skate App - Datenbankschema (fuer die statische HTML/JS-Version)
-- Im Supabase SQL Editor ausfuehren.
-- ============================================================

-- ---------- profiles ----------
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  avatar_url text,
  created_at timestamptz not null default now()
);

alter table profiles enable row level security;

create policy "Profiles are readable by everyone"
  on profiles for select using (true);

create policy "Users can insert their own profile"
  on profiles for insert with check (auth.uid() = id);

create policy "Users can update their own profile"
  on profiles for update using (auth.uid() = id);

-- ---------- tricks ----------
create table if not exists tricks (
  id text primary key,
  name text not null,
  category text not null,
  difficulty smallint not null default 1,
  stance text not null default 'regular',
  aliases text[] not null default '{}'
);

alter table tricks enable row level security;

create policy "Tricks are readable by everyone"
  on tricks for select using (true);

-- ---------- game_rooms ----------
create table if not exists game_rooms (
  id uuid primary key default gen_random_uuid(),
  room_code text unique not null,
  mode text not null check (mode in ('SKATE', 'SK8')),
  status text not null default 'lobby' check (status in ('lobby', 'active', 'finished')),
  host_id uuid not null references profiles(id),
  created_at timestamptz not null default now()
);

alter table game_rooms enable row level security;

create policy "Game rooms are readable by everyone"
  on game_rooms for select using (true);

create policy "Authenticated users can create a room"
  on game_rooms for insert with check (auth.uid() = host_id);

create policy "Host can update their room"
  on game_rooms for update using (auth.uid() = host_id);

-- ---------- game_players ----------
create table if not exists game_players (
  id uuid primary key default gen_random_uuid(),
  game_id uuid not null references game_rooms(id) on delete cascade,
  profile_id uuid not null references profiles(id),
  player_order smallint not null check (player_order in (0, 1)),
  joined_at timestamptz not null default now(),
  unique (game_id, player_order),
  unique (game_id, profile_id)
);

alter table game_players enable row level security;

create policy "Game players are readable by everyone"
  on game_players for select using (true);

create policy "Users can join a room as themselves"
  on game_players for insert with check (auth.uid() = profile_id);

-- ---------- game_rounds ----------
create table if not exists game_rounds (
  id uuid primary key default gen_random_uuid(),
  game_id uuid not null references game_rooms(id) on delete cascade,
  round_number int not null,
  setter_id uuid not null references profiles(id),
  defender_id uuid not null references profiles(id),
  trick_id text not null references tricks(id),
  result text not null check (result in ('made', 'missed')),
  created_at timestamptz not null default now(),
  unique (game_id, round_number)
);

alter table game_rounds enable row level security;

create policy "Game rounds are readable by everyone"
  on game_rounds for select using (true);

create policy "Players can insert rounds for their own game"
  on game_rounds for insert
  with check (
    exists (
      select 1 from game_players gp
      where gp.game_id = game_rounds.game_id
        and gp.profile_id = auth.uid()
    )
    and auth.uid() in (setter_id, defender_id)
  );

-- ---------- skate_spots ----------
create table if not exists skate_spots (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  location_lat double precision,
  location_lng double precision,
  obstacles text[] not null default '{}',
  difficulty smallint not null default 1,
  created_by uuid references profiles(id),
  created_at timestamptz not null default now()
);

alter table skate_spots enable row level security;

create policy "Spots are readable by everyone"
  on skate_spots for select using (true);

create policy "Authenticated users can add a spot"
  on skate_spots for insert with check (auth.uid() = created_by);

-- ---------- Indizes ----------
create index if not exists idx_game_players_game_id on game_players(game_id);
create index if not exists idx_game_rounds_game_id on game_rounds(game_id, round_number);
create index if not exists idx_game_rooms_room_code on game_rooms(room_code);

-- ---------- Realtime ----------
alter publication supabase_realtime add table game_rounds;
alter publication supabase_realtime add table game_rooms;
alter publication supabase_realtime add table game_players;

-- ---------- Seed: Trick-Datenbank ----------
insert into tricks (id, name, category, difficulty, stance, aliases) values
  ('ollie', 'Ollie', 'flip', 1, 'regular', '{}'),
  ('kickflip', 'Kickflip', 'flip', 2, 'regular', '{"kick flip","kick-flip"}'),
  ('heelflip', 'Heelflip', 'flip', 2, 'regular', '{"heel flip"}'),
  ('varial_kickflip', 'Varial Kickflip', 'flip', 3, 'regular', '{"v-flip"}'),
  ('varial_heelflip', 'Varial Heelflip', 'flip', 3, 'regular', '{}'),
  ('tre_flip', 'Tre Flip', 'flip', 4, 'regular', '{"360 flip","360 kickflip"}'),
  ('hardflip', 'Hardflip', 'flip', 4, 'regular', '{}'),
  ('inward_heelflip', 'Inward Heelflip', 'flip', 4, 'regular', '{"inheel"}'),
  ('impossible', 'Impossible', 'flip', 4, 'regular', '{}'),
  ('nollie_kickflip', 'Nollie Kickflip', 'flip', 3, 'nollie', '{}'),
  ('fakie_kickflip', 'Fakie Kickflip', 'flip', 3, 'fakie', '{}'),
  ('switch_kickflip', 'Switch Kickflip', 'flip', 4, 'switch', '{}'),
  ('shuvit', 'Shuvit', 'shuvit', 1, 'regular', '{"shove it","shove-it"}'),
  ('pop_shuvit', 'Pop Shuvit', 'shuvit', 2, 'regular', '{"pop shove it"}'),
  ('fs_shuvit', 'FS Shuvit', 'shuvit', 2, 'regular', '{"frontside shuvit"}'),
  ('bs_shuvit', 'BS Shuvit', 'shuvit', 2, 'regular', '{"backside shuvit"}'),
  ('360_shuvit', '360 Shuvit', 'shuvit', 3, 'regular', '{"360 pop shuvit"}'),
  ('fs_180', 'Frontside 180', 'spin', 2, 'regular', '{"fs 180"}'),
  ('bs_180', 'Backside 180', 'spin', 2, 'regular', '{"bs 180"}'),
  ('fs_360', 'Frontside 360', 'spin', 3, 'regular', '{"fs 360"}'),
  ('bs_360', 'Backside 360', 'spin', 4, 'regular', '{"bs 360"}'),
  ('5050', '50-50', 'grind', 2, 'regular', '{"fifty fifty"}'),
  ('5_0', '5-0', 'grind', 2, 'regular', '{"five oh"}'),
  ('nosegrind', 'Nosegrind', 'grind', 3, 'regular', '{}'),
  ('smith_grind', 'Smith Grind', 'grind', 3, 'regular', '{}'),
  ('crooked_grind', 'Crooked Grind', 'grind', 3, 'regular', '{"crooks"}'),
  ('boardslide', 'Boardslide', 'slide', 2, 'regular', '{}'),
  ('lipslide', 'Lipslide', 'slide', 3, 'regular', '{}'),
  ('noseslide', 'Noseslide', 'slide', 3, 'regular', '{}'),
  ('tailslide', 'Tailslide', 'slide', 3, 'regular', '{}'),
  ('manual', 'Manual', 'manual', 1, 'regular', '{}'),
  ('nose_manual', 'Nose Manual', 'manual', 2, 'regular', '{}'),
  ('indy_grab', 'Indy Grab', 'grab', 2, 'regular', '{}'),
  ('melon_grab', 'Melon Grab', 'grab', 2, 'regular', '{"mute grab"}'),
  ('boneless', 'Boneless', 'other', 2, 'regular', '{}'),
  ('no_comply', 'No Comply', 'other', 2, 'regular', '{"no-comply"}')
on conflict (id) do nothing;
