const express = require('express')
const asyncHandler = require('express-async-handler')
const { requireAuth } = require('../../utils/auth')
const { User, Photo, Comment } = require('../../db/models');
const router = express.Router();

router.get('/photos/:id(\\d+)', asyncHandler(async (req, res) => {
    const photoId = parseInt(req.params.id, 10)
    const comments = await Comment.findAll({
        where: {
            photoId,
        },
        include: User
    })
    return res.json(comments)
}))

router.put('/photos/:id(\\d+)', requireAuth, asyncHandler(async (req, res) => {
    const photoId = parseInt(req.params.id, 10)
    const { body } = req.body
    const comment = await Comment.findOne({
        where: {
            id: photoId
        }
    })
    await comment.update({
        body
    })
    return res.json(comment)
}))

router.post('/photos/:id(\\d+)', requireAuth, asyncHandler(async (req, res) => {
    const photoId = parseInt(req.params.id, 10)
    const { body, userId } = req.body
    const newComment = await Comment.create({
        body,
        userId,
        photoId,
    })
    const comment = await Comment.findByPk(newComment.id, {
        include: User
    })
    return res.json(comment)
}))

router.delete('/:id(\\d+)', requireAuth, asyncHandler(async (req, res) => {
    const commentId = parseInt(req.params.id, 10)
    const comment = await Comment.findByPk(commentId)
    await comment.destroy()
    res.status(204).end()
}))

module.exports = router