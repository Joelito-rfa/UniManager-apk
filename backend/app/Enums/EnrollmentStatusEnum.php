<?php

namespace App\Enums;

enum EnrollmentStatusEnum: string
{
    case Active = 'active';
    case Completed = 'completed';
    case Dropped = 'dropped';
}
