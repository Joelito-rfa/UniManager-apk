<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreUserRequest;
use App\Http\Requests\Admin\UpdateUserRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Services\UserService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function __construct(private UserService $userService) {}

    public function index(Request $request): JsonResponse
    {
        $users = $this->userService->paginate($request);
        return response()->json([
            'success' => true,
            'data' => UserResource::collection($users),
            'meta' => [
                'current_page' => $users->currentPage(),
                'last_page' => $users->lastPage(),
                'per_page' => $users->perPage(),
                'total' => $users->total(),
            ],
        ]);
    }

    public function store(StoreUserRequest $request): JsonResponse
    {
        $user = $this->userService->create($request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Utilisateur créé avec succès',
            'data' => new UserResource($user),
        ], 201);
    }

    public function show(User $user): JsonResponse
    {
        $user->load(['roles', 'student.program', 'student.level', 'teacher.department']);
        return response()->json([
            'success' => true,
            'data' => new UserResource($user),
        ]);
    }

    public function update(UpdateUserRequest $request, User $user): JsonResponse
    {
        $user = $this->userService->update($user, $request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Utilisateur modifié avec succès',
            'data' => new UserResource($user),
        ]);
    }

    public function destroy(User $user): JsonResponse
    {
        $this->userService->delete($user);
        return response()->json([
            'success' => true,
            'message' => 'Utilisateur supprimé avec succès',
        ]);
    }

    public function assignRoles(Request $request, User $user): JsonResponse
    {
        $request->validate(['roles' => 'required|array', 'roles.*' => 'string|exists:roles,name']);
        $this->userService->assignRoles($user, $request->roles);
        return response()->json([
            'success' => true,
            'message' => 'Rôles attribués avec succès',
            'data' => new UserResource($user->load('roles')),
        ]);
    }
}
