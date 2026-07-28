# Build Stage
FROM node:22 AS builder

WORKDIR /app

# Install git & cleanup cache
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# Clone Notesnook monorepo
RUN git clone --depth=1 https://github.com/streetwriters/notesnook.git .

# Install dependencies (monorepo root)
RUN npm ci

# Accept build-time environment variables for server URLs
ARG NN_API_HOST
ARG NN_AUTH_HOST
ARG NN_SSE_HOST
ARG NN_MONOGRAPH_HOST

# Set environment variables for the build process
ENV NN_API_HOST=${NN_API_HOST}
ENV NN_AUTH_HOST=${NN_AUTH_HOST}
ENV NN_SSE_HOST=${NN_SSE_HOST}
ENV NN_MONOGRAPH_HOST=${NN_MONOGRAPH_HOST}

# Build just the web app
RUN npm run build:web

# Production Stage
FROM caddy:2.11

RUN rm -rf /usr/share/caddy/*

COPY --from=builder /app/apps/web/build /usr/share/caddy

COPY Caddyfile /etc/caddy/Caddyfile

EXPOSE 80
