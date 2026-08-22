require("dotenv").config();

const express = require("express");
const cors = require("cors");

const commandsRouter = require("./routes/commands");
const pool = require("./db");

const app = express();

const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

app.get("/api/health", async (req, res) => {
  try {
    await pool.query("SELECT 1");

    res.json({
      status: "healthy",
      database: "connected",
      service: "dockerbuddy-api",
    });
  } catch (error) {
    res.status(503).json({
      status: "unhealthy",
      database: "disconnected",
      service: "dockerbuddy-api",
    });
  }
});

app.use("/api/commands", commandsRouter);

app.listen(PORT, () => {
  console.log(`DockerBuddy API running on port ${PORT}`);
});
