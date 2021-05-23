'use strict';

module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert('Photos', [
      { title: "Gliese 667Cc", description: "Earth Siblings", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/gliese-667cc.jpg", userId: 1 },
      { title: "Kepler-22b", description: "Earth Siblings", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/607694main_Kepler22bArtwork_full.jpg", userId: 1 },
      { title: "Kepler-69c", description: "Earth Siblings", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/742553main_Kepler69c_full.jpg", userId: 1 },
      { title: "Kepler-62f", description: "Planet that looks like Earth", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/742529main_Kepler62f_full.jpg", userId: 2 },
      { title: "Kepler-186f", description: 'Planet photo', imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/kepler186f_artistconcept_2.jpg", userId: 3 },
      { title: "Kepler-452b", description: 'A random planet', imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/452b_artistconcept_beautyshot.jpg", userId: 4 },
    ])
  },

  down: (queryInterface, Sequelize) => {
    /*
      Add reverting commands here.
      Return a promise to correctly handle asynchronicity.

      Example:
      return queryInterface.bulkDelete('People', null, {});
    */
   return queryInterface.bulkDelete('Photos', null, {});
  }
};
