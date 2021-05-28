import React, { useState } from "react";
import * as sessionActions from "../../store/session";
import { useDispatch } from "react-redux";
import usePaswordToggle from '../../context/UserForm/UsePasswordToggle'
import './LoginForm.css'

function LoginForm() {

    function FloatingEvt(evt) {
        if (evt.target.value.length > 0) {
            evt.target.classList.add('has-value')
        } else {
            evt.target.classList.remove('has-value')
        }
    }
    const [showPassword] = usePaswordToggle();
    const [PwInputType, IconPass] = showPassword();
    const dispatch = useDispatch();
    const [credential, setCredential] = useState("");
    const [password, setPassword] = useState("");
    const [errors, setErrors] = useState([]);

    const handleSubmit = (e) => {
        e.preventDefault();
        setErrors([]);
        return dispatch(sessionActions.login({ credential, password })).catch(
            async (res) => {
                const data = await res.json();
                if (data && data.errors) setErrors(data.errors);
            }
        );
    };

    return (
        <div className='form-container'>
        <form onSubmit={handleSubmit} className="login-container" autoComplete='off'>
            <ul>
                {errors.map((error, idx) => (
                    <li key={idx}>{error}</li>
                ))}
            </ul>
                <div className='input-floating'>
                    <input
                        value={credential}
                        type="text"
                        className="form-control"
                        onBlur={FloatingEvt}
                        onChange={(e) => setCredential(e.target.value)}
                        required
                    />
                    <label htmlFor="user-input">Username or Email</label>
                </div>
                <div className='input-floating'>
                    <input
                        type={PwInputType}
                        className="form-control"
                        required
                        value={password}
                        onBlur={FloatingEvt}
                        onChange={(e) => setPassword(e.target.value)}
                    />
                    <label htmlFor="">Password</label>
                    <span>{IconPass}</span>
                </div>
                <div className='btn'>
                    <button type="submit" className='login-btn'>Log In</button>
                </div>
            </form>
            <div className='signup-redirect'>
                <p>Don't have an account? &nbsp;
            <a href="/signup" className='redirect'>Create an account here</a>
                </p>
            </div>
        </div>
    );
}

export default LoginForm;