import { useSelector } from "react-redux";
// import { Redirect } from 'react-router-dom';
// import Demo from '../Demo'
// import images from './images'
import { Redirect } from "react-router-dom";
import "./SplashPage.css";

function SplashPage() {
  const user = useSelector((state) => state.session.user);
  //     useEffect(() => {
  //         const script = document.createElement('script');

  //         script.src = "/public/script.js";
  //         script.async = true;

  //         document.body.appendChild(script);

  //         return () => {
  //             document.body.removeChild(script);
  //         }
  //     }, []);

  if (user) {
    return <Redirect to="/explore"></Redirect>;
  }

  return (
    <div className="splash-page">
      <h1 className="greetings">Welcome to UniverseJF!</h1>
      <h2 className="message">
        Join us as a registered user or use a demo to test the website!
      </h2>
    </div>
  );
}

export default SplashPage;
