const express = require('express');
const axios = require('axios');  
const { upcomingMatches, matchLive, getCompetitions, getMatchesByCompetition, getMatchById, addToFavorites, getFavorites, removeFromFavorites } = require('../controllers/apiController');
const authMiddleware = require('../middlewares/authMiddleware');
require('dotenv').config(); 

const router = express.Router();  // Sử dụng express.Router() để tạo router

// Endpoint lấy trận đấu sắp diễn ra
router.get('/matches/upcoming', upcomingMatches);

router.get('/matches/live', matchLive);
router.get('/matches/competitions', getCompetitions);
router.get('/matches/matchByCompetitions', getMatchesByCompetition);
router.post("/matches/addFavoriteMatch",authMiddleware, addToFavorites);
router.get("/matches/getfavorite", authMiddleware, getFavorites);
router.delete('/matches/remove', authMiddleware, removeFromFavorites);
router.get('/matches/:fixtureId', getMatchById);

module.exports = router;  
