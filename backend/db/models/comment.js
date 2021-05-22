'use strict';
module.exports = (sequelize, DataTypes) => {
  const Comment = sequelize.define('Comment', {
    body: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    photoId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
  }, {});
  Comment.associate = function(models) {
    Comment.belongsTo(models.User, { foreignKey: 'userId'})
    Comment.belongsTo(models.Photo, { foreignKey: 'photoId'})
  };
  return Comment;
};