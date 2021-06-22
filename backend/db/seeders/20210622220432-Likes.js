'use strict';

module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert('Likes', [
      { photoId: 1, userId: 2 },
      { photoId: 1, userId: 3 },
      { photoId: 1, userId: 4 },
      { photoId: 1, userId: 5 },
      { photoId: 1, userId: 6 },
      { photoId: 2, userId: 2 },
      { photoId: 2, userId: 3 },
      { photoId: 2, userId: 4 },
    ])
  },

  down: (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('Likes', null, {})
  }
};
