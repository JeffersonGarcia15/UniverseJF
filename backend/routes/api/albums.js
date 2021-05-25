const express = require('express')
const asyncHandler = require('express-async-handler')
const { Album, AlbumPhoto } = require('../../db/models')
const { requireAuth } = require('../../utils/auth')
const router = express.Router()




