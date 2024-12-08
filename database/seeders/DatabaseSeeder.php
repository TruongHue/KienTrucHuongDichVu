<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     *
     * @return void
     */
    public function run()
    {
        // \App\Models\User::factory(10)->create();

        // Insert admin user
        DB::table('users')->insert([
            'UserName' => 'admin@example.com',
            'Password' => Hash::make('password123'),
        ]);
    }
}
