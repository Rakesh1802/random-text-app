const express = require('express');
const sql = require('mssql');
const path = require('path');

const app = express();
const PORT = process.env.PORT;

/* ===============================
   Azure SQL configuration
   =============================== */
const sqlConfig = {
    server: process.env.DB_SERVER, 
    database: process.env.DB_NAME,
    port: 1433,
    authentication: {
        type: 'azure-active-directory-default', 
        options: {
            clientId: process.env.AZURE_CLIENT_ID 
        }
    },
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
            SELECT TOP 1 text, author
            FROM quotes
            ORDER BY NEWID()
        `);

        if (result.recordset.length === 0) {
            return res.json({ text: null, author: null });
        }

        res.json({ text: result.recordset[0].text, author: result.recordset[0].author });

    } catch (err) {
        console.error('SQL error:', err);
        res.status(500).json({ error: 'Database error' });
    }
});

/* ===============================
   Health check
   =============================== */
app.get('/health', async (req, res) => {
    try {
        const pool = await getPool();

        // Lightweight connectivity check
        await pool.request().query('SELECT 1');

        res.status(200).json({
            status: 'UP',
            database: 'CONNECTED'
        });
    } catch (err) {
        console.error('Health check failed:', err);

        res.status(503).json({
            status: 'DOWN',
            database: 'DISCONNECTED'
        });
    }
});


/* ===============================
   Start server
   =============================== */
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
