'use strict';
module.exports = (sequelize, DataTypes) => {
  const Album = sequelize.define('Album', {
    title: {
      type: DataTypes.STRING,
      allowNull: false
    },
    description: {
      type: DataTypes.STRING
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false
    }
  }, {});
  Album.associate = function (models) {
    Album.belongsTo(models.User, { foreignKey: 'userId' })
    const columnMapping = {
      through: 'AlbumPhoto',
      otherKey: 'photoId',
      foreignKey: 'albumId',
      onDelete: 'CASCADE'
    }
    Album.belongsToMany(models.Photo, columnMapping)
    Album.hasMany(models.AlbumPhoto, { foreignKey: 'albumId', onDelete: 'CASCADE', hooks: true})
  };
  return Album;
};