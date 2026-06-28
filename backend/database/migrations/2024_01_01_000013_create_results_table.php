<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('results', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained()->onDelete('cascade');
            $table->foreignId('course_id')->constrained()->onDelete('cascade');
            $table->string('semester');
            $table->string('academic_year');
            $table->decimal('final_grade', 5, 2);
            $table->integer('credits_obtained')->default(0);
            $table->string('status', 20)->default('failed');
            $table->foreignId('validated_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamp('validated_at')->nullable();
            $table->timestamps();
            $table->unique(['student_id', 'course_id', 'semester', 'academic_year'], 'results_unique');
            $table->index('student_id');
            $table->index('course_id');
            $table->index('validated_by');
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('results');
    }
};
