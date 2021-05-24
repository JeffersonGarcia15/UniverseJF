const express = require('express')
const asyncHandler = require('express-async-handler')
const { requireAuth } = require('../../utils/auth')
const { User, Photo, Comment} = require('../../db/models')
const router = express.Router();

router.get('', asyncHandler(async (req, res) => {
    const photos = await Photo.findAll({ include: User })
    return res.json(photos);
}))

router.get('/:id(\\d+)', asyncHandler(async (req, res) => {
    const photoId = parseInt(req.params.id, 10)
    const photo = await Photo.findByPk(photoId, {
        include: User
    })
    return res.json(photo)
}))

module.exports = router