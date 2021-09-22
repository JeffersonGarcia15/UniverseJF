import { csrfFetch } from './csrf'

const LOAD_ALL_TAGS = 'tags/LOAD_ALL_TAGS'
const ADD_TO_PHOTO = 'tags/ADD_TO_PHOTO'
const LOAD_EVERY_TAG = 'tags/LOAD_EVERY_TAG'
const ADD_SINGLE_TAG = 'tags/ADD_SINGLE_TAG'


const loadTags = tags => {
    return {
        type: LOAD_ALL_TAGS,
        tags
    }
}


const addTagToPhoto = photo => {
    return {
        type: ADD_TO_PHOTO,
        photo
    }
}


const loadAllTags = tags => {
    return {
        type: LOAD_EVERY_TAG,
        tags
    }
}

const addSingleTag = (tag) => {
    return {
        type: ADD_SINGLE_TAG,
        tag
    }
}


export const getAllTags = photoId => async dispatch => {
    const response = await csrfFetch(`/api/tags/photos/${photoId}`)
    if (response.ok) {
        const tag = await response.json()
        dispatch(loadTags(tag))
    }
}


export const createTag = tagInfo => async dispatch => {
    const response = await csrfFetch(`/api/tags/new`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(tagInfo)
    })
    if (response.ok) {
        const tag = await response.json()
        dispatch(addSingleTag(tag))
    }
}


export const addUserTagToPhoto = photoInfo => async dispatch => {
    const response = await csrfFetch(`/api/tags/${photoInfo.photoId}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(photoInfo)
    })
    if (response.ok) {
        const photo = await response.json()
        dispatch(addTagToPhoto(photo))
    }

}

export const getEveryTag = () => async dispatch => {
    const response = await csrfFetch('/api/tags')
    if (response.ok) {
        const tags = await response.json()
        dispatch(loadAllTags(tags))
    }
}


const initialState = {}

export default function tagsReducer(state = initialState, action) {
    let updatedState = {...state}
    switch (action.type) {
        case LOAD_EVERY_TAG: {
            const newState = {}
            action.tags.forEach(tag => {
                newState[tag.id] = tag
            })
            return newState
        }
        case LOAD_ALL_TAGS: {
            updatedState[action.tag.id] = action.tag
            return updatedState
            // return newState
        }
        case ADD_TO_PHOTO: {
            updatedState[action.photo.photoId] = action.photo
            return updatedState
        }
        default:
            return state
    }
}

