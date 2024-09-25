import React, { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { useParams, Redirect } from "react-router-dom";
import {
  getAllComments,
  createComment,
  updateComment,
  deleteSingleComment,
} from "../../store/comments";

import "./Comments.css";

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

  const editComment = async (commentId, body, e) => {
    e.preventDefault();
    // history.push()
    await dispatch(updateComment(body, commentId));
    setBody("");
    setShowForm(false);
  };

  const deleteComment = (photoId) => {
    // e.preventDefault()
    let alert = window.confirm("Are you sure you want to delete your comment?");
    if (alert) {
      dispatch(deleteSingleComment(photoId));
    }
  };

  const openForm = (comment) => {
    setShowForm(true);
    setBody(comment.body);
    setFormId(comment.id);
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
                    <p className="comments__comment__owner">
                      {comment.User?.firstName}
                    </p>
                    <p>{comment.body}</p>
                  </div>
                </div>
                {user.id === comment.userId && (
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
                )}
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
