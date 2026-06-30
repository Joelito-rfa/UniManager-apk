import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  AppException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory AppException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException(
          message: 'La connexion a expiré. Vérifiez votre connexion internet.',
          statusCode: null,
        );
      case DioExceptionType.connectionError:
        return AppException(
          message: 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
          statusCode: null,
        );
      case DioExceptionType.cancel:
        return AppException(message: 'La requête a été annulée.');
      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response);
      case DioExceptionType.badCertificate:
        return AppException(message: 'Erreur de certificat de sécurité.');
      case DioExceptionType.unknown:
        return AppException(
          message: 'Une erreur inattendue est survenue. Réessayez.',
          statusCode: null,
        );
    }
  }

  static AppException _handleStatusCode(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    String message;
    Map<String, dynamic>? errors;

    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? '';
      errors = data['errors'] as Map<String, dynamic>?;
    } else {
      message = data?.toString() ?? '';
    }

    if (message.isEmpty) {
      message = switch (statusCode) {
        400 => 'Requête invalide.',
        401 => 'Session expirée. Veuillez vous reconnecter.',
        403 => 'Accès non autorisé.',
        404 => 'Ressource introuvable.',
        409 => 'Conflit avec les données existantes.',
        422 => 'Données invalides.',
        429 => 'Trop de tentatives. Réessayez plus tard.',
        _ => 'Erreur serveur ($statusCode). Réessayez plus tard.',
      };
    }

    return AppException(
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  String get userFriendlyMessage {
    if (statusCode == 401) {
      return 'Votre session a expiré. Veuillez vous reconnecter.';
    }
    return message;
  }

  @override
  String toString() => 'AppException: $message (HTTP $statusCode)';
}
