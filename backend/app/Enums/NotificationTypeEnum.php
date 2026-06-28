<?php

namespace App\Enums;

enum NotificationTypeEnum: string
{
    case Info = 'info';
    case Warning = 'warning';
    case Success = 'success';
    case Error = 'error';
}
