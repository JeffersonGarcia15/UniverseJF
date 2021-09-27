const express = require('express');
const asyncHandler = require('express-async-handler');
const { User, Album, Photo, Comment, AlbumPhoto } = require('../../db/models');
const { check } = require('express-validator');
const { handleValidationErrors } = require('../../utils/validation');
const { setTokenCookie, requireAuth } = require('../../utils/auth');

const { singlePublicFileUpload } = require('../../awsS3');
const { singleMulterUpload } = require('../../awsS3');

const router = express.Router();

const validateSignup = [
  check('firstName')
    .notEmpty()
    .withMessage('Please provide a value for first name.'),
  check('lastName')
    .notEmpty()
    .withMessage('Please provide a value for last name.'),
  check('email')
    .exists({ checkFalsy: true })
    .isEmail()
    .withMessage('Please provide a valid email.'),
  check('username')
    .exists({ checkFalsy: true })
    .isLength({ min: 4 })
    .withMessage('Please provide a username with at least 4 characters.'),
  check('username')
    .not()
    .isEmail()
    .withMessage('Username cannot be an email.'),
  check('password')
    .exists({ checkFalsy: true })
    .isLength({ min: 6 })
    .withMessage('Password must be 6 characters or more.'),
  handleValidationErrors,
];

// Post /api/users ---Sign up
router.post(
  "/",
  singleMulterUpload("image"),
  validateSignup,
  asyncHandler(async (req, res) => {
    const { firstName, lastName, email, password, username } = req.body;
    // const profileImageUrl = await singlePublicFileUpload(req.file);
    const user = await User.signup({
      firstName,
      lastName,
      username,
      email,
      password,
      // profileImageUrl,
      // imgUrl
    });

    setTokenCookie(res, user);

    return res.json({
      user,
    });
  })
);
  

router.get('/:id(\\d+)', asyncHandler(async(req, res) => {
  const id = parseInt(req.params.id, 10)
  const user = await Photo.findAll({ 
    where: {
      userId: id
    },
    include: User
  })
  return res.json(user)
}))

module.exports = router;