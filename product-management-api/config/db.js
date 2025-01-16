const mysql = require('mysql2'); // Import mysql2 thay vì mysql

// Tạo kết nối cơ sở dữ liệu
const dbProduct = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'product_db'
});

// Kết nối với cơ sở dữ liệu
dbProduct.connect((err) => {
    if (err) {
        console.error('Error connecting to the database: ', err);
        return;
    }
    console.log('Connected to the MySQL database');
});

// Export kết nối dbProduct
module.exports = dbProduct;
