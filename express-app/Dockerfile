# Dockerfile multi-stage, smaller final image
# 1) build stage 

FROM node:20-alpine AS builder

WORKDIR /app

# Copy manifest first to leverage Docker cache
COPY package*.json ./
# prefer npm ci for reproducible installs, ensures package-lock.json is committed

RUN npm ci --only=production 

COPY . .

# 2) runtime stage

FROM node:20-alpine

WORKDIR /app

ENV NODE_ENV=production

# create non-root user to run the app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# COPY from builder stage
COPY --from=builder /app /app

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

# healthcheck used by some runners 
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \
 CMD wget -qO- http://localhost:3000/health || exit 1

CMD [ "node", "index.js" ]