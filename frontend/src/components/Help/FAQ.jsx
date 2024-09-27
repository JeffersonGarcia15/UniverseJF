import React, { useState } from "react";
import "./FAQ.css";

// FAQ Data
const faqData = {
    general: [
        {
            title: "What is this project?",
            description:
                "This is a clone of Flickr, developed during Week16 of the 24 week Full Stack engineering program at App Academy, created to demonstrate full-stack development skills.",
        },
        {
            title: "What technologies are used?",
            description:
                "This project is built using React, Redux, Express, CSS, and AWS S3.",
        },
        {
            title: "Are there any privacy concerns?",
            description:
                "Since this is for demonstration purposes, I would suggest not uploading any sensitive data.",
        },
        {
            title: "Can I contribute to this project?",
            description:
                "You are welcome to contribute with the best astronomy images you have!",
        },
        {
            title: "Is this affiliated with Flickr?",
            description:
                "No, this is a non-commercial clone project built for educational purposes. It is not associated with Flickr or any of its affiliates.",
        },
    ],
};

// Helper FAQ Section Component
function FAQSection({ sectionTitle, items }) {
    const [openItemIndex, setOpenItemIndex] = useState(null);

    const handleToggle = (index) => {
        if (openItemIndex === index) {
            setOpenItemIndex(null);
        } else {
            setOpenItemIndex(index);
        }
    };

    const getIcon = (index) => {
        return openItemIndex === index ? (
            <svg
                xmlns="http://www.w3.org/2000/svg"
                width="30"
                height="31"
                fill="none"
                viewBox="0 0 30 31"
            >
                <path
                    fill="#301534"
                    d="M15 3.313A12.187 12.187 0 1 0 27.188 15.5 12.2 12.2 0 0 0 15 3.312Zm4.688 13.124h-9.375a.938.938 0 0 1 0-1.875h9.374a.938.938 0 0 1 0 1.876Z"
                />
            </svg>
        ) : (
            <svg
                xmlns="http://www.w3.org/2000/svg"
                width="30"
                height="31"
                fill="none"
                viewBox="0 0 30 31"
            >
                <path
                    fill="#301534"
                    d="M15 3.313A12.187 12.187 0 1 0 27.188 15.5 12.2 12.2 0 0 0 15 3.312Zm4.688 13.124h-9.375a.938.938 0 0 1 0-1.875h9.374a.938.938 0 0 1 0 1.876Z"
                />
            </svg>
        );
    };

    return (
        <div className="FAQ__container">
            <div className="FAQ__modal">
                <header className="modal-header-container">
                    <svg xmlns="http://www.w3.org/2000/svg" width="40" height="41" fill="none" viewBox="0 0 40 41">
                        <path fill="#3e70bb" d="M37.5 20.5a2.467 2.467 0 0 1-1.64 2.344l-9.913 3.604-3.603 9.911a2.5 2.5 0 0 1-4.688 0l-3.604-9.922-9.911-3.593a2.5 2.5 0 0 1 0-4.688l9.921-3.604 3.594-9.911a2.5 2.5 0 0 1 4.688 0l3.604 9.921 9.911 3.594A2.467 2.467 0 0 1 37.5 20.5Z" />
                    </svg>
                    <h1 className="title">{sectionTitle}</h1>
                </header>
                {items.map((item, index) => (
                    <div key={index} className="accordion-item">
                        <div
                            className="accordion-title-and-icon"
                            onClick={() => handleToggle(index)}
                        >
                            <h2 className="accordion-title">{item.title}</h2>
                            {getIcon(index)}
                        </div>
                        {openItemIndex === index && (
                            <p className="description">{item.description}</p>
                        )}
                        <hr />
                    </div>
                ))}
            </div>
        </div>
    );
}

function FAQ() {
    return (
        <FAQSection sectionTitle="General FAQ" items={faqData.general} />
    );
}

export default FAQ;
