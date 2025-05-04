const express = require('express');
const axios = require('axios');  
const { upcomingMatches, matchLive, getCompetitions, getMatchesByCompetition, getMatchById } = require('../controllers/apiController');
require('dotenv').config(); 

const router = express.Router();  // Sử dụng express.Router() để tạo router

// Endpoint lấy trận đấu sắp diễn ra
router.get('/matches/upcoming', upcomingMatches);

router.get('/matches/live', matchLive);
router.get('/matches/competitions', getCompetitions);
router.get('/matches/matchByCompetitions', getMatchesByCompetition);
router.get('/matches/:fixtureId', getMatchById);

module.exports = router;  
