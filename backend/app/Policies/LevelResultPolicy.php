<?php

namespace App\Policies;

use App\Models\User;
use App\Models\LevelResult;

class LevelResultPolicy
{
    public function viewAny(User $user): bool { return $user->hasPermissionTo('view-results'); }
    public function view(User $user, LevelResult $levelResult): bool { return $user->hasPermissionTo('view-results'); }
    public function create(User $user): bool { return $user->hasPermissionTo('create-results'); }
    public function update(User $user, LevelResult $levelResult): bool { return $user->hasPermissionTo('edit-results'); }
    public function delete(User $user, LevelResult $levelResult): bool { return $user->hasPermissionTo('delete-results'); }
}
