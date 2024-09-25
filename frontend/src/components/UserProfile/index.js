import React, { useEffect } from "react";
import { useParams, useHistory } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux";
import { getUsersPhotos } from "../../store/photos";
import ProfileNavBar from "../ProfileNavBar";
import "./UserProfile.css";

function UserProfile() {
  const history = useHistory();
  const dispatch = useDispatch();
  const { userId } = useParams();
  const user = useSelector((state) => state.session.user);
  const photos = useSelector((state) => state.photos);

  const photoInfo = Object.values(photos);
  useEffect(() => {
    dispatch(getUsersPhotos(userId));
  }, [dispatch, userId]);

  const photostreamNavBar = (e) => {
    e.preventDefault();
    history.push(`/profile/${userId}`);
  };

  const albumsNavBar = (e) => {
    e.preventDefault();
    history.push(`/profile/${userId}/albums`);
  };

  return (
    <React.Fragment>
      <ProfileNavBar></ProfileNavBar>

      <div className="explore__container">
        <div className="explore__photo--grid">
          {Object.values(photos).map((photo) => {
            return (
              <div key={photo.id} className="single-photo-container">
                <a
                  href={`/photos/${photo.id}`}
                  onClick={(e) => {
                    e.preventDefault();
                    history.push(`/photos/${photo.id}`);
                  }}
                >
                  <div className="photo-collection">
                    <img
                      className="photo-info"
                      src={photo.imgUrl}
                      alt={photo.title}
                    />
                    <div className="photo-title">
                      <p className="user-photo-title">{photo.title}</p>
                      <p className="photo-user">by {photo.User?.username}</p>
                    </div>
                  </div>
                </a>
                {/* <a href={`/profile/${photo?.User.id}`}>
                                <div>
                                    <p id='photo-user'>by {photo.User?.username}</p>
                                </div>
                            </a> */}
              </div>
            );
          })}
        </div>
      </div>
      {/* <div className='profile-side-container'>
                <div className='profile-avatar'>

                </div>

            </div> */}
    </React.Fragment>
  );
}

export default UserProfile;
