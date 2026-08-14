const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { initializeFirebase } = require('./config/firebase');
const locationRoutes = require('./routes/locationRoutes');
const transitRoutes = require('./routes/transitRoutes');

dotenv.config();

// Initialize Firebase Admin SDK
initializeFirebase();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api', locationRoutes);
app.use('/api', transitRoutes);

// Health Check Endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
