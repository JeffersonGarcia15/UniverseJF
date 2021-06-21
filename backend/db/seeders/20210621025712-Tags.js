'use strict';

module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert('Tags', [
      { name: "Planet" },
      { name: "Planet" },
      { name: "Planet" },
      { name: "Galaxy" },
      { name: "Galaxy" },
      { name: "Other" },
      { name: "Unknown" },
    ])
  },

  down: (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('Tags', null, {})
  }
};
