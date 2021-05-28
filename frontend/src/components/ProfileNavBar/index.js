import React, { useEffect } from 'react';
import { useParams, useHistory } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import './ProfileNavBar.css'

function ProfileNavBar() {
    const { userId } = useParams()

    const user = useSelector(state => state.session.user)
    const photos = useSelector(state => state.photos)
    const history = useHistory()
    const photoInfo = Object.values(photos)


    const photostreamNavBar = e => {
        e.preventDefault();
        history.push(`/profile/${userId}`);
    }

    const albumsNavBar = e => {
        e.preventDefault();
        history.push(`/profile/${userId}/albums`);
    }
    return (
        <div >
            <div className='profile-container'>
                <div className='user-info-container'>
                    <img src={user.profileImageUrl} alt="profile" className='Profile-img' />
                </div>

                <div className="user-info-profile">
                    <h2 className="full-name">{user.firstName} {user.lastName}</h2>
                    <div className='extra-info'>
                        <p className="user-name">{user.username}</p>
                        <a className='followers' href="">followers(coming soon...)</a>
                        <a className="following" href="">following(coming soon...)</a>
                        <p className="count-photo-user">{photoInfo.length} photo(s)</p>
                    </div>
                </div>
            </div>
            <div className='navBars'>
                <button className='tag' onClick={photostreamNavBar}>Photostream</button>
                <button className='tag' onClick={albumsNavBar}>Albums</button>
            </div>
        </div>
    )
}

export default ProfileNavBar
