import { csrfFetch } from './csrf'

const LOAD_ALL_TAGS = 'tags/LOAD_ALL_TAGS'



const loadTags = tags => {
    return {
        type: LOAD_ALL_TAGS,
        tags
    }
}


export const getAllTags = photoId => async dispatch => {
    const response = await csrfFetch(`/api/tags/photos/${photoId}`)
    if (response.ok) {
        const tags = await response.json()
        dispatch(loadTags(tags))
    }
}


const initialState = {}

export default function tagsReducer(state = initialState, action) {
    let updatedState = {...state}
    switch (action.type) {
        case LOAD_ALL_TAGS: {
            const newState = {}
            action.tags.forEach(tag => {
                newState[tag.id] = tag
            })
            return newState
        }
        default:
            return state
    }
}

