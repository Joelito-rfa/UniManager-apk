<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('courses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('subject_id')->constrained()->onDelete('cascade');
            $table->foreignId('teacher_id')->constrained()->onDelete('cascade');
            $table->foreignId('classroom_id')->nullable()->constrained()->onDelete('set null');
            $table->string('semester');
            $table->string('academic_year');
            $table->string('group_name')->nullable();
            $table->timestamps();
            $table->unique(['subject_id', 'teacher_id', 'semester', 'academic_year', 'group_name'], 'courses_unique');
            $table->index('subject_id');
            $table->index('teacher_id');
            $table->index('classroom_id');
            $table->index('semester');
            $table->index('academic_year');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('courses');
    }
};
