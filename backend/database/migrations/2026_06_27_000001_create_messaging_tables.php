<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('conversations', function (Blueprint $table) {
            $table->id();
            $table->string('code', 20)->unique()->nullable();
            $table->string('type', 20)->default('direct');
            $table->string('name')->nullable();
            $table->timestamps();
            $table->index('type');
        });

        Schema::create('conversation_participants', function (Blueprint $table) {
            $table->id();
            $table->foreignId('conversation_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->timestamp('last_read_at')->nullable();
            $table->timestamps();
            $table->unique(['conversation_id', 'user_id']);
            $table->index('user_id');
            $table->index('conversation_id');
        });

        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->string('code', 20)->unique()->nullable();
            $table->foreignId('conversation_id')->constrained()->onDelete('cascade');
            $table->foreignId('sender_id')->constrained('users')->onDelete('cascade');
            $table->text('content');
            $table->timestamps();
            $table->index('conversation_id');
            $table->index('sender_id');
            $table->index('created_at');
        });

        Schema::create('message_reactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('message_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('reaction', 20);
            $table->timestamps();
            $table->unique(['message_id', 'user_id']);
            $table->index('message_id');
            $table->index('user_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('message_reactions');
        Schema::dropIfExists('messages');
        Schema::dropIfExists('conversation_participants');
        Schema::dropIfExists('conversations');
    }
};
