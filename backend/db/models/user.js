'use strict';
const { Validator } = require('sequelize');
const bcrypt = require('bcryptjs');

module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define('User', {
    firstName: {
      type: DataTypes.STRING(30),
      allowNull: false,
    },
    lastName: {
      type: DataTypes.STRING(30),
      allowNull: false,
    },
    username: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        len: [3, 30],
        isNotEmail(value) {
          if (Validator.isEmail(value)) {
            throw new Error('Cannot be an email.');
          }
        },
      },
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        len: [3, 256]
      },
    },
    hashedPassword: {
      type: DataTypes.STRING.BINARY,
      allowNull: false,
      validate: {
        len: [60, 60]
      },
    },
    profileImageUrl: {
      type: DataTypes.STRING,
      allowNull: true,
      defaultValue: 'https://universejf.s3.us-east-2.amazonaws.com/default-avatar.png'
    },
    banner: {
      type: DataTypes.STRING,
      allowNull: true,
      defaultValue: 'https://universejf.s3.us-east-2.amazonaws.com/20180121_Taipei%2C_Taiwan_Skyline_from_Xiangshan.jpg'
    }
  },
  {
    defaultScope: {
      attributes: {
        exclude: ['hashedPassword', 'email', 'createdAt', 'updatedAt'],
      },
    },
    scopes: {
      currentUser: {
        attributes: { exclude: ['hashedPassword'] },
      },
      loginUser: {
        attributes: {},
      },
    },
  });

  User.prototype.toSafeObject = function () { // remember, this cannot be an arrow function
    const { id, firstName, lastName, username, email, profileImageUrl, banner } = this; // context will be the User instance
    return { id, firstName, lastName, username, email, profileImageUrl, banner };
  };

  User.prototype.validatePassword = function (password) {
    return bcrypt.compareSync(password, this.hashedPassword.toString());
  };

  User.getCurrentUserById = async function (id) {
    return await User.scope('currentUser').findByPk(id);
  };

  User.login = async function ({ credential, password }) {
    const { Op } = require('sequelize');
    const user = await User.scope('loginUser').findOne({
      where: {
        [Op.or]: {
          username: credential,
          email: credential,
        },
      },
    });
    if (user && user.validatePassword(password)) {
      return await User.scope('currentUser').findByPk(user.id);
    }
  };

  User.signup = async function ({ firstName, lastName, username, email, password, profileImageUrl }) {
    const hashedPassword = bcrypt.hashSync(password);
    const user = await User.create({
      firstName,
      lastName,
      username,
      email,
      hashedPassword,
      profileImageUrl
    });
    return await User.scope('currentUser').findByPk(user.id);
  };
  
  User.associate = function(models) {
    User.hasMany(models.Photo, { foreignKey: 'userId' });
    User.hasMany(models.Album, { foreignKey: 'userId' });
    User.hasMany(models.Comment, { foreignKey: 'userId' });
    User.hasMany(models.Like, { foreignKey: 'userId'})
  };
  return User;
};