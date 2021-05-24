import React, { useEffect } from 'react';
import { Redirect, useParams, useHistory } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { getUsersPhotos } from '../../store/photos';
import './UserProfile.css'

function UserProfile() {
    const history = useHistory()
    const dispatch = useDispatch()
    const { userId } = useParams()
    const user = useSelector(state => state.session.user)
    const photos = useSelector(state => state.photos)
    console.log('Photos in profile', photos); //1: {id: 1, …}2: { id: 2, object with keys 1, 2
    // represents the same behavior as photos in Explore so Object.values should work
    console.log('This is id', userId);

    useEffect(() => {
        dispatch(getUsersPhotos(userId))
    }, [dispatch, userId])

    // const onSubmit = (e) => {
    //     e.preventDefault()
    //     history.push(`/photos/${photo.id}`)
    // }

    return (
        <div className='profile-container'>
            {Object.values(photos).map(photo => {
                return (
                    <div key={photo.id} className='single-photo'>
                        <a href={`/photos/${photo.id}`} onClick={e => {e.preventDefault(); history.push(`/photos/${photo.id}`)}}>
                        <div className='photo-container'>
                        <img src={photo.imgUrl} alt={photo.title} />
                        </div>
                        <div className='photo-info'>
                            <p className='photo-title'>{photo.title}</p>
                        </div>

                        </a>
                    </div>
                )
            })}
            <div className='profile-side-container'>
                <div className='profile-avatar'>

                </div>

            </div>
        </div>
    )
}

export default UserProfile;
