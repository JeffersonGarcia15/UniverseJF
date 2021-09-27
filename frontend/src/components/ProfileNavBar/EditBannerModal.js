import { useState } from 'react'
import { Modal } from '../../context/Modal'
import EditBanner from './EditBanner'


function EditBannerModal() {
    const [showModal, setShowModal] = useState(false)

    return (
        <>
            <button className="btn-edit" onClick={() => setShowModal(true)} >Edit Profile Picture</button>
            {showModal && (
                <Modal onClose={() => setShowModal(false)}>
                    <EditBanner />
                </Modal>
            )}

        </>
    )



}

export default EditBannerModal