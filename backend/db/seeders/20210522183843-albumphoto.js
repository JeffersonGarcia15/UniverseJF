'use strict';

module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert('AlbumPhotos', [
      { photoId: 1, albumId: 1 },
      { photoId: 2, albumId: 1},
      { photoId: 3, albumId: 1 },
      { photoId: 4, albumId: 1 },
      { photoId: 5, albumId: 3 },
      { photoId: 6, albumId: 2 },
      { photoId: 7, albumId: 2 },
      { photoId: 8, albumId: 2 },
      { photoId: 9, albumId: 2 },
      { photoId: 10, albumId: 3 },
      { photoId: 11, albumId: 3 },
      { photoId: 12, albumId: 1 },
      { photoId: 13, albumId: 3 },
      { photoId: 14, albumId: 1 },
      { photoId: 15, albumId: 1 },
      { photoId: 16, albumId: 2 },
      { photoId: 17, albumId: 3 },
      { photoId: 18, albumId: 3 },
      { photoId: 19, albumId: 3 },
      { photoId: 20, albumId: 3 },
      { photoId: 21, albumId: 1 },
      { photoId: 22, albumId: 4 },
      { photoId: 23, albumId: 4 },
      { photoId: 24, albumId: 5},
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
