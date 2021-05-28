import Login from '../LoginFormModal/LoginForm'
import Signup from '../SignupFormPage'
import useSwitchBtn from '../../context/UserForm/UseSwitchButton'
import './UserForm.css'

function UserForm() {
    const [isLogin, isLoginClick,
        isSignup, isSignupClick,
        isSignUpSelected, isLoginSelected] = useSwitchBtn();
    return (
        <div className='userForm-container'>
            <div className="userForm-content">
                <div className='welcoming-text'>
                    <h1>UniverseJF!</h1>
                </div>
                <div className="h-line"></div>
                <div className="btn-switch-floating">
                    <button className={`btn-switch-login ${isLogin}`} onClick={isLoginClick}>Log In</button>
                    <button className={`btn-switch-signup ${isSignup}`} onClick={isSignupClick}>Sign Up</button>
                </div>
                <div className={isLoginSelected}>
                    <Login></Login>
                </div>
                <div className={isSignUpSelected}>
                    <Signup></Signup>
                </div>
            </div>
        </div>
    )
}

export default UserForm;