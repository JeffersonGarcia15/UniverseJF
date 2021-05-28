import React from 'react';
import { NavLink } from 'react-router-dom';
import { useSelector } from 'react-redux';
import ProfileButton from './ProfileButton';
// import LoginFormModal from '../LoginFormModal/LoginForm'
// import PhotoUpload from '../PhotoUpload'
// import UserForm from '../UserForm'
import PhotoUploadModal from '../../context/PhotoUploadModal'
import Demo from '../Demo'

import './Navigation.css';

function Navigation({ isLoaded }) {
  const sessionUser = useSelector(state => state.session.user);

  let sessionLinks;
  if (sessionUser) {
    sessionLinks = (
      <>
        <div className='containers'>
          <a href="/explore">
            <i className="fas fa-meteor"></i>
          </a>
        </div>
        <div className='container-name'>
          <div className='profile-btn'>
            <ProfileButton user={sessionUser} />

          </div>
          <PhotoUploadModal></PhotoUploadModal>

        </div>

      </>
    );
  } else {
    sessionLinks = (
      <>
        <div className='containers-2'>
          <a href="/">
            <i className="fas fa-meteor"></i>
          </a>
        </div>
        {/* <UserForm/> */}
        <div className='containers-botones'>
          <NavLink to="/auth" className='sign-up'>Sign Up/Log in</NavLink>
          <Demo></Demo>

        </div>
      </>
    );
  }

  return (
    <>
      <div className='isLoaded'>
        {isLoaded && sessionLinks}
        {/* <Demo></Demo> */}
      </div>
    </>

  );
}

export default Navigation;