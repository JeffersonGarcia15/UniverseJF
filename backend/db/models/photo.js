'use strict';
module.exports = (sequelize, DataTypes) => {
  const Photo = sequelize.define('Photo', {
    title: {
      type: DataTypes.STRING,
      allowNull: false
    },
    description: {
      type: DataTypes.STRING
    },
    imgUrl: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    }
  }, {});
  Photo.associate = function(models) {
    Photo.belongsTo(models.User, { foreignKey: 'userId'})
    const columnMapping = {
      through: 'Album_Photo',
      otherKey: 'albumId',
      foreignKey: 'photoId',
      onDelete: 'CASCADE'
    }
    Photo.belongsToMany(models.Album, columnMapping)
  };

  Photo.uploadImage = async function (title, description, imgUrl, userId) {
    const photo = await Photo.create({
      title,
      description,
      imgUrl,
      userId
    });
    return photo;
  };
  return Photo;
};