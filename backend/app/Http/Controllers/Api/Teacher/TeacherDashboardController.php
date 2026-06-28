<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Controller;
use App\Services\DashboardService;
use Illuminate\Http\JsonResponse;

class TeacherDashboardController extends Controller
{
    public function __construct(private DashboardService $dashboardService) {}

    public function index(): JsonResponse
    {
        $teacher = auth()->user()->teacher;
        if (!$teacher) {
            return response()->json(['success' => false, 'message' => 'L\'enseignant est introuvable'], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $this->dashboardService->getTeacherStats($teacher->id),
        ]);
    }
}
