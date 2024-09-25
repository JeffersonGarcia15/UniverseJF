import React, { useState } from "react";
import { useParams, useHistory } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux";
import { addSingleUserAlbum } from "../../store/albums";
import EditProfileModal from "./EditProfileModal";
import EditProfilePictureModal from "./EditProfilePictureModal";
import EditBannerModal from "./EditBannerModal";

import AddIcon from "@material-ui/icons/Add";

import "./ProfileNavBar.css";
import { Modal } from "../../context/Modal";

function ProfileNavBar() {
  const { userId } = useParams();

  const dispatch = useDispatch();
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [toggleCreateAlbum, setToggleCreateAlbum] = useState(false);
  const user = useSelector((state) => state.session.user);
  const photos = useSelector((state) => state.photos);
  const history = useHistory();
  const photoInfo = Object.values(photos);

  const photostreamNavBar = (e) => {
    e.preventDefault();
    history.push(`/profile/${userId}`);
  };

  const albumsNavBar = (e) => {
    e.preventDefault();
    history.push(`/profile/${userId}/albums`);
  };

  const createAlbum = async (e) => {
    e.preventDefault();
    const albumObject = {
      title,
      description,
      userId: user.id,
    };
    dispatch(addSingleUserAlbum(albumObject));
    setTitle("");
    setDescription("");
    setToggleCreateAlbum((prev) => !prev);
  };

  function toggleCreateAlbumFunction() {
    setToggleCreateAlbum((prev) => !prev);
  }

  return (
    <div>
      <div
        className="profile-container"
        style={{ backgroundImage: `url(${user.banner})` }}
      >
        <div className="user-info-container">
          <img
            src={user.profileImageUrl}
            alt="profile"
            className="Profile-img"
          />
          <EditProfilePictureModal />
        </div>

        <div className="user-info-profile">
          <h2 className="full-name">
            {user.firstName} {user.lastName}
          </h2>
          <div className="extra-info">
            <p className="user-name">{user.username}</p>
            <a className="followers" href="">
              followers(coming soon...)
            </a>
            <a className="following" href="">
              following(coming soon...)
            </a>
            <p className="count-photo-user">{photoInfo.length} photo(s)</p>
            <EditBannerModal />
          </div>
        </div>
      </div>
      <div className="navBars">
        <button className="tag" onClick={photostreamNavBar}>
          Photostream
        </button>
        <button className="tag" onClick={albumsNavBar}>
          Albums
        </button>
        <AddIcon
          onClick={toggleCreateAlbumFunction}
          className="albums__add--icon"
        />
        {toggleCreateAlbum && (
          <Modal onClose={toggleCreateAlbumFunction}>
            <div className="update__delete__container">
              <h3 className="update__delete__title">Create a new album</h3>
              <input
                type="text"
                placeholder="Title..."
                className="update__delete__input"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
              />
              <input
                type="text"
                className="update__delete__input"
                placeholder="Description..."
                value={description}
                onChange={(e) => setDescription(e.target.value)}
              />
              <button className="update__button" onClick={createAlbum}>
                Create
              </button>
            </div>
          </Modal>
        )}
      </div>
      <div>
        <EditProfileModal></EditProfileModal>
      </div>
    </div>
  );
}

export default ProfileNavBar;
