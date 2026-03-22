# Express + TypeScript + Prisma API

REST API built with Express 5, TypeScript, and Prisma ORM (PostgreSQL).

## Prerequisites

- Node.js 20+
- PostgreSQL (local or hosted)

## Setup

1. Install dependencies:

   ```bash
   npm install
   ```

2. Configure environment:

   ```bash
   cp .env.example .env
   ```

   Set `DATABASE_URL` to your PostgreSQL connection string and optional `PORT` (defaults to `3000`).

3. Create the database schema and generate the Prisma client:

   ```bash
   npx prisma migrate dev --name init
   npx prisma generate
   ```

## Scripts

| Command        | Description                          |
| -------------- | ------------------------------------ |
| `npm run dev`  | Run in development with `ts-node-dev` |
| `npm run build`| Compile TypeScript to `dist/`        |
| `npm start`    | Run compiled app (`node dist/server.js`) |

## API

| Method | Path       | Description        |
| ------ | ---------- | ------------------ |
| GET    | `/health`  | Health check       |
| GET    | `/users`   | List users         |
| POST   | `/users`   | Create user (JSON: `email`, optional `name`) |

Example:

```bash
curl http://localhost:3000/health
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","name":"Ada"}'
```

## Docker

Build and run (set `DATABASE_URL` in the environment at runtime, e.g. via your host or orchestrator):

```bash
docker build -t express-ts-prisma-api .
docker run -p 3000:3000 -e DATABASE_URL="postgresql://..." express-ts-prisma-api
```

Apply migrations against the deployment database:

```bash
npx prisma migrate deploy
```

## Deployment notes

- **Railway / similar:** provide `DATABASE_URL` and `PORT`. Run `npx prisma migrate deploy` after deploy or as a release step so tables exist before traffic hits the app.
- **CI:** `.github/workflows/deploy.yml` runs install, `prisma generate`, and `npm run build` on pushes to `main`.

## Project layout

```
src/
  app.ts
  server.ts
  prisma/client.ts
  routes/
  controllers/
prisma/
  schema.prisma
```

Prisma is pinned to **v6** so the client matches the classic `PrismaClient` setup from typical Express + Prisma tutorials. Upgrading to Prisma 7 requires schema and client changes (driver adapters, config).
