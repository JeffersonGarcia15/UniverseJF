import React, { useState, useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { useHistory, useParams } from "react-router-dom";
import { uploadSinglePhoto } from "../../store/photos";
import { addUserPhotoToAlbum, getUserAlbums } from "../../store/albums";

import "./PhotoUpload.css";

function PhotoUpload({ photo }) {
  const dispatch = useDispatch();
  const { userId } = useParams();
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [imgUrl, setImgUrl] = useState(null);
  const [showMenu, setShowMenu] = useState(false);
  const [addPhotoAlbum, setAddPhotoAlbum] = useState("");
  const sessionUser = useSelector((state) => state.session.user);
  const albums = useSelector((state) => state.albums);

  useEffect(() => {
    dispatch(getUserAlbums(userId));
  }, [dispatch, userId]);

  const openMenu = () => {
    if (showMenu) return;
    setShowMenu(true);
  };

  useEffect(() => {
    if (!showMenu) return;

    const closeMenu = () => {
      setShowMenu(false);
    };

    // document.addEventListener('click', closeMenu);

    return () => document.removeEventListener("click", closeMenu);
  }, [showMenu]);

  // const addPhotoToAlbum = async e => {
  //     // e.preventDefault();
  //     // const addSinglePhotoToAlbum = {
  //     //     photoId: userId,
  //     //     albumId: addPhotoAlbum
  //     // }
  //     // dispatch(addUserPhotoToAlbum(addSinglePhotoToAlbum))
  // }

  const onSubmit = async (e) => {
    e.preventDefault();
    setShowMenu(false);
    const addSinglePhotoToAlbum = {
      photoId: userId,
      albumId: addPhotoAlbum,
    };

    await dispatch(
      uploadSinglePhoto({ title, description, imgUrl, userId: sessionUser.id })
    );
    dispatch(addUserPhotoToAlbum(addSinglePhotoToAlbum));
    // .catch(async (res) => {
    //     if (res.data && res.data.errors) setErrors(res.data.errors);
    // });
    // history.push('/')
  };
  const updateFile = (e) => {
    const file = e.target.files[0];
    if (file) setImgUrl(file);
  };

  return (
    <div>
      <button onClick={openMenu}>
        <i className="fas fa-camera-retro"></i>
      </button>
      {showMenu && (
        <form onSubmit={onSubmit}>
          <h4>Upload Your Photo</h4>
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
          <input type="file" onChange={updateFile} />
          {/* <form onSubmit={addPhotoToAlbum}> */}
          <input type="hidden" value={photo.userId}>
            <select
              value={addPhotoAlbum}
              onChange={(e) => setAddPhotoAlbum(e.target.value)}
            >
              <option value="">Choose an Album</option>
              {Object.values(albums).map((album) => {
                return (
                  <option key={album.id} value={album.id}>
                    {album.name}
                  </option>
                );
              })}
            </select>
          </input>
          {/* </form> */}
          <button type="submit">Submit</button>
        </form>
      )}
      {/* <button type='submit'>Submit Photo</button> */}
    </div>
  );
}

export default PhotoUpload;
