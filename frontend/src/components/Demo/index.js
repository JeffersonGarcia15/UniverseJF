import React from 'react';
import { useHistory } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import './Demo.css'

import { login } from '../../store/session';

function Demo() {
    const history = useHistory()
    const dispatch = useDispatch()

    const handleSubmit = async (e) => {
        e.preventDefault()
        const demoUser = {
            credential: 'JeffersonGarcia15',
            password: 'Physics1!'
        }
        await dispatch(login(demoUser))
        history.push('/explore')
    }
    return (
        <div className='demo-user'>
            <form onSubmit={handleSubmit}>
                <button type="submit" className="demo-btn">Demo</button>
            </form>
        </div>
    )
}
export default Demo;