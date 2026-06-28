<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('results', function (Blueprint $table) {
            $table->string('decision', 20)->default('failed')->after('status');
            $table->integer('credit_value')->default(0)->after('credits_obtained');
            $table->decimal('grade_point', 4, 2)->nullable()->after('credit_value');
        });
    }

    public function down(): void
    {
        Schema::table('results', function (Blueprint $table) {
            $table->dropColumn(['decision', 'credit_value', 'grade_point']);
        });
    }
};
