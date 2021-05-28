import React, { useEffect } from 'react';
import { useParams, useHistory } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { getUsersPhotos } from '../../store/photos';
import './UserProfile.css'

function UserProfile() {
    const history = useHistory()
    const dispatch = useDispatch()
    const { userId } = useParams()
    const user = useSelector(state => state.session.user)
    const photos = useSelector(state => state.photos)
    // console.log('Photos in profile', photos); //1: {id: 1, …}2: { id: 2, object with keys 1, 2
    // // represents the same behavior as photos in Explore so Object.values should work
    // console.log('This is id', userId);
    // console.log('___________------______', user);
    const photoInfo = Object.values(photos)
    // console.log('AQUI PHOTOINFO', photoInfo);

    useEffect(() => {
        dispatch(getUsersPhotos(userId))
    }, [dispatch, userId])

    // const onSubmit = (e) => {
    //     e.preventDefault()
    //     history.push(`/photos/${photo.id}`)
    // }

    const photostreamNavBar = e => {
        e.preventDefault();
        history.push(`/profile/${userId}`);
    }

    const albumsNavBar = e => {
        e.preventDefault();
        history.push(`/profile/${userId}/albums`);
    }

    return (
        <React.Fragment>
            <div className='profile-container'>
                <div className='user-info'>
                    <div className='user-fullName'>
                        <img src={user.profileImageUrl} alt="profile" className='userProfile' />
                        <p className='followers'>{user.username} 0 followers 1 following {photoInfo.length} photo(s)</p>
                    </div>
                    <div className='extra-info'>
                        <p>{user.firstName} {user.lastName}</p>

                    </div>
                </div>
                <div className='navBars'>
                    <a className='tag' href={`/profile`} onClick={photostreamNavBar}>Photostream</a>
                    <a className='tag' href={`/profile/${userId}/albums`} onClick={albumsNavBar}>Albums</a>
                </div>
            </div>
            <div className='explore-container'>
                <div className='photo-container'>
                    {Object.values(photos).map(photo => {
                        return (
                            <div key={photo.id} className='single-photo-container'>
                                <a href={`/photos/${photo.id}`}
                                    onClick={e => {
                                        e.preventDefault();
                                        history.push(`/photos/${photo.id}`)
                                    }}>
                                    <div className='photo-collection'>
                                        <img className='photo-info' src={photo.imgUrl} alt={photo.title} />
                                        <div className='photo-title'>
                                            <p className='user-photo-title'>{photo.title}</p>
                                            <p className='photo-user'>by {photo.User?.username}</p>
                                        </div>
                                    </div>
                                </a>
                                {/* <a href={`/profile/${photo?.User.id}`}>
                                <div>
                                    <p id='photo-user'>by {photo.User?.username}</p>
                                </div>
                            </a> */}
                            </div>
                        )
                    })}
                </div>
            </div>
            <div className='profile-side-container'>
                <div className='profile-avatar'>

                </div>

            </div>
        </React.Fragment>
    )
}

export default UserProfile;
