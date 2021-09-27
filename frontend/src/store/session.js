// Imports from external library
import { csrfFetch } from './csrf';

const SET_USER = 'session/setUser';
const REMOVE_USER = 'session/removeUser';
const UPDATE_USER = "session/UPDATE_USER"


const setUser = (user) => {
    return {
        type: SET_USER,
        payload: user,
    };
};

const removeUser = () => {
    return {
        type: REMOVE_USER,
    };
};

export const createUser = (firstName, lastName, username, email, password ) => async (dispatch) => {
    // const { firstName, lastName, username, email, password } = user;
    // const formData = new FormData();
    // formData.append('firstName', firstName)
    // formData.append('lastName', lastName)
    // formData.append("username", username);
    // formData.append("email", email);
    // formData.append('image', image)
    // // formData.append('imgUrl', imgUrl)
    // formData.append("password", password);

    // // for multiple files
    // if (images && images.length !== 0) {
    //     for (var i = 0; i < images.length; i++) {
    //         formData.append("images", images[i]);
    //     }
    // }

    // // for single file
    // if (imgUrl) formData.append("image", imgUrl);

    const res = await csrfFetch(`/api/users/`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            firstName, lastName, username, email, password
        }),
    });

    const data = await res.json();
    dispatch(setUser(data.user));
};


export const login = (user) => async (dispatch) => {
    const { credential, password } = user;
    const response = await csrfFetch('/api/session', {
        method: 'POST',
        body: JSON.stringify({
            credential,
            password,
        }),
    });
    const data = await response.json();
    dispatch(setUser(data.user));
    return response;
};
// updateProfileImage
export const updateUserProfile = (firstName, lastName, username, user_id) => async dispatch => {
    const formData = new FormData()

    formData.append("firstName", firstName)
    formData.append("lastName", lastName)
    formData.append("username", username)
    // formData.append("username", username)

    // if (profileImageUrl) formData.append("image", profileImageUrl)
    // if (banner) formData.append("image", banner)

    const response = await csrfFetch(`/api/session/updateUser/${user_id}`, {
        method: "PUT",
        headers: {
            "Content-Type": "multipart/form-data",
        },
        body: formData,
    })
    const data = await response.json();
    dispatch(setUser(data))

}

export const updateUserProfilePhoto = (profileImageUrl, user_id) => async dispatch => {
    const formData = new FormData()

    // formData.append("firstName", firstName)
    // formData.append("lastName", lastName)
    // formData.append("username", username)
    // formData.append("username", username)

    if (profileImageUrl) formData.append("image", profileImageUrl)
    // if (banner) formData.append("image", banner)

    const response = await csrfFetch(`/api/session/updateProfileImage/${user_id}`, {
        method: "PUT",
        headers: {
            "Content-Type": "multipart/form-data",
        },
        body: formData,
    })
    const data = await response.json();
    dispatch(setUser(data))

}

export const updateUserBanner = (banner, user_id) => async dispatch => {
    const formData = new FormData()

    // formData.append("firstName", firstName)
    // formData.append("lastName", lastName)
    // formData.append("username", username)
    // formData.append("username", username)

    if (banner) formData.append("image", banner)
    // if (banner) formData.append("image", banner)

    const response = await csrfFetch(`/api/session/updateBanner/${user_id}`, {
        method: "PUT",
        headers: {
            "Content-Type": "multipart/form-data",
        },
        body: formData,
    })
    const data = await response.json();
    dispatch(setUser(data))

}

const initialState = { user: null };

const sessionReducer = (state = initialState, action) => {
    let newState;
    let updatedState = {...state}
    switch (action.type) {
        case SET_USER:
            return { ...state, user: action.payload };
        case REMOVE_USER:
            newState = Object.assign({}, state);
            newState.user = null;
            return newState;
        case UPDATE_USER:
            updatedState[action.user.id] = action.user
            return updatedState;
        default:
            return state;
    }
};

export const restoreUser = () => async dispatch => {
    const response = await csrfFetch('/api/session');
    const data = await response.json();
    dispatch(setUser(data.user));
    return response;
};

export const signup = (user) => async (dispatch) => {
    const { firstName, lastName, username, email, password, imgUrl } = user;
    const response = await csrfFetch("/api/users", {
        method: "POST",
        body: JSON.stringify({
            firstName,
            lastName,
            username,
            email,
            password,
            imgUrl
        }),
    });
    const data = await response.json();
    dispatch(setUser(data.user));
    return response;
};

export const logout = () => async (dispatch) => {
   
    const response = await csrfFetch('/api/session', {
        method: 'DELETE',
    });

    dispatch(removeUser());
    return response;
};

export default sessionReducer;