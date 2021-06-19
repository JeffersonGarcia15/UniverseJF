'use strict';
module.exports = (sequelize, DataTypes) => {
  const AlbumPhoto = sequelize.define('AlbumPhoto', {
    photoId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    albumId: {
      type: DataTypes.INTEGER,
      allowNull: false
    } 
  }, {});
  AlbumPhoto.associate = function(models) {
    AlbumPhoto.belongsTo(models.Photo, { foreignKey: 'photoId' })
  };
  return AlbumPhoto;
};