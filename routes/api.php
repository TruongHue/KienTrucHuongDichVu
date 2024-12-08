<?php

use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\Route;

// Route đăng nhập
Route::post('/login', [AuthController::class, 'login']);

// Route kiểm tra xác thực token
Route::get('/auth', function () {
    return response()->json(['message' => 'Token is valid']);
})->middleware('jwt.auth');  // Middleware này kiểm tra JWT token

// Route hello yêu cầu xác thực JWT
Route::middleware('jwt.auth')->get('/hello', function () {
    Log::info('Hello API accessed successfully');
    return response()->json(['message' => 'Hello World']);
});
