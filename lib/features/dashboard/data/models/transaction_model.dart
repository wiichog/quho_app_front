import 'package:json_annotation/json_annotation.dart';
import 'package:quho_app/features/dashboard/domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.category,
    required super.description,
    required super.date,
    required super.isRecurring,
    super.merchantId,
    super.merchantDisplayName,
    super.merchantName,
    super.suggestedCategory,
    super.incomeSourceId,
    super.incomeSourceName,
    super.originalCurrency,
    super.originalAmount,
    super.exchangeRate,
    super.relatedTransactionId,
    super.fromAccount,
    super.toAccount,
    super.isIgnored = false,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    print('🔵 [MODEL] Parseando TransactionModel');
    print('📦 [MODEL] JSON: $json');
    
    try {
      // Convertir id de int a String
      final id = json['id'].toString();
      print('📦 [MODEL] id: $id');
      
      // El API usa 'transaction_type' en lugar de 'type'
      final type = json['transaction_type'] as String? ?? 'expense';
      print('📦 [MODEL] type: $type');
      
      // Amount puede venir como String o num
      final amount = (json['amount'] is String) 
          ? double.parse(json['amount'] as String) 
          : (json['amount'] as num).toDouble();
      print('📦 [MODEL] amount: $amount');
      
      // Category puede ser null o int (id de categoría), usar category_name si está disponible
      final categoryValue = json['category'];
      final categoryName = json['category_name'] as String?;
      final category = categoryName ?? (categoryValue?.toString() ?? 'Sin categoría');
      print('📦 [MODEL] category: $category');
      
      final description = json['description'] as String? ?? '';
      print('📦 [MODEL] description: $description');
      
      final date = DateTime.parse(json['date'] as String);
      print('📦 [MODEL] date: $date');
      
      // is_recurring no viene en el API, usar false por defecto
      final isRecurring = json['is_recurring'] as bool? ?? false;
      print('📦 [MODEL] isRecurring: $isRecurring');
      
      // Parsear merchant
      final merchantId = json['merchant_id'] as int?;
      final merchantDisplayName = json['merchant_display_name'] as String?;
      final merchantName = json['merchant_name'] as String?;
      print('📦 [MODEL] merchant: $merchantDisplayName (ID: $merchantId)');
      
      // Parsear suggested_category (para GASTOS)
      SuggestedCategory? suggestedCategory;
      final suggestedCategoryJson = json['suggested_category'] as Map<String, dynamic>?;
      if (suggestedCategoryJson != null) {
        suggestedCategory = SuggestedCategory(
          id: suggestedCategoryJson['id'] as int,
          slug: suggestedCategoryJson['slug'] as String,
          displayName: suggestedCategoryJson['display_name'] as String,
          icon: suggestedCategoryJson['icon'] as String?,
          color: suggestedCategoryJson['color'] as String?,
          source: suggestedCategoryJson['source'] as String,
          confidence: (suggestedCategoryJson['confidence'] as num).toDouble(),
        );
        print('📦 [MODEL] suggested_category: ${suggestedCategory.displayName} (${suggestedCategory.source})');
      }
      
      // Parsear income_source (para INGRESOS)
      final incomeSourceId = json['income_source_id'] as int?;
      final incomeSourceName = json['income_source_name'] as String?;
      if (incomeSourceId != null) {
        print('📦 [MODEL] income_source: $incomeSourceName (ID: $incomeSourceId)');
      }

      // Moneda original (para transacciones internacionales)
      final originalCurrency = json['original_currency'] as String?;
      final originalAmountRaw = json['original_amount'];
      final exchangeRateRaw = json['exchange_rate'];
      final originalAmount = originalAmountRaw == null
          ? null
          : (originalAmountRaw is String
              ? double.tryParse(originalAmountRaw)
              : (originalAmountRaw as num).toDouble());
      final exchangeRate = exchangeRateRaw == null
          ? null
          : (exchangeRateRaw is String
              ? double.tryParse(exchangeRateRaw)
              : (exchangeRateRaw as num).toDouble());
      if (originalCurrency != null && originalAmount != null) {
        print('📦 [MODEL] original: $originalCurrency $originalAmount (rate: ${exchangeRate ?? '-'} )');
      }
      
      // Parsear transfer fields
      final relatedTransactionId = json['related_transaction_id']?.toString();
      final fromAccount = json['from_account'] as String?;
      final toAccount = json['to_account'] as String?;
      if (type == 'transfer') {
        print('📦 [MODEL] transfer: $fromAccount → $toAccount');
      }
      
      // Parsear is_ignored
      final isIgnored = json['is_ignored'] as bool? ?? false;
      
      print('✅ [MODEL] TransactionModel parseado correctamente');
      
      return TransactionModel(
        id: id,
        type: type,
        amount: amount,
        category: category,
        description: description,
        date: date,
        isRecurring: isRecurring,
        merchantId: merchantId,
        merchantDisplayName: merchantDisplayName,
        merchantName: merchantName,
        suggestedCategory: suggestedCategory,
        incomeSourceId: incomeSourceId,
        incomeSourceName: incomeSourceName,
        originalCurrency: originalCurrency,
        originalAmount: originalAmount,
        exchangeRate: exchangeRate,
        relatedTransactionId: relatedTransactionId,
        fromAccount: fromAccount,
        toAccount: toAccount,
        isIgnored: isIgnored,
      );
    } catch (e, stackTrace) {
      print('❌ [MODEL] Error parseando TransactionModel: $e');
      print('❌ [MODEL] JSON: $json');
      print('❌ [MODEL] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'is_recurring': isRecurring,
    };
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      type: type,
      amount: amount,
      category: category,
      description: description,
      date: date,
      isRecurring: isRecurring,
      merchantId: merchantId,
      merchantDisplayName: merchantDisplayName,
      merchantName: merchantName,
      suggestedCategory: suggestedCategory,
      incomeSourceId: incomeSourceId,
      incomeSourceName: incomeSourceName,
      originalCurrency: originalCurrency,
      originalAmount: originalAmount,
      exchangeRate: exchangeRate,
      relatedTransactionId: relatedTransactionId,
      fromAccount: fromAccount,
      toAccount: toAccount,
      isIgnored: isIgnored,
    );
  }
}

