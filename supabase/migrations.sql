-- 1. perfis
create table perfis (
  id              uuid references auth.users(id) primary key,
  nome            text,
  role            text check (role in ('admin','franqueado','operador','anunciante')),
  franqueado_id   uuid
);

-- 2. franqueados
create table franqueados (
  id          uuid default gen_random_uuid() primary key,
  nome        text not null,
  cidade      text,
  estado      text,
  user_id     uuid references auth.users(id),
  ativo       boolean default true,
  criado_em   timestamptz default now()
);

-- 3. dispositivos
create table dispositivos (
  id               uuid default gen_random_uuid() primary key,
  numero_serie     text not null unique,
  mac_address      text unique,
  modelo           text default 'ESP32 DevKit v1',
  versao_firmware  text,
  carro_id         uuid,
  franqueado_id    uuid references franqueados(id),
  status           text check (status in ('estoque','instalado','manutencao','inativo')),
  instalado_em     timestamptz,
  criado_em       timestamptz default now()
);

-- 4. carros
create table carros (
  id              uuid default gen_random_uuid() primary key,
  codigo          text not null,
  veiculo         text not null,
  placa           text,
  cidade          text,
  franqueado_id   uuid references franqueados(id),
  operador_id     uuid references auth.users(id),
  dispositivo_id  uuid references dispositivos(id),
  ativo           boolean default true,
  criado_em       timestamptz default now()
);

-- 5. operadores
create table operadores (
  id              uuid default gen_random_uuid() primary key,
  nome            text,
  user_id         uuid references auth.users(id),
  franqueado_id   uuid references franqueados(id),
  criado_em       timestamptz default now()
);

-- 6. campanhas
create table campanhas (
  id                  uuid default gen_random_uuid() primary key,
  nome                text not null,
  anunciante_id       uuid references auth.users(id),
  franqueado_id       uuid references franqueados(id),
  horas_contratadas   integer not null,
  data_inicio         date,
  data_fim            date,
  carro_ids           uuid[],
  criado_em           timestamptz default now()
);

-- 7. eventos
create table eventos (
  id              uuid default gen_random_uuid() primary key,
  carro_id        uuid references carros(id),
  dispositivo_id  uuid references dispositivos(id),
  numero_serie    text references dispositivos(numero_serie),
  tipo            text check (tipo in ('ligou','desligou')),
  latitude        decimal(10,8),
  longitude       decimal(11,8),
  registrado_em   timestamptz default now()
);

-- 8. rastreamento
create table rastreamento (
  id              uuid default gen_random_uuid() primary key,
  carro_id        uuid references carros(id),
  dispositivo_id  uuid references dispositivos(id),
  latitude        decimal(10,8) not null,
  longitude       decimal(11,8) not null,
  velocidade_kmh  decimal(5,1),
  direcao_graus   decimal(5,1),
  registrado_em   timestamptz default now()
);

-- Retenção automática de 90 dias
-- Note: Requires pg_cron extension to be enabled in Supabase
select cron.schedule(
  'limpar-rastreamento-antigo',
  '0 3 * * 0',
  $$delete from rastreamento where registrado_em < now() - interval '90 days'$$
);

-- RLS — POLICIES:

-- perfis
alter table perfis enable row level security;
create policy "perfil proprio" on perfis
  for all using (auth.uid() = id);

-- franqueados
alter table franqueados enable row level security;
create policy "admin ve todos" on franqueados
  for all using (
    exists (select 1 from perfis where id = auth.uid() and role = 'admin')
  );
create policy "franqueado ve o seu" on franqueados
  for select using (user_id = auth.uid());

-- carros
alter table carros enable row level security;
create policy "admin ve todos" on carros
  for all using (
    exists (select 1 from perfis where id = auth.uid() and role = 'admin')
  );
create policy "franqueado ve os seus" on carros
  for all using (
    franqueado_id in (
      select id from franqueados where user_id = auth.uid()
    )
  );
create policy "operador ve os seus" on carros
  for select using (operador_id = auth.uid());

-- dispositivos
alter table dispositivos enable row level security;
create policy "admin ve todos" on dispositivos
  for all using (
    exists (select 1 from perfis where id = auth.uid() and role = 'admin')
  );
create policy "franqueado ve os seus" on dispositivos
  for select using (
    franqueado_id in (
      select id from franqueados where user_id = auth.uid()
    )
  );

-- operadores
alter table operadores enable row level security;
create policy "admin ve todos" on operadores
  for all using (
    exists (select 1 from perfis where id = auth.uid() and role = 'admin')
  );
create policy "franqueado ve os seus" on operadores
  for all using (
    franqueado_id in (
      select id from franqueados where user_id = auth.uid()
    )
  );

-- campanhas
alter table campanhas enable row level security;
create policy "admin ve todas" on campanhas
  for all using (
    exists (select 1 from perfis where id = auth.uid() and role = 'admin')
  );
create policy "franqueado ve as suas" on campanhas
  for all using (
    franqueado_id in (
      select id from franqueados where user_id = auth.uid()
    )
  );
create policy "anunciante ve a sua" on campanhas
  for select using (anunciante_id = auth.uid());

-- eventos
alter table eventos enable row level security;
create policy "admin ve todos" on eventos
  for all using (
    exists (select 1 from perfis where id = auth.uid() and role = 'admin')
  );
create policy "franqueado ve dos seus carros" on eventos
  for select using (
    carro_id in (
      select id from carros where franqueado_id in (
        select id from franqueados where user_id = auth.uid()
      )
    )
  );
create policy "anunciante ve dos carros da campanha" on eventos
  for select using (
    carro_id = any(
      select unnest(carro_ids) from campanhas
      where anunciante_id = auth.uid()
    )
  );

-- rastreamento
alter table rastreamento enable row level security;
create policy "admin ve todos" on rastreamento
  for all using (
    exists (select 1 from perfis where id = auth.uid() and role = 'admin')
  );
create policy "franqueado ve dos seus carros" on rastreamento
  for select using (
    carro_id in (
      select id from carros where franqueado_id in (
        select id from franqueados where user_id = auth.uid()
      )
    )
  );

-- Ativar Realtime nas tabelas eventos e rastreamento
-- Isso é feito via interface do Supabase ou via SQL:
alter publication supabase_realtime add table eventos;
alter publication supabase_realtime add table rastreamento;

-- 9. contratos
create table contratos (
  id                uuid default gen_random_uuid() primary key,
  franqueado_id     uuid references franqueados(id),
  valor_mensal      decimal(10,2) not null default 497.00,
  dia_vencimento    integer not null default 10,
  data_inicio       date not null,
  carencia_meses    integer default 0,
  carencia_ate      date,
  desconto_percent  decimal(5,2) default 0,
  desconto_ate      date,
  observacoes       text,
  ativo             boolean default true,
  criado_em         timestamptz default now()
);

-- 10. cobrancas
create table cobrancas (
  id              uuid default gen_random_uuid() primary key,
  contrato_id     uuid references contratos(id),
  franqueado_id   uuid references franqueados(id),
  mes_referencia  text not null,
  data_vencimento date not null,
  valor_original  decimal(10,2) not null,
  desconto        decimal(10,2) default 0,
  valor_final     decimal(10,2) not null,
  status          text check (status in (
                    'pendente','pago','atrasado',
                    'carencia','cancelado'
                  )) default 'pendente',
  data_pagamento  date,
  observacoes     text,
  criado_em       timestamptz default now()
);

-- RLS — POLICIES para financeiro (Admin tem acesso total, Franqueado apenas leitura do seu)
alter table contratos enable row level security;
create policy "admin gerencia contratos" on contratos
  for all using (exists (select 1 from perfis where id = auth.uid() and role = 'admin'));
create policy "franqueado ve seu contrato" on contratos
  for select using (franqueado_id in (select id from franqueados where user_id = auth.uid()));

alter table cobrancas enable row level security;
create policy "admin gerencia cobrancas" on cobrancas
  for all using (exists (select 1 from perfis where id = auth.uid() and role = 'admin'));
create policy "franqueado ve suas cobrancas" on cobrancas
  for select using (franqueado_id in (select id from franqueados where user_id = auth.uid()));
