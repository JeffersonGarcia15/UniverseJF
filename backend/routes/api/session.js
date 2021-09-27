const express = require('express')
const router = express.Router();
const asyncHandler = require('express-async-handler');
const { check } = require('express-validator');
const { handleValidationErrors } = require('../../utils/validation');
const { singlePublicFileUpload, singleMulterUpload } = require('../../awsS3');
const { setTokenCookie, restoreUser } = require('../../utils/auth');
const { User } = require('../../db/models');

const validateLogin = [
  check('credential')
    .exists({ checkFalsy: true })
    .notEmpty()
    .withMessage('Please provide a valid email or username.'),
  check('password')
    .exists({ checkFalsy: true })
    .withMessage('Please provide a password.'),
  handleValidationErrors,
];

// Log in
router.post(
  '/',
  validateLogin,
  asyncHandler(async (req, res, next) => {
    const { credential, password } = req.body;

    const user = await User.login({ credential, password });

    if (!user) {
      const err = new Error('Login failed');
      err.status = 401;
      err.title = 'Login failed';
      err.errors = ['The provided credentials were invalid.'];
      return next(err);
    }

    await setTokenCookie(res, user);

    return res.json({
      user,
    });
  }),
);

// Log out
router.delete(
    '/',
    (_req, res) => {
      res.clearCookie('token');
      return res.json({ message: 'success' });
    }
);

// Restore session user
router.get(
    '/',
    restoreUser,
    (req, res) => {
      const { user } = req;
      if (user) {
        return res.json({
          user: user.toSafeObject()
        });
      } else return res.json({});
    }
);

router.get('/:id', asyncHandler(async (req, res) => {
  const id = parseInt(req.params.id, 10);
  const user = await User.findByPk(id)

  return res.json(user)
}))
  
router.put('/updateUser/:id', singleMulterUpload("image"), asyncHandler(async (req, res) => {
  const id = parseInt(req.params.id, 10)
  const {firstName, lastName, username } = req.body
  const user = await User.findByPk(id)
  // const profileImageUrl = await singlePublicFileUpload(req.file)
  // const banner = await singlePublicFileUpload(req.file)
  const update = await user.update({
    firstName,
    lastName,
    username,
    // profileImageUrl,
    // banner
  })
  return res.json(update)
}))

router.put('/updateProfileImage/:id', singleMulterUpload("image"), asyncHandler(async (req, res) => {
  const id = parseInt(req.params.id, 10)
  // const { firstName, lastName, username } = req.body
  const user = await User.findByPk(id)
  const profileImageUrl = await singlePublicFileUpload(req.file)
  // const banner = await singlePublicFileUpload(req.file)
  const update = await user.update({
    // firstName,
    // lastName,
    // username,
    profileImageUrl,
    // banner
  })
  return res.json(update)
}))

// router.put('/updateBanner/:id', singleMulterUpload("image"), asyncHandler(async (req, res) => {
//   const id = parseInt(req.params.id, 10)
//   const user = await User.findByPk(id)
//   const banner = await singlePublicFileUpload(req.file)
//   const update = await user.update({ banner })
//   return res.json(update)
// }))
router.put('/updateBanner/:id', singleMulterUpload("image"), asyncHandler(async (req, res) => {
  const id = parseInt(req.params.id, 10)
  // const { firstName, lastName, username } = req.body
  const user = await User.findByPk(id)
  // const profileImageUrl = await singlePublicFileUpload(req.file)
  const banner = await singlePublicFileUpload(req.file)
  const update = await user.update({
    // firstName,
    // lastName,
    // username,
    // profileImageUrl,
    banner
  })
  return res.json(update)
}))
  
module.exports = router;