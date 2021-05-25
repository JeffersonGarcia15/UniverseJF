'use strict';

module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert('AlbumPhotos', [
      { photoId: 1, albumId: 1 },
      { photoId: 2, albumId: 1},
      { photoId: 3, albumId: 1 },
      { photoId: 4, albumId: 2 },
      { photoId: 5, albumId: 3 },
      { photoId: 6, albumId: 3 },
    ])
    /*
      Add altering commands here.
      Return a promise to correctly handle asynchronicity.

      Example:
      return queryInterface.bulkInsert('People', [{
        name: 'John Doe',
        isBetaMember: false
      }], {});
    */
  },

  down: (queryInterface, Sequelize) => {
    /*
      Add reverting commands here.
      Return a promise to correctly handle asynchronicity.

      Example:
      return queryInterface.bulkDelete('People', null, {});
    */
   return queryInterface.bulkDelete('AlbumPhotos', null, {})
  }
};
