/// Validadores para formularios en QUHO
class Validators {
  // Email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    
    return null;
  }

  // Password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    
    // Verifica que tenga al menos una mayúscula
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe contener al menos una mayúscula';
    }
    
    // Verifica que tenga al menos una minúscula
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Debe contener al menos una minúscula';
    }
    
    // Verifica que tenga al menos un número
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }
    
    return null;
  }

  // Password confirmation
  static String? Function(String?) passwordConfirmation(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Confirma tu contraseña';
      }
      
      if (value != password) {
        return 'Las contraseñas no coinciden';
      }
      
      return null;
    };
  }

  // Required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null 
          ? '$fieldName es requerido' 
          : 'Este campo es requerido';
    }
    return null;
  }

  // Min length
  static String? Function(String?) minLength(int length, {String? fieldName}) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return fieldName != null 
            ? '$fieldName es requerido' 
            : 'Este campo es requerido';
      }
      
      if (value.length < length) {
        return fieldName != null
            ? '$fieldName debe tener al menos $length caracteres'
            : 'Debe tener al menos $length caracteres';
      }
      
      return null;
    };
  }

  // Max length
  static String? Function(String?) maxLength(int length, {String? fieldName}) {
    return (String? value) {
      if (value != null && value.length > length) {
        return fieldName != null
            ? '$fieldName no puede tener más de $length caracteres'
            : 'No puede tener más de $length caracteres';
      }
      
      return null;
    };
  }

  // Phone number (Mexican format)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }
    
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    
    if (cleaned.length != 10) {
      return 'El teléfono debe tener 10 dígitos';
    }
    
    return null;
  }

  // Amount (positive number)
  static String? amount(String? value) {
    if (value == null || value.isEmpty) {
      return 'El monto es requerido';
    }
    
    final amount = double.tryParse(value.replaceAll(',', ''));
    
    if (amount == null) {
      return 'Monto inválido';
    }
    
    if (amount <= 0) {
      return 'El monto debe ser mayor a 0';
    }
    
    return null;
  }

  // Positive amount (can be zero)
  static String? positiveAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'El monto es requerido';
    }
    
    final amount = double.tryParse(value.replaceAll(',', ''));
    
    if (amount == null) {
      return 'Monto inválido';
    }
    
    if (amount < 0) {
      return 'El monto no puede ser negativo';
    }
    
    return null;
  }

  // Date
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return 'La fecha es requerida';
    }
    
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  // Date in past
  static String? pastDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'La fecha es requerida';
    }
    
    try {
      final date = DateTime.parse(value);
      if (date.isAfter(DateTime.now())) {
        return 'La fecha debe estar en el pasado';
      }
      return null;
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  // Date in future
  static String? futureDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'La fecha es requerida';
    }
    
    try {
      final date = DateTime.parse(value);
      if (date.isBefore(DateTime.now())) {
        return 'La fecha debe estar en el futuro';
      }
      return null;
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  // Nombre completo
  static String? fullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    
    final parts = value.trim().split(' ');
    
    if (parts.length < 2) {
      return 'Ingresa tu nombre completo';
    }
    
    if (parts.any((part) => part.length < 2)) {
      return 'Nombre inválido';
    }
    
    return null;
  }

  // Alphanumeric
  static String? alphanumeric(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'Solo se permiten letras y números';
    }
    
    return null;
  }

  // Only letters
  static String? onlyLetters(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
    
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
      return 'Solo se permiten letras';
    }
    
    return null;
  }

  // Only numbers
  static String? onlyNumbers(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Solo se permiten números';
    }
    
    return null;
  }

  // Combina múltiples validadores
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }

  // Private constructor
  Validators._();
}

