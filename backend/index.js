const { port } = require('./config');
require('dotenv').config();
const env = process.env.NODE_ENV || 'development';

console.log("********************************", { env })

const app = require('./app');
const db = require('./db/models');

// Check the database connection before starting the app
db.sequelize
    .authenticate()
    .then(() => {
        console.log('Database connection success! Sequelize is ready to use...');
        // console.log("THE DBDBDBDBDBDBDBDBDBDB", db)

        // Start listening for connections
        app.listen(port, () => console.log(`Listening on port ${port}...`));
    })
    .catch((err) => {
        console.log('Database connection failure.');
        console.error(err);
    });