# 1. Usa a imagem oficial do n8n como base
FROM docker.n8n.io/n8nio/n8n

# 2. Define o usuário como root para ter permissão de copiar arquivos
USER root

# 3. Cria as pastas de destino (caso não existam)
RUN mkdir -p /home/node/workflows
RUN mkdir -p /home/node/prompt

# 4. Copia seus arquivos locais para dentro da imagem
# Certifique-se que as pastas 'workflows' e 'prompt' existem no seu projeto
COPY ./workflows /home/node/workflows
COPY ./prompt /home/node/prompt

# 5. Ajusta as permissões para o usuário do n8n (node)
RUN chown -R node:node /home/node/workflows
RUN chown -R node:node /home/node/prompt

# 6. Volta para o usuário padrão do n8n
USER node