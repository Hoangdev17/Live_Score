const express = require('express');
const axios = require('axios');
const cors = require('cors');
const dotenv = require('dotenv');

const apiRoutes = require('./routes/apiRoutes.js')
const authRoutes = require('./routes/authRoutes.js');
const connectDB = require('./config/db.js');

dotenv.config();
const PORT = process.env.PORT;

const app = express();
app.use(cors());
app.use(express.json());

connectDB();

const API_KEY = process.env.FOOTBALL_API_KEY;  // Lấy API key từ .env

// Endpoint lấy các trận đấu sắp diễn ra
app.use("/api", apiRoutes);
app.use("/api/auth", authRoutes);

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
