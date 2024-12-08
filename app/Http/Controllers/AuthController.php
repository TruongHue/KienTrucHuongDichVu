<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Tymon\JWTAuth\Facades\JWTAuth;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use Illuminate\Support\Facades\Log;


class AuthController extends Controller
{
    public function login(Request $request)
{
    Log::info('Login Attempt:', $request->only('UserName', 'Password'));

    $credentials = $request->only('UserName', 'Password');

    // Tìm user theo username
    $user = User::where('UserName', $request->UserName)->first();

    // Kiểm tra nếu tìm thấy user
    if ($user && Hash::check($request->Password, $user->Password)) {
        Log::info('Password match');

        // Tạo token JWT nếu mật khẩu khớp
        $Token = JWTAuth::fromUser($user);

        // Cập nhật token vào cột Token
        $user-> token = $Token;
        if ($user->save()) {
            Log::info('Token saved successfully');
        } else {
            Log::error('Failed to save token');
        }
        
        Log::info('User Data:', $user ? $user->toArray() : []);

        // Trả về token dưới dạng phản hồi JSON
        return response()->json([
            'Token' => $Token
        ]);
    } else {
        Log::info('Password mismatch');
    }

    // Trả về lỗi nếu không tìm thấy user hoặc mật khẩu sai
    return response()->json(['error' => 'Invalid credentials'], 401);
}


    

    public function me()
    {
        // Trả về thông tin người dùng đã xác thực
        return response()->json(auth()->user());
    }
}
