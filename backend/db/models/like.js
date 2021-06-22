'use strict';
module.exports = (sequelize, DataTypes) => {
  const Like = sequelize.define('Like', {
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    photoId: {
      type: DataTypes.INTEGER,
      allowNull: false
    }
  }, {});
  Like.associate = function(models) {
    Like.belongsTo(models.Photo, { foreignKey: 'photoId'})
    Like.belongsTo(models.User, { foreignKey: 'userId'})
  };
  return Like;
};