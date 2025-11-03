import 'package:intl/intl.dart';

/// Utilidades para formatear valores en QUHO
class Formatters {
  // Formatters de moneda
  static final NumberFormat _currencyNumberFormat = NumberFormat('#,##0.00', 'es_GT');

  static final NumberFormat _currencyFormatCompact = NumberFormat.compactCurrency(
    symbol: 'Q',
    decimalDigits: 0,
    locale: 'es_GT',
  );

  /// Formatea un número como moneda: Q1,234.56
  static String currency(double amount) {
    return 'Q${_currencyNumberFormat.format(amount)}';
  }

  /// Formatea un número como moneda compacta: \$1.2K
  static String currencyCompact(double amount) {
    return _currencyFormatCompact.format(amount);
  }

  /// Formatea un número como moneda sin símbolo: 1,234.56
  static String currencyWithoutSymbol(double amount) {
    return NumberFormat('#,##0.00', 'es_MX').format(amount);
  }

  // Formatters de fecha
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'es_MX');
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM', 'es_MX');

  /// Formatea una fecha: 15/03/2024
  static String date(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Formatea una fecha con hora: 15/03/2024 14:30
  static String dateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Formatea solo la hora: 14:30
  static String time(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Formatea mes y año: Marzo 2024
  static String monthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Formatea día y mes: 15 Mar
  static String dayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  /// Formatea una fecha de forma relativa: "Hace 2 horas", "Ayer", "Hace 3 días"
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Hace un momento';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'Hace $minutes minuto${minutes == 1 ? '' : 's'}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Hace $hours hora${hours == 1 ? '' : 's'}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace $weeks semana${weeks == 1 ? '' : 's'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months mes${months == 1 ? '' : 'es'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Hace $years año${years == 1 ? '' : 's'}';
    }
  }

  // Formatters de números
  static final NumberFormat _numberFormat = NumberFormat('#,##0', 'es_MX');
  static final NumberFormat _decimalFormat = NumberFormat('#,##0.00', 'es_MX');
  static final NumberFormat _percentFormat = NumberFormat('#,##0.0%', 'es_MX');

  /// Formatea un número entero: 1,234
  static String number(int number) {
    return _numberFormat.format(number);
  }

  /// Formatea un número decimal: 1,234.56
  static String decimal(double number) {
    return _decimalFormat.format(number);
  }

  /// Formatea un porcentaje: 45.5%
  static String percentage(double value) {
    return _percentFormat.format(value);
  }

  /// Formatea un número abreviado: 1.2K, 3.5M
  static String compactNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      final k = number / 1000;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}K';
    } else if (number < 1000000000) {
      final m = number / 1000000;
      return '${m.toStringAsFixed(m >= 10 ? 0 : 1)}M';
    } else {
      final b = number / 1000000000;
      return '${b.toStringAsFixed(b >= 10 ? 0 : 1)}B';
    }
  }

  // Formatters de texto
  /// Capitaliza la primera letra de una cadena
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitaliza la primera letra de cada palabra
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Trunca un texto y agrega puntos suspensivos
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Formatters de teléfono
  /// Formatea un número de teléfono: (555) 123-4567
  static String phone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    return phone;
  }

  // Private constructor
  Formatters._();
}

