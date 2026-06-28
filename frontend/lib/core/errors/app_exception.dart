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

  factory AppException.fromDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return AppException(
          message: 'La connexion a expiré. Veuillez réessayer.',
          statusCode: null,
        );
      case DioExceptionType.sendTimeout:
        return AppException(
          message: 'L\'envoi de la requête a expiré.',
          statusCode: null,
        );
      case DioExceptionType.receiveTimeout:
        return AppException(
          message: 'La réception de la réponse a expiré.',
          statusCode: null,
        );
      case DioExceptionType.badResponse:
        return _handleStatusCode(e.response);
      case DioExceptionType.cancel:
        return AppException(
          message: 'La requête a été annulée.',
          statusCode: null,
        );
      case DioExceptionType.connectionError:
        return AppException(
          message: 'La connexion a échoué. Vérifiez votre réseau.',
          statusCode: null,
        );
      default:
        return AppException(
          message: 'Une erreur est survenue. Veuillez réessayer.',
          statusCode: null,
        );
    }
  }

  factory AppException.fromString(String message) {
    return AppException(message: message);
  }

  static AppException _handleStatusCode(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;
    String message;
    dynamic errors;

    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? '';
      errors = data['errors'];
    } else {
      message = data?.toString() ?? '';
    }

    switch (statusCode) {
      case 400:
        return AppException(
          message: message.isNotEmpty ? message : 'La requête est invalide.',
          statusCode: statusCode,
          errors: errors,
        );
      case 401:
        return AppException(
          message: message.isNotEmpty ? message : 'Vous n\'êtes pas autorisé. Veuillez vous connecter.',
          statusCode: statusCode,
          errors: errors,
        );
      case 403:
        return AppException(
          message: message.isNotEmpty ? message : 'L\'accès est refusé.',
          statusCode: statusCode,
          errors: errors,
        );
      case 404:
        return AppException(
          message: message.isNotEmpty ? message : 'La ressource est introuvable.',
          statusCode: statusCode,
          errors: errors,
        );
      case 422:
        return AppException(
          message: message.isNotEmpty ? message : 'Les données sont invalides.',
          statusCode: statusCode,
          errors: errors,
        );
      case 500:
        return AppException(
          message: message.isNotEmpty ? message : 'Une erreur interne du serveur est survenue.',
          statusCode: statusCode,
          errors: errors,
        );
      default:
        return AppException(
          message: message.isNotEmpty ? message : 'Une erreur est survenue.',
          statusCode: statusCode,
          errors: errors,
        );
    }
  }

  @override
  String toString() => message;
}
