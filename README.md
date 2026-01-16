# 🍎 Saúde IA Backend

> Uma API de backend inteligente que utiliza **Llama 3 (via Groq)** e **n8n** para processar linguagem natural e registrar dados nutricionais automaticamente no **Supabase**.

![n8n](https://img.shields.io/badge/Orchestration-n8n-red?style=flat&logo=n8n)
![Supabase](https://img.shields.io/badge/Database-Supabase-green?style=flat&logo=supabase)
![Docker](https://img.shields.io/badge/Deploy-Docker-blue?style=flat&logo=docker)
![AI Model](https://img.shields.io/badge/AI-Llama%203.3-purple?style=flat)

## 🏗️ Arquitetura

O sistema funciona como um pipeline de ETL (Extract, Transform, Load) alimentado por IA:

1.  **Ingestão (Webhook):** Recebe input natural (ex: "Comi 2 ovos e café").
2.  **Agente AI (Llama 3):** O `system_prompt.txt` define a persona do LLM para estruturar dados não estruturados (JSON estrito).
3.  **Processamento:** Normaliza os dados e calcula totais via JavaScript.
4.  **Persistência:** Salva os logs na tabela `food_logs` do Supabase.

## 📂 Estrutura do Projeto

```bash
personal-ai-backend/
├── database/
│   └── 01_init.sql          # Schema do Banco de Dados
├── prompt/
│   └── system_prompt.txt # Engenharia de Prompt (System Role)
├── workflows/
│   └── main_workflow.json   # Workflow Auto-importável
├── .env.example             # Modelo das variáveis de ambiente
└── docker-compose.yml       # Orquestração

## 🔧 Troubleshooting (Solução de Problemas)

Se após rodar o `docker compose up`, o workflow não aparecer automaticamente na lista:

1.  Isso pode ocorrer devido a permissões de pasta no Windows/Linux.
2.  Para resolver, execute o comando de importação manual:

```bash
docker compose exec n8n n8n import:workflow --input=/home/node/workflows/main_workflow.json
