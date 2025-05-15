const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

// Define the User schema
const userSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        trim: true,
    },
    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true,
        trim: true,
    },
    password: {
        type: String,
        required: true,
        minlength: 6,
    },
     favorites: [
    {
      id: Number,
      date: String,
      status: String,
      venue: String,
      homeTeam: String,
      awayTeam: String,
      homeLogo: String,
      awayLogo: String,
      goals: {
        home: Number,
        away: Number,
      },
      competition: String,
      country: String,
    }
  ]
},
{
    timestamps: true
});

// Create the User model
const User = mongoose.model('User', userSchema);

module.exports = User;