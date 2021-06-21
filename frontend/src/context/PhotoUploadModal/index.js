import React, { useState, useEffect } from 'react';
import { Modal } from '../Modal';
import { useDispatch, useSelector } from "react-redux";
import { useHistory, useParams } from 'react-router-dom'
// import { useHistory } from 'react-router-dom';
import { uploadSinglePhoto } from '../../store/photos';
import { addUserPhotoToAlbum, getUserAlbums } from '../../store/albums'
import { addUserTagToPhoto, getEveryTag } from '../../store/tags'
import './PhotoUploadModal.css'

function PhotoUploadModal() {
    const dispatch = useDispatch()
    // const history = useHistory()
    const { userId } = useParams()
    const [title, setTitle] = useState('')
    const [description, setDescription] = useState('')
    const [imgUrl, setImgUrl] = useState(null)
    const [showMenu, setShowMenu] = useState(false)
    const [addPhotoAlbum, setAddPhotoAlbum] = useState('')
    const [addTagPhoto, setAddTagPhoto] = useState('')
    const [photoId, setPhotoId] = useState(null)
    const albums = useSelector(state => state.albums)
    const photo = useSelector(state => state.photos)
    const tags = useSelector(state => state.tags)
    let idOfPhoto = (Object.keys(photo)[Object.keys(photo).length - 1])
    let intIdOfPhoto = parseInt(idOfPhoto, 10) + 1
    let idOfTag = (Object.keys(tags)[Object.keys(tags).length - 1])
    let intIdOfTag = parseInt(idOfTag, 10) + 1

    // let idOfTag =

        // Object.size = function(obj) {
        //     let size = 0,
        //     key;
        //     for (key in obj) {
        //         if (obj.hasOwnProperty(key)) size++
        //     }
        //     return size
        // }
        // let size = Object.size(photo)
        // photo = Object.values(photo).map()
        // console.log('------------------------', Object.keys(photo).length);
        // console.log('000000000000000', photo);
        // console.log('****************************', Object.values(photo)[0]);
        // console.log('############################', intIdOfPhoto)
        console.log('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$', photo);
    console.log('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^', tags);


    // const [errors, setErrors] = useState([])
    const sessionUser = useSelector(state => state.session.user)

    useEffect(() => {
        dispatch(getUserAlbums(sessionUser.id))
    }, [dispatch, sessionUser.id])


    useEffect(() => {
        dispatch(getEveryTag(sessionUser.id))
    }, [dispatch, sessionUser.id])

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

        await dispatch(uploadSinglePhoto({ title, description, imgUrl, userId: sessionUser.id }))
        setShowMenu(false)
        // e.preventDefault();
        const addSinglePhotoToAlbum = {
            photoId: intIdOfPhoto,
            albumId: addPhotoAlbum
        }
        const addTagToPhoto = {
            photoId: addTagPhoto,
            tagId: intIdOfTag
            }
        console.log('+++++++++++++++++++++++++++', addSinglePhotoToAlbum);
        await dispatch(addUserPhotoToAlbum(addSinglePhotoToAlbum))
        await dispatch(addUserTagToPhoto())
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
        <div className='modal'>
            <button onClick={openMenu} className='icon'>
                <i className="fas fa-camera-retro"></i>
            </button>
            {showMenu && (
                <div>
                    <Modal onClose={() => setShowMenu(false)}>
                        {/* <div className='space-font'>
                            <i className="fas fa-meteor"></i>
                        </div> */}
                        <form className='form-container' onSubmit={onSubmit}>
                            <h4 className='upload'>Upload Your Photo</h4>
                            <input placeholder='Title' className='title' type="text" value={title} onChange={(e) => setTitle(e.target.value)} />
                            <input placeholder='Description' className='description' type="text" value={description} onChange={(e) => setDescription(e.target.value)} />
                            <input className='photo-upload' type="file" onChange={updateFile} />
                            {/* <form onSubmit={addPhotoToAlbum}> */}
                            <input type="hidden" value={photo.id} disabled></input>
                            <select value={addPhotoAlbum} onChange={(e) => setAddPhotoAlbum(e.target.value)}>
                                <option value="">Choose an Album</option>
                                {Object.values(albums).map(album => {
                                    return (
                                        <option key={album.id} value={album.id}>{album.title}</option>
                                    )
                                })}
                            </select>
                            {/* <button type='button' formAction={addPhotoToAlbum}>Add</button> */}
                            {/* </form> */}
                            <button className='btn' type='submit' onClick={() => console.log(photo.id)}>Submit</button>
                        </form>

                    </Modal>

                </div>
            )}
            {/* <button type='submit'>Submit Photo</button> */}
        </div>
    )


}

export default PhotoUploadModal