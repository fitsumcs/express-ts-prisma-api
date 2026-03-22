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
   npx prisma migrate dev
   npx prisma generate
   ```

   The repo includes an initial migration under `prisma/migrations/`. If you prefer Docker Compose for Postgres, start the DB first (`docker compose up -d db`) and point `DATABASE_URL` at it before running the commands above.

## Scripts

| Command        | Description                          |
| -------------- | ------------------------------------ |
| `npm run dev`  | Run in development with `ts-node-dev` |
| `npm run build`| Compile TypeScript to `dist/`        |
| `npm start`    | Run compiled app (`node dist/server.js`) |
| `npm run db:seed` | Insert/update example user (`demo@example.com`) via `prisma/seed.js` |

After migrations, you can seed locally so `GET /users` returns one user:

```bash
npm run db:seed
```

Docker and Railway builds run **migrate → seed → server** automatically.

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

### Docker Compose (app + PostgreSQL)

Start the API and database together. The app waits for Postgres to be healthy, runs `prisma migrate deploy`, then starts the server.

```bash
docker compose up --build
```

- **API:** http://localhost:3000  
- **Postgres:** `localhost:5432`, user `postgres`, password `postgres`, database `mydb`  

If port `5432` is already used on your machine, change the host mapping in `docker-compose.yml` (for example `"5433:5432"` under `db.ports`).

**Database only** (run the app on the host with `npm run dev`):

```bash
docker compose up -d db
```

Use `DATABASE_URL="postgresql://postgres:postgres@localhost:5432/mydb"` in `.env` (adjust the port if you changed the mapping).

## Deployment notes

- **Railway / similar:** set `DATABASE_URL` (from the platform’s Postgres) and `PORT`. The **Dockerfile** runs `npx prisma migrate deploy` before `node dist/server.js`, so the schema is applied on each deploy. If you ever deploy without that image (for example Nixpacks only), run `npx prisma migrate deploy` manually against production or add a release command.
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
  migrations/
  seed.js
docker-compose.yml
```

Prisma is pinned to **v6** so the client matches the classic `PrismaClient` setup from typical Express + Prisma tutorials. Upgrading to Prisma 7 requires schema and client changes (driver adapters, config).
