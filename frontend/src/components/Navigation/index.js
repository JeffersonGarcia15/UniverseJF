import React from 'react';
import { NavLink } from 'react-router-dom';
import { useSelector } from 'react-redux';
import ProfileButton from './ProfileButton';
import LoginFormModal from '../LoginFormModal';
import Demo from '../Demo'

import './Navigation.css';

function Navigation({ isLoaded }) {
  const sessionUser = useSelector(state => state.session.user);

  let sessionLinks;
  if (sessionUser) {
    sessionLinks = (
      <>
      <div className='container'>
      <a href="/explore">
        <i className="fas fa-meteor"></i>
      </a>
      </div>
      <ProfileButton user={sessionUser} />
      </>
    );
  } else {
    sessionLinks = (
      <>
        <div className='container'>
          <a href="/">
            <i className="fas fa-meteor"></i>
          </a>
        </div>
        <LoginFormModal />
        <NavLink to="/signup" className='sign-up'>Sign Up</NavLink>
        <Demo></Demo>
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