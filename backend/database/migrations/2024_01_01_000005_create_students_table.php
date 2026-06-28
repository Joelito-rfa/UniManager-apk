<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('students', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->onDelete('cascade');
            $table->string('student_number')->unique();
            $table->date('date_of_birth')->nullable();
            $table->text('address')->nullable();
            $table->string('phone', 20)->nullable();
            $table->date('enrollment_date')->default(now());
            $table->foreignId('program_id')->constrained()->onDelete('cascade');
            $table->foreignId('level_id')->constrained()->onDelete('cascade');
            $table->timestamps();
            $table->index('program_id');
            $table->index('level_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('students');
    }
};
