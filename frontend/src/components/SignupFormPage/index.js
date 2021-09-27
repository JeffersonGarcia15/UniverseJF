// CreateUser.js file
import { useState } from "react";
import { createUser } from "../../store/session";
// import * as sessionActions from "../../store/session";
import { useDispatch, useSelector } from "react-redux";
import { Redirect, useHistory } from "react-router-dom";
import usePaswordToggle from '../../context/UserForm/UsePasswordToggle'
import './SignupForm.css'

const CreateUser = () => {
    function FloatingEvt(evt) {
        if (evt.target.value.length > 0) {
            evt.target.classList.add('has-value')
        } else {
            evt.target.classList.remove('has-value')
        }
    }
    const [showPassword, showConfirmPass] = usePaswordToggle();
    const [PwInputType, IconPass] = showPassword();
    const [PwConfirmInputType, IconPassConfirm] = showConfirmPass();
    const [filename, setFilename] = useState("Upload a profile picture...");
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
            dispatch(createUser(firstName, lastName, username, email, password ))
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
            history.push('/explore')
        }
        return setErrors(['Password field and confirm password fields do not match'])
    };

    const updateFile = (e) => {
        const file = e.target.files[0];
        if (file) {
            setFilename(file.name)
            setImage(file);
        }
    };

    // for multiple file upload
    //   const updateFiles = (e) => {
    //     const files = e.target.files;
    //     setImages(files);
    //   };

    return (
        <div>
            {errors.length > 0 &&
                errors.map((error) => <div className='errors' key={error}>{error}</div>)}
            <form onSubmit={handleSubmit}>
                <div className="signup-content">
                    <div className="input-group">
                        <div className="input-floting">
                            <input type="text" className="form-control" onBlur={FloatingEvt} value={firstName} onChange={(e) => setFirstName(e.target.value)} />
                            <label htmlFor="">First Name</label>
                        </div>
                        <div className="input-floting">
                            <input type="text" className="form-control" onBlur={FloatingEvt} value={lastName} onChange={(e) => setLastName(e.target.value)} />
                            <label htmlFor="">Last Name</label>
                        </div>
                    </div>

                    <div className="input-group">
                        <div className="input-floting">
                            <input type="text" className="form-control" onBlur={FloatingEvt} value={username} onChange={(e) => setUsername(e.target.value)} />
                            <label htmlFor="">Username</label>
                        </div>
                        <div className="input-floting">
                            <input type="email" className="form-control" onBlur={FloatingEvt} value={email} onChange={(e) => setEmail(e.target.value)} />
                            <label htmlFor="">Email</label>
                        </div>
                    </div>
                    <div className="input-group">
                        <div className="input-floting">
                            <input type={PwInputType} className="form-control" onBlur={FloatingEvt} value={password} onChange={(e) => setPassword(e.target.value)} />
                            <label htmlFor="">Password</label>
                            <span>{IconPass}</span>
                        </div>
                        <div className="input-floting">
                            <input type={PwConfirmInputType} className="form-control" onBlur={FloatingEvt} value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} />
                            <label htmlFor="">Confirm password</label>
                            <span>{IconPassConfirm}</span>
                        </div>
                    </div>
                    {/* <div className="inputfile-box">
                        <input type="file" id="file" className="inputfile"
                            accept="image/*"
                            onChange={updateFile} />
                        <label htmlFor="file">
                            <span id="file-name" className="file-box">{filename}</span>
                            <span className="file-button">
                                Select File
                                </span>
                        </label>
                    </div> */}
                    <button type="submit" className="signup-btn" >Create User</button>
                </div>
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