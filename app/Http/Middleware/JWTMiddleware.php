<?php

namespace App\Http\Middleware;

use Closure;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;
use Tymon\JWTAuth\Exceptions\TokenInvalidException;
use Exception;

class JWTMiddleware
{
    public function handle($request, Closure $next)
{
    try {
        // Kiểm tra xem token có tồn tại trong header không
        if (!$request->hasHeader('Authorization')) {
            return response()->json(['error' => 'Authorization token is missing'], 400);
        }

        // Lấy token từ header Authorization
        $token = $request->bearerToken();

        // Nếu token hợp lệ, thực hiện xác thực người dùng
        $user = JWTAuth::parseToken()->authenticate();
        Log::info('Authenticated User: ', $user ? $user->toArray() : ['null']);

        // Nếu không xác thực được, trả về lỗi
        if (!$user) {
            return response()->json(['error' => 'User not found'], 401);
        }

    } catch (TokenExpiredException $e) {
        return response()->json(['error' => 'Token has expired'], 401);
    } catch (TokenInvalidException $e) {
        return response()->json(['error' => 'Token is invalid'], 401);
    } catch (JWTException $e) {
        return response()->json(['error' => 'Token is missing or invalid'], 401);
    } catch (Exception $e) {
        // Xử lý các lỗi không mong muốn
        return response()->json(['error' => 'Something went wrong'], 500);
    }

    // Tiếp tục request nếu xác thực thành công
    return $next($request);
}

}
