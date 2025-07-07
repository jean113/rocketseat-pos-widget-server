# INDICA QUAL IAMGEMVC VAI USAR
FROM node:24.3.0 AS base

# EXECUTA COMANDO
RUN npm i -g pnpm

FROM base AS dependencies

# TUDO QUE VAI ACONTECER A PARTIR DESTA LINHA SERÁ FEITA NESTE CAMINHO - BOA PRÁTICA
WORKDIR /usr/src/app

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile

FROM base AS build

WORKDIR /usr/src/app

# CÓPIA TUDO O QUE VC ESPECIFICOU PARA O CONTAINER
COPY . .
COPY --from=dependencies /usr/src/app/node_modules ./node_modules

RUN pnpm build
# descart as dev dependencia
RUN pnpm prune --prod

FROM node:20 AS deploy

USER 1000

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/package.json ./package.json

# cria variaveis de ambiente no .env DENTRO DO CONTAINER
ENV CLOUDFLARE_ACCESS_KEY_ID="#"
ENV CLOUDFLARE_SECRET_ACCESS_KEY="#"
ENV CLOUDFLARE_BUCKET="#"
ENV CLOUDFLARE_ACCOUNT_ID="#"
ENV CLOUDFLARE_PUBLIC_URL="http://localhost:3333"

# QUAL PORTA SERÁ EXECUTADO
EXPOSE 3333

#comando que vai segurar a execução do nosso container
CMD ["dist/server.js"]