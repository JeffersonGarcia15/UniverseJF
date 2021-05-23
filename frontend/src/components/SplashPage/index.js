import { useSelector } from 'react-redux'
import { Redirect } from 'react-router-dom';
import Demo from '../Demo'
import images from './images'
import './SplashPage.css'

function SplashPage() {

    

    return (
        <div className="splash-page">
            <div className='welcome-message'>
                <h1 className='greetings'>
                    Welcome to UniverseJF!
                </h1>
            </div>
        </div>
    )
}

export default SplashPage
