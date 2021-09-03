import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useParams, useHistory } from 'react-router-dom';
import { getSingleUserPhoto, getAllPhotos } from '../../store/photos';
import { addUserLikeToPhoto, getAllLikes, deleteSingleLike } from '../../store/likes'
import Comments from '../Comments'
import UpdateDelePhoto from '../UpdateDeletePhoto'
import FavoriteIcon from '@material-ui/icons/Favorite';
import './UserPhotos.css'

function UserPhoto() {
    const history = useHistory()
    const dispatch = useDispatch()
    const { photoId } = useParams()
    const user = useSelector(state => state.session.user)
    const photo = useSelector(state => state.photos[photoId])
    const likes = useSelector(state => state.likes)
    const tags = photo?.Tags
    const likeId = Object.values(likes).find(like => like.userId == user.id && like.photoId == photoId)
    const deleteLike = parseInt(likeId?.id, 10)
    const photoLength = photo?.Likes?.length
    const likesInPhoto = Object.values(likes)?.filter(like => like.photoId == photoId)
    const [deleteSwitch, setDeleteSwitch] = useState(false)
    const isPhotoLiked = likesInPhoto?.some(like => like.userId === user.id)

    // useEffect(() => {
    //     dispatch(getSingleUserPhoto(photoId))
    // }, [dispatch, photoId, photoLength])

    // useEffect(() => {
    //     dispatch(getAllPhotos())
    //     dispatch(getAllLikes)
    // }, [dispatch, likeId, deleteLike])

    useEffect(() => {
        dispatch(getAllLikes())
    }, [dispatch, deleteLike])

    useEffect(() => {
        dispatch(getAllPhotos())
        dispatch(getAllLikes)
    }, [])

    const addLike = async (e) => {
    e.preventDefault()
    const addSingleLikeToPhoto = {
        photoId: photoId,
        userId: user.id
    }
    await dispatch(addUserLikeToPhoto(addSingleLikeToPhoto))
}

const dislike = async (e) => {
    e.preventDefault()
    await dispatch(deleteSingleLike(deleteLike))
}

    useEffect(() => {
        dispatch(getAllPhotos())
        dispatch(getAllLikes)
    }, [dispatch, isPhotoLiked])

    return (
        <div className='photo--component'>
            <div className='componente-foto'>
                <img src={photo?.imgUrl} alt={photo?.title} className='single-photo' />
            </div>
            <div className='color-fondo'>
                <div className='foto-informacion'>
                    {user.id === photo?.User.id}
                    <div>

                        <FavoriteIcon onClick={isPhotoLiked ? dislike : addLike} style={{ color: isPhotoLiked ? 'red' : 'gray', cursor: 'pointer' }} className="icon"></FavoriteIcon>
                        <div className='photo-owner'>
                            <a href={`/profile/${photo?.User.id}`} onClick={e => { e.preventDefault(); history.push(`/profile/${photo?.User.id}`) }}>{photo?.User.firstName}</a>
                            <p>{photoLength} Like(s)</p>
                            <h3 className='h3-size'>{photo?.title}</h3>
                            <p>{photo?.description}</p>
                            <div>
                                {tags?.map(function (tag, idx) {
                                    return (
                                        <div key={idx}>{tag?.name}</div>
                                    )
                                })}
                            </div>
                        </div>
                    </div>
                </div>
                <div>
                    <UpdateDelePhoto></UpdateDelePhoto>
                    <hr />
                </div>
                <div>
                    <Comments></Comments>
                </div>
            </div>
        </div>
    )

}


export default UserPhoto;
