<?php

namespace App\Models;

use Tymon\JWTAuth\Contracts\JWTSubject; // Thêm dòng này
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable implements JWTSubject // Implement JWTSubject
{
    use HasApiTokens, HasFactory, Notifiable;
    protected $primaryKey = 'IdUser';

    /**
     * Các thuộc tính có thể gán hàng loạt.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'Username',
        'Password',
        'token',
    ];

    /**
     * Các thuộc tính cần ẩn khi tuần tự hóa (serialization).
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'Password',
        'remember_token',
    ];

    public $timestamps = true;

    /**
     * Các thuộc tính cần ép kiểu (cast).
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
    ];

    /**
     * Lấy ID cho JWT
     *
     * @return mixed
     */
    public function getJWTIdentifier()
    {
        return $this->getKey(); // Trả về khóa chính của user
    }

    /**
     * Lấy các claims tùy chỉnh cho JWT
     *
     * @return array
     */
    public function getJWTCustomClaims()
    {
        return [];
    }
}
