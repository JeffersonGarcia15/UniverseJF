import React, { useEffect } from "react";
import { Redirect, useHistory } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux";
import { getAllPhotos } from "../../store/photos";
import "./Explore.css";

function Explore() {
  const history = useHistory();
  const dispatch = useDispatch();
  const user = useSelector((state) => state.session.user);
  const photos = useSelector((state) => state.photos);

  useEffect(() => {
    dispatch(getAllPhotos());
  }, [dispatch]);

  if (!user) {
    return <Redirect to="/auth"></Redirect>;
  }

  return (
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
            </div>
          );
        })}
      </div>
    </div>
  );
}

export default Explore;
