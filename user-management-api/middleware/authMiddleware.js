require('dotenv').config();
const jwt = require('jsonwebtoken');
const SECRET_KEY = process.env.JWT_SECRET;

// Middleware xác thực JWT và phân quyền nhiều vai trò
const authenticate = (...allowedRoles) => {
    return (req, res, next) => {
        const token = req.headers['authorization']?.split(' ')[1];

        if (!token) {
            return res.status(403).json({ message: 'No token provided' });
        }

        jwt.verify(token, SECRET_KEY, (err, decoded) => {
            if (err) {
                return res.status(401).json({ message: 'Invalid or expired token' });
            }

            console.log("Decoded token:", decoded);

            // Kiểm tra nếu role không nằm trong danh sách allowedRoles
            if (allowedRoles.length > 0 && !allowedRoles.includes(decoded.role)) {
                return res.status(403).json({ message: 'Access denied' });
            }

            req.user = decoded;
            next();
        });
    };
};

module.exports = authenticate;
