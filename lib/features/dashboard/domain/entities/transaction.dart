import 'package:equatable/equatable.dart';

/// Categoría sugerida para una transacción
class SuggestedCategory extends Equatable {
  final int id;
  final String slug;
  final String displayName;
  final String? icon;
  final String? color;
  final String source; // 'merchant' | 'ai'
  final double confidence; // 0.0 - 1.0

  const SuggestedCategory({
    required this.id,
    required this.slug,
    required this.displayName,
    this.icon,
    this.color,
    required this.source,
    required this.confidence,
  });

  @override
  List<Object?> get props => [id, slug, displayName, icon, color, source, confidence];
}

/// Transacción financiera
class Transaction extends Equatable {
  final String id;
  final String type; // 'income' | 'expense' | 'transfer'
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final bool isRecurring;
  
  // Moneda original (para transacciones en moneda extranjera)
  final String? originalCurrency; // e.g., 'USD'
  final double? originalAmount;   // e.g., 20.00
  final double? exchangeRate;     // e.g., 7.67
  
  // Establecimiento/Comercio
  final int? merchantId;
  final String? merchantDisplayName;
  final String? merchantName;
  
  // Categoría sugerida (prioridad: merchant > IA) - para GASTOS
  final SuggestedCategory? suggestedCategory;
  
  // Fuente de ingreso - para INGRESOS
  final int? incomeSourceId;
  final String? incomeSourceName;
  
  // Transfer-specific fields
  final String? relatedTransactionId;
  final String? fromAccount;
  final String? toAccount;
  
  // Ignorar transacción
  final bool isIgnored;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.isRecurring,
    this.merchantId,
    this.merchantDisplayName,
    this.merchantName,
    this.suggestedCategory,
    this.incomeSourceId,
    this.incomeSourceName,
    this.originalCurrency,
    this.originalAmount,
    this.exchangeRate,
    this.relatedTransactionId,
    this.fromAccount,
    this.toAccount,
    this.isIgnored = false,
  });

  /// Es un ingreso
  bool get isIncome => type == 'income';

  /// Es un gasto
  bool get isExpense => type == 'expense';
  
  /// Es una transferencia/conversión
  bool get isTransfer => type == 'transfer';
  
  /// Tiene un merchant asociado
  bool get hasMerchant => merchantId != null;
  
  /// Tiene una categoría sugerida
  bool get hasSuggestedCategory => suggestedCategory != null;

  @override
  List<Object?> get props => [
        id,
        type,
        amount,
        category,
        description,
        date,
        isRecurring,
        merchantId,
        merchantDisplayName,
        merchantName,
        suggestedCategory,
        incomeSourceId,
        incomeSourceName,
        originalCurrency,
        originalAmount,
        exchangeRate,
        relatedTransactionId,
        fromAccount,
        toAccount,
        isIgnored,
      ];
}

