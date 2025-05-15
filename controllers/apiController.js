const axios = require('axios');
require('dotenv').config();
const redis = require('redis');
const User = require('../models/User');
const client = redis.createClient();

// Helper function to standardize match data
const standardizeMatch = (matchData) => {
  const homeScore = matchData.goals?.home ?? 0;
  const awayScore = matchData.goals?.away ?? 0;

  return {
    id: matchData.id ?? 0,
    homeTeam: matchData.homeTeam ?? '',
    awayTeam: matchData.awayTeam ?? '',
    date: matchData.date ?? '',
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

    console.log(response.data);

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

exports.getMatchById = async (req, res) => {
  const { fixtureId } = req.params;

  if (!fixtureId) {
    return res.status(400).json({ error: 'Thiếu fixture ID' });
  }

  try {
    const response = await axios.get('https://v3.football.api-sports.io/fixtures', {
      headers: {
        'x-apisports-key': process.env.API_FOOTBALL_KEY,
      },
      params: {
        id: fixtureId,
      },
    });

    const matchData = response.data.response[0];

    if (!matchData) {
      return res.status(404).json({ error: 'Không tìm thấy trận đấu' });
    }

    const match = {
      id: matchData.fixture.id,
      date: matchData.fixture.date,
      status: matchData.fixture.status.long,
      venue: matchData.fixture.venue.name,
      referee: matchData.fixture.referee,
      homeTeam: matchData.teams?.home?.name || 'N/A',  // Kiểm tra home team có tồn tại không
      awayTeam: matchData.teams?.away?.name || 'N/A',  // Kiểm tra away team có tồn tại không
      homeLogo: matchData.teams?.home?.logo || '',     // Kiểm tra logo home có tồn tại không
      awayLogo: matchData.teams?.away?.logo || '',     // Kiểm tra logo away có tồn tại không
      goals: {
        home: matchData.goals?.home || 0,
        away: matchData.goals?.away || 0,
      },
      league: matchData.league?.name || 'N/A',         // Kiểm tra league có tồn tại không
      season: matchData.league?.season || 'N/A',       // Kiểm tra season có tồn tại không
      statistics: (matchData.statistics || []).map((stat) => ({
        team: {
          id: stat.team.id,
          name: stat.team.name,
          logo: stat.team.logo,
        },
        statistics: stat.statistics.map((s) => ({
          type: s.type,
          value: s.value,
        })),
      })),
      events: (matchData.events || []).map((event) => ({
        time: {
          elapsed: event.time.elapsed,
          extra: event.time.extra ?? null,
        },
        team: {
          id: event.team.id,
          name: event.team.name,
          logo: event.team.logo,
        },
        player: {
          id: event.player.id,
          name: event.player.name,
        },
        assist: event.assist
          ? {
              id: event.assist.id,
              name: event.assist.name,
            }
          : null,
        type: event.type,
        detail: event.detail,
        comments: event.comments,
      })),
      lineups: {
        // Kiểm tra nếu matchData.lineup là một mảng hợp lệ
        home: Array.isArray(matchData.lineups) && matchData.lineups.length > 0
          ? matchData.lineups.find((team) => team.team.id === matchData.teams?.home?.id) || null
          : null,
        away: Array.isArray(matchData.lineups) && matchData.lineups.length > 1
          ? matchData.lineups.find((team) => team.team.id === matchData.teams?.away?.id) || null
          : null,
      },
    };

    // Thêm chi tiết cho lineups (startXI, substitutes)
    if (match.lineups.home) {
      match.lineups.home = {
        teamName: matchData.teams?.home?.name || 'N/A',
        formation: match.lineups.home.formation || 'N/A',
        coach: match.lineups.home.coach ? {
          name: match.lineups.home.coach.name,
          photo: match.lineups.home.coach.photo,
        } : null,
        startXI: (match.lineups.home.startXI || []).map((player) => ({
          id: player.player?.id,
          name: player.player?.name,
          position: player.player?.position,
          photo: player.player?.photo,
        })),
        substitutes: (match.lineups.home.substitutes || []).map((player) => ({
          id: player.player?.id,
          name: player.player?.name,
          position: player.player?.position,
          photo: player.player?.photo,
        })),
      };
    }

    if (match.lineups.away) {
      match.lineups.away = {
        teamName: matchData.teams?.away?.name || 'N/A',
        formation: match.lineups.away.formation || 'N/A',
        coach: match.lineups.away.coach ? {
          name: match.lineups.away.coach.name,
          photo: match.lineups.away.coach.photo,
        } : null,
        startXI: (match.lineups.away.startXI || []).map((player) => ({
          id: player.player?.id,
          name: player.player?.name,
          position: player.player?.position,
          photo: player.player?.photo,
        })),
        substitutes: (match.lineups.away.substitutes || []).map((player) => ({
          id: player.player?.id,
          name: player.player?.name,
          position: player.player?.position,
          photo: player.player?.photo,
        })),
      };
    }

    res.json(match);
  } catch (err) {
    console.error('Error fetching match by ID:', err.message);
    res.status(500).json({ error: 'Không thể lấy thông tin trận đấu từ API-Football' });
  }
};

exports.addToFavorites = async (req, res) => {
  const { fixtureId } = req.body;
  const userId = req.user.id;

  console.log(userId);

  if (!fixtureId) {
    return res.status(400).json({ error: 'Thiếu fixture ID' });
  }

  try {
    // Lấy dữ liệu trận đấu từ API-Football
    const response = await axios.get('https://v3.football.api-sports.io/fixtures', {
      headers: {
        'x-apisports-key': process.env.API_FOOTBALL_KEY,
      },
      params: {
        id: fixtureId,
      },
    });

    const matchData = response.data.response[0];
    if (!matchData) {
      return res.status(404).json({ error: 'Không tìm thấy trận đấu' });
    }

    const match = {
      id: matchData.fixture.id,
      date: matchData.fixture.date,
      status: matchData.fixture.status.long,
      venue: matchData.fixture.venue.name,
      homeTeam: matchData.teams.home.name,
      awayTeam: matchData.teams.away.name,
      homeLogo: matchData.teams.home.logo,
      awayLogo: matchData.teams.away.logo,
      goals: {
        home: matchData.goals.home ?? 0,
        away: matchData.goals.away ?? 0,
      },
      competition: matchData.league.name ?? '',
      country: matchData.league.country ?? '',
    };

    // Cập nhật user document, thêm trận vào favorites nếu chưa có
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ error: 'Người dùng không tồn tại' });
    }

    // Kiểm tra xem đã có trong favorites chưa
    const exists = user.favorites.some(fav => fav.id === match.id);
    if (exists) {
      return res.status(400).json({ error: 'Trận đấu đã có trong danh sách yêu thích' });
    }

    // Thêm vào favorites rồi lưu
    user.favorites.push(match);
    await user.save();

    res.status(200).json({ message: 'Đã thêm trận đấu vào danh sách yêu thích', match });
  } catch (err) {
    console.error('Error adding to favorites:', err.message);
    res.status(500).json({ error: 'Không thể thêm trận đấu vào danh sách yêu thích' });
  }
};

exports.getFavorites = async (req, res) => {
  const userId = req.user.id;

  try {
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ error: 'Người dùng không tồn tại' });
    }

    res.status(200).json({ favorites: user.favorites });
  } catch (err) {
    console.error('Error getting favorites:', err.message);
    res.status(500).json({ error: 'Không thể lấy danh sách yêu thích' });
  }
};

exports.removeFromFavorites = async (req, res) => {
  const { fixtureId } = req.body;
  const userId = req.user.id;

  if (!fixtureId) {
    return res.status(400).json({ error: 'Thiếu fixture ID' });
  }

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: 'Người dùng không tồn tại' });
    }

    user.favorites = user.favorites.filter(fav => fav.id !== fixtureId);
    await user.save();

    res.status(200).json({ message: 'Đã xóa trận đấu khỏi danh sách yêu thích' });
  } catch (err) {
    console.error('Error removing from favorites:', err.message);
    res.status(500).json({ error: 'Không thể xóa trận đấu khỏi danh sách yêu thích' });
  }
};