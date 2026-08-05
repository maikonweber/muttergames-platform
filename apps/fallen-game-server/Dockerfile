FROM node:22-alpine AS build
WORKDIR /app
RUN corepack enable
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
COPY apps/fallen-game-server/package.json apps/fallen-game-server/
RUN pnpm install --filter @muttergames/fallen-game-server...
COPY apps/fallen-game-server apps/fallen-game-server
RUN pnpm --filter @muttergames/fallen-game-server build

FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/apps/fallen-game-server/dist ./dist
COPY --from=build /app/apps/fallen-game-server/package.json ./
COPY --from=build /app/node_modules ./node_modules
EXPOSE 4010/tcp 9001/udp
CMD ["node", "dist/main.js"]
