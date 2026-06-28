<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('level_results', function (Blueprint $table) {
            $table->id();
            $table->string('code', 20)->unique()->nullable();
            $table->foreignId('student_id')->constrained()->onDelete('cascade');
            $table->foreignId('level_id')->constrained()->onDelete('cascade');
            $table->foreignId('program_id')->constrained()->onDelete('cascade');
            $table->string('academic_year');
            $table->decimal('total_points', 8, 2)->default(0);
            $table->decimal('total_coefficients', 8, 2)->default(0);
            $table->decimal('average_grade', 5, 2)->default(0);
            $table->integer('total_credits_obtained')->default(0);
            $table->integer('total_credits_required')->default(0);
            $table->string('mention', 30)->nullable();
            $table->string('decision', 20)->default('ajourne');
            $table->timestamp('published_at')->nullable();
            $table->foreignId('validated_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamps();

            $table->unique(['student_id', 'level_id', 'academic_year'], 'level_results_unique');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('level_results');
    }
};
