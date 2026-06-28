<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Illuminate\Notifications\Messages\MailMessage;

class ResetPassword extends Notification
{
    use Queueable;

    public function __construct(
        public string $token
    ) {}

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Réinitialisation de votre mot de passe')
            ->greeting('Bonjour ' . ($notifiable->name ?? '') . ',')
            ->line('Vous recevez cet email suite à votre demande de réinitialisation de mot de passe.')
            ->line('Voici votre code de réinitialisation :')
            ->line('**' . $this->token . '**')
            ->line('Ce code expire dans 60 minutes.')
            ->line('Si vous n\'avez pas demandé cette réinitialisation, ignorez cet email.')
            ->salutation('L\'équipe UniManager');
    }
}
