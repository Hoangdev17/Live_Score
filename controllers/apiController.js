const axios = require('axios');
require('dotenv').config();
const redis = require('redis');
const client = redis.createClient();

// Helper function to standardize match data
const standardizeMatch = (matchData) => {
  const homeScore = matchData.goals?.home ?? 0;
  const awayScore = matchData.goals?.away ?? 0;

  return {
    id: matchData.id ?? 0,
    homeTeam: matchData.homeTeam ?? '',
    awayTeam: matchData.awayTeam ?? '',
    utcDate: matchData.date ?? '',
    competition: matchData.competition ?? '',
    country: matchData.country ?? '',
    score: `${homeScore}-${awayScore}`,
    homeTeamLogo: matchData.homeLogo ?? '',
    awayTeamLogo: matchData.awayLogo ?? '',
    homeTeamScore: homeScore,
    awayTeamScore: awayScore,
    status: matchData.status ?? 'SCHEDULED',
    venue: matchData.venue ?? '',
  };
};

exports.upcomingMatches = async (req, res) => {
  try {
    // Gọi API từ Football-Data.org
    const response = await axios.get(process.env.API_URL, {
      headers: { 'X-Auth-Token': process.env.API_KEY },
    });

    // Chuẩn hóa dữ liệu trận đấu
    const matches = response.data.matches.map((match) =>
      standardizeMatch({
        id: match.id,
        homeTeam: match.homeTeam.name,
        awayTeam: match.awayTeam.name,
        date: match.utcDate,
        // Các trường không có trong API, để trống hoặc mặc định
        competition: '',
        country: '',
        goals: { home: 0, away: 0 }, // Không có trong API này
        homeLogo: '',
        awayLogo: '',
        status: match.status ?? 'SCHEDULED',
        venue: '',
      })
    );

    res.json(matches);
  } catch (error) {
    res.status(500).json({ error: 'Không thể lấy dữ liệu trận đấu' });
  }
};

exports.matchLive = async (req, res) => {
  try {
    const response = await axios.get(process.env.API_FOOTBALL_URL, {
      headers: {
        'x-apisports-key': process.env.API_FOOTBALL_KEY,
      },
    });

    const matches = response.data.response.map((item) =>
      standardizeMatch({
        id: item.fixture.id,
        homeTeam: item.teams.home.name,
        awayTeam: item.teams.away.name,
        date: item.fixture.date,
        competition: item.league.name,
        country: item.league.country,
        goals: {
          home: item.goals.home ?? 0,
          away: item.goals.away ?? 0,
        },
        homeLogo: item.teams.home.logo ?? '',
        awayLogo: item.teams.away.logo ?? '',
        status: item.fixture.status.long ?? 'SCHEDULED',
        venue: item.fixture.venue.name ?? '',
      })
    );

    res.json(matches);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Không thể lấy dữ liệu từ API-Football' });
  }
};

exports.getCompetitions = async (req, res) => {
  try {
    const response = await axios.get('https://v3.football.api-sports.io/leagues', {
      headers: {
        'x-apisports-key': process.env.API_FOOTBALL_KEY,
      },
    });

    const competitions = response.data.response
      .map((item) => {
        // Tìm mùa giải hiện tại hoặc cuối cùng nằm trong khoảng 2021–2023
        const validSeason = item.seasons
          .filter((season) => season.year >= 2021 && season.year <= 2023)
          .find((season) => season.current) ||
          item.seasons
            .filter((season) => season.year >= 2021 && season.year <= 2023)
            .at(-1);

        if (!validSeason) return null; // Bỏ qua nếu không có mùa nào phù hợp

        return {
          id: item.league.id ?? 0,
          name: item.league.name ?? '',
          country: item.country.name ?? '',
          flag: item.country.flag ?? '',
          logo: item.league.logo ?? '',
          season: {
            year: validSeason.year ?? 0,
            start: validSeason.start ?? '',
            end: validSeason.end ?? '',
          },
        };
      })
      .filter(Boolean); // Bỏ null

    res.json(competitions);
  } catch (err) {
    console.error('Error fetching competitions:', err.message);
    res.status(500).json({ error: 'Không thể lấy dữ liệu giải đấu từ API-Football' });
  }
};

exports.getMatchesByCompetition = async (req, res) => {
  const { league, season } = req.query;

  if (!league || !season) {
    return res.status(400).json({ error: 'Thiếu league hoặc season' });
  }

  try {
    const response = await axios.get('https://v3.football.api-sports.io/fixtures', {
      headers: {
        'x-apisports-key': process.env.API_FOOTBALL_KEY,
      },
      params: {
        league,
        season,
      },
    });

    const matches = response.data.response.map((item) =>
      standardizeMatch({
        id: item.fixture.id,
        date: item.fixture.date,
        status: item.fixture.status.long,
        venue: item.fixture.venue.name,
        homeTeam: item.teams.home.name,
        awayTeam: item.teams.away.name,
        homeLogo: item.teams.home.logo,
        awayLogo: item.teams.away.logo,
        goals: {
          home: item.goals.home,
          away: item.goals.away,
        },
        competition: item.league.name ?? '',
        country: item.league.country ?? '',
      })
    );

    res.json(matches);
  } catch (err) {
    console.error('Error fetching matches:', err.message);
    res.status(500).json({ error: 'Không thể lấy dữ liệu trận đấu từ API-Football' });
  }
};