const express = require('express')
const asyncHandler = require('express-async-handler')
const { requireAuth } = require('../../utils/auth')
const { User, Photo, Comment, Tag, Tag_Photo, Like } = require('../../db/models');
const router = express.Router();


router.post('/:id(\\d+)', asyncHandler(async (req, res) => {
    const { userId, photoId } = req.body
    const likeInfo = await Like.create({
        photoId,
        userId
    })
    return res.json(likeInfo)

}))

router.get('/', asyncHandler(async (req, res) => {
    const likes = await Like.findAll({})
    return res.json(likes)
}))

router.get('/photos/:id(\\d+)', asyncHandler(async (req, res) => {
    const photoId = parseInt(req.params.id, 10)
    const likes = await Like.findAll({
        where: {
            photoId
        }
    })
    return res.json(likes)
}))

module.exports = router


