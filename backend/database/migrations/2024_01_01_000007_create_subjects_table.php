<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subjects', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('code')->unique();
            $table->text('description')->nullable();
            $table->integer('credits')->default(3);
            $table->decimal('coefficient', 4, 2)->default(1.00);
            $table->foreignId('program_id')->constrained()->onDelete('cascade');
            $table->foreignId('teacher_id')->nullable()->constrained()->onDelete('set null');
            $table->timestamps();
            $table->index('program_id');
            $table->index('teacher_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subjects');
    }
};
