const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const userController = require('./controllers/userController');
const cors = require('cors');

// Middleware để phân tích JSON
app.use(express.json()); // Hoặc bodyParser.json() nếu bạn sử dụng body-parser

// Sử dụng middleware CORS để cho phép các yêu cầu từ các domain khác
app.use(cors()); 

// Sử dụng router từ userController
app.use('/api/users', userController);

// Lắng nghe server
app.listen(8000, () => {
    console.log('Server đang chạy trên port 8000');
});
