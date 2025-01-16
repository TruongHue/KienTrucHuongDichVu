const express = require('express');
const router = express.Router(); 
const User = require('../models/userModel');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const validator = require('validator');
const db = require('../config/db');
const crypto = require('crypto');
const authenticate = require('../middleware/authMiddleware'); // Sửa lại theo tên đúng xuất ra

// SECRET_KEY đã được lưu trong config
const SECRET_KEY = process.env.JWT_SECRET || crypto.randomBytes(64).toString('hex');

// Đăng ký
router.post('/register', (req, res) => {
    const { name, password, email, role = 'Employee' } = req.body;

    if (!name || !password || !email) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    if (!validator.isEmail(email)) {
        return res.status(400).json({ message: 'Invalid email format' });
    }

    const checkDuplicateQuery = 'SELECT * FROM users WHERE email = ? OR name = ?';
    db.query(checkDuplicateQuery, [email, name], (err, results) => {
        if (err) {
            return res.status(500).json({ message: 'Error querying database', error: err });
        }

        if (results.length > 0) {
            let errorMessage = '';
            if (results.some(user => user.email === email)) {
                errorMessage += 'Email already exists. ';
            }
            if (results.some(user => user.name === name)) {
                errorMessage += 'Username already exists.';
            }
            return res.status(400).json({ message: errorMessage.trim() });
        }

        bcrypt.hash(password, 10, (err, hashedPassword) => {
            if (err) {
                return res.status(500).json({ message: 'Error hashing password' });
            }

            const query = 'INSERT INTO users (name, password, email, role) VALUES (?, ?, ?, ?)';
            db.query(query, [name, hashedPassword, email, role], (err, result) => {
                if (err) {
                    return res.status(500).json({ message: 'Error inserting user', error: err });
                }
                res.status(201).json({ message: 'User registered successfully!' });
            });
        });
    });
});

// Đăng nhập
router.post('/login', (req, res) => {
    const { name, password } = req.body;

    if (!name || !password) {
        return res.status(400).json({ message: 'Username and Password are required.' });
    }

    const query = 'SELECT * FROM users WHERE name = ?';
    db.query(query, [name], (err, results) => {
        if (err) {
            return res.status(500).json({ message: 'An error occurred while querying the database.', error: err });
        }

        if (results.length === 0) {
            return res.status(400).json({ message: 'Account does not exist or incorrect password.' });
        }

        const user = results[0];

        bcrypt.compare(password, user.password, (err, isMatch) => {
            if (err) {
                return res.status(500).json({ message: 'An error occurred while checking the password.' });
            }

            if (isMatch) {
                const token = jwt.sign(
                    { id: user.id, name: user.name, role: user.role },
                    SECRET_KEY,
                    { expiresIn: '1h' }
                );
                return res.status(200).json({ token, role: user.role, id: user.id });
            } else {
                return res.status(400).json({ message: 'Incorrect password.' });
            }
        });
    });
});

// Lấy danh sách tất cả người dùng
router.get('/users', authenticate('Admin'), (req, res) => {
    const query = 'SELECT id, name, email, role FROM users'; 
    db.query(query, (err, results) => {
        if (err) {
            return res.status(500).json({ message: 'Error fetching users', error: err });
        }
        res.status(200).json(results);
    });
});

// Xóa người dùng theo ID
router.delete('/users/:id', authenticate('Admin'), (req, res) => {
    const userId = req.params.id;

    const deleteQuery = 'DELETE FROM users WHERE id = ?';
    db.query(deleteQuery, [userId], (err, result) => {
        if (err) {
            return res.status(500).json({ message: 'Error deleting user', error: err });
        }

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        res.status(200).json({ message: 'User deleted successfully' });
    });
});

module.exports = router;
