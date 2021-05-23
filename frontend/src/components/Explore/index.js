import React, { useEffect } from 'react';
import { Redirect, useHistory } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { getAllPhotos } from '../../store/photos';
import './Explore.css'

console.log('!getAllPhotos Action',getAllPhotos);

function Explore() {
    const history = useHistory()
    const dispatch = useDispatch()
    const user = useSelector(state => state.session.user);
    const photos = useSelector(state => state.photos)

    // console.log('THIS IS PHOTOS', photos[1].imgUrl);
    
    

    useEffect(() => {
        dispatch(getAllPhotos())
    }, [dispatch])

    // if (!user) {
    //     return (
    //         <Redirect to='/login'></Redirect>
    //     )
    // }
    
    return (
        <div className='explore-gallery'>
            <div className='explore-grid-container'>
                {Object.values(photos).map(photo => {
                    return (
                        <div key={photo.id} className='photo-container'>
                            <a href={`/photos/${photo.id}`}
                                onClick={e => {
                                    e.preventDefault();
                                    history.push(`/photos/${photo.id}`)
                                }}>
                                <div className='photo-box'>
                                    <img className='photo' src={photo.imgUrl} alt={photo.title} />
                                    <div className='text-display'>
                                        <p id='explore-photo-title'>{photo.title}</p>
                                        <p id='explore-photo-user'>by {photo.User?.username}</p>
                                    </div>
                                </div>
                            </a>
                        </div>
                    )
                })}
            </div>
        </div>
    )
}

export default Explore