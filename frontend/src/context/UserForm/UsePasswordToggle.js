import { useState } from 'react'
const usePaswordToggle = () => {
    const usePwToggle = () => {

        const [visible, setVisible] = useState(false);
        const Icon = (<i className={`fas ${visible ? "fa-eye-slash" : "fa-eye"} pw-icon`}
            onClick={() => setVisible(visiblity => !visiblity)}></i>);


        const InputType = visible ? "text" : "password";
        return [InputType, Icon]
    }
    const usePwConfirmToggle = () => {
        const [visible, setVisible] = useState(false);
        const Icon = (<i className={`fas ${visible ? "fa-eye-slash" : "fa-eye"} pw-icon`}
            onClick={() => setVisible(visiblity => !visiblity)}></i>);
        const InputType = visible ? "text" : "password";
        return [InputType, Icon]
    }
    return [usePwToggle, usePwConfirmToggle]
}

export default usePaswordToggle