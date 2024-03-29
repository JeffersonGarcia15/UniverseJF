const router = require('express').Router();
const sessionRouter = require('./session.js');
const usersRouter = require('./users.js');
const photosRouter = require('./photos')
const albumsRouter = require('./albums')
const commentsRouter = require('./comments')
const tagsRouter = require('./tag')
const likesRouter = require('./likes')

router.use('/session', sessionRouter);

router.use('/users', usersRouter);

router.use('/photos', photosRouter)

router.use('/albums', albumsRouter)

router.use('/comments', commentsRouter)

router.use('/tags', tagsRouter)

router.use('/likes', likesRouter)

router.post('/test', function (req, res) {
    res.json({ requestBody: req.body });
});

// GET /api/set-token-cookie
const asyncHandler = require('express-async-handler');
const { setTokenCookie } = require('../../utils/auth.js');
const { User } = require('../../db/models');
router.get('/set-token-cookie', asyncHandler(async (req, res) => {
    const user = await User.findOne({
        where: {
            username: 'Demo-lition'
        },
    })
    setTokenCookie(res, user);
    return res.json({ user });
}));

const { restoreUser } = require('../../utils/auth.js');
router.get(
    '/restore-user',
    restoreUser,
    (req, res) => {
        return res.json(req.user);
    }
);

const { requireAuth } = require('../../utils/auth.js');
router.get(
    '/require-auth',
    requireAuth,
    (req, res) => {
        return res.json(req.user);
    }
);

router.get('/', (req, res) => {
    res.send('Hello World!')
})

module.exports = router;