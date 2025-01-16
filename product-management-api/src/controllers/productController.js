const productModel = require('../models/productModel'); // Import model xử lý sản phẩm
const authenticate = require('../middleware/authMiddleware'); // Middleware xác thực quyền truy cập

// Lấy tất cả sản phẩm
const getAllProducts = (req, res) => {
    productModel.getAllProducts((err, products) => {
        if (err) {
            return res.status(500).json({ message: 'Error fetching products', error: err });
        }
        res.status(200).json(products);
    });
};

// Lấy sản phẩm theo ID
const getProductById = (req, res) => {
    const productId = req.params.id;

    productModel.getProductById(productId, (err, product) => {
        if (err) {
            return res.status(500).json({ message: 'Error fetching product', error: err });
        }

        if (!product) {
            return res.status(404).json({ message: 'Product not found' });
        }

        res.status(200).json(product);
    });
};

// Thêm mới sản phẩm
const addProduct = (req, res) => {
    const { name, code, price, quantity, description, image_url } = req.body;

    if (!name || !code || !price || !quantity) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    productModel.addProduct(name, code, price, quantity, description, image_url, (err, productId) => {
        if (err) {
            return res.status(500).json({ message: 'Error adding product', error: err });
        }
        res.status(201).json({ message: 'Product added successfully', id: productId });
    });
};

// Cập nhật sản phẩm
const updateProduct = (req, res) => {
    const productId = req.params.id;  // Lấy id từ URL
    const { price, quantity } = req.body;

    // Kiểm tra dữ liệu đầu vào
    if (price === undefined || quantity === undefined) {
        return res.status(400).json({ message: 'Missing price or quantity' });
    }

    // Gọi model để cập nhật sản phẩm
    productModel.updateProduct(price, quantity, productId, (err, affectedRows) => {
        if (err) {
            return res.status(500).json({ message: 'Error updating product', error: err });
        }

        if (affectedRows === 0) {
            return res.status(404).json({ message: 'Product not found' });
        }

        res.status(200).json({ message: 'Product updated successfully' });
    });
};


// Xóa sản phẩm
const deleteProduct = (req, res) => {
    const productId = req.params.id;

    productModel.deleteProduct(productId, (err, affectedRows) => {
        if (err) {
            return res.status(500).json({ message: 'Error deleting product', error: err });
        }

        if (affectedRows === 0) {
            return res.status(404).json({ message: 'Product not found' });
        }

        res.status(200).json({ message: 'Product deleted successfully' });
    });
};

// Cập nhật số lượng sản phẩm sau khi thanh toán
const updateProductQuantity = (req, res) => {
    const { id, quantity } = req.body;

    if (!id || !quantity) {
        return res.status(400).json({ message: 'Missing productId or quantity' });
    }

    productModel.decreaseQuantity(id, quantity, (err, result) => {
        if (err) {
            return res.status(500).json({ message: 'Error updating product quantity', error: err });
        }

        if (result.affectedRows === 0) {
            return res.status(400).json({ message: 'Not enough stock' });
        }

        res.status(200).json({ message: 'Product quantity updated successfully' });
    });
};

module.exports = {
    getAllProducts,
    getProductById,
    addProduct,
    updateProduct,
    deleteProduct,
    updateProductQuantity,
};
