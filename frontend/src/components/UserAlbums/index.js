import { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { useParams, useHistory } from "react-router";
import { getSingleUserAlbum } from "../../store/albums";

function UserAlbums() {
  const history = useHistory();
  const dispatch = useDispatch();
  const { albumId } = useParams();
  const user = useSelector((state) => state.session.user);
  const album = useSelector((state) => state.albums[albumId]);
  const photo = useSelector((state) => state.photos);

  useEffect(() => {
    dispatch(getSingleUserAlbum(albumId));
  }, [dispatch, albumId]);

  function pushToPhotoDetails(id) {
    history.push(`/photos/${id}`);
  }

  return (
    <div>
      <div className="explore__photo--grid">
        {album?.id == albumId &&
          album.Photos.map((photo) => {
            return (
              <div key={photo.id} className="single-photo-container">
                <div onClick={() => pushToPhotoDetails(photo.id)}>
                  <div className="photo-collection">
                    <img
                      className="photo-info"
                      src={photo.imgUrl}
                      alt={photo.title}
                    />
                    <div className="photo-title">
                      <p className="user-photo-title">{photo.title}</p>
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
      </div>
    </div>
  );
}
// {
//     user.id === album.userId && (
//         <div>
//             <button onClick={() => openForm(album)}>Edit Album</button>
//             {showForm && album.id === formId ?
//                 <form onSubmit={(e) => editAlbum(album.id, title, description, e)} key={album.id} >
//                     <input type="text" value={title} onChange={(e) => setTitle(e.target.value)}></input>
//                     <input type="text" value={description} onChange={(e) => setDescription(e.target.value)}>Edit Description</input>
//                     <button type='submit' onSubmit={(e) => editAlbum(album.id, title, description, e)}>Edit Title</button>
//                     <button onClick={() => deleteAlbum(album.id)}>Delete Album</button>
//                     {/* <button></button> */}
//                 </form>
//                 : null}
//         </div>
//     )
// }

export default UserAlbums;
