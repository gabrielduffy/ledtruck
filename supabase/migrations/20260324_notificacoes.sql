-- 1. ADICIONANDO CAMPOS DE TELEFONE
ALTER TABLE franqueados ADD COLUMN IF NOT EXISTS telefone TEXT;
ALTER TABLE perfis ADD COLUMN IF NOT EXISTS telefone TEXT;

-- 2. TABELA DE CONFIGURAÇÕES DE NOTIFICAÇÕES
CREATE TABLE IF NOT EXISTS configuracoes_notificacoes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  franqueado_id UUID REFERENCES franqueados(id) ON DELETE CASCADE,
  tipo TEXT NOT NULL, -- ex: 'painel_ligado', 'painel_desligado', 'campanha_90', 'campanha_100', 'relatorio_diario', 'sem_sinal'
  canal_email BOOLEAN DEFAULT TRUE,
  canal_whatsapp BOOLEAN DEFAULT TRUE,
  canal_interno BOOLEAN DEFAULT TRUE,
  email_assunto TEXT,
  email_corpo TEXT,
  whatsapp_corpo TEXT,
  ativo BOOLEAN DEFAULT TRUE,
  data_atualizacao TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(franqueado_id, tipo)
);

-- 3. TABELA DE LOGS DO SISTEMA
CREATE TABLE IF NOT EXISTS logs_sistema (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tipo TEXT NOT NULL, -- ex: 'email_enviado', 'whatsapp_enviado', 'falha_envio'
  canal TEXT NOT NULL, -- ex: 'email', 'whatsapp', 'interno', 'sistema'
  destinatario TEXT,
  status TEXT CHECK (status IN ('sucesso','falha','pendente')),
  mensagem TEXT,
  payload JSONB,
  franqueado_id UUID REFERENCES franqueados(id) ON DELETE SET NULL,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- Index para facilitar a limpeza cron e a busca
CREATE INDEX IF NOT EXISTS idx_logs_sistema_status_criado_em ON logs_sistema(status, criado_em);

-- 4. FUNÇÃO E TRIGGER PARA LIMPEZA DE LOGS (PG_CRON)
-- Cleanup semanal: Sucessos mantêm 60 dias, falhas mantêm 90 dias
SELECT cron.schedule(
  'limpeza_logs_semanal', 
  '0 3 * * 0', -- Todo domingo às 03:00 da manhã
  $$
    DELETE FROM logs_sistema WHERE status != 'falha' AND criado_em < NOW() - INTERVAL '60 days';
    DELETE FROM logs_sistema WHERE status = 'falha' AND criado_em < NOW() - INTERVAL '90 days';
  $$
);

-- 5. DEBOUNCE PARA NOTIFICAÇÕES DE CONEXÃO (LIGADO/DESLIGADO)
-- Tabela auxiliar para controlar o último aviso de mudança de status por carro
CREATE TABLE IF NOT EXISTS controle_envio_status (
    carro_id UUID PRIMARY KEY,
    ultimo_status_notificado TEXT,
    ultimo_envio TIMESTAMPTZ
);

-- Regra de Debounce (5 minutos): A ser invocada pelas triggers de EVENTOS
CREATE OR REPLACE FUNCTION notificar_status_painel() RETURNS TRIGGER AS $$
DECLARE
    v_ultimo_envio TIMESTAMPTZ;
    v_ultimo_status TEXT;
    v_tempo_passado INTERVAL;
BEGIN
    -- Verifica o status atual
    SELECT ultimo_envio, ultimo_status_notificado INTO v_ultimo_envio, v_ultimo_status
    FROM controle_envio_status WHERE carro_id = NEW.carro_id;

    -- Se é a mesma notificação, e passou menos de 5 min, cancela (debounce)
    IF v_ultimo_status = NEW.tipo AND (NOW() - v_ultimo_envio) < INTERVAL '5 minutes' THEN
        RETURN NEW;
    END IF;

    -- Caso contrário, atualiza a tabela de controle e prossegue com inserção webhook
    INSERT INTO controle_envio_status (carro_id, ultimo_status_notificado, ultimo_envio)
    VALUES (NEW.carro_id, NEW.tipo, NOW())
    ON CONFLICT (carro_id) DO UPDATE 
    SET ultimo_status_notificado = NEW.tipo, ultimo_envio = NOW();

    -- Faz chamada HTTP Edge Function (Asíncrona via pgsodium ou payload pra tabela pendente)
    -- Em ambiente Supabase, usa-se 'net.http_post' com url de webhook.
    -- Iremos focar nas chamadas a partir das aplicações ou trigger webhook hook.

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_eventos_status_painel
    AFTER INSERT ON eventos
    FOR EACH ROW
    WHEN (NEW.tipo IN ('ligou', 'desligou'))
    EXECUTE FUNCTION notificar_status_painel();

-- 6. RELATÓRIO DIÁRIO (PG_CRON AS 23H) - ENFILEIRAMENTO COM DELAY
-- O pg_cron chama a Edge Function de Relatório Diário, e ela resolverá os lotes de 10 c/ intervalo de 2s.
SELECT cron.schedule(
  'disparo_relatorio_23h',
  '0 23 * * *', -- Todos os dias às 23:00
  $$
    -- Efetua chamada ao Edge Function Master de relatórios diários.
    -- (Supondo ext http ativada para Supabase webhook)
    SELECT net.http_post(
        url:='https://lbgkzweqtdlqkmjhbkrq.supabase.co/functions/v1/relatorio-diario-worker',
        headers:='{"Content-Type": "application/json", "Authorization": "Bearer xxx"}'::jsonb
    );
  $$
);
