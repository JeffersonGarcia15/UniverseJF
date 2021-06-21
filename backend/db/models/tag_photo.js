'use strict';
module.exports = (sequelize, DataTypes) => {
  const Tag_Photo = sequelize.define('Tag_Photo', {
    photoId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    tagId: {
      type: DataTypes.INTEGER,
      allowNull: false
    }
  }, {});
  Tag_Photo.associate = function(models) {
    // associations can be defined here
  };
  return Tag_Photo;
};