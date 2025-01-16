const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController'); // Import controller
const authenticate = require('../middleware/authMiddleware'); // Import middleware

// Middleware xác thực quyền truy cập
const authenticateAdmin = authenticate('Admin');
const authenticateAdminOrEmployee = authenticate('Admin', 'Employee');

// Định nghĩa các route cho sản phẩm
router.get('/', authenticateAdminOrEmployee, productController.getAllProducts); // Lấy tất cả sản phẩm
router.get('/:id', authenticateAdmin, productController.getProductById); // Lấy sản phẩm theo ID
router.post('/', authenticateAdmin, productController.addProduct); // Thêm sản phẩm mới
router.put('/:id', authenticateAdmin, productController.updateProduct); // Cập nhật sản phẩm
router.delete('/:id', authenticateAdmin, productController.deleteProduct); // Xóa sản phẩm
router.put('/:id/decrease-quantity', authenticateAdminOrEmployee, productController.updateProductQuantity); // Cập nhật số lượng sản phẩm

module.exports = router; // Xuất khẩu router
