import React, { useState, useEffect } from "react";
import { Modal } from "../Modal";
import { useDispatch, useSelector } from "react-redux";
import { useHistory, useParams } from "react-router-dom";
// import { useHistory } from 'react-router-dom';
import { uploadSinglePhoto } from "../../store/photos";
import { addUserPhotoToAlbum, getUserAlbums } from "../../store/albums";
import { addUserTagToPhoto, getEveryTag, createTag } from "../../store/tags";
import "./PhotoUploadModal.css";

function PhotoUploadModal() {
  const dispatch = useDispatch();
  // const history = useHistory()
  const { userId } = useParams();
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  // const [name, setName]
  const [imgUrl, setImgUrl] = useState(null);
  const [showMenu, setShowMenu] = useState(false);
  const [addPhotoAlbum, setAddPhotoAlbum] = useState("");
  const [addTagPhoto, setAddTagPhoto] = useState("");
  const [addTag, setAddTag] = useState("");
  const [photoId, setPhotoId] = useState(null);
  const [name, setName] = useState("");
  const [tagTitle, setTagTitle] = useState("");
  const [tagsArray, setTagsArray] = useState([]);
  const albums = useSelector((state) => state.albums);
  const photo = useSelector((state) => state.photos);
  const tags = useSelector((state) => state.tags);

  // const [errors, setErrors] = useState([])
  const sessionUser = useSelector((state) => state.session.user);

  useEffect(() => {
    dispatch(getUserAlbums(sessionUser.id));
  }, [dispatch, sessionUser.id, photoId]);

  useEffect(() => {
    dispatch(getEveryTag(sessionUser.id));
  }, [dispatch, sessionUser.id]);

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

  // const onSubmit = async (e) => {
  //     e.preventDefault()
  //     const uploadPhoto = {
  //         title,
  //         description,
  //         imgUrl,
  //         userId: sessionUser.id
  //     }
  //     const newSinglePhoto = await dispatch(uploadSinglePhoto(uploadPhoto))
  //     setTitle('')
  //     setDescription('')
  //     setImgUrl('')
  //     history.push(`/photos/${newSinglePhoto.id}`)

  // }
  // const addPhotoToAlbum = async e => {
  //     e.preventDefault();
  //     const addSinglePhotoToAlbum = {
  //         photoId: userId,
  //         albumId: addPhotoAlbum
  //     }
  //     dispatch(addUserPhotoToAlbum(addSinglePhotoToAlbum))
  // }

  const onSubmit = async (e) => {
    e.preventDefault();

    const photo = await dispatch(
      uploadSinglePhoto({
        title,
        description,
        imgUrl,
        userId: sessionUser.id,
      })
    );

    // Send the entire array of tags to the backend in a single request
    const tagsResponse = await dispatch(createTag({ tagsArray }));

    // Assign tags to the photo
    await Promise.all(
      tagsResponse.map(({ id }) =>
        dispatch(addUserTagToPhoto({ tagId: id, photoId: photo.id }))
      )
    );

    await dispatch(addUserPhotoToAlbum(addPhotoAlbum, photo));

    setShowMenu(false);
    setTitle("");
    setDescription("");
    setTagsArray([]);
    setTagTitle("");
  };

  const updateFile = (e) => {
    const file = e.target.files[0];
    if (file) setImgUrl(file);
  };

  function handleKeyDown(e) {
    if (e.key === "Enter" && tagTitle.trim() !== "") {
      e.preventDefault();
      setTagsArray((prev) => {
        return [...prev, tagTitle];
      });
      setTagTitle("");
    }
  }

  function removeTag(e, name) {
    e.preventDefault();
    e.stopPropagation();
    setTagsArray((prev) => {
      return prev.filter((tag) => tag !== name);
    });
  }

  return (
    <div className="modal">
      <button onClick={openMenu} className="icon">
        <i className="fas fa-camera-retro"></i>
      </button>
      {showMenu && (
        <div>
          <Modal onClose={() => setShowMenu(false)}>
            <form className="form-container" onSubmit={onSubmit}>
              <h4 className="upload">Upload Your Photo</h4>
              <input
                placeholder="Title"
                className="title"
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
              />
              <input
                placeholder="Description"
                className="description"
                type="text"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
              />

              <input
                className="photo-upload"
                type="file"
                accept="image/png, image/gif, image/jpeg"
                onChange={updateFile}
              />
              {/* <form onSubmit={addPhotoToAlbum}> */}
              <input type="hidden" value={photo.id} disabled></input>
              <select
                value={addPhotoAlbum}
                onChange={(e) => setAddPhotoAlbum(e.target.value)}
              >
                <option value="">Choose an Album</option>
                {Object.values(albums).map((album) => {
                  return (
                    <option key={album.id} value={album.id}>
                      {album.title}
                    </option>
                  );
                })}
              </select>
              <div className="PhotoUploadModal__tags__container">
                {tagsArray.map((tag, idx) => (
                  <div className="photo__component__tag" key={idx}>
                    <span>{tag}</span>
                    <button
                      className="close"
                      onClick={(e) => removeTag(e, tag)}
                    >
                      X
                    </button>
                  </div>
                ))}
              </div>
              <input
                type="text"
                value={tagTitle}
                onChange={(e) => setTagTitle(e.target.value)}
                onKeyDown={handleKeyDown}
              />
              {/* <textarea value={name} onChange={(e) => setName(e.target.value)}> */}
              {/* <li value={addTag} onChange={(e) => setAddTag(e.target.value)}></li> */}
              {/* <input type="text" value={tagList} onChange={(e) => setAddTagPhoto(e.target.value)}></input> */}
              {/* </textarea>  */}
              {/* <button type='button' formAction={addPhotoToAlbum}>Add</button> */}
              {/* </form> */}
              <button className="btn" type="submit">
                Submit
              </button>
            </form>
          </Modal>
        </div>
      )}
      {/* <button type='submit'>Submit Photo</button> */}
    </div>
  );
}

export default PhotoUploadModal;
