<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreDepartmentRequest;
use App\Http\Requests\Admin\UpdateDepartmentRequest;
use App\Http\Resources\DepartmentResource;
use App\Models\Department;
use App\Services\DepartmentService;
use App\Services\IdentifierService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DepartmentController extends Controller
{
    public function __construct(private DepartmentService $departmentService) {}

    public function index(Request $request): JsonResponse
    {
        $departments = $this->departmentService->paginate($request);
        return response()->json([
            'success' => true,
            'data' => DepartmentResource::collection($departments),
            'meta' => [
                'current_page' => $departments->currentPage(),
                'last_page' => $departments->lastPage(),
                'per_page' => $departments->perPage(),
                'total' => $departments->total(),
            ],
        ]);
    }

    public function store(StoreDepartmentRequest $request): JsonResponse
    {
        $department = $this->departmentService->create($request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Département créé avec succès',
            'data' => new DepartmentResource($department),
        ], 201);
    }

    public function show(Department $department): JsonResponse
    {
        $department->load(['programs', 'teachers.user']);
        return response()->json([
            'success' => true,
            'data' => new DepartmentResource($department),
        ]);
    }

    public function update(UpdateDepartmentRequest $request, Department $department): JsonResponse
    {
        $department = $this->departmentService->update($department, $request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Département modifié avec succès',
            'data' => new DepartmentResource($department),
        ]);
    }

    public function nextCode(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'next_code' => app(IdentifierService::class)->generateForClass(Department::class),
            ],
        ]);
    }

    public function destroy(Department $department): JsonResponse
    {
        $this->departmentService->delete($department);
        return response()->json([
            'success' => true,
            'message' => 'Département supprimé avec succès',
        ]);
    }
}
