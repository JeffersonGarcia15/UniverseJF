const express = require('express')
const asyncHandler = require('express-async-handler')
const { requireAuth } = require('../../utils/auth')
const { User, Photo, Comment, Tag, Tag_Photo } = require('../../db/models');
const router = express.Router();


router.get('/photos/:id(\\d+)', asyncHandler(async (req, res) => {
    const photoId = parseInt(req.params.id, 10)
    const tags = await Tag.findAll({
        where: {
            photoId,
        }
    })
    return res.json(tags)
}))


router.post('/photos/:id(\\d+)', requireAuth, asyncHandler(async (req, res) => {
    // const photoId = parseInt(req.params.id, 10)
    const { name } = req.body
    const newTag = await Tag.create({
        name,
    })
    const tag = await Tag.findByPk(newTag.id)
    return res.json(tag)
}))

router.post('/:id(\\d+)', requireAuth, asyncHandler(async (req, res) => {
    const { photoId, tagId } = req.body;
    const tagInfo = await Tag_Photo.create({
        photoId,
        tagId
    })

    // console.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!------------------------------', albumInfo);
    return res.json(tagInfo)
}))


module.exports = router