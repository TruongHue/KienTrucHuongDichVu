const db = require('../config/db');

// Mô hình người dùng
const User = {
  create: (name, email, password, role, callback) => {
    const query = `INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)`;
    db.query(query, [name, email, password, role], callback);
  },
  
  getAll: (callback) => {
    const query = `SELECT * FROM users`;
    db.query(query, callback);
  },
  
  getById: (userId, callback) => {
    const query = `SELECT * FROM users WHERE id = ?`;
    db.query(query, [userId], callback);
  },
  
  update: (userId, name, email, password, role, callback) => {
    const query = `UPDATE users SET name = ?, email = ?, password = ?, role = ? WHERE id = ?`;
    db.query(query, [name, email, password, role, userId], callback);
  },
  
  delete: (userId, callback) => {
    const query = `DELETE FROM users WHERE id = ?`;
    db.query(query, [userId], callback);
  }
};

module.exports = User;
