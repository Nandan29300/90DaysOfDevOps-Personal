const express = require("express");
const { Client } = require("pg");
const { createClient } = require("redis");
const os = require("os");

const app = express();
const port = 3000;

const DATABASE_URL = process.env.DATABASE_URL;
const REDIS_HOST = process.env.REDIS_HOST || "redis";

const db = new Client({
  connectionString: DATABASE_URL,
});

const redis = createClient({
  url: `redis://${REDIS_HOST}:6379`,
});

redis.on("error", (err) => {
  console.error("Redis error:", err.message);
});


// Initialize PostgreSQL
async function initDb() {
  let attempts = 10;

  while (attempts > 0) {
    try {
      await db.connect();

      await db.query(`
        CREATE TABLE IF NOT EXISTS visits (
          id SERIAL PRIMARY KEY,
          count INTEGER NOT NULL
        );
      `);

      console.log("PostgreSQL connected.");
      return;
    } catch (error) {
      attempts--;

      console.log(
        `PostgreSQL not ready. Retrying... (${attempts} attempts left)`
      );

      if (attempts === 0) {
        throw error;
      }

      await new Promise((resolve) => setTimeout(resolve, 3000));
    }
  }
}


// Connect to Redis
async function initRedis() {
  await redis.connect();
  console.log("Redis connected.");
}


// Home page
app.get("/", async (req, res) => {
  try {
    const result = await db.query(
      "SELECT count FROM visits WHERE id = 1"
    );

    let count;

    if (result.rows.length > 0) {
      count = result.rows[0].count + 1;

      await db.query(
        "UPDATE visits SET count = $1 WHERE id = 1",
        [count]
      );
    } else {
      count = 1;

      await db.query(
        "INSERT INTO visits (id, count) VALUES (1, $1)",
        [count]
      );
    }

    await redis.set("last_visit", count);

    const cachedValue = await redis.get("last_visit");

    const hostname = os.hostname();

    res.send(`
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>Day 34 - Docker Compose</title>

  <style>
    * {
      box-sizing: border-box;
    }

    body {
      margin: 0;
      min-height: 100vh;
      font-family: Arial, sans-serif;
      background:
        radial-gradient(circle at top left, #243b55, transparent 40%),
        radial-gradient(circle at bottom right, #141e30, #0f172a);
      color: white;
      display: flex;
      justify-content: center;
      align-items: center;
      padding: 30px;
    }

    .container {
      width: 100%;
      max-width: 850px;
    }

    .card {
      background: rgba(255, 255, 255, 0.08);
      border: 1px solid rgba(255, 255, 255, 0.15);
      border-radius: 24px;
      padding: 40px;
      backdrop-filter: blur(15px);
      box-shadow: 0 25px 70px rgba(0, 0, 0, 0.35);
    }

    .header {
      text-align: center;
      margin-bottom: 35px;
    }

    .header h1 {
      margin: 0;
      font-size: 38px;
    }

    .header p {
      color: #aab7c4;
      margin-top: 10px;
    }

    .counter {
      text-align: center;
      margin: 30px 0;
    }

    .counter-value {
      font-size: 70px;
      font-weight: bold;
      color: #38bdf8;
    }

    .counter-label {
      color: #aab7c4;
      font-size: 16px;
    }

    .services {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 15px;
      margin-top: 30px;
    }

    .service {
      padding: 20px;
      border-radius: 16px;
      background: rgba(255, 255, 255, 0.06);
      text-align: center;
      border: 1px solid rgba(255, 255, 255, 0.08);
    }

    .service-icon {
      font-size: 32px;
      margin-bottom: 10px;
    }

    .service h3 {
      margin: 5px 0;
    }

    .status {
      display: inline-block;
      margin-top: 8px;
      padding: 5px 12px;
      border-radius: 20px;
      background: rgba(34, 197, 94, 0.15);
      color: #4ade80;
      font-size: 13px;
    }

    .info {
      margin-top: 30px;
      padding: 20px;
      border-radius: 16px;
      background: rgba(0, 0, 0, 0.2);
    }

    .info-row {
      display: flex;
      justify-content: space-between;
      padding: 8px 0;
      border-bottom: 1px solid rgba(255,255,255,0.08);
    }

    .info-row:last-child {
      border-bottom: none;
    }

    .label {
      color: #94a3b8;
    }

    .footer {
      text-align: center;
      margin-top: 25px;
      color: #64748b;
      font-size: 13px;
    }

    @media (max-width: 700px) {
      .services {
        grid-template-columns: 1fr;
      }

      .card {
        padding: 25px;
      }

      .header h1 {
        font-size: 28px;
      }
    }
  </style>
</head>

<body>

  <div class="container">

    <div class="card">

      <div class="header">
        <h1>🐳 Docker Compose</h1>
        <p>Day 34 — Multi-Container Application</p>
      </div>

      <div class="counter">
        <div class="counter-value">${count}</div>
        <div class="counter-label">Total Page Visits</div>
      </div>

      <div class="services">

        <div class="service">
          <div class="service-icon">🟢</div>
          <h3>Node.js</h3>
          <div class="status">● Running</div>
        </div>

        <div class="service">
          <div class="service-icon">🐘</div>
          <h3>PostgreSQL</h3>
          <div class="status">● Connected</div>
        </div>

        <div class="service">
          <div class="service-icon">⚡</div>
          <h3>Redis</h3>
          <div class="status">● Connected</div>
        </div>

      </div>

      <div class="info">

        <div class="info-row">
          <span class="label">Cached Value</span>
          <strong>${cachedValue}</strong>
        </div>

        <div class="info-row">
          <span class="label">Container</span>
          <strong>${hostname}</strong>
        </div>

        <div class="info-row">
          <span class="label">Application Port</span>
          <strong>3000</strong>
        </div>

        <div class="info-row">
          <span class="label">Architecture</span>
          <strong>Node + PostgreSQL + Redis</strong>
        </div>

      </div>

      <div class="footer">
        Running with Docker Compose 🚀
      </div>

    </div>

  </div>

</body>
</html>
    `);

  } catch (error) {
    console.error("Request error:", error.message);

    res.status(500).send(`
      <h1>Application Error</h1>
      <p>${error.message}</p>
    `);
  }
});


// Health endpoint
app.get("/health", async (req, res) => {
  try {
    await db.query("SELECT 1");
    await redis.ping();

    res.status(200).json({
      status: "healthy",
      database: "connected",
      redis: "connected",
    });

  } catch (error) {
    res.status(503).json({
      status: "unhealthy",
      error: error.message,
    });
  }
});


// Start application
async function startApp() {
  try {
    await initDb();
    await initRedis();

    app.listen(port, "0.0.0.0", () => {
      console.log(`Server running on port ${port}`);
    });

  } catch (error) {
    console.error("Failed to start application:", error);
    process.exit(1);
  }
}


// Graceful shutdown
async function shutdown() {
  console.log("Shutting down...");

  try {
    await db.end();

    if (redis.isOpen) {
      await redis.quit();
    }

    process.exit(0);

  } catch (error) {
    console.error("Shutdown error:", error);
    process.exit(1);
  }
}

process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);

startApp();
