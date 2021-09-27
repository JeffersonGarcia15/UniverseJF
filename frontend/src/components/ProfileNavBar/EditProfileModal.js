import { useState } from 'react'
import { Modal } from '../../context/Modal'
import EditProfile from './EditProfile'


function EditProfileModal() {
    const [showModal, setShowModal] = useState(false)

    return (
        <>
                <button className="btn-edit" onClick={() => setShowModal(true)} >Edit Profile</button>
                {showModal && (
                    <Modal onClose={() => setShowModal(false)}>
                        <EditProfile />
                    </Modal>
                )}

        </>
    )



}

export default EditProfileModal