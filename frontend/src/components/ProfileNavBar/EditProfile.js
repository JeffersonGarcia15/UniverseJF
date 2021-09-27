import { useState } from 'react'
import { useParams, useHistory } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { updateUserProfile } from '../../store/session'

function EditProfile() {
    const history = useHistory()
    const dispatch = useDispatch()
    const user = useSelector(state => state.session.user)
    const [errors, setErrors] = useState([])
    const [username, setUserName] = useState(user.username)
    const [firstName, setFirstName] = useState(user.firstName)
    const [lastName, setLastName] = useState(user.lastName)
    const [profileImageUrl, setProfileImageUrl] = useState(user.profileImageUrl)
    // const [banner, setBanner] = useState(user.banner)

    const onSubmit = async (e) => {
        e.preventDefault()
        const data = await dispatch(updateUserProfile(firstName, lastName, username, user.id))
        if (data?.errors) {
            setErrors(data?.errors)
        }
        // history.push('/explore')
    };

    const updateUserName = (e) => {
        setUserName(e.target.value);
    };

    // const updateFirstName = (e) => {
    //     setFirstName(e.target.value)
    // }

    const updateLastName = (e) => {
        setLastName(e.target.value)
    }

    const updateProfileImageUrl = (e) => {
        const file = e.target.files[0]
        if (file) setProfileImageUrl(file)
    }

    // const updateBanner = (e) => {
    //     const file = e.target.files[0]
    //     if (file) setBanner(file)
    // }

    return (
        <div className="form-UpdateProfile">
            <form onSubmit={onSubmit}>
                <ul className="form-errors">
                    {errors?.map((error, ind) => <li key={ind}>{error}</li>)}
                </ul>
                <h2>Update Profile</h2>
                <div className="floating-label">
                    <input
                        type='text'
                        name='firstName'
                        onChange={(e) => setFirstName(e.target.value)}
                        value={firstName}
                        required
                        placeholder='First Name'
                    ></input>
                </div>
                <div className="floating-label">
                    <input
                        type='text'
                        name='lastName'
                        onChange={updateLastName}
                        value={lastName}
                        required
                        placeholder='Last Name'
                    ></input>
                </div>
                <div className="floating-label">
                    <input
                        type='text'
                        name='username'
                        onChange={updateUserName}
                        value={username}
                        required
                        placeholder='username'
                    ></input>
                </div>
                {/* <div className="upload-file">
                    <label>Change Your Profile Picture</label>
                    <input type="file"
                        accept="image/png, image/gif, image/jpeg"
                        onChange={updateProfileImageUrl} />
                </div> */}
                {/* <div className="upload-file">
                    <label>Change Your Banner</label>
                    <input type="file"
                        accept="image/png, image/gif, image/jpeg"
                        onChange={updateBanner} />
                </div> */}
                <div>
                    <button type="submit" className="btn-form">Update</button>
                </div>
            </form>
        </div>
    )
}

export default EditProfile;