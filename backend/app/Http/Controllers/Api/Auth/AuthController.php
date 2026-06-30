<?php

namespace App\Http\Controllers\Api\Auth;

use App\Events\UserRegistered;
use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ChangePasswordRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterAdminRequest;
use App\Http\Requests\Auth\RegisterStudentRequest;
use App\Http\Requests\Auth\RegisterTeacherRequest;
use App\Http\Requests\Auth\UpdateProfileRequest;
use App\Http\Resources\UserResource;
use App\Models\AdminInvitationCode;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function __construct(private AuthService $authService) {}

    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->authService->login($request->validated());
        return response()->json($result);
    }

    public function registerStudent(RegisterStudentRequest $request): JsonResponse
    {
        $result = $this->authService->registerStudent($request->validated());
        return response()->json($result, 201);
    }

    public function registerTeacher(RegisterTeacherRequest $request): JsonResponse
    {
        $result = $this->authService->registerTeacher($request->validated());
        return response()->json($result, 201);
    }

    public function registerAdmin(RegisterAdminRequest $request): JsonResponse
    {
        $result = $this->authService->registerAdmin($request->validated());
        return response()->json($result, 201);
    }

    public function checkStudent(Request $request): JsonResponse
    {
        $request->validate([
            'student_number' => 'required|string',
        ]);

        $result = $this->authService->checkStudent($request->only('student_number'));
        return response()->json($result, $result['success'] ? 200 : 404);
    }

    public function checkTeacher(Request $request): JsonResponse
    {
        $request->validate([
            'teacher_number' => 'required|string',
        ]);

        $result = $this->authService->checkTeacher($request->only('teacher_number'));
        return response()->json($result, $result['success'] ? 200 : 404);
    }

    public function generateInvitationCode(): JsonResponse
    {
        $user = auth()->user();

        if (!$user || !$user->hasRole('admin')) {
            return response()->json([
                'success' => false,
                'message' => 'Action non autorisée.',
            ], 403);
        }

        $invitation = AdminInvitationCode::generateCode($user->id);

        return response()->json([
            'success' => true,
            'message' => 'Code d\'invitation généré avec succès.',
            'data' => [
                'code' => $invitation->code,
            ],
        ]);
    }

    public function logout(): JsonResponse
    {
        $this->authService->logout();
        return response()->json(['success' => true, 'message' => 'Déconnexion réussie']);
    }

    public function refresh(): JsonResponse
    {
        try {
            $result = $this->authService->refresh();
            return response()->json($result);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token invalide ou expiré',
            ], 401);
        }
    }

    public function me(): JsonResponse
    {
        $user = auth()->user()->load(['roles', 'student.program', 'student.level', 'teacher.department']);
        return response()->json([
            'success' => true,
            'data' => new UserResource($user),
        ]);
    }

    public function updateProfile(UpdateProfileRequest $request): JsonResponse
    {
        $user = auth()->user();
        $data = $request->validated();

        $user->update(array_intersect_key($data, array_flip(['name', 'email', 'phone', 'avatar'])));

        return response()->json([
            'success' => true,
            'message' => 'Profil mis à jour avec succès',
            'data' => new UserResource($user->fresh()),
        ]);
    }

    public function changePassword(ChangePasswordRequest $request): JsonResponse
    {
        $user = auth()->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Le mot de passe actuel est incorrect',
            ], 422);
        }

        $user->update(['password' => Hash::make($request->new_password)]);

        return response()->json([
            'success' => true,
            'message' => 'Mot de passe modifié avec succès',
        ]);
    }

    public function forgotPassword(Request $request): JsonResponse
    {
        $request->validate(['email' => 'required|email|exists:users,email']);
        $this->authService->forgotPassword($request->email);
        return response()->json(['success' => true, 'message' => 'Email envoyé']);
    }

    public function resetPassword(Request $request): JsonResponse
    {
        $request->validate([
            'token' => 'required',
            'email' => 'required|email',
            'password' => 'required|min:8|confirmed',
        ]);
        $this->authService->resetPassword($request->all());
        return response()->json(['success' => true, 'message' => 'Mot de passe réinitialisé']);
    }
}
