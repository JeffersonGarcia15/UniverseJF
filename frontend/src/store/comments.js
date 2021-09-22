import { csrfFetch } from './csrf'

const LOAD_ALL_COMMENTS = 'photos/LOAD_ALL_COMMENTS'
const ADD_SINGLE_COMMENT = 'photos/ADD_SINGLE_COMMENT'
const UPDATE_SINGLE_COMMENT = 'photos/UPDATE_SINGLE_COMMENT'
const DELETE_SINGLE_COMMENT = 'photos/DELETE_SINGLE_COMMENT'

const loadComments = comments => {
    return {
        type: LOAD_ALL_COMMENTS,
        comments
    }
}

export const addSingleComment = (comment) => {
    return {
        type: ADD_SINGLE_COMMENT,
        comment
    }
}

export const updateSingleComment = (comment) => {
    return {
        type: UPDATE_SINGLE_COMMENT,
        comment
    }
}

export const deleteComment = comment => {
    return {
        type: DELETE_SINGLE_COMMENT,
        comment
    }
}

export const getAllComments = photoId => async dispatch => {
    const response = await csrfFetch(`/api/comments/photos/${photoId}`)
    if (response.ok) {
        const comments = await response.json()
        dispatch(loadComments(comments))
    }
}

export const updateComment = (body, commentId) => async dispatch => {
    const response = await csrfFetch(`/api/comments/photos/${commentId}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({body})
    })
    if (response.ok) {
        const updatedComment = await response.json()
        dispatch(updateSingleComment(updatedComment))
    }
}

export const createComment = comment => async dispatch => {
    const response = await csrfFetch(`/api/comments/photos/${comment.photoId}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(comment)
    })
    if (response.ok) {
        const newComment = await response.json()
        dispatch(addSingleComment(newComment))
    }
}

export const deleteSingleComment = commentId => async dispatch => {
    const response = await csrfFetch(`/api/comments/${commentId}`, {
        method: 'DELETE'
    })
    if (response.ok) {
        dispatch(deleteComment(commentId))
    }
}




const initialState = {}

export default function commentsReducer(state = initialState, action) {
    let updatedState = {...state}
    switch (action.type) {
        case LOAD_ALL_COMMENTS: {
            const newState = {}
            action.comments.forEach(comment => {
                newState[comment.id] = comment
            })
            return newState
        }
        case ADD_SINGLE_COMMENT: {
            updatedState[action.comment.id] = action.comment
            return updatedState
        }
        case UPDATE_SINGLE_COMMENT: {
            updatedState[action.comment.id] = action.comment
            return updatedState
        }
        case DELETE_SINGLE_COMMENT: {
            delete updatedState[action.comment]
            return updatedState
        }
        default:
            return state
    }
}
