const express = require("express");
const router = express.Router();
const db = require("../config/database");

// 1. READ: Tampilkan semua To-Do
router.get("/", async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT * FROM todos ORDER BY created_at DESC"
    );
    res.render("todos", {
      todos: rows,
      error: null,
    });
  } catch (err) {
    console.error(err);
    res.render("todos", {
      todos: [],
      error: "Gagal mengambil data dari database.",
    });
  }
});

// 2. CREATE: Tambah To-Do Baru
router.post("/add", async (req, res) => {
  const { task } = req.body;
  if (!task) return res.redirect("/");

  try {
    // Query 1: Insert ke Todos
    await db.query("INSERT INTO todos (task) VALUES (?)", [task]);

    // --- TANTANGAN LOGIC LOGS ---
    // Mahasiswa harus menambahkan codingan insert ke tabel logs di sini
    // Mendapatkan ID tugas yang baru ditambahkan
    const [result] = await db.query("SELECT LAST_INSERT_ID() as id");
    const taskId = result[0].id;
    // Insert log untuk penambahan tugas
    await db.query("INSERT INTO logs (action, task_id) VALUES (?, ?)", ['add', taskId]);
    // -----------------------------

    res.redirect("/");
  } catch (err) {
    console.error(err);
    res.redirect("/");
  }
});

// 3. UPDATE: Toggle Status
router.post("/toggle/:id", async (req, res) => {
  try {
    const [rows] = await db.query("SELECT completed FROM todos WHERE id = ?", [
      req.params.id,
    ]);
    if (rows.length > 0) {
      const newStatus = rows[0].completed ? 0 : 1;
      await db.query("UPDATE todos SET completed = ? WHERE id = ?", [
        newStatus,
        req.params.id,
      ]);
      // --- TANTANGAN LOGIC LOGS ---
      // Mahasiswa harus menambahkan codingan insert ke tabel logs di sini
      // Insert log untuk perubahan status tugas
      await db.query("INSERT INTO logs (action, task_id) VALUES (?, ?)", ['toggle', req.params.id]);
      // -----------------------------
    }
    res.redirect("/");
  } catch (err) {
    console.error(err);
    res.redirect("/");
  }
});

// 4. DELETE: Hapus Todo
router.post("/delete/:id", async (req, res) => {
  try {
    await db.query("DELETE FROM todos WHERE id = ?", [req.params.id]);
    // --- TANTANGAN LOGIC LOGS ---
    // Mahasiswa harus menambahkan codingan insert ke tabel logs di sini
    // Insert log untuk penghapusan tugas
    await db.query("INSERT INTO logs (action, task_id) VALUES (?, ?)", ['delete', req.params.id]);
    // -----------------------------
    res.redirect("/");
  } catch (err) {
    console.error(err);
    res.redirect("/");
  }
});

module.exports = router;
