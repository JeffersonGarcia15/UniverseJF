import React, { useState, useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { useHistory } from 'react-router-dom'
import { uploadSinglePhoto } from '../../store/photos'
import './PhotoUpload.css'

function PhotoUpload() {
    const dispatch = useDispatch()
    const [title, setTitle] = useState('')
    const [description, setDescription] = useState('')
    const [imgUrl, setImgUrl] = useState(null)
    const [showMenu, setShowMenu] = useState(false)
    const sessionUser = useSelector(state => state.session.user)

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


    const onSubmit = async (e) => {
        e.preventDefault();

        await dispatch(uploadSinglePhoto({title, description, imgUrl, userId: sessionUser.id}))
        setShowMenu(false)
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
                <input type="text" value={title} onChange={(e) => setTitle(e.target.value)} />
                <input type="text" value={description} onChange={(e) => setDescription(e.target.value)} />
                <input type="file" onChange={updateFile} />
                <button type='submit'>Submit</button>
            </form>
                )}
            {/* <button type='submit'>Submit Photo</button> */}
        </div>
    )

}

export default PhotoUpload