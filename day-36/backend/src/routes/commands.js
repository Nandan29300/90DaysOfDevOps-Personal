const express = require("express");
const pool = require("../db");

const router = express.Router();

// GET /api/commands
router.get("/", async (req, res) => {
  try {
    const { search, category } = req.query;

    let query = `
      SELECT id, title, command, description, category, example
      FROM docker_commands
    `;

    const values = [];
    const conditions = [];

    if (search) {
      values.push(`%${search}%`);

      conditions.push(`
        (
          title ILIKE $${values.length}
          OR command ILIKE $${values.length}
          OR description ILIKE $${values.length}
        )
      `);
    }

    if (category) {
      values.push(category);
      conditions.push(`category = $${values.length}`);
    }

    if (conditions.length > 0) {
      query += ` WHERE ${conditions.join(" AND ")}`;
    }

    query += " ORDER BY id";

    const result = await pool.query(query, values);

    res.json(result.rows);
  } catch (error) {
    console.error("Failed to fetch commands:", error);

    res.status(500).json({
      error: "Failed to fetch Docker commands",
    });
  }
});

module.exports = router;
