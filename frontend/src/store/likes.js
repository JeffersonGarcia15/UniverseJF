import { csrfFetch } from './csrf'

const LOAD_ALL_LIKES = 'likes/LOAD_ALL_LIKES'
const ADD_TO_PHOTO = 'likes/ADD_TO_PHOTO'
const DELETE_SINGLE_LIKE = 'likes/DELETE_SINGLE_LIKE'


const loadAllLikes = likes => {
    return {
        type: LOAD_ALL_LIKES,
        likes
    }
}

const addLikeToPhoto = photo => {
    return {
        type: ADD_TO_PHOTO,
        photo
    }
}

export const deleteLike = like => {
    return {
        type: DELETE_SINGLE_LIKE,
        like
    }
}


export const getAllLikes = () => async dispatch => {
    const response = await csrfFetch('/api/likes')
    if (response.ok) {
        const likes = await response.json()
        dispatch(loadAllLikes(likes))
    }
}

export const addUserLikeToPhoto = photoInfo => async dispatch => {
    const response = await csrfFetch(`/api/likes/${photoInfo.photoId}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(photoInfo)
    })
    if (response.ok) {
        const like = await response.json()
        dispatch(addLikeToPhoto(like))
    }
}

export const deleteSingleLike = likeId => async dispatch => {
    const response = await csrfFetch(`/api/likes/${likeId}`, {
        method: 'DELETE'
    })
    if (response.ok) {
        dispatch(deleteLike(likeId))
    }
}



const initialState = {}

export default function likesReducer(state = initialState, action) {
    let updatedState = {...state}
    switch (action.type) {
        case LOAD_ALL_LIKES: {
            const newState = {}
            action.likes.forEach(like => {
                newState[like.id] = like
            })
            return newState
        }
        case ADD_TO_PHOTO: {
            updatedState[action.photo.photoId] = action.photo
            return updatedState
        }
        case DELETE_SINGLE_LIKE: {
            delete updatedState[action.like]
            return updatedState
        }
        default:
            return state
    }
}


