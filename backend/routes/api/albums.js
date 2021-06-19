const express = require('express')
const asyncHandler = require('express-async-handler')
const { Album, AlbumPhoto, Photo } = require('../../db/models')
const { requireAuth } = require('../../utils/auth')
const { singlePublicFileUpload, singleMulterUpload } = require("../../awsS3")
const { response } = require('express')
const router = express.Router()

// router.post('/new', requireAuth, singleMulterUpload('photo'), asyncHandler(async(req, res) => {
//     let album;
//     const { title, description, userId } = req.body
//     if (req.file) {
//         const imageUrl = await singlePublicFileUpload(req.file)
//         album = await Album.create({
//             title,
//             description,
//             userId
//         })
//     }
//     else {
//         album = await Album.create({
//             title,
//             description,
//             userId
//         })
//     }
//     return res.json({
//         album
//     })
// }))

router.post('/new', requireAuth, asyncHandler(async (req, res) => {
    const { title, description, userId } = req.body
    const newSingleAlbum = await Album.create({
        title,
        description,
        userId
    })
    return res.json(newSingleAlbum)
}))

router.post('/:id(\\d+)', requireAuth, asyncHandler(async (req, res) => {
    const { photoId, albumId } = req.body;
    await AlbumPhoto.create({
        photoId,
        albumId
    })
}))

router.get('/user/:id(\\d+)', requireAuth, asyncHandler(async (req, res) => {
    const id = parseInt(req.params.id, 10)
    const albums = await Album.findAll({
        where: {
            userId: id
        },
        include: Photo
    })
    return res.json(albums)
}))

router.get('/:id(\\d+)', asyncHandler(async (req, res) => {
    const albumId = parseInt(req.params.id, 10)
    const album = await Album.findByPk(albumId, {
        include: Photo
    })
    return res.json(album)
}))

router.put('/user/:id(\\d+)', requireAuth, asyncHandler(async (req, res) => {
    const albumId = parseInt(req.params.id, 10)
    const { title, description } = req.body
    const album = await Album.findOne({
        where: {
            id: albumId
        }
    })
    await album.update({
        title,
        description
    })
    return res.json(album)
}))


router.delete('/:id(\\d+)', requireAuth, asyncHandler(async (req, res) => {
    const albumId = parseInt(req.params.id, 10)
    const album = await Album.findByPk(albumId)
    await album.destroy()
    res.status(204).end()
}))

module.exports = router