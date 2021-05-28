import React, { useState, useEffect } from "react";
import { useDispatch, useSelector } from 'react-redux';
import * as sessionActions from '../../store/session';
import { useHistory } from 'react-router-dom';
import './Navigation.css'

function ProfileButton({ user }) {
  const sessionUser = useSelector(state => state.session.user)
  const history = useHistory()
  const dispatch = useDispatch();
  const [showMenu, setShowMenu] = useState(false);

  
  const openMenu = () => {
    if (showMenu) return;
    setShowMenu(true);
  };
  
  useEffect(() => {
    if (!showMenu) return;
    
    const closeMenu = () => {
      setShowMenu(false);
    };
    
    document.addEventListener('click', closeMenu);
    
    return () => document.removeEventListener("click", closeMenu);
  }, [showMenu]);
  const profile = (e) => {
    e.preventDefault()
    history.push(`/profile/${sessionUser.id}`)
  }

  const logout = (e) => {
    e.preventDefault();
    dispatch(sessionActions.logout());
    history.push('/')
  };

  return (
    <>
      <button className='profile-circle' onClick={openMenu}>
        <i className="fas fa-user-circle" />
      </button>
      {showMenu && (
        // <ul className="profile-dropdown">
        //   <li>{user.username}</li>
        //   <li>{user.email}</li>
        //   <li>
        //     <button onClick={logout}>Log Out</button>
        //   </li>
        // </ul>
        <div className='profile-dropdown'>
          <a href={`/profile/${sessionUser.id}`} onClick={profile} className='profile' >Profile</a>
          <a href="/" onClick={logout} className='logout'>Log Out</a>
        </div>
      )}
    </>
  );
}

export default ProfileButton;