import React, { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { useParams, useHistory } from "react-router-dom";
import { getSingleUserPhoto, getAllPhotos } from "../../store/photos";
import {
  addUserLikeToPhoto,
  getAllLikes,
  deleteSingleLike,
} from "../../store/likes";
import { getAllComments } from "../../store/comments";
import Comments from "../Comments";
import UpdateDelePhoto from "../UpdateDeletePhoto";
import FavoriteIcon from "@material-ui/icons/Favorite";
import MoreHorizIcon from "@material-ui/icons/MoreHoriz";
import "./UserPhotos.css";
import { Modal } from "../../context/Modal";

function UserPhoto() {
  const history = useHistory();
  const dispatch = useDispatch();
  const { photoId } = useParams();
  const user = useSelector((state) => state.session.user);
  const photo = useSelector((state) => state.photos[photoId]);
  const likes = useSelector((state) => state.likes);
  const comments = useSelector((state) => state.comments);
  const tags = photo?.Tags;
  const likeId = Object.values(likes).find(
    (like) => like.userId == user.id && like.photoId == photoId
  );
  const deleteLike = parseInt(likeId?.id, 10);
  const photoLength = photo?.Likes?.length;
  const likesInPhoto = Object.values(likes)?.filter(
    (like) => like.photoId == photoId
  );
  const [deleteSwitch, setDeleteSwitch] = useState(false);
  const [openUpdateDeleteModal, setOpenUpdateDeleteModal] = useState(false);
  const isPhotoLiked = likesInPhoto?.some((like) => like.userId === user.id);

  useEffect(() => {
    dispatch(getSingleUserPhoto(photoId));
    dispatch(getAllComments(photoId));
  }, [dispatch, photoId]);

  // useEffect(() => {
  //     dispatch(getAllPhotos())
  //     dispatch(getAllLikes)
  // }, [dispatch, likeId, deleteLike])

  useEffect(() => {
    dispatch(getAllLikes());
  }, [dispatch, deleteLike]);

  useEffect(() => {
    dispatch(getAllPhotos());
    dispatch(getAllLikes);
  }, []);

  const addLike = async (e) => {
    e.preventDefault();
    const addSingleLikeToPhoto = {
      photoId: photoId,
      userId: user.id,
    };
    await dispatch(addUserLikeToPhoto(addSingleLikeToPhoto));
  };

  const dislike = async (e) => {
    e.preventDefault();
    await dispatch(deleteSingleLike(deleteLike));
  };

  useEffect(() => {
    dispatch(getAllPhotos());
    dispatch(getAllLikes);
  }, [dispatch, isPhotoLiked]);

  function openUpdateDeleteModalFunction() {
    setOpenUpdateDeleteModal((prev) => !prev);
  }

  return (
    <div className="photo__component">
      <div className="photo__component__img">
        <img src={photo?.imgUrl} alt={photo?.title} className="single-photo" />
        <MoreHorizIcon
          className="horiz-icon"
          onClick={openUpdateDeleteModalFunction}
        ></MoreHorizIcon>
        {openUpdateDeleteModal && (
          <Modal onClose={openUpdateDeleteModalFunction}>
            <div className="update__delete__container">
              <h3 className="update__delete__title">Edit your photo</h3>
              <input
                type="text"
                className="update__delete__input"
                value={photo.title}
              />
              <input
                type="text"
                className="update__delete__input"
                value={photo.description}
              />
              <button className="update__button">Save updates</button>
              <button className="delete__button">Delete photo</button>
            </div>
          </Modal>
        )}
        <FavoriteIcon
          onClick={isPhotoLiked ? dislike : addLike}
          style={{
            color: isPhotoLiked ? "red" : "white",
          }}
          className="heart-icon"
        ></FavoriteIcon>
      </div>
      <div className="photo__component__info__comments__and__tags">
        <div className="photo__component__background">
          <div>
            <div className="photo__component__information">
              <div className="photo__component__photo__information">
                <img
                  src={photo?.User.profileImageUrl}
                  alt={`${photo?.User.firstName}`}
                  className="photo__component__photo__owner__img"
                />
                <div className="photo__component__photo__owner__photo__title">
                  <a
                    className="photo__component__photo__owner__name"
                    href={`/profile/${photo?.User.id}`}
                    onClick={(e) => {
                      e.preventDefault();
                      history.push(`/profile/${photo?.User.id}`);
                    }}
                  >
                    {photo?.User.firstName}
                  </a>
                  <h3 className="photo__component__photo__title">
                    {photo?.title}
                  </h3>
                  <p>{photo?.description}</p>
                </div>
              </div>
              <div className="photo__component__metadata">
                <div className="photos__faves__count">
                  <p className="faves__count">{photoLength}</p>
                  <p className="faves__text">faves</p>
                </div>
                <div className="photos__comments__count">
                  <p className="comments__count">
                    {Object.values(comments).length}
                  </p>
                  <p className="comments__text">comments</p>
                </div>
              </div>
            </div>
          </div>
          <div>
            {/* <UpdateDelePhoto></UpdateDelePhoto> */}
            <hr />
          </div>
          <div>
            <Comments></Comments>
          </div>
        </div>
        <div className="photo__component__tags">
          <div className="tags">
            <p className="tags__title">Tags</p>
            <div className="tags__container">
              {tags?.map(function (tag, idx) {
                return (
                  <div className="photo__component__tag" key={idx}>
                    {tag?.name}
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default UserPhoto;
