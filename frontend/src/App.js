// src/App.js
import React, { useState, useEffect } from 'react';

function App() {
  // 백엔드 URL: .env 파일에 REACT_APP_BACKEND_URL을 설정하거나 기본값 사용
  const backendUrl = process.env.REACT_APP_BACKEND_URL || 'http://localhost:8000';

  const [name, setName] = useState('');
  const [comment, setComment] = useState('');
  const [comments, setComments] = useState([]);

  // 댓글 불러오기 함수
  const fetchComments = async () => {
    try {
      const response = await fetch(`${backendUrl}/comments`);
      const data = await response.json();
      setComments(data);
    } catch (error) {
      console.error('Error fetching comments:', error);
    }
  };

  // 컴포넌트 마운트 시 댓글 불러오기
  useEffect(() => {
    fetchComments();
  }, []);

  // 댓글 등록 핸들러
  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!name || !comment) {
      alert('Please fill out both name and comment.');
      return;
    }
    try {
      const response = await fetch(`${backendUrl}/comments`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, comment }),
      });
      if (!response.ok) {
        throw new Error('Error posting comment');
      }
      setName('');
      setComment('');
      fetchComments(); // 댓글 재불러오기
    } catch (error) {
      console.error('Error posting comment:', error);
    }
  };

  return (
    <div style={{ maxWidth: '600px', margin: '0 auto', padding: '20px' }}>
      <h1>Comments</h1>
      <form onSubmit={handleSubmit} style={{ marginBottom: '20px' }}>
        <input
          type="text"
          placeholder="Your Name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          style={{ width: '100%', padding: '10px', marginBottom: '10px' }}
        />
        <textarea
          placeholder="Your Comment"
          value={comment}
          onChange={(e) => setComment(e.target.value)}
          rows="4"
          style={{ width: '100%', padding: '10px', marginBottom: '10px' }}
        ></textarea>
        <button type="submit" style={{ padding: '10px 20px' }}>
          Submit
        </button>
      </form>
      <div>
        {comments.length === 0 ? (
          <p>No comments yet.</p>
        ) : (
          comments.map((c, index) => (
            <div
              key={index}
              style={{
                border: '1px solid #ddd',
                padding: '10px',
                marginBottom: '10px',
              }}
            >
              <strong>{c.name}</strong>
              <p>{c.comment}</p>
            </div>
          ))
        )}
      </div>
    </div>
  );
}

export default App;