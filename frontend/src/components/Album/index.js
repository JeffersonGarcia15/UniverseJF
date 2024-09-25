import React, { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { useParams, useHistory } from "react-router-dom";
import {
  getUserAlbums,
  addSingleUserAlbum,
  updateAlbum,
  deleteSingleAlbum,
} from "../../store/albums";
import ProfileNavBar from "../ProfileNavBar";

import MoreHorizIcon from "@material-ui/icons/MoreHoriz";

import "./Albums.css";
import { Modal } from "../../context/Modal";
// import '../UserProfile/UserProfile.css'

function Albums() {
  const dispatch = useDispatch();
  const { userId } = useParams();
  const user = useSelector((state) => state.session.user);
  const albums = useSelector((state) => state.albums);
  const [selectedAlbum, setSelectedAlbum] = useState();
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [newTitle, setNewTitle] = useState("");
  const [newDescription, setNewDescription] = useState("");
  const [newAlbum, setNewAlbum] = useState("");
  const [showForm, setShowForm] = useState(false);
  const [newShowForm, setNewShowForm] = useState(false);
  const [formId, setFormId] = useState(null);
  const history = useHistory();

  useEffect(() => {
    dispatch(getUserAlbums(userId));
  }, [dispatch, userId]);

  const createAlbum = async (e) => {
    e.preventDefault();
    const albumObject = {
      title: newTitle,
      description: newDescription,
      userId: user.id,
    };
    dispatch(addSingleUserAlbum(albumObject));
    setNewTitle("");
    setNewDescription("");
  };

  const editAlbum = async (e) => {
    e.preventDefault();
    await dispatch(updateAlbum(title, description, selectedAlbum.id));
    setTitle("");
    setDescription("");
    setShowForm(false);
    // dispatch(updateAlbum({
    //     title,
    //     description,
    //     // albumId
    // }))
  };

  const deleteAlbum = () => {
    let alert = window.confirm("Are you sure you want to delete your album?");
    if (alert) {
      dispatch(deleteSingleAlbum(selectedAlbum.id));
    }
  };

  const toggleUpdateDeleteAlbum = (album) => {
    setShowForm((prev) => !prev);
    setTitle(album.title);
    setDescription(album.description);
    setFormId(album.id);
    setSelectedAlbum(album);
  };

  return (
    <div className="background">
      <ProfileNavBar></ProfileNavBar>
      {/* <div className="new">
        <button onClick={() => setNewShowForm(true)}>New Album</button>
      </div> */}
      {/* {newShowForm && (
        <div className="newalbum">
          <form onSubmit={createAlbum}>
            <input
              className="inputalbum"
              placeholder="Title"
              type="text"
              value={newTitle}
              onChange={(e) => setNewTitle(e.target.value)}
            />
            <br />
            <textarea
              placeholder="Description"
              type="text"
              value={newDescription}
              onChange={(e) => setNewDescription(e.target.value)}
              cols="30"
              rows="10"
            ></textarea>
            <br />
            <button type="submit">Save Album</button>
          </form>
        </div>
      )} */}
      <div className="albums">
        {Object.values(albums).map((album) => {
          return (
            <div key={album.id} className="album">
              {/* <div className="title">
              <h4>{album.title}</h4>
            </div>
            <div>
              <h4>{album.description}</h4>
            </div> */}
              {/* <div>
              {user.id === album.userId && (
                <div>
                  <button onClick={() => openForm(album)}>Edit Album</button>
                  {showForm && album.id === formId ? (
                    <form
                      onSubmit={(e) =>
                        editAlbum(album.id, title, description, e)
                      }
                      key={album.id}
                    >
                      <input
                        type="text"
                        value={title}
                        onChange={(e) => setTitle(e.target.value)}
                      />
                      <input
                        type="text"
                        value={description}
                        onChange={(e) => setDescription(e.target.value)}
                      />
                      <button
                        type="submit"
                        onSubmit={(e) =>
                          editAlbum(album.id, title, description, e)
                        }
                      >
                        Edit Title
                      </button>
                      <button onClick={() => deleteAlbum(album.id)}>
                        Delete Album
                      </button>
                    </form>
                  ) : null}
                </div>
              )}
            </div> */}
              <div className="explore-container">
                <div className="photo-container">
                  {album.Photos && (
                    <div
                      key={album.Photos[0]?.id}
                      className="single-photo-container"
                    >
                      {/* <a href={`/albums/${album.id}`}> */}
                      <div className="photo-collection">
                        <img
                          className="photo-info"
                          src={album.Photos[0]?.imgUrl}
                          alt={album.Photos[0]?.title}
                        />
                        <MoreHorizIcon
                          className="albums__horiz--icon"
                          onClick={() => toggleUpdateDeleteAlbum(album)}
                        />
                        <div className="photo-title">
                          <p className="user-photo-title">{album.title}</p>
                          <p className="user-photo-description">
                            {album.description}
                          </p>
                          <p className="user-number-photos">
                            {album.Photos.length === 1
                              ? "1 photo"
                              : `${album.Photos.length} photos`}
                          </p>
                        </div>
                      </div>
                      {/* </a> */}
                    </div>
                  )}
                  {showForm && (
                    <div>
                      {selectedAlbum.id === album.id && (
                        <Modal onClose={toggleUpdateDeleteAlbum}>
                          <div className="update__delete__container">
                            <h3 className="update__delete__title">
                              Edit your album
                            </h3>
                            <input
                              type="text"
                              className="update__delete__input"
                              value={title}
                              onChange={(e) => setTitle(e.target.value)}
                            />
                            <input
                              type="text"
                              className="update__delete__input"
                              value={description}
                              onChange={(e) => setDescription(e.target.value)}
                            />
                            <button
                              className="update__button"
                              onClick={editAlbum}
                            >
                              Save updates
                            </button>
                            <button
                              className="delete__button"
                              onClick={deleteAlbum}
                            >
                              Delete comment
                            </button>
                          </div>
                        </Modal>
                      )}
                    </div>
                  )}
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

export default Albums;
