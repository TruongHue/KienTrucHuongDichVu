const mysql = require('mysql2');

// Tạo kết nối đến cơ sở dữ liệu MySQL user
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',           // Tên người dùng MySQL của bạn
  password: '',           // Mật khẩu MySQL của bạn
  database: 'user_db'     // Tên cơ sở dữ liệu của bạn
});

// Kết nối đến cơ sở dữ liệu user
db.connect(err => {
  if (err) {
    console.error('Error connecting to the user database:', err);
  } else {
    console.log('Connected to user MySQL');
  }
});

// Export cả hai kết nối
module.exports = db;
