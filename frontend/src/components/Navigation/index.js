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
      <ProfileButton user={sessionUser} />
    );
  } else {
    sessionLinks = (
      <>
        <LoginFormModal />
        <NavLink to="/signup">Sign Up</NavLink>
      </>
    );
  }

  return (
      <div className="navbar-container">
        <div className='container'>
        <i className="fas fa-home"></i>
        <NavLink exact to="/">Home</NavLink>
        </div>
        <div className="isLoaded"></div>
        {isLoaded && sessionLinks}
      <div className="demo-user">
        <Demo></Demo>
      </div>

      </div>

  );
}

export default Navigation;