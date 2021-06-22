import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useParams, useHistory } from 'react-router-dom';
import { getSingleUserPhoto } from '../../store/photos';
import { addUserLikeToPhoto, getAllLikes } from '../../store/likes'
import Comments from '../Comments'
import UpdateDelePhoto from '../UpdateDeletePhoto'
import './UserPhotos.css'

function UserPhoto() {
    const history = useHistory()
    const dispatch = useDispatch()
    const { photoId } = useParams()
    const user = useSelector(state => state.session.user)
    const photo = useSelector(state => state.photos[photoId])
    const likes = useSelector(state => state.likes)
    const tags = photo?.Tags
    // console.log('photo from UserPhotos in components', photo);
    // console.log('This is photoId', photoId)
    console.log('THIS IS TAGS??????????????', photo);
    console.log('DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD', likes);
    // console.log('===============================', photo?.Likes?.length);
    // const totalLikes = (Object.keys(photo)[Object.keys(photo).length - 1])
    // console.log('@@@@@@@@@@@@@@@@@@@@@@@', tags.map);

    useEffect(() => {
        dispatch(getSingleUserPhoto(photoId))
    }, [dispatch, photoId])

    useEffect(() => {
        dispatch(getAllLikes(photoId))
    }, [dispatch, photoId])

    const addLike = async (e) => {
        e.preventDefault()
        const addSingleLikeToPhoto = {
            photoId: photoId,
            userId: user.id
        }
        console.log('ZzzzzzzzzzZXzzzzzzzzzzzzzzzzzzzzzzzzzzzz', addSingleLikeToPhoto);
        await dispatch(addUserLikeToPhoto(addSingleLikeToPhoto))
    }

    return (
        <div className='photo--component'>
            <div className='componente-foto'>
                <img src={photo?.imgUrl} alt={photo?.title} className='single-photo' />
            </div>
            <div className='color-fondo'>
                <div className='foto-informacion'>
                    {user.id === photo?.User.id}
                    <>
                    <div>
                        {/* <form onSubmit={addLike}>
                                <button className='buton-plane' type='submit' onSubmit={(e) => editComment(comment.id, body, e)}>
                                    <i className="fas fa-paper-plane"></i></button>
                        </form> */}
                            <button className='buton-plane' type='submit' onClick={addLike}>
                                <i className="fas fa-paper-plane"></i></button>
                    </div>
                        <div className='photo-owner'>
                            <a href={`/profile/${photo?.User.id}`} onClick={e => { e.preventDefault(); history.push(`/profile/${photo?.User.id}`) }}>{photo?.User.firstName}</a>
                            <p>{photo?.Likes?.length} Like(s)</p>
                            <h3 className='h3-size'>{photo?.title}</h3>
                            <p>{photo?.description}</p>
                            <div>
                                {tags?.map(function (tag, idx) {
                                    return (
                                        <div key={idx}>{tag?.name}</div>
                                    )
                                })}
                                {/* {photo.Tags[0].name} */}
                                {/* <p>{photo.Tags[0].name}</p> */}
                                {/* {photo.Tags?.map(tag => {
                                <div>{tag.name}</div>
                                // <button onClick={() => console.log('QUEB))))))))))))))))))))))))))', tag.name)}>JONASSSSSSSS</button>
                            })} */}
                                {/* <button onClick={() => console.log('QUEB))))))))))))))))))))))))))',photo.Tags[0].name)}>JONASSSSSSSS</button> */}
                            </div>
                        </div>
                    </>
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