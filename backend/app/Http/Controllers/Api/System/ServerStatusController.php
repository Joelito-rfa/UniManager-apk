<?php

namespace App\Http\Controllers\Api\System;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;

class ServerStatusController extends Controller
{
    public function index(): JsonResponse
    {
        $start = microtime(true);
        try {
            DB::connection()->getPdo();
            $dbOk = true;
        } catch (\Exception) {
            $dbOk = false;
        }
        $responseTime = round((microtime(true) - $start) * 1000);

        $status = $dbOk ? 'operational' : 'maintenance';

        return response()->json([
            'success' => true,
            'data' => [
                'status' => $status,
                'database' => $dbOk,
                'response_time_ms' => $responseTime,
                'timestamp' => now()->toIso8601String(),
                'php_version' => PHP_VERSION,
                'laravel_version' => app()->version(),
            ],
        ]);
    }
}
