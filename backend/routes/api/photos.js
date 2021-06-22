const express = require('express')
const asyncHandler = require('express-async-handler')
const { requireAuth } = require('../../utils/auth')
const { User, Photo, Comment, Tag, Like} = require('../../db/models');
const { singleMulterUpload, singlePublicFileUpload} = require('../../awsS3');
const router = express.Router();

router.get('/', asyncHandler(async (req, res) => {
    const photos = await Photo.findAll({ include: [User, Tag, Like] })
    return res.json(photos);
}))

router.get('/:id(\\d+)', asyncHandler(async (req, res) => {
    const photoId = parseInt(req.params.id, 10)
    const photo = await Photo.findByPk(photoId, {
        include: [User, Tag, Like]
    })
    return res.json(photo)
}))

router.post('/new', requireAuth, singleMulterUpload('photo'), asyncHandler(async (req, res) => {
    const { title, description, userId } = req.body
    // console.log(req.body, '==========================');
    // res.json('JEFF')
    const imgUrl = await singlePublicFileUpload(req.file)

    const photoObject = {
        title,
        description,
        userId,
        imgUrl
    }
    const data = await Photo.create(photoObject)
    const photo = await Photo.findByPk(data.id, {
        include: User
    })
    return res.json( photo )
}))

router.put('/:id(\\d+)', requireAuth, asyncHandler(async (req, res) => {
    const photoId = parseInt(req.params.id, 10) 
    const {title, description} = req.body
    await Photo.update({
        title,
        description
    },
    {
        where: {
            id: photoId
        }
    }
    )
    const updatedPhoto = await Photo.findByPk(photoId, {
        include: User
    })  
    return res.json(updatedPhoto)

}))

router.delete('/:id(\\d+)', requireAuth, asyncHandler(async (req, res) => {
    const photoId = parseInt(req.params.id, 10)
    const deleteUserPhoto = await Photo.findByPk(photoId)
    await deleteUserPhoto.destroy()
    res.status(204).end()
}))

module.exports = router