import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useParams, useHistory } from 'react-router-dom';
import { getUserAlbums, addSingleUserAlbum } from '../../store/albums';
import ProfileNavBar from '../ProfileNavBar'
import './Albums.css'
// import '../UserProfile/UserProfile.css'

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
            <ProfileNavBar></ProfileNavBar>
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
                        <div className='explore-container'>
                            <div className='photo-container'>
                                {album.Photos && album.Photos.map(photo => {
                                    return (
                                        <div key={photo.id} className='single-photo-container'>
                                            <a href={`/photos/${photo.id}`}>
                                                <div className='photo-collection'>
                                                    <img className='photo-info' src={photo.imgUrl} alt={photo.title} />
                                                    <div className='photo-title'>
                                                        <p className='user-photo-title'>{photo.title}</p>
                                                        {/* <p className='photo-user'>by {photo.User?.username}</p> */}
                                                    </div>
                                                </div>
                                            </a>
                                        </div>

                                    )
                                })}
                            </div>
                        </div>
                    </div>
                )

            })}
        </div>
    )
}


export default Albums