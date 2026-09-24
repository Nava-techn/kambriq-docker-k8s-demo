FROM node:26-bookworm-slim

RUN npm install -g pnpm

WORKDIR /usr/src/app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY prisma ./prisma

RUN pnpm install

COPY . .

RUN pnpm build

EXPOSE 3000

CMD ["node", "dist/apps/api/main.js"]
