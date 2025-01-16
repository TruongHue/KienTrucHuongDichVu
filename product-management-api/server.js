const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const productRoutes = require('./src/routes/productRoutes'); // Import route

const app = express();
app.use(bodyParser.json()); // Middleware xử lý dữ liệu JSON
app.use(cors()); // Cấu hình CORS

// Sử dụng productRoutes cho các route liên quan đến sản phẩm
app.use('/api/products', productRoutes); // Đặt prefix '/api/products' cho các route sản phẩm

const port = 8001; // Port của dịch vụ quản lý sản phẩm
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
