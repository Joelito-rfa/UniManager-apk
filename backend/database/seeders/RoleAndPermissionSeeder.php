<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RoleAndPermissionSeeder extends Seeder
{
    public function run(): void
    {
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        $permissions = [
            'view-students', 'create-students', 'edit-students', 'delete-students',
            'view-teachers', 'create-teachers', 'edit-teachers', 'delete-teachers',
            'view-departments', 'create-departments', 'edit-departments', 'delete-departments',
            'view-programs', 'create-programs', 'edit-programs', 'delete-programs',
            'view-levels', 'create-levels', 'edit-levels', 'delete-levels',
            'view-subjects', 'create-subjects', 'edit-subjects', 'delete-subjects',
            'view-courses', 'create-courses', 'edit-courses', 'delete-courses',
            'view-classrooms', 'create-classrooms', 'edit-classrooms', 'delete-classrooms',
            'view-schedules', 'create-schedules', 'edit-schedules', 'delete-schedules',
            'view-enrollments', 'create-enrollments', 'edit-enrollments', 'delete-enrollments',
            'view-grades', 'create-grades', 'edit-grades', 'delete-grades',
            'view-results', 'create-results', 'edit-results', 'delete-results',
            'view-dashboard',
            'view-reports', 'export-reports',
            'view-users', 'create-users', 'edit-users', 'delete-users',
            'view-resources', 'create-resources', 'edit-resources', 'delete-resources',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission, 'guard_name' => 'api']);
        }

        $admin = Role::firstOrCreate(['name' => 'admin', 'guard_name' => 'api']);
        $admin->givePermissionTo(Permission::all());

        $teacher = Role::firstOrCreate(['name' => 'teacher', 'guard_name' => 'api']);
        $teacher->givePermissionTo([
            'view-courses', 'view-schedules', 'view-students',
            'view-grades', 'create-grades', 'edit-grades',
            'view-results', 'view-dashboard',
            'view-resources', 'create-resources', 'edit-resources', 'delete-resources',
        ]);

        $student = Role::firstOrCreate(['name' => 'student', 'guard_name' => 'api']);
        $student->givePermissionTo([
            'view-courses', 'view-schedules',
            'view-grades', 'view-results',
            'view-dashboard', 'view-resources',
        ]);
    }
}
