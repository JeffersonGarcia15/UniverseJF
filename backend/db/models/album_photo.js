'use strict';
module.exports = (sequelize, DataTypes) => {
  const Album_Photo = sequelize.define('Album_Photo', {
    photoId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    albumId: {
      type: DataTypes.INTEGER,
      allowNull: false
    } 
  }, {});
  Album_Photo.associate = function(models) {
    // associations can be defined here
  };
  return Album_Photo;
};