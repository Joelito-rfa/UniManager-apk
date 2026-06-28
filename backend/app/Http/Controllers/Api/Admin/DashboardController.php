<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Services\DashboardService;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    public function __construct(private DashboardService $dashboardService) {}

    public function index(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => $this->dashboardService->getStats(),
        ]);
    }

    public function charts(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => $this->dashboardService->getChartData(),
        ]);
    }
}
