import { useState } from 'react';

const FormControl = evt => {
    const [hasValue, setFloating] = useState(false)

    const a = evt;
    const StayFloating = hasValue ? "has-value" : "";

    const FlotingEvt = () => {
        if (a !== "") {
            setFloating(true);
        } else {
            setFloating(false);
        }
    }

    if (evt.target.value.length > 0) {
        evt.target.classList.add('has-value')
    } else {
        evt.target.classList.remove('has-value')
    }
    return [StayFloating, FlotingEvt]
}

export default FormControl;