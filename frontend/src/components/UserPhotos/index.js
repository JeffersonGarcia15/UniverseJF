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
    const photo = useSelector(state => state.photos[photoId])
    console.log('photo from UserPhotos in components', photo);
    console.log('This is photoId', photoId)

    useEffect(() => {
        dispatch(getSingleUserPhoto(photoId))
    }, [dispatch, photoId])

    return (
        <div className='photo-component'>
            <div className='photo-container'>
            <img src={photo?.imgUrl} alt={photo?.title}/>
            </div>
            <div className='photo-info'>
                {user.id === photo?.User.id}
                <div className='photo-owner'>
                    <a href={`/profile/${photo?.User.id}`} onClick={e => { e.preventDefault(); history.push(`/profile/${photo?.User.id}`) }}>{photo?.User.firstName}</a>
                </div>
            </div>
        </div>
    )

}


export default UserPhoto;