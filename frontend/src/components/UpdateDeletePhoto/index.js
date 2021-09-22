import React, { useState } from 'react';
import { useDispatch, useSelector } from "react-redux";
import { useHistory, useParams } from 'react-router-dom';
import { updatePhoto, deleteSinglePhoto } from '../../store/photos';
import './UpdateDeletePhoto.css'

function UpdateDeletePhoto() {
    const dispatch = useDispatch()
    const history = useHistory()
    const { photoId } = useParams()
    const photo = useSelector(state => state.photos[photoId])
    const user = useSelector(state => state.session.user)

    const [title, setTitle] = useState(photo?.title)
    const [description, setDescription] = useState(photo?.description)



    const updateUserPhoto = async (e) => {
        e.preventDefault()
        
        dispatch(updatePhoto({
            title,
            description,
            photoId
        }))
        history.push('/explore')
    }

    const deletePhoto = async (e) => {
        e.preventDefault()
        let alert = window.confirm('Are you sure you want to delete your photo?')
        if (alert) {
            dispatch(deleteSinglePhoto(photo.id))
        }
        history.push('/explore')

    }

    return (
        <div>
            {user.id === photo?.userId && (
            <form onSubmit={updateUserPhoto}>
                <input type="text" value={title} onChange={e => setTitle(e.target.value)} placeholder='New Title' />
                <input type="text" value={description} onChange={e => setDescription(e.target.value)} placeholder='New Description' />
                <button className='boton-comentario' type='submit'>Save Updates</button>
                <button className='boton-comentario' onClick={deletePhoto}> Delete Photo</button>
            </form>
            )}
        </div>
    )

}


export default UpdateDeletePhoto