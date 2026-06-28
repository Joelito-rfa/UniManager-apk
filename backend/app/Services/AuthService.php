<?php

namespace App\Services;

use App\Models\AdminInvitationCode;
use App\Models\Student;
use App\Models\Teacher;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Tymon\JWTAuth\Facades\JWTAuth;

class AuthService
{
    public function login(array $data): array
    {
        if (!$token = JWTAuth::attempt(['email' => $data['email'], 'password' => $data['password']])) {
            throw new \Illuminate\Validation\ValidationException(
                validator([], []),
                'L\'email ou le mot de passe est incorrect'
            );
        }

        $user = auth()->user()->load(['roles', 'student', 'teacher']);

        return [
            'success' => true,
            'message' => 'Connexion réussie',
            'data' => [
                'access_token' => $token,
                'refresh_token' => null,
                'token_type' => 'bearer',
                'expires_in' => auth()->factory()->getTTL() * 60,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->getRoleNames()->first(),
                    'avatar' => $user->avatar,
                ],
            ],
        ];
    }

    public function registerStudent(array $data): array
    {
        $student = Student::where('student_number', $data['student_number'])->first();

        if (!$student || !$student->date_of_birth) {
            throw new \Illuminate\Validation\ValidationException(
                validator([], []),
                'Étudiant non trouvé. Veuillez contacter l\'administration.'
            );
        }

        if ($student->date_of_birth->format('Y-m-d') !== $data['date_of_birth']) {
            throw new \Illuminate\Validation\ValidationException(
                validator([], []),
                'Les informations fournies ne correspondent pas.'
            );
        }

        if ($student->user_id) {
            throw new \Illuminate\Validation\ValidationException(
                validator([], []),
                'Un compte existe déjà pour cet étudiant.'
            );
        }

        $email = $data['email'] ?? strtolower(str_replace(' ', '.', $student->student_number)) . '@unimanager.edu';

        $user = User::create([
            'name' => 'Étudiant ' . $student->student_number,
            'email' => $email,
            'password' => Hash::make($data['password']),
        ]);

        $user->assignRole('student');

        $student->update(['user_id' => $user->id]);

        $token = JWTAuth::fromUser($user);

        return [
            'success' => true,
            'token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth()->factory()->getTTL() * 60,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => 'student',
            ],
        ];
    }

    public function registerTeacher(array $data): array
    {
        $teacher = Teacher::where('teacher_number', $data['teacher_number'])->first();

        if (!$teacher) {
            throw new \Illuminate\Validation\ValidationException(
                validator([], []),
                'Enseignant introuvable. Veuillez contacter l\'administration.'
            );
        }

        if ($teacher->user_id) {
            throw new \Illuminate\Validation\ValidationException(
                validator([], []),
                'Un compte existe déjà pour cet enseignant.'
            );
        }

        $user = User::create([
            'name' => 'Enseignant ' . $teacher->teacher_number,
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
        ]);

        $user->assignRole('teacher');

        $teacher->update(['user_id' => $user->id]);

        $token = JWTAuth::fromUser($user);

        return [
            'success' => true,
            'token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth()->factory()->getTTL() * 60,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => 'teacher',
            ],
        ];
    }

    public function registerAdmin(array $data): array
    {
        $invitation = AdminInvitationCode::where('code', $data['invitation_code'])
            ->where('used', false)
            ->first();

        if (!$invitation) {
            throw new \Illuminate\Validation\ValidationException(
                validator([], []),
                'Le code d\'invitation est invalide ou déjà utilisé.'
            );
        }

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
        ]);

        $user->assignRole('admin');

        $invitation->markAsUsed($user->id);

        $token = JWTAuth::fromUser($user);

        return [
            'success' => true,
            'token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth()->factory()->getTTL() * 60,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => 'admin',
            ],
        ];
    }

    public function checkStudent(array $data): array
    {
        $student = Student::with(['program', 'level'])
            ->where('student_number', $data['student_number'])
            ->first();

        if (!$student) {
            return [
                'success' => false,
                'message' => 'Étudiant non trouvé. Veuillez contacter l\'administration.',
            ];
        }

        if ($student->user_id) {
            return [
                'success' => false,
                'message' => 'Un compte existe déjà pour cet étudiant.',
            ];
        }

        return [
            'success' => true,
            'message' => 'Étudiant trouvé',
            'data' => [
                'id' => $student->id,
                'student_number' => $student->student_number,
                'name' => 'Étudiant ' . $student->student_number,
                'program' => $student->program?->name,
                'level' => $student->level?->name,
                'has_date_of_birth' => !is_null($student->date_of_birth),
            ],
        ];
    }

    public function checkTeacher(array $data): array
    {
        $teacher = Teacher::with(['department'])
            ->where('teacher_number', $data['teacher_number'])
            ->first();

        if (!$teacher) {
            return [
                'success' => false,
                'message' => 'Enseignant introuvable. Veuillez contacter l\'administration.',
            ];
        }

        if ($teacher->user_id) {
            return [
                'success' => false,
                'message' => 'Un compte existe déjà pour cet enseignant.',
            ];
        }

        return [
            'success' => true,
            'message' => 'Enseignant trouvé',
            'data' => [
                'id' => $teacher->id,
                'teacher_number' => $teacher->teacher_number,
                'name' => 'Enseignant ' . $teacher->teacher_number,
                'department' => $teacher->department?->name,
            ],
        ];
    }

    public function logout(): void
    {
        auth()->logout();
    }

    public function refresh(): array
    {
        $token = auth()->refresh();
        return [
            'success' => true,
            'token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth()->factory()->getTTL() * 60,
        ];
    }

    public function forgotPassword(string $email): void
    {
        Password::sendResetLink(['email' => $email]);
    }

    public function resetPassword(array $data): void
    {
        $status = Password::reset(
            $data,
            function ($user, $password) {
                $user->password = Hash::make($password);
                $user->save();
            }
        );

        if ($status !== Password::PASSWORD_RESET) {
            throw new \Illuminate\Validation\ValidationException(
                validator([], []),
                __($status)
            );
        }
    }
}
