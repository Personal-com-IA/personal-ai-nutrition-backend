-- Tabela de Usuários
CREATE TABLE users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    username TEXT UNIQUE NOT NULL, -- Ex: 'gabriel_dev'
    current_weight DECIMAL(5,2),
    goal_weight DECIMAL(5,2),
    daily_calories_target INT DEFAULT 2000,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de Logs de Alimentação (Saída do Agente 1)
CREATE TABLE food_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    raw_text TEXT NOT NULL,       -- O que veio do front: "2 ovos"
    calories INT,                 -- Calculado pelo Llama
    protein INT,
    carbs INT,
    fat INT,
    processed_json JSONB,         -- Guarda o JSON completo do Llama por segurança
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- NOVA TABELA: Estado do Treino (Para o Agente de Estados)
CREATE TABLE workout_state (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) NOT NULL UNIQUE, -- 1 estado por usuário
    current_state TEXT DEFAULT 'IDLE',       -- Ex: 'ASKING_GOAL', 'LOGGING_SET'
    context JSONB DEFAULT '{}'::JSONB,       -- Memória do contexto atual (ex: exercício atual)
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ÍNDICES DE PERFORMANCE (Essencial para buscas rápidas pelo ID do usuário)
CREATE INDEX idx_food_logs_user ON food_logs(user_id);
CREATE INDEX idx_workout_state_user ON workout_state(user_id);

-- Inserir um usuário de teste (para você usar esse ID no Postman/Front)
-- COPIE O ID GERADO APÓS RODAR ISSO
INSERT INTO users (username, current_weight) VALUES ('usuario_teste', 80.0) RETURNING id;
