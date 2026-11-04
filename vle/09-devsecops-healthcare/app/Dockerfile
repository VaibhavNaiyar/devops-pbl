# Hardened image: pinned base, multi-stage, prod deps only, non-root, read-only friendly
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

FROM node:20-alpine
RUN apk upgrade --no-cache
ENV NODE_ENV=production PORT=8080
WORKDIR /app
COPY --from=deps --chown=node:node /app/node_modules ./node_modules
COPY --chown=node:node src ./src
USER 1000
EXPOSE 8080
HEALTHCHECK --interval=15s --timeout=3s CMD ["wget", "-qO-", "http://localhost:8080/health"]
CMD ["node", "src/server.js"]
