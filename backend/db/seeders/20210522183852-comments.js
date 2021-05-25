'use strict';

module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert('Comments', [
      {body: 'So beautiful', userId: 2, photoId: 1},
      { body: 'That looks just like Earth!', userId: 3, photoId: 1 },
      { body: 'That photo looks almost as good as the ones I take!', userId: 4, photoId: 1},
      { body: 'That looks just like the picture I uploaded!', userId: 4, photoId: 2},
      { body: 'No comments', userId: 2, photoId: 3},
      { body: 'Great picture', userId: 1, photoId: 4 },
      { body: 'Awesome picture', userId: 4, photoId: 5 },
      { body: 'Did you steal that picture from me?', userId: 1, photoId: 6 },
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
    return queryInterface.bulkDelete('Comments', null, {})
  }
};
