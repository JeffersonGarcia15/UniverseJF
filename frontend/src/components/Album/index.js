import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useParams, useHistory } from 'react-router-dom';
import { getUserAlbums, addSingleUserAlbum } from '../../store/albums';
import './Albums.css'
import '../UserProfile/UserProfile.css'

function Albums() {
    const history = useHistory()
    const dispatch = useDispatch()
    const { userId } = useParams()
    const user = useSelector(state => state.session.user)
    const albums = useSelector(state => state.albums)
    const [title, setTitle] = useState('')
    const [description, setDescription] = useState('')
    const [showForm, setShowForm] = useState(false)
    const photos = useSelector(state => state.photos)

    const photoInfo = Object.values(photos)


    // console.log('THIS IS ALBUMS', albums);

    useEffect(() => {
        dispatch(getUserAlbums(userId))
    }, [dispatch, userId])

    const createAlbum = async (e) => {
        e.preventDefault()
        const albumObject = {
            title,
            description,
            userId: user.id
        }
        dispatch(addSingleUserAlbum(albumObject))
        setTitle('')
        setDescription('')
    }
    const photostreamNavBar = e => {
        e.preventDefault();
        history.push(`/profile/${userId}`);
    }

    const albumsNavBar = e => {
        e.preventDefault();
        history.push(`/profile/${userId}/albums`);
    }

    return (
        <div className='background'>
            <div className='profile-contenedor'>
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
            <div className='new'>
                <button onClick={() => setShowForm(true)}>New Album</button>
            </div>
            {showForm && (
                <form onSubmit={createAlbum}>
                    <input type="text" value={title} onChange={(e) => setTitle(e.target.value)} />
                    <textarea value={description} onChange={(e) => setDescription(e.target.value)} cols="30" rows="10"></textarea>
                    <button type='submit'>Save Album</button>
                </form>
            )}
            {Object.values(albums).map(album => {
                return (
                    <div key={album.id} className='album'>
                        <div className='title'>
                            <h4>{album.title}</h4>
                        </div>
                        <div>
                            <h4>{album.description}</h4>
                        </div>
                        {album.Photos && album.Photos.map(photo => {
                            return (
                                <div className='explore-container'>
                                    <div className='photo-container'>
                                <div key={photo.id} className='single-photo-container'>
                                    <a href={`/photos/${photo.id}`}>
                                        <div className='photo-collection'> 
                                            <img src={photo.imgUrl} alt={photo.title} className='photo-info' />
                                        <div className='photo-title'>
                                            <p className='user-photo-title'>{photo.description}</p>
                                            </div>
                                        </div>
                                    </a>
                                </div>

                                    </div>
                                </div>
                            )
                        })}
                    </div>
                    )

            })}
        </div>
    )
}


export default Albums