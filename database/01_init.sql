-- =================================================================
-- PROJETO IA 2025.1 - SCHEMA DE BANCO DE DADOS (PostgreSQL)
-- =================================================================

-- 0. EXTENSÕES
-- Habilita funções de criptografia e geração de UUIDs randômicos
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. LIMPEZA DE AMBIENTE (DDL)
-- Remove tabelas antigas para garantir uma instalação limpa
DROP TABLE IF EXISTS public.ai_learning CASCADE;
DROP TABLE IF EXISTS public.workout_logs CASCADE;
DROP TABLE IF EXISTS public.workout_plans CASCADE;
DROP TABLE IF EXISTS public.user_preferences CASCADE;
DROP TABLE IF EXISTS public.food_logs CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- =================================================================
-- 2. DEFINIÇÃO DAS TABELAS (SCHEMA)
-- =================================================================

-- TABELA: USERS
-- Entidade central para integridade referencial
CREATE TABLE public.users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    username TEXT UNIQUE NOT NULL, 
    current_weight DECIMAL(5,2),
    goal_weight DECIMAL(5,2),
    daily_calories_target INT DEFAULT 2000,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- TABELA: FOOD_LOGS
-- Histórico de alimentação processado pelo Agente Nutricional
CREATE TABLE public.food_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE, 
    raw_text TEXT NOT NULL,       -- Input original do usuário
    calories INT,                 
    protein DECIMAL(10,2),        
    carbs DECIMAL(10,2),          
    fat DECIMAL(10,2),            
    processed_json JSONB,         -- Output estruturado da LLM
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- TABELA: USER_PREFERENCES (ESTADO)
-- Armazena o "Current State" do usuário para o Agente Baseado em Estados.
-- Utiliza JSONB para flexibilidade em listas de exclusão e equipamentos.
CREATE TABLE public.user_preferences (
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL PRIMARY KEY, 
    goal TEXT,                          
    injuries TEXT,                      
    disliked_exercises JSONB DEFAULT '[]'::JSONB, 
    disliked_foods JSONB DEFAULT '[]'::JSONB,     
    available_equipment JSONB DEFAULT '["Peso do corpo"]'::JSONB, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- TABELA: WORKOUT_PLANS (PLANEJAMENTO)
-- Armazena a saída estruturada do Agente Planner (Objetivos).
CREATE TABLE public.workout_plans (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL, 
    split_type TEXT,                
    current_day TEXT,               
    plan_structure JSONB,           -- JSON contendo a estratégia de longo prazo (Chain of Thought)
    active BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- TABELA: WORKOUT_LOGS
-- Registro de execução de tarefas e feedback imediato.
CREATE TABLE public.workout_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL, 
    workout_day TEXT,               
    exercises_performed JSONB,   
    calories_burned INT,          
    feedback TEXT,                  
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- TABELA: AI_LEARNING (MEMÓRIA EPISÓDICA)
-- Componente crítico para o Agente que Aprende (Requisito 2.4).
-- Armazena episódios negativos para injetar no contexto futuro (RAG simplificado).
CREATE TABLE public.ai_learning (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    topic TEXT DEFAULT 'Feedback Negativo', 
    bad_experience TEXT NOT NULL,    -- O fato aprendido (ex: "Dor no joelho com agachamento")
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =================================================================
-- 3. DADOS DE SEED (PARA TESTES AUTOMATIZADOS)
-- =================================================================

-- Insere usuários padrão para validação dos fluxos via cURL.
-- O ID 'fe1e80c2...' é utilizado nos scripts de teste da documentação.
INSERT INTO public.users (id, username, current_weight) 
VALUES 
('65239ade-c15e-4044-8f6e-423ea91809ae', 'usuario_demo_1', 80.0),
('fe1e80c2-34d1-4edb-a140-875c1c8cfa00', 'usuario_demo_2', 72.0)
ON CONFLICT (id) DO NOTHING;