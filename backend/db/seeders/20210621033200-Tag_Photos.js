"use strict";

module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert("Tag_Photos", [
      { photoId: 1, tagId: 1 },
      { photoId: 1, tagId: 2 },
      { photoId: 1, tagId: 3 },
      { photoId: 1, tagId: 4 },
      { photoId: 1, tagId: 5 },
      { photoId: 1, tagId: 6 },
      { photoId: 1, tagId: 7 },
      { photoId: 1, tagId: 8 },
      { photoId: 1, tagId: 9 },
      { photoId: 1, tagId: 10 },
      { photoId: 2, tagId: 2 },
      { photoId: 3, tagId: 3 },
      { photoId: 6, tagId: 4 },
      { photoId: 7, tagId: 5 },
      { photoId: 23, tagId: 6 },
      { photoId: 24, tagId: 7 },
    ]);
  },

  down: (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete("Tag_Photos", null, {});
  },
};
