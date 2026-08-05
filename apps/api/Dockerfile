FROM node:22-alpine AS build
WORKDIR /app
RUN corepack enable
COPY package.json ./
RUN pnpm install --frozen-lockfile=false --dangerously-allow-all-builds
COPY . .
RUN pnpm build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup -S nodejs && adduser -S nestjs -G nodejs
RUN corepack enable
COPY package.json ./
RUN pnpm install --prod --frozen-lockfile=false --dangerously-allow-all-builds
COPY --from=build --chown=nestjs:nodejs /app/dist ./dist
USER nestjs
EXPOSE 3001
CMD ["node", "dist/main.js"]
