"use strict";

module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert("Tags", [
      { name: "Planet" },
      { name: "Galaxy" },
      { name: "Other" },
      { name: "Unknown" },
      { name: "habitable" },
      { name: "red-dwarf" },
      { name: "black-hole" },
      { name: "moon" },
      { name: "star" },
      { name: "landscape" },
    ]);
  },

  down: (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete("Tags", null, {});
  },
};
