import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useParams, Redirect, useHistory } from 'react-router-dom';
import { getSingleUserPhoto } from '../../store/photos';
import './UserPhotos.css'

function UserPhoto() {
    const history = useHistory()
    const dispatch = useDispatch()
    const { photoId } = useParams()
    const user = useSelector(state => state.session.user)
    const photo = useSelector(state => state.photo)
    console.log('photo from UserPhotos in components', photo);
    console.log('This is photoId', photoId)

    useEffect(() => {
        dispatch(getSingleUserPhoto(photoId))
    }, [dispatch, photoId])

    return (
        <div>
            Hello
        </div>
    )

}


export default UserPhoto;