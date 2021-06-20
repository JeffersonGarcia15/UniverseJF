import {csrfFetch} from "./csrf"

const LOAD_ALL_PHOTOS = 'photos/LOAD_ALL_PHOTOS'
const LOAD_SINGLE_PHOTO = 'photos/LOAD_SINGLE_PHOTO'
const ADD_SINGLE_PHOTO = 'photos/ADD_SINGLE_PHOTO'
const UPDATE_SINGLE_PHOTO = 'photos/UPDATE_SINGLE_PHOTO'
const DELETE_SINGLE_PHOTO = 'photos/DELETE_SINGLE_PHOTO'

export const loadPhotos = photos => {
    return {
        type: LOAD_ALL_PHOTOS,
        photos,
    };
};

export const loadSinglePhoto = photo => {
    return {
        type: LOAD_SINGLE_PHOTO,
        photo,
    }
}

export const addSinglePhoto = (photo) => {
    return {
        type: ADD_SINGLE_PHOTO,
        photo
    }
}

export const updateSinglePhoto = photo => {
    return {
        type: UPDATE_SINGLE_PHOTO,
        photo
    }
}

export const deletePhoto = photo => {
    return {
        type: DELETE_SINGLE_PHOTO,
        photo
    }
}


export const getAllPhotos = () => async dispatch => {
    const response = await csrfFetch('/api/photos');

    if (response.ok) {
        const photos = await response.json()
        // console.log('Photos from my action in store', photos);
        dispatch(loadPhotos(photos))
    }
}

export const getSingleUserPhoto = (photoId) => async dispatch => {
    const response = await csrfFetch(`/api/photos/${photoId}`)
    if (response.ok) {
        const photo = await response.json()
        // console.log('photo from photos in store folder', photo);
        dispatch(loadSinglePhoto(photo))
    }
    // dispatch(loadSinglePhoto(response.photo));
    // return response.photo;
}

export const getUsersPhotos = userId => async dispatch => {
    const response = await csrfFetch(`/api/users/${userId}`)
    if (response.ok) {
        const photos = await response.json()
        // console.log('HERE WE HAVE PHOTOS BASED ON USERID', photos);
        dispatch(loadPhotos(photos))
    }
}


export const uploadSinglePhoto = (singlePhoto) => async dispatch => {
    // const response = await csrfFetch(`/api/photos/new`, {
    //     method: 'POST',
    //     headers: {
    //         'Content-Type': 'application/json'
    //     },
    //     body: JSON.stringify(singlePhoto)
    // })
    // if (response.ok) {
    //     const photo = await response.json()
    //     console.log('THis is uploadSinglePhoto', photo);
    //     dispatch(addSinglePhoto(photo))
    //     return photo
    // }
    const { title, description, userId, imgUrl } = singlePhoto
    // console.log('This is singlePhoto',singlePhoto);
    const formData = new FormData()
    formData.append('title', title)
    formData.append('description', description)
    formData.append('userId', userId)
    formData.append('photo', imgUrl)

    const response = await csrfFetch('/api/photos/new', {
        method: 'POST',
        headers: {
            "Content-Type": "multipart/form-data"
        },
        body: formData,
    })
    const photo = await response.json()
    dispatch(addSinglePhoto(photo))
}

export const updatePhoto = photo => async dispatch => {
    const response = await csrfFetch(`/api/photos/${photo.photoId}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(photo)
    })
    if (response.ok) {
        const updatedPhoto = await response.json()
        // console.log('%%%%%%%%%', updatedPhoto );
        dispatch(updateSinglePhoto(updatedPhoto))
    }
}

export const deleteSinglePhoto = photoId => async dispatch => {
    const response = await csrfFetch(`/api/photos/${photoId}`, {
        method: 'DELETE'
    })
    if (response.ok) {
        dispatch(deletePhoto(photoId))
    }
}


const initialState = {};

export default function photosReducer(state = initialState, action) {
    let updatedState = {...state}
    switch (action.type) {
        case LOAD_ALL_PHOTOS: {
            const newState = {}
            action.photos.forEach(photo => {
                newState[photo.id] = photo
            })
            return newState
        }
        case LOAD_SINGLE_PHOTO: {
            updatedState[action.photo.id] = action.photo
            return updatedState
        }
        case ADD_SINGLE_PHOTO: {
            updatedState[action.photo.id] = action.photo
            return updatedState
        }
        case UPDATE_SINGLE_PHOTO: {
            updatedState[action.photo.id] = action.photo
            return updatedState
        }
        case DELETE_SINGLE_PHOTO: {
            delete updatedState[action.photo]
            return updatedState
        }
        default:
            return state;
    }
}
