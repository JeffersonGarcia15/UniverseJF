'use strict';
module.exports = (sequelize, DataTypes) => {
  const Tag = sequelize.define('Tag', {
    name: DataTypes.STRING
  }, {});
  Tag.associate = function(models) {
    const columnMapping = {
      through: 'Tag_Photo',
      otherKey: 'photoId',
      foreignKey: 'tagId',
      onDelete: 'CASCADE'
    }
    Tag.belongsToMany(models.Photo, columnMapping)
  };
  return Tag;
};