const express = require('express');
const sql = require('mssql');
const path = require('path');

const app = express();
const PORT = process.env.PORT;

/* ===============================
   Azure SQL configuration
   =============================== */
const sqlConfig = {
    server: process.env.DB_SERVER,            // <server>.database.windows.net
    database: process.env.DB_NAME,             // appdb
    user: process.env.DB_USER,                 // sqladmin
    password: process.env.DB_PASSWORD,
    port: 1433,
    options: {
        encrypt: true,
        trustServerCertificate: false
    }
};

/* ===============================
   Connection Pool
   =============================== */
let pool;

async function getPool() {
    if (!pool) {
        pool = await sql.connect(sqlConfig);
    }
    return pool;
}

/* ===============================
   Static frontend
   =============================== */
app.use(express.static(path.join(__dirname, 'public')));

/* ===============================
   API: fetch random quote
   =============================== */
app.get('/api/random-text', async (req, res) => {
    try {
        const pool = await getPool();

        const result = await pool.request().query(`
            SELECT TOP 1 text
            FROM quotes
            ORDER BY NEWID()
        `);

        if (result.recordset.length === 0) {
            return res.json({ text: null });
        }

        res.json({ text: result.recordset[0].text });

    } catch (err) {
        console.error('SQL error:', err);
        res.status(500).json({ error: 'Database error' });
    }
});

/* ===============================
   Start server
   =============================== */
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
