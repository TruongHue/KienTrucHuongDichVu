const db = require('../../config/db'); // Cấu hình kết nối đến database

// Lấy danh sách tất cả sản phẩm
const getAllProducts = (callback) => {
    const query = 'SELECT * FROM products';
    db.query(query, (err, results) => {
        if (err) {
            return callback(err, null);
        }
        callback(null, results);
    });
};

// Lấy sản phẩm theo ID
const getProductById = (id, callback) => {
    const query = 'SELECT * FROM products WHERE id = ?';
    db.query(query, [id], (err, results) => {
        if (err) {
            return callback(err, null);
        }
        if (results.length === 0) {
            return callback(null, null); // Sản phẩm không tìm thấy
        }
        callback(null, results[0]);
    });
};

// Thêm sản phẩm mới
const addProduct = (name, code, price, quantity, description, image_url, callback) => {
    // Kiểm tra sản phẩm có trùng mã code hay không
    const checkQuery = 'SELECT COUNT(*) AS count FROM products WHERE code = ?';
    
    db.query(checkQuery, [code], (err, result) => {
        if (err) {
            return callback(err, null);
        }

        // Nếu sản phẩm với code đã tồn tại
        if (result[0].count > 0) {
            return callback(null, { message: 'Sản phẩm với mã code này đã tồn tại' });
        }

        // Nếu chưa có sản phẩm trùng code, thêm sản phẩm mới
        const insertQuery = 'INSERT INTO products (name, code, price, quantity, description, image_url) VALUES (?, ?, ?, ?, ?, ?)';
        
        db.query(insertQuery, [name, code, price, quantity, description, image_url], (err, result) => {
            if (err) {
                return callback(err, null);
            }
            callback(null, { insertId: result.insertId }); // Trả về ID của sản phẩm vừa thêm
        });
    });
};


// Cập nhật sản phẩm
const updateProduct = (price, quantity, id, callback) => {
    const query = 'UPDATE products SET price = ?, quantity = ? WHERE id = ?';

    db.query(query, [price, quantity, id], (err, result) => {
        if (err) {
            return callback(err, null);
        }
        callback(null, result.affectedRows); // Trả về số dòng bị ảnh hưởng
    });
};


// Xóa sản phẩm
const deleteProduct = (id, callback) => {
    const query = 'DELETE FROM products WHERE id = ?';
    db.query(query, [id], (err, result) => {
        if (err) {
            return callback(err, null);
        }
        callback(null, result.affectedRows); // Trả về số dòng bị ảnh hưởng
    });
};

// Giảm số lượng sản phẩm
const decreaseQuantity = (id, quantity, callback) => {
    const checkQuery = 'SELECT * FROM products WHERE id = ?';
    db.query(checkQuery, [id], (err, results) => {
        if (err) return callback(err, null);
        if (results.length === 0) return callback(new Error('Product not found'), null);

        const currentQuantity = results[0].quantity;
        if (currentQuantity < quantity) {
            return callback(new Error('Not enough stock to decrease'), null);
        }

        const newQuantity = currentQuantity - quantity;
        const updateQuery = 'UPDATE products SET quantity = ? WHERE id = ?';
        db.query(updateQuery, [newQuantity, id], (err, result) => {
            if (err) return callback(err, null);
            callback(null, result); // Trả về kết quả
        });
    });
};

module.exports = {
    getAllProducts,
    getProductById,
    addProduct,
    updateProduct,
    deleteProduct,
    decreaseQuantity,
};
