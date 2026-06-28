<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class ContactController extends Controller
{
    public function support(): JsonResponse
    {
        $admin = User::role('admin')->first();

        if (!$admin) {
            return response()->json([
                'success' => false,
                'message' => 'Aucun administrateur disponible pour le support.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $admin->id,
                'name' => $admin->name,
                'email' => $admin->email,
                'avatar' => $admin->avatar,
            ],
        ]);
    }
}
