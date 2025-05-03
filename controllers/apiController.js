const axios = require('axios');  
require('dotenv').config(); 
const redis = require('redis');
const client = redis.createClient();

exports.upcomingMatches = async (req, res) => {
    try {
        // Gọi API từ Football-Data.org
        const response = await axios.get(process.env.API_URL, {
          headers: { 'X-Auth-Token': process.env.API_KEY },
        });
        
        // Trả về danh sách trận đấu
        const matches = response.data.matches.map(match => ({
          id: match.id,
          homeTeam: match.homeTeam.name,
          awayTeam: match.awayTeam.name,
          date: match.utcDate,
        }));
        
        res.json(matches);
      } catch (error) {
        res.status(500).json({ error: 'Không thể lấy dữ liệu trận đấu' });
      }
}

exports.matchLive = async (req, res) => {
    try {
        const response = await axios.get(process.env.API_FOOTBALL_URL, {
          headers: {
            'x-apisports-key': process.env.API_FOOTBALL_KEY
          }
        });
    
        const matches = response.data.response.map(item => ({
          id: item.fixture.id,
          homeTeam: item.teams.home.name,
          awayTeam: item.teams.away.name,
          utcDate: item.fixture.date,
          competition: item.league.name,
          country: item.league.country,
          score: `${item.goals.home} - ${item.goals.away}`
        }));

        // console.log(response.data.response);
    
        res.json(matches);
      } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: 'Không thể lấy dữ liệu từ API-Football' });
      }
}


exports.getCompetitions = async (req, res) => {
  try {
    const response = await axios.get('https://v3.football.api-sports.io/leagues', {
      headers: {
        'x-apisports-key': process.env.API_FOOTBALL_KEY
      }
    });

    const competitions = response.data.response.map(item => {
      // Lọc mùa giải hiện tại
      const currentSeason = item.seasons.find(season => season.current) || item.seasons.at(-1);

      return {
        id: item.league.id,
        name: item.league.name,
        country: item.country.name,
        flag: item.country.flag,
        logo: item.league.logo,
        season: {
          year: currentSeason.year,
          start: currentSeason.start,
          end: currentSeason.end
        }
      };
    });

    res.json(competitions);
  } catch (err) {
    console.error('Error fetching competitions:', err.message);
    res.status(500).json({ error: 'Không thể lấy dữ liệu giải đấu từ API-Football' });
  }
};