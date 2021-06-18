import { csrfFetch } from './csrf'

const LOAD_ALL_ALBUMS = 'albums/LOAD_ALL_ALBUMS'
const ADD_SINGLE_ALBUM = 'albums/ADD_SINGLE_ALBUM'
const ADD_TO_ALBUM = 'albums/ADD_TO_ALBUM'
const UPDATE_SINGLE_ALBUM = 'albums/UPDATE_SINGLE_ALBUM'
const DELETE_SINGLE_ALBUM = 'albums/DELETE_SINGLE_ALBUM'


export const loadAlbums = albums => {
    return {
        type: LOAD_ALL_ALBUMS,
        albums
    }
}

export const addSingleAlbum = album => {
    return {
        type: ADD_SINGLE_ALBUM,
        album
    }
}

export const addPhotoToAlbum = album => {
    return {
        type: ADD_TO_ALBUM,
        album
    }
}
export const updateSingleAlbum = (album) => {
    return {
        type: UPDATE_SINGLE_ALBUM,
        album
    }
}

export const deleteAlbum = album => {
    return {
        type: DELETE_SINGLE_ALBUM,
        album
    }
}

export const getUserAlbums = userId => async dispatch => {
    const response = await csrfFetch(`/api/albums/user/${userId}`)
    if (response.ok) {
        const albums = await response.json()
        // console.log('HERE ARE USER ALBUMS', albums);
        dispatch(loadAlbums(albums))
    }
}

export const addUserPhotoToAlbum = albumInfo => async dispatch => {
    const response = await csrfFetch(`/api/albums/${albumInfo.albumId}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(albumInfo)
    })
    if (response.ok) {
        const album = await response.json()
        dispatch(addPhotoToAlbum(album))
    }
}

export const addSingleUserAlbum = albumInfo => async dispatch => {
    const response = await csrfFetch('/api/albums/new', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(albumInfo)
    })

    if (response.ok) {
        const album = await response.json()
        dispatch(addSingleAlbum(album))
    }
}

export const updateAlbum = (title, description, albumId) => async dispatch => {
    const response = await csrfFetch(`/api/albums/user/${albumId}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({title, description})
    })
    if (response.ok) {
        const updatedAlbum = await response.json()
        dispatch(updateSingleAlbum(updatedAlbum))
    }
}

export const deleteSingleAlbum = albumId => async dispatch => {
    const response = await csrfFetch(`/api/albums/${albumId}`, {
        method: 'DELETE'
    })
    if (response.ok) {
        dispatch(deleteAlbum(albumId))
    }
}

const initialState = {}

export default function albumsReducer(state = initialState, action) {
    let updatedState = {...state}
    switch (action.type) {
        case LOAD_ALL_ALBUMS: {
            const newState = {}
            action.albums.forEach(album => {
                newState[album.id] = album
            })
            return newState
        }
        case ADD_SINGLE_ALBUM: {
            updatedState[action.album.id] = action.album
            return updatedState
        }
        case ADD_TO_ALBUM: {
            updatedState[action.album.albumId] = action.album
            return updatedState
        }
        case UPDATE_SINGLE_ALBUM: {
            updatedState[action.album.id] = action.album
            return updatedState
        }
        case DELETE_SINGLE_ALBUM: {
            delete updatedState[action.album]
            return updatedState
        }
        default:
            return state
    }
}