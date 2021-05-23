import {csrfFetch} from "./csrf"

const LOAD_ALL_PHOTOS = 'photos/LOAD_ALL_PHOTOS';

export const loadPhotos = photos => {
    return {
        type: LOAD_ALL_PHOTOS,
        photos,
    };
};

export const getAllPhotos = () => async dispatch => {
    const response = await csrfFetch('/api/photos');

    if (response.ok) {
        const photos = await response.json()
        console.log('Photos from my action in store', photos);
        dispatch(loadPhotos(photos))
    }
}
const initialState = {};

export default function photosReducer(state = initialState, action) {
    let updatedState = {...state}
    switch (action.type) {
        case LOAD_ALL_PHOTOS: {
            action.photos.forEach(photo => {
                updatedState[photo.id] = photo
            })
            return updatedState
        }
        default:
            return state;
    }
}
