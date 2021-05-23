import React, { useState } from "react";
import * as sessionActions from "../../store/session";
import { useDispatch } from "react-redux";
import './LoginForm.css'

function LoginForm() {
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
        <form onSubmit={handleSubmit} className="login-container">
            <ul>
                {errors.map((error, idx) => (
                    <li key={idx}>{error}</li>
                ))}
            </ul>
            <div className='space-font'>
                <i className="fas fa-meteor"></i>
            </div>
            <div className='welcoming-text'>
                Log in to UniverseJF!
            </div>
            <div className='user-email'>
        <input
                type="text"
                value={credential}
                onChange={(e) => setCredential(e.target.value)}
                placeholder="Username or Email"
                className='user-input'
                required
                />
            </div>
            <div className='password'>
                
        <input
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="Password"
                    className='user-password'
                    required
                />
            </div>
            <div className='btn'>
            <button type="submit" className='login-btn'>Log In</button>
            </div>
        </form>
        <div className='signup-redirect'>
            <p>
            Don't have an account?
            <a href="/sing-up" className='redirect'>Create an account here</a>
            </p>
        </div>
        </div>
    );
}

export default LoginForm;