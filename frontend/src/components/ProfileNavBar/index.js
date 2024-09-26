import React, { useState } from "react";
import { useParams, useHistory } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux";
import { addSingleUserAlbum } from "../../store/albums";
import {
  updateUserProfilePhoto,
  updateUserBanner,
  updateUserProfile,
} from "../../store/session";
import EditProfileModal from "./EditProfileModal";
import EditProfilePictureModal from "./EditProfilePictureModal";
import EditBannerModal from "./EditBannerModal";

import AddIcon from "@material-ui/icons/Add";
import SettingsIcon from "@material-ui/icons/Settings";

import "./ProfileNavBar.css";
import { Modal } from "../../context/Modal";

function ProfileNavBar() {
  const { userId } = useParams();

  const dispatch = useDispatch();
  const user = useSelector((state) => state.session.user);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [toggleCreateAlbum, setToggleCreateAlbum] = useState(false);
  const [toggleUpdateProfilePicture, setToggleUpdateProfilePicture] =
    useState(false);
  const [toggleUpdateBanner, setToggleUpdateBanner] = useState(false);
  const [toggleUpdateProfile, setToggleUpdateProfile] = useState(false);
  const [username, setUserName] = useState(user.username);
  const [firstName, setFirstName] = useState(user.firstName);
  const [lastName, setLastName] = useState(user.lastName);
  const [banner, setBanner] = useState();
  const [profileImageUrl, setProfileImageUrl] = useState();
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

  const onSubmit = async (e) => {
    e.preventDefault();
    await dispatch(updateUserProfilePhoto(profileImageUrl, user.id));
    setProfileImageUrl();
    setToggleUpdateProfilePicture((prev) => !prev);
  };

  const onSubmitBanner = async (e) => {
    e.preventDefault();
    const data = await dispatch(updateUserBanner(banner, user.id));
    // if (data?.errors) {
    //   setErrors(data?.errors);
    // }
    setToggleUpdateBanner((prev) => !prev);
  };

  const updateProfileImageUrl = (e) => {
    const file = e.target.files[0];
    if (file) setProfileImageUrl(file);
  };

  const updateBanner = (e) => {
    const file = e.target.files[0];
    if (file) setBanner(file);
  };

  function toggleUpdateProfilePictureFunction(e) {
    e.stopPropagation();
    e.preventDefault();
    setToggleUpdateProfilePicture((prev) => !prev);
  }

  function toggleUpdateBannerFunction(e) {
    e.stopPropagation();
    e.preventDefault();
    setToggleUpdateBanner((prev) => !prev);
  }

  function toggleUpdateProfileFunction(e) {
    e.stopPropagation();
    e.preventDefault();
    setToggleUpdateProfile((prev) => !prev);
  }

  const onSubmitProfileUpdate = async (e) => {
    e.preventDefault();
    const data = await dispatch(
      updateUserProfile(firstName, lastName, username, user.id)
    );
    // if (data?.errors) {
    //   setErrors(data?.errors);
    // }
    // history.push('/explore')
    setToggleUpdateProfile((prev) => !prev);
  };

  const updateUserName = (e) => {
    setUserName(e.target.value);
  };

  // const updateFirstName = (e) => {
  //     setFirstName(e.target.value)
  // }

  const updateLastName = (e) => {
    setLastName(e.target.value);
  };

  return (
    <div>
      <div
        className="profile-container"
        style={{ backgroundImage: `url(${user.banner})` }}
        onClick={toggleUpdateBannerFunction}
      >
        {toggleUpdateBanner && (
          <Modal onClose={toggleUpdateBannerFunction}>
            <div
              className="form-UpdateProfile"
              onClick={(e) => e.stopPropagation()}
            >
              <form onSubmit={onSubmitBanner}>
                <h2>Update Banner</h2>
                <div className="upload-file">
                  <label>Change Your Banner</label>
                  <input
                    type="file"
                    accept="image/png, image/gif, image/jpeg"
                    onChange={updateBanner}
                  />
                </div>
                <div>
                  <button type="submit" className="btn-form" disabled={!banner}>
                    Update banner
                  </button>
                </div>
              </form>
            </div>
          </Modal>
        )}
        <div className="user-info-container">
          <img
            onClick={toggleUpdateProfilePictureFunction}
            src={user.profileImageUrl}
            alt="profile"
            className="Profile-img"
          />
          <div className="user-info-profile">
            <div className="name__settings">
              <h2 className="full-name">
                {user.firstName} {user.lastName}
              </h2>
              <SettingsIcon onClick={toggleUpdateProfileFunction} />
            </div>
            <div className="extra-info">
              <p className="user-name">{user.username}</p>
              <p className="count-photo-user">{photoInfo.length} photo(s)</p>
            </div>
          </div>
        </div>

        {toggleUpdateProfile && (
          <Modal onClose={toggleUpdateProfileFunction}>
            <div
              className="form-UpdateProfile"
              onClick={(e) => e.stopPropagation()}
            >
              <form
                onSubmit={onSubmitProfileUpdate}
                className="form-EditProfile"
              >
                {/* <ul className="form-errors">
                  {errors?.map((error, ind) => (
                    <li key={ind}>{error}</li>
                  ))}
                </ul> */}
                <h2>Update Profile</h2>
                <label htmlFor="firstName">First name</label>
                <input
                  type="text"
                  name="firstName"
                  id="firstName"
                  onChange={(e) => setFirstName(e.target.value)}
                  value={firstName}
                  required
                  placeholder="First Name"
                ></input>
                <label htmlFor="lastName">Last name</label>
                <input
                  type="text"
                  name="lastName"
                  id="lastName"
                  onChange={updateLastName}
                  value={lastName}
                  required
                  placeholder="Last Name"
                ></input>
                <label htmlFor="userName">User name</label>
                <input
                  type="text"
                  name="username"
                  id="username"
                  onChange={updateUserName}
                  value={username}
                  required
                  placeholder="username"
                ></input>
                <div>
                  <button type="submit" className="btn-form">
                    Update
                  </button>
                </div>
              </form>
            </div>
          </Modal>
        )}

        {toggleUpdateProfilePicture && (
          <Modal onClose={toggleUpdateProfilePictureFunction}>
            <div
              className="form-UpdateProfile"
              onClick={(e) => e.stopPropagation()}
            >
              <form onSubmit={onSubmit}>
                {/* <ul className="form-errors">
                {errors?.map((error, ind) => (
                  <li key={ind}>{error}</li>
                ))}
              </ul> */}
                <h2>Update profile picture</h2>
                <div className="upload-file">
                  <label>Change Your Profile Picture</label>
                  <input
                    type="file"
                    accept="image/png, image/gif, image/jpeg"
                    onChange={updateProfileImageUrl}
                  />
                </div>
                <div>
                  <button
                    type="submit"
                    className="btn-form"
                    disabled={!profileImageUrl}
                  >
                    Save changes
                  </button>
                </div>
              </form>
            </div>
          </Modal>
        )}
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
    </div>
  );
}

export default ProfileNavBar;
