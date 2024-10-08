import React, { useState, useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Route, Switch } from "react-router-dom";
// import SignupFormPage from "./components/SignupFormPage";
import * as sessionActions from "./store/session";
import Navigation from "./components/Navigation";
import SplashPage from "./components/SplashPage";
import Footer from "./components/Footer";
import Explore from "./components/Explore";
// import LogingFormModal from './components/LoginFormModal'
import UserProfile from "./components/UserProfile";
// import UserPhotos from './components/UserPhotos'
import UserPhoto from "./components/UserPhotos";
import Albums from "./components/Album";
import NotFound from "./components/NotFound";
import UserForm from "./components/UserForm";
import UserAlbums from "./components/UserAlbums";
import FAQ from "./components/Help/FAQ";
import { AboutUs } from "./components/AboutUs/AboutUs";

function App() {
  const dispatch = useDispatch();
  const [isLoaded, setIsLoaded] = useState(false);
  const user = useSelector((state) => state.session.user);
  useEffect(() => {
    dispatch(sessionActions.restoreUser()).then(() => setIsLoaded(true));
  }, [dispatch]);

  return (
    <>
      <Navigation isLoaded={isLoaded} />
      {isLoaded && (
        <Switch>
          {console.log("WHAT IS GOING ON?", user)}
          <Route exact path="/">
            <SplashPage></SplashPage>
          </Route>
          <Route path="/auth">
            <UserForm />
          </Route>
          <Route exact path="/explore">
            <Explore />
          </Route>
          <Route exact path="/profile/:userId">
            <UserProfile></UserProfile>
          </Route>
          <Route path="/photos/:photoId">
            <UserPhoto></UserPhoto>
          </Route>
          <Route exact path="/profile/:userId/albums">
            <Albums></Albums>
          </Route>
          <Route exact path="/albums/:albumId">
            <UserAlbums></UserAlbums>
          </Route>
          <Route exact path="/faq">
            <FAQ />
          </Route>
          <Route exact path="/about-us">
            <AboutUs />
          </Route>
          <Route>
            <NotFound></NotFound>
          </Route>
        </Switch>
      )}
      {user && <Footer></Footer>}
    </>
  );
}

export default App;
