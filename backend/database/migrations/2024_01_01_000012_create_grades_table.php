<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('grades', function (Blueprint $table) {
            $table->id();
            $table->foreignId('enrollment_id')->constrained()->onDelete('cascade');
            $table->string('grade_type');
            $table->decimal('grade_value', 5, 2);
            $table->decimal('coefficient', 4, 2)->default(1.00);
            $table->text('comment')->nullable();
            $table->foreignId('graded_by')->constrained('users')->onDelete('cascade');
            $table->timestamps();
            $table->index('enrollment_id');
            $table->index('graded_by');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('grades');
    }
};
