import { useHistory } from "react-router-dom";
import "./Footer.css";
import { useState } from "react";
import { Modal } from "../../context/Modal";

/*
    Footer ->
    - Explore
        Planets
        Galaxies
        Habitable planets
        Black holes
        Stars
        Moons
        Other
    - About Us
        About the Project
            This Flickr clone is a side project designed to practice front-end and back-end development and it is part of the Week16 requirements at App Academy.
            It showcases image uploads, user galleries, tags, comments and more.
        Tech Stack
            Built using React, Express.js, PostgreSQL, CSS, and AWS S3.
        Contributors
            Jefferson Jurado Garcia
        GitHub Repo
            https://github.com/JeffersonGarcia15/UniverseJF
    - Help
        How It Works
        FAQ
        General FAQ
    - Social Media
        LinkedIn
        GitHub
        Portfolio
        Wellfound
    - Legal
        Terms & Conditions
        Privacy Policy
    - Extras
        Become a contributor
            By uploading pictures of your favorite planets/stars and anything related to the world of Astronomy!
        Partner with Us

*/

function Footer() {
  const history = useHistory();
  const [showHowItWorks, setShowHowItWorks] = useState(false);

  function toggleShowHowItWorks() {
    setShowHowItWorks((prev) => !prev);
  }
  return (
    <footer className="footer">
      {showHowItWorks && (
        <Modal onClose={toggleShowHowItWorks}>
          <h1>
            Please visit the{" "}
            <a
              href="https://github.com/JeffersonGarcia15/UniverseJF"
              target="_blank"
              className="footer__how__it__works__a"
              rel="noreferrer"
            >
              repo
            </a>{" "}
            to see some of the app's demos{" "}
          </h1>
        </Modal>
      )}
      <nav className="footer__logo">
        <i
          className="fas fa-meteor"
          onClick={() => history.push("/explore")}
        ></i>
      </nav>
      <nav
        className="footer__explore footer__section
      "
      >
        <p className="footer__section__title">Explore</p>
        <ul className="footer__ul">
          <li className="footer__li">Planets</li>
          <li className="footer__li">Galaxies</li>
          <li className="footer__li">Habitable planets</li>
          <li className="footer__li">Black holes</li>
          <li className="footer__li">Stars</li>
          <li className="footer__li">Moons</li>
          <li className="footer__li">Other</li>
        </ul>
      </nav>
      <nav
        className="footer__about__us footer__section
      "
      >
        <p className="footer__section__title">About Us</p>
        <ul className="footer__ul">
          <li className="footer__li" onClick={() => history.push("/about-us")}>
            Meet the team
          </li>
          <li className="footer__li">About the Project</li>
          <li className="footer__li">Tech Stack</li>
          <li className="footer__li">Contributors</li>
          <li className="footer__li">GitHub Repo</li>
        </ul>
      </nav>
      <nav
        className="footer__help footer__section
      "
      >
        <p className="footer__section__title">Help</p>
        <ul className="footer__ul">
          <li className="footer__li" onClick={toggleShowHowItWorks}>
            How It Works
          </li>
          <li className="footer__li" onClick={() => history.push("/faq")}>
            FAQ
          </li>
        </ul>
      </nav>
      <nav
        className="footer__social__media footer__section
      "
      >
        <p className="footer__section__title">Social Media</p>
        <ul className="footer__ul">
          <li className="footer__li">
            <a
              href="https://www.linkedin.com/in/jefferson-jurado-garcia/"
              target="_blank"
              rel="noreferrer"
              className="footer__social__media__a"
            >
              LinkedIn
            </a>
          </li>
          <li className="footer__li">
            <a
              href="https://github.com/JeffersonGarcia15"
              target="_blank"
              rel="noreferrer"
              className="footer__social__media__a"
            >
              GitHub
            </a>
          </li>
          <li className="footer__li">
            <a
              href="https://jefferson-portfolio.onrender.com/"
              target="_blank"
              rel="noreferrer"
              className="footer__social__media__a"
            >
              Portfolio
            </a>
          </li>
          <li className="footer__li">
            <a
              href="https://wellfound.com/u/jefferson-a-lopez-garcia"
              target="_blank"
              rel="noreferrer"
              className="footer__social__media__a"
            >
              Wellfound
            </a>
          </li>
        </ul>
      </nav>
      <nav
        className="footer__legal footer__section
      "
      >
        <p className="footer__section__title">Legal</p>
        <ul className="footer__ul">
          <li className="footer__li">Terms & Conditions</li>
          <li className="footer__li">Privacy Policy</li>
        </ul>
      </nav>
      <nav
        className="footer__extras footer__section
      "
      >
        <p className="footer__section__title">Extras</p>
        <ul className="footer__ul">
          <li className="footer__li">Become a contributor</li>
          <li className="footer__li">Partner with Us</li>
        </ul>
      </nav>
    </footer>
  );
}

export default Footer;
