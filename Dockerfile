FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

RUN npx prisma generate
RUN npm run build

EXPOSE 3000

# Apply migrations to the linked DB (e.g. Railway Postgres), then start the API
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/server.js"]
