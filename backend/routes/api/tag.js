const express = require("express");
const asyncHandler = require("express-async-handler");
const { requireAuth } = require("../../utils/auth");
const { User, Photo, Comment, Tag, Tag_Photo } = require("../../db/models");
const router = express.Router();

router.get(
  "/",
  asyncHandler(async (req, res) => {
    const tags = await Tag.findAll({});
    return res.json(tags);
  })
);

router.get(
  "/photos/:id(\\d+)",
  asyncHandler(async (req, res) => {
    const photoId = parseInt(req.params.id, 10);
    const tags = await Tag.findAll({
      where: {
        photoId,
      },
    });
    return res.json(tags);
  })
);

router.post(
  "/new",
  requireAuth,
  asyncHandler(async (req, res) => {
    const { tagsArray } = req.body;

    const existingTags = await Tag.findAll({
      where: {
        name: tagsArray,
      },
    });

    const existingTagNames = existingTags.map((tag) => tag.name);

    const newTagNames = tagsArray.filter(
      (tagName) => !existingTagNames.includes(tagName)
    );

    // If there are new tags to create, bulk create them
    let newTags = [];
    if (newTagNames.length > 0) {
      newTags = await Tag.bulkCreate(newTagNames.map((name) => ({ name })));
    }

    // Combine the existing tags with the new tags to return them all
    const allTags = [...existingTags, ...newTags];

    return res.json(allTags);
  })
);

router.post(
  "/:id(\\d+)",
  requireAuth,
  asyncHandler(async (req, res) => {
    const { photoId, tagId } = req.body;
    const tagInfo = await Tag_Photo.create({
      photoId,
      tagId,
    });

    return res.json(tagInfo);
  })
);

module.exports = router;
