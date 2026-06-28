<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('code', 20)->unique()->nullable()->after('id');
        });

        Schema::table('profiles', function (Blueprint $table) {
            $table->string('code', 20)->unique()->nullable()->after('id');
        });

        Schema::table('teachers', function (Blueprint $table) {
            $table->string('code', 20)->unique()->nullable()->after('id');
        });

        Schema::table('students', function (Blueprint $table) {
            $table->string('code', 20)->unique()->nullable()->after('id');
        });

        Schema::table('courses', function (Blueprint $table) {
            $table->string('code', 20)->unique()->nullable()->after('id');
        });

        Schema::table('course_resources', function (Blueprint $table) {
            $table->string('code', 20)->unique()->nullable()->after('id');
        });

        Schema::table('enrollments', function (Blueprint $table) {
            $table->string('code', 20)->unique()->nullable()->after('id');
        });

        Schema::table('grades', function (Blueprint $table) {
            $table->string('code', 20)->unique()->nullable()->after('id');
        });

        Schema::table('notifications', function (Blueprint $table) {
            $table->string('code', 20)->unique()->nullable()->after('id');
        });

        Schema::table('results', function (Blueprint $table) {
            $table->string('code', 20)->unique()->nullable()->after('id');
        });

        Schema::table('schedules', function (Blueprint $table) {
            $table->string('code', 20)->unique()->nullable()->after('id');
        });
    }

    public function down(): void
    {
        $tables = ['users', 'profiles', 'teachers', 'students', 'courses', 'course_resources', 'enrollments', 'grades', 'notifications', 'results', 'schedules'];

        foreach ($tables as $table) {
            Schema::table($table, function (Blueprint $t) use ($table) {
                $t->dropUnique([$table . '_code_unique']);
                $t->dropColumn('code');
            });
        }
    }
};
