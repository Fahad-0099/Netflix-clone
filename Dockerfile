FROM node:20.17.0 AS builder

WORKDIR /app

# Accept the API key before running the build step to break cache if the key changes
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL=https://themoviedb.org

COPY package.json yarn.lock ./
RUN yarn config set network-timeout 600000 -g
RUN yarn install

COPY . .
RUN yarn build

FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*

COPY --from=builder /app/dist .
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
ENTRYPOINT ["nginx","-g","daemon off;"]
