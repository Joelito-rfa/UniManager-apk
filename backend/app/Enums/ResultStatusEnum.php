<?php

namespace App\Enums;

enum ResultStatusEnum: string
{
    case Validated = 'validated';
    case Failed = 'failed';
}
