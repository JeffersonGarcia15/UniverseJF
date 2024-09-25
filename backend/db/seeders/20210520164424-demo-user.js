"use strict";
// const faker = require('faker');
const bcrypt = require("bcryptjs");

module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert(
      "Users",
      [
        {
          firstName: "Jefferson",
          lastName: "Lopez",
          username: "JeffersonGarcia15",
          profileImageUrl:
            "https://universejf.s3.us-east-2.amazonaws.com/image.png",
          email: "jeffersongarcia1599@gmail.com",
          hashedPassword: bcrypt.hashSync("Physics1!"),
        },
        {
          firstName: "Yeilyn",
          lastName: "Portillo",
          username: "Yeilyn",
          profileImageUrl:
            "https://astrogram.s3.us-east-2.amazonaws.com/avatar.png",
          email: "Yeilyn@gmail.com",
          hashedPassword: bcrypt.hashSync("yoga"),
        },
        {
          firstName: "Jaba",
          lastName: "Bancroft",
          username: "Jaba",
          profileImageUrl:
            "https://universejf.s3.us-east-2.amazonaws.com/jaba.png",
          email: "jababancroft@gmail.com",
          hashedPassword: bcrypt.hashSync("Greenpepper"),
        },
        {
          firstName: "Jonas",
          lastName: "Garcia",
          username: "JonasG4",
          profileImageUrl:
            "https://universejf.s3.us-east-2.amazonaws.com/Jonas.jpg",
          email: "jonasgarcia@gmail.com",
          hashedPassword: bcrypt.hashSync("izalco"),
        },
        {
          firstName: "Kevin",
          lastName: "Garcia",
          username: "Qu3boludo",
          profileImageUrl:
            "https://universejf.s3.us-east-2.amazonaws.com/Qu3bo.jpg",
          email: "kevingarcia@gmail.com",
          hashedPassword: bcrypt.hashSync("soyapango"),
        },
        {
          firstName: "Adonay",
          lastName: "Reyes",
          username: "Warron",
          profileImageUrl:
            "https://universejf.s3.us-east-2.amazonaws.com/Adonay.jpg",
          email: "adonayreyes@gmail.com",
          hashedPassword: bcrypt.hashSync("ilopango"),
        },
      ],
      {}
    );
  },

  down: (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete("Users", null, {});
  },
};
