<?php

namespace Tests\Feature;

use App\Models\Department;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SearchApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
    }

    public function test_search_requires_authentication(): void
    {
        $response = $this->getJson('/api/search?q=test');
        $response->assertStatus(401);
    }

    public function test_search_returns_results(): void
    {
        $user = User::create(['name' => 'Admin Test', 'email' => 'admin@test.com', 'password' => bcrypt('password')]);
        Department::create(['name' => 'Informatique', 'description' => 'Desc']);

        $response = $this->actingAs($user, 'api')->getJson('/api/search?q=Info');

        $response->assertStatus(200)
            ->assertJson(['success' => true])
            ->assertJsonStructure([
                'data' => [
                    'students', 'teachers', 'departments', 'programs',
                    'levels', 'subjects', 'courses', 'classrooms',
                ],
            ]);
    }

    public function test_search_validates_query_parameter(): void
    {
        $user = User::create(['name' => 'Admin Test', 'email' => 'admin@test.com', 'password' => bcrypt('password')]);

        $response = $this->actingAs($user, 'api')->getJson('/api/search');

        $response->assertStatus(422);
    }

    public function test_search_accessible_by_all_roles(): void
    {
        $user = User::create(['name' => 'Test', 'email' => 'test@test.com', 'password' => bcrypt('password')]);

        $response = $this->actingAs($user, 'api')->getJson('/api/search?q=test');
        $response->assertStatus(200);
    }
}
