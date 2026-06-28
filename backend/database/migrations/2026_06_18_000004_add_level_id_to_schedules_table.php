<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('schedules', function (Blueprint $table) {
            $table->foreignId('level_id')->nullable()->after('classroom_id')->constrained()->onDelete('set null');
            $table->index('level_id');
        });
    }

    public function down(): void
    {
        Schema::table('schedules', function (Blueprint $table) {
            $table->dropForeign(['level_id']);
            $table->dropIndex(['level_id']);
            $table->dropColumn('level_id');
        });
    }
};
