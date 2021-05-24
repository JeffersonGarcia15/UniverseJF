import { useSelector } from 'react-redux'
import { Redirect } from 'react-router-dom';
import Demo from '../Demo'
import images from './images'
import './SplashPage.css'

function SplashPage() {
//     useEffect(() => {
//         const script = document.createElement('script');

//         script.src = "/public/script.js";
//         script.async = true;

//         document.body.appendChild(script);

//         return () => {
//             document.body.removeChild(script);
//         }
//     }, []);
    

    return (
        <div className="splash-page">
            <script src="/public/script.js"></script>
            <div className='welcome-message'>
                <h1 className='greetings'>
                    Welcome to UniverseJF!
                </h1>
            </div>
        </div>
    )
}

export default SplashPage
