const express = require('express')
const asyncHandler = require('express-async-handler')
const { requireAuth } = require('../../utils/auth')
const { User, Photo, Comment} = require('../../db/models')
const router = express.Router();

router.get('', asyncHandler(async (req, res) => {
    const photos = await Photo.findAll({ include: User })
    return res.json(photos);
}))

module.exports = router