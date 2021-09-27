import { csrfFetch } from "./csrf"

const UPDATE_USER = "profiles/UPDATE_USER"
// const UPDATE_BANNER = "profiles/UPDATE_BANNER"

// const updateProfileImageUrl = data => ({
//     type: UPDATE_PROFILE_IMAGE_URL,
//     payload: data
// })

const updateUser = user => ({
    type: UPDATE_USER,
    payload: user
})

// export const updateUserProfileImage = (imageUrl, user) => async dispatch => {
//     const formData = new FormData()
//     if (imageUrl) formData.append("image", imageUrl)
//     const response = await csrfFetch(`api/user/updateProfileImageUrl/${user.id}`, {
//         method: "PUT",
//         headers: {
//             "Content-Type": "multipart/form-data",
//         },
//         body: formData,
//     })
//     const data = await response.json();
//     dispatch(updateProfileImageUrl(data))
    
// }

export const updateUserProfileImage = (firstName, lastName, username, imageUrl, banner, user_id) => async dispatch => {
    const formData = new FormData()

    formData.append("firstName", firstName)
    formData.append("lastName", lastName)
    formData.append("username", username)
    // formData.append("username", username)

    if (imageUrl) formData.append("image", imageUrl)
    if (imageUrl) formData.append("image", banner)

    const response = await csrfFetch(`api/user/updateBanner/${user_id}`, {
        method: "PUT",
        headers: {
            "Content-Type": "multipart/form-data",
        },
        body: formData,
    })
    const data = await response.json();
    dispatch(updateUser(data))

}

const initialState = {}

const profile = (state, initialState) => {
    let updatedState = { ...state }
    switch (action.type) {
        case UPDATE_USER:
            updatedState[action.id] = action.user
            return updatedState
        default:
            return state
    }
}

