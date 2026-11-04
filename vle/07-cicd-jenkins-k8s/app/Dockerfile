# Multi-stage, non-root, small image
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

FROM node:20-alpine
ENV NODE_ENV=production
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY src ./src
USER node
EXPOSE 3000
HEALTHCHECK --interval=15s --timeout=3s CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "src/server.js"]
