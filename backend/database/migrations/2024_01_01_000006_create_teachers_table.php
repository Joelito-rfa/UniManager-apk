<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('teachers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->onDelete('cascade');
            $table->string('teacher_number')->unique();
            $table->string('speciality')->nullable();
            $table->date('date_of_birth')->nullable();
            $table->text('address')->nullable();
            $table->string('phone', 20)->nullable();
            $table->date('hire_date');
            $table->foreignId('department_id')->nullable()->constrained()->onDelete('set null');
            $table->timestamps();
            $table->index('department_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('teachers');
    }
};
