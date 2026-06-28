class Validators {
  static String? required(String? value, [String fieldName = 'Ce champ']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'email est requis';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'L\'email est invalide';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Le mot de passe doit contenir au moins une majuscule';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final cleaned = value.trim().replaceAll(RegExp(r'[\s\-().]'), '');
    if (!RegExp(r'^\+?\d{8,15}$').hasMatch(cleaned)) {
      return 'Le téléphone ne doit contenir que des chiffres';
    }
    return null;
  }

  static String? name(String? value, [String fieldName = 'Le nom']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    if (value.trim().length < 2) {
      return '$fieldName doit contenir au moins 2 caractères';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'La confirmation est requise';
    }
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  static String? numeric(String? value, [String fieldName = 'Ce champ']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value.trim())) {
      return '$fieldName doit être un nombre valide';
    }
    return null;
  }

  static String? minLength(String? value, int min, [String fieldName = 'Ce champ']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    if (value.trim().length < min) {
      return '$fieldName doit contenir au moins $min caractères';
    }
    return null;
  }

  static String? maxLength(String? value, int max, [String fieldName = 'Ce champ']) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length > max) {
      return '$fieldName ne doit pas dépasser $max caractères';
    }
    return null;
  }
}
