import {csrfFetch} from "./csrf"

const LOAD_ALL_PHOTOS = 'photos/LOAD_ALL_PHOTOS';
const LOAD_SINGLE_PHOTO = 'photos/LOAD_SINGLE_PHOTO'

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

export const getAllPhotos = () => async dispatch => {
    const response = await csrfFetch('/api/photos');

    if (response.ok) {
        const photos = await response.json()
        console.log('Photos from my action in store', photos);
        dispatch(loadPhotos(photos))
    }
}

export const getSingleUserPhoto = (photoId) => async dispatch => {
    const response = await fetch(`/api/photos/${photoId}`)
    if (response.ok) {
        const photo = await response.json()
        console.log('photo from photos in store folder', photo);
        dispatch(loadSinglePhoto(photo))
    }
    // dispatch(loadSinglePhoto(response.photo));
    // return response.photo;
}

export const getUsersPhotos = userId => async dispatch => {
    const response = await csrfFetch(`/api/users/${userId}`)
    if (response.ok) {
        const photos = await response.json()
        console.log('HERE WE HAVE PHOTOS BASED ON USERID', photos);
        dispatch(loadPhotos(photos))
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
        default:
            return state;
    }
}
