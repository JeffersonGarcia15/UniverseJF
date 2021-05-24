// CreateUser.js file
import { useState } from "react";
import { createUser } from "../../store/session";
import * as sessionActions from "../../store/session";
import { useDispatch, useSelector } from "react-redux";
import { Redirect, useHistory } from "react-router-dom";
import './SignupForm.css'

const CreateUser = () => {
    const history = useHistory()

    const [firstName, setFirstName] = useState("");
    const [lastName, setLastName] = useState("");
    const [username, setUsername] = useState("");
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [confirmPassword, setConfirmPassword] = useState('')
    const [image, setImage] = useState(null);
    // for multuple file upload
    //   const [images, setImages] = useState([]);
    const [errors, setErrors] = useState([]);

    
    const dispatch = useDispatch();
    const user = useSelector((state) => state.session.user);
    if (user) return <Redirect to="/"></Redirect>

    const handleSubmit = (e) => {
        e.preventDefault();
        if (password === confirmPassword) {
            setErrors([])
            let newErrors = [];
            dispatch(createUser({firstName, lastName, username, email, password, image }))
                // .then(() => {
                //     setUsername("");
                //     setEmail("");
                //     setPassword("");
                //     setImage(null);
                // })
                .catch(async (res) => {
                    const data = await res.json();
                    if (data && data.errors) {
                        newErrors = data.errors;
                        setErrors(newErrors);
                    }
                });

        }   
            history.push('/explore')
            return setErrors(['Password field and confirm password fields do not match'])
    };

    const updateFile = (e) => {
        const file = e.target.files[0];
        if (file) setImage(file);
    };

    // for multiple file upload
    //   const updateFiles = (e) => {
    //     const files = e.target.files;
    //     setImages(files);
    //   };

    return (
        <div>
            <h1>AWS S3 Express-React Demo</h1>
            {errors.length > 0 &&
                errors.map((error) => <div key={error}>{error}</div>)}
            <form
                style={{ display: "flex", flexFlow: "column" }}
                onSubmit={handleSubmit}
            >
                <label>
                    <input
                        type="text"
                        placeholder="First Name"
                        value={firstName}
                        onChange={(e) => setFirstName(e.target.value)}
                    />
                </label>
                <label>
                    <input
                        type="text"
                        placeholder="Last Name"
                        value={lastName}
                        onChange={(e) => setLastName(e.target.value)}
                    />
                </label>
                <label>
                    <input
                        type="text"
                        placeholder="Username"
                        value={username}
                        onChange={(e) => setUsername(e.target.value)}
                    />
                </label>
                <label>
                    <input
                        type="email"
                        placeholder="Email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                    />
                </label>
                <label>
                    <input
                        type="password"
                        placeholder="Password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                    />
                </label>
                <div id='floatContainer' className='float-container'>
                    <label>Confirm Password</label>
                    <input
                        className='floatField'
                        type='password'
                        value={confirmPassword}
                        onChange={(e) => setConfirmPassword(e.target.value)}
                        required
                    />
                </div>
                <label> Please upload a profile picture: 
                    <input type="file" onChange={updateFile} />
                </label>
                {/* <label>
            Multiple Upload
            <input 
              type="file"
              multiple
              onChange={updateFiles} />
          </label> */}
                <button type="submit" >Create User</button>
            </form>
            <div>
                {user && (
                    <div>
                        <h1>{user.username}</h1>
                        <img
                            style={{ width: "150px" }}
                            src={user.profileImageUrl}
                            alt="profile"
                        />
                    </div>
                )}
            </div>
        </div>
    );
};

export default CreateUser;