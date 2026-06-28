<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('levels', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('code')->unique();
            $table->foreignId('program_id')->constrained()->onDelete('cascade');
            $table->timestamps();
            $table->index('program_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('levels');
    }
};
