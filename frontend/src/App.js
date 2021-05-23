import React, { useState, useEffect } from "react";
import { useDispatch } from "react-redux";
import { Route, Switch } from "react-router-dom";
import SignupFormPage from "./components/SignupFormPage";
import * as sessionActions from "./store/session";
import Navigation from "./components/Navigation";
import SplashPage from './components/SplashPage'
import Footer from './components/Footer'
import Explore from './components/Explore'
import LogingFormModal from './components/LoginFormModal'

function App() {
  const dispatch = useDispatch();
  const [isLoaded, setIsLoaded] = useState(false);
  useEffect(() => {
    dispatch(sessionActions.restoreUser()).then(() => setIsLoaded(true));
  }, [dispatch]);

  return (
    <>
      <Navigation isLoaded={isLoaded} />
      {isLoaded && (
        <Switch>
          <Route exact path='/'>
            <SplashPage></SplashPage>
          </Route>
          <Route path="/signup">
            <SignupFormPage />
          </Route>
          <Route path='/explore'>
            <Explore />
          </Route>
        </Switch>
      )}
      <Footer></Footer>
    </>
  );
}

export default App;