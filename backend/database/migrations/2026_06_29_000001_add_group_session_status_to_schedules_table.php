<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('schedules', function (Blueprint $table) {
            $table->string('group', 50)->nullable()->after('type');
            $table->string('session', 20)->nullable()->after('group');
            $table->string('status', 20)->default('active')->after('session');
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::table('schedules', function (Blueprint $table) {
            $table->dropIndex(['status']);
            $table->dropColumn('status');
            $table->dropColumn('session');
            $table->dropColumn('group');
        });
    }
};
