import { useState } from 'react'
import { Modal } from '../../context/Modal'
import EditProfilePicture from './EditProfilePicture'


function EditProfilePictureModal() {
    const [showModal, setShowModal] = useState(false)

    return (
        <>
            <button className="btn-edit" onClick={() => setShowModal(true)} >Edit Profile Picture</button>
            {showModal && (
                <Modal onClose={() => setShowModal(false)}>
                    <EditProfilePicture />
                </Modal>
            )}

        </>
    )



}

export default EditProfilePictureModal