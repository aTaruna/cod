const express = require("express");
const router = express.Router();
const db = require("../config/database");

// ROUTE: GET /logs
// 1. Ambil data dari tabel 'logs'
// 2. Render file view (misal: logs.ejs) dengan data tersebut

router.get("/", async (req, res) => {
  try {
    // Mengambil semua data dari tabel logs, diurutkan berdasarkan timestamp terbaru
    const [logs] = await db.query("SELECT * FROM logs ORDER BY timestamp DESC");
    // Render view logs.ejs dengan data logs
    res.render("logs", { logs: logs });
  } catch (err) {
    console.error(err);
    // Jika terjadi error, render view dengan pesan error atau redirect
    res.render("logs", { logs: [], error: "Gagal mengambil data logs dari database." });
  }
});

module.exports = router;
