import { useState } from 'react'

const useSwitchBtn = () => {
    const [isLoginActive, setLoginActivation] = useState(false);
    const [isSignupActive, setSignupActivation] = useState(false);

    const login = isLoginActive ? "" : "active";
    const signup = isSignupActive ? "active" : "";
    const isLoginSelected = isLoginActive ? "hidden" : "";
    const isSignUpSelected = isSignupActive ? "" : "hidden";

    const LoginClick = () => {
        if (isLoginActive === true) {
            setLoginActivation(activation => !activation);
            setSignupActivation(activation => !activation);
        }
    }

    const SignupClick = () => {
        if (isSignupActive === false) {
            setLoginActivation(activation => !activation);
            setSignupActivation(activation => !activation);
        }
    }


    return [login, LoginClick, signup, SignupClick, isSignUpSelected, isLoginSelected]

}

export default useSwitchBtn;