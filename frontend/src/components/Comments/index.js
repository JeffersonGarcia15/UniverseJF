import React, { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { useParams, Redirect } from "react-router-dom";
import {
  getAllComments,
  createComment,
  updateComment,
  deleteSingleComment,
} from "../../store/comments";

import MoreHorizIcon from "@material-ui/icons/MoreHoriz";

import "./Comments.css";
import { Modal } from "../../context/Modal";

function Comments() {
  // const history = useHistory()
  const dispatch = useDispatch();
  const { photoId } = useParams();
  const user = useSelector((state) => state.session.user);
  const comments = useSelector((state) => state.comments);
  const [body, setBody] = useState("");
  const [newComment, setNewComment] = useState("");
  const [showForm, setShowForm] = useState(false);
  const [formId, setFormId] = useState(null);
  const [selectedComment, setSelectedComment] = useState();

  useEffect(() => {
    dispatch(getAllComments(photoId));
  }, [dispatch, photoId]);

  const userComment = async (e) => {
    e.preventDefault();

    dispatch(
      createComment({
        body: newComment,
        userId: user.id,
        photoId,
      })
    );
    setNewComment("");
  };

  async function editComment(e) {
    e.preventDefault();
    // history.push()
    await dispatch(updateComment(body, formId));
    setBody("");
    setShowForm(false);
    setSelectedComment();
    setFormId();
  }

  const deleteComment = () => {
    // e.preventDefault()
    let alert = window.confirm("Are you sure you want to delete your comment?");
    if (alert) {
      dispatch(deleteSingleComment(formId));
    }
    setBody("");
    setShowForm(false);
    setSelectedComment();
    setFormId();
  };

  const toggleUpdateDeleteComment = (comment) => {
    setShowForm((prev) => !prev);
    setBody(comment.body);
    setFormId(comment.id);
    setSelectedComment(comment);
  };

  if (!user) {
    return <Redirect to="/"></Redirect>;
  }

  return (
    <div className="comments__container">
      {Object.values(comments).map((comment) => {
        return (
          <div key={comment.id} className="comments">
            <div>
              <div>
                <div className="comments__information">
                  <img
                    src={comment.User?.profileImageUrl}
                    alt={`${comment.User?.firstName}`}
                    className="comments__information__user__photo"
                  />
                  <div className="comments__information__name__and__comment">
                    <div className="comments__comment__owner__and__update__delete">
                      <p className="comments__comment__owner">
                        {comment.User?.firstName}
                      </p>
                      {user.id === comment.userId && (
                        <MoreHorizIcon
                          onClick={() => toggleUpdateDeleteComment(comment)}
                          className="comments__horiz--icon"
                        />
                      )}
                    </div>
                    <p>{comment.body}</p>
                  </div>
                </div>
                {showForm && comment.id === formId && (
                  <div>
                    {user.id === selectedComment.userId ? (
                      <Modal onClose={toggleUpdateDeleteComment}>
                        <div className="update__delete__container">
                          <h3 className="update__delete__title">
                            Edit your comment
                          </h3>
                          <input
                            type="text"
                            className="update__delete__input"
                            value={body}
                            onChange={(e) => setBody(e.target.value)}
                          />
                          <button
                            className="update__button"
                            onClick={editComment}
                          >
                            Save updates
                          </button>
                          <button
                            className="delete__button"
                            onClick={deleteComment}
                          >
                            Delete comment
                          </button>
                        </div>
                      </Modal>
                    ) : null}
                  </div>
                )}
                {/* {user.id === comment.userId && (
                  <div>
                    <button
                      className="comments__button"
                      onClick={() => openForm(comment)}
                    >
                      Edit Comment
                    </button>

                    {showForm && comment.id === formId ? (
                      <form
                        onSubmit={(e) => editComment(comment.id, body, e)}
                        key={comment.id}
                      >
                        <input
                          type="text"
                          value={body}
                          onChange={(e) => setBody(e.target.value)}
                        />
                        <button
                          className="comments__button--plane"
                          type="submit"
                          onSubmit={(e) => editComment(comment.id, body, e)}
                        >
                          <i className="fas fa-paper-plane"></i>
                        </button>
                        <button
                          className="comments__button--plane"
                          onClick={() => deleteComment(comment.id)}
                        >
                          <i className="fas fa-trash-restore-alt"></i>
                        </button>
                      </form>
                    ) : null}
                  </div>
                )} */}
              </div>
            </div>
          </div>
        );
      })}
      <div>
        <form onSubmit={userComment} className="comments__form">
          <textarea
            className="comments__textarea"
            value={newComment}
            onChange={(e) => setNewComment(e.target.value)}
            cols="30"
            rows="10"
            placeholder="Comment here..."
          ></textarea>
          <div>
            <button className="comments__button" type="submit">
              Add comment
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default Comments;
