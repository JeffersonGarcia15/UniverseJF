import { useState } from 'react'
import { useParams, useHistory } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { updateUserProfilePhoto } from '../../store/session'

function EditProfilePicture() {
    const dispatch = useDispatch()
    const user = useSelector(state => state.session.user)
    const [errors, setErrors] = useState([])
    const [profileImageUrl, setProfileImageUrl] = useState(user.profileImageUrl)
    // const [banner, setBanner] = useState(user.banner)

    const onSubmit = async (e) => {
        e.preventDefault()
        const data = await dispatch(updateUserProfilePhoto(profileImageUrl,user.id))
        if (data?.errors) {
            setErrors(data?.errors)
        }
    };


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
                <div className="upload-file">
                    <label>Change Your Profile Picture</label>
                    <input type="file"
                        accept="image/png, image/gif, image/jpeg"
                        onChange={updateProfileImageUrl} />
                </div>
                {/* <div className="upload-file">
                    <label>Change Your Banner</label>
                    <input type="file"
                        accept="image/png, image/gif, image/jpeg"
                        onChange={updateBanner} />
                </div> */}
                <div>
                    <button type="submit" className="btn-form">Icon</button>
                </div>
            </form>
        </div>
    )
}

export default EditProfilePicture;