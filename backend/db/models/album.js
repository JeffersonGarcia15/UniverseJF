"use strict";
module.exports = (sequelize, DataTypes) => {
  const Album = sequelize.define(
    "Album",
    {
      title: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      description: {
        type: DataTypes.STRING,
      },
      userId: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
    },
    {
      hooks: {
        // Before the album is destroyed, find all associated photos and delete them
        async beforeDestroy(album, options) {
          const photos = await album.getPhotos(); // Fetch all associated photos
          for (let photo of photos) {
            await photo.destroy(); // Delete each photo
          }
        },
      },
    }
  );

  Album.associate = function (models) {
    Album.belongsTo(models.User, { foreignKey: "userId" });

    const columnMapping = {
      through: "AlbumPhoto",
      otherKey: "photoId",
      foreignKey: "albumId",
      onDelete: "CASCADE",
    };

    Album.belongsToMany(models.Photo, columnMapping);
    Album.hasMany(models.AlbumPhoto, {
      foreignKey: "albumId",
      onDelete: "CASCADE",
      hooks: true,
    });
  };

  return Album;
};
