import React, { useState, useEffect } from 'react';
import { Modal } from '../Modal';
import { useDispatch, useSelector } from "react-redux";
// import { useHistory } from 'react-router-dom';
import { uploadSinglePhoto } from '../../store/photos';
import './PhotoUploadModal.css'

function PhotoUploadModal({ user }) {
        const dispatch = useDispatch()
        // const history = useHistory()
        const [title, setTitle] = useState('')
        const [description, setDescription] = useState('')
        const [imgUrl, setImgUrl] = useState(null)
        const [showMenu, setShowMenu] = useState(false)
        // const [errors, setErrors] = useState([])
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

        const onSubmit = async (e) => {
            e.preventDefault();

            await dispatch(uploadSinglePhoto({ title, description, imgUrl, userId: sessionUser.id }))
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
                        <input  className='photo-upload' type="file" onChange={updateFile} />
                        <button className='btn' type='submit'>Submit</button>
                    </form>

                    </Modal>

                    </div>
                )}
                {/* <button type='submit'>Submit Photo</button> */}
            </div>
        )


}

export default PhotoUploadModal