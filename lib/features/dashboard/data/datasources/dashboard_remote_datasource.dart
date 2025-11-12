import 'package:dio/dio.dart';
import 'package:quho_app/core/constants/app_constants.dart';
import 'package:quho_app/core/errors/exceptions.dart';
import 'package:quho_app/core/network/api_client.dart';
import 'package:quho_app/features/dashboard/data/models/budget_summary_model.dart';
import 'package:quho_app/features/dashboard/data/models/transaction_model.dart';
import 'package:quho_app/features/dashboard/data/models/budget_advice_model.dart';
import 'package:quho_app/features/dashboard/data/models/category_budget_tracking_model.dart';

/// Modelo simple para categorías (para GASTOS)
class CategoryModel {
  final int id;
  final String slug;
  final String displayName;
  final String? icon;
  final String? color;
  final int? parentId;
  final String? parentName;
  final String? fullPath;

  CategoryModel({
    required this.id,
    required this.slug,
    required this.displayName,
    this.icon,
    this.color,
    this.parentId,
    this.parentName,
    this.fullPath,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // Helper para extraer string de un campo que puede ser string, map o null
    String? extractString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map) {
        // Si es un Map, intentar extraer un campo común
        return value['name'] as String? ?? value['display_name'] as String?;
      }
      return value.toString();
    }

    return CategoryModel(
      id: json['id'] as int,
      slug: json['slug'] as String,
      displayName: json['display_name'] as String,
      icon: extractString(json['icon']),
      color: extractString(json['color']),
      parentId: json['parent_id'] as int?,
      parentName: json['parent_name'] as String?,
      fullPath: json['full_path'] as String?,
    );
  }
}

/// Modelo de tracking para fuentes de ingreso
class IncomeTracking {
  final double expectedAmount;
  final double receivedAmount;
  final double remainingAmount;
  final int count;
  final bool isFullyReceived;

  IncomeTracking({
    required this.expectedAmount,
    required this.receivedAmount,
    required this.remainingAmount,
    required this.count,
    required this.isFullyReceived,
  });

  factory IncomeTracking.fromJson(Map<String, dynamic> json) {
    return IncomeTracking(
      expectedAmount: (json['expected_amount'] as num?)?.toDouble() ?? 0.0,
      receivedAmount: (json['received_amount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remaining_amount'] as num?)?.toDouble() ?? 0.0,
      count: json['count'] as int? ?? 0,
      isFullyReceived: json['is_fully_received'] as bool? ?? false,
    );
  }
}

/// Modelo simple para fuentes de ingreso (para INGRESOS)
class IncomeSourceModel {
  final int id;
  final String name;
  final double amount;
  final String frequency;
  final IncomeTracking? tracking;

  IncomeSourceModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.frequency,
    this.tracking,
  });

  factory IncomeSourceModel.fromJson(Map<String, dynamic> json) {
    final trackingJson = json['tracking'] as Map<String, dynamic>?;
    return IncomeSourceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      amount: double.parse(json['amount'].toString()),
      frequency: json['frequency'] as String,
      tracking: trackingJson != null ? IncomeTracking.fromJson(trackingJson) : null,
    );
  }
}

/// Tracking para gastos fijos
class FixedExpenseTracking {
  final double budgetedAmount;
  final double spentAmount;
  final double remainingAmount;
  final bool isClosed;
  final bool isIgnored;
  final bool isOverBudget;

  FixedExpenseTracking({
    required this.budgetedAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.isClosed,
    required this.isIgnored,
    required this.isOverBudget,
  });

  factory FixedExpenseTracking.fromJson(Map<String, dynamic> json) {
    return FixedExpenseTracking(
      budgetedAmount: double.parse(json['budgeted_amount'].toString()),
      spentAmount: double.parse(json['spent_amount'].toString()),
      remainingAmount: double.parse(json['remaining_amount'].toString()),
      isClosed: json['is_closed'] as bool,
      isIgnored: json['is_ignored'] as bool,
      isOverBudget: json['is_over_budget'] as bool,
    );
  }
}

/// Modelo simple para gastos fijos (para GASTOS)
class FixedExpenseModel {
  final int id;
  final String name;
  final double amount;
  final String frequency;
  final int categoryId;
  final String categoryName;
  final FixedExpenseTracking? tracking;

  FixedExpenseModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.frequency,
    required this.categoryId,
    required this.categoryName,
    this.tracking,
  });

  factory FixedExpenseModel.fromJson(Map<String, dynamic> json) {
    final trackingJson = json['tracking'] as Map<String, dynamic>?;
    
    return FixedExpenseModel(
      id: json['id'] as int,
      name: json['name'] as String,
      amount: double.parse(json['amount'].toString()),
      frequency: json['frequency'] as String,
      categoryId: json['category_id'] as int,
      categoryName: json['category_name'] as String,
      tracking: trackingJson != null ? FixedExpenseTracking.fromJson(trackingJson) : null,
    );
  }
}

/// Interfaz del datasource remoto del Dashboard
abstract class DashboardRemoteDataSource {
  Future<BudgetSummaryModel> getBudgetSummary({required String month});
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5});
  Future<List<TransactionModel>> getPendingCategorizationTransactions({String ordering = 'asc'});
  Future<List<BudgetAdviceModel>> getBudgetAdvice();
  Future<List<CategoryModel>> getCategories();
  Future<List<IncomeSourceModel>> getIncomeSources();
  Future<void> deactivateIncomeSource({required int incomeSourceId});
  Future<List<FixedExpenseModel>> getFixedExpenses();
  Future<void> toggleFixedExpenseStatus({required int fixedExpenseId, required String action});
  Future<void> resetCategorizations();
  Future<TransactionModel> categorizeTransaction({
    required String transactionId,
    required int categoryId,
    bool updateMerchant = false,
    int? fixedExpenseId,
  });
  Future<TransactionModel> categorizeIncomeTransaction({
    required String transactionId,
    required int incomeSourceId,
  });
  Future<TransactionModel> categorizeIncomeWithNewSource({
    required String transactionId,
    required String name,
    required double amount,
    required String frequency,
    bool isNetAmount = true,
    String taxContext = 'other',
  });
  Future<TransactionModel> uncategorizeTransaction({
    required String transactionId,
  });
  Future<TransactionModel> ignoreTransaction({
    required String transactionId,
    bool isIgnored = true,
  });
  Future<List<CategoryBudgetTrackingModel>> getCategoryBudgetTrackings({String? month});
  Future<CategoryBudgetTrackingModel> toggleCategoryTrackingClosed({required int trackingId});
  
  /// Ajustar balance manualmente
  Future<Map<String, dynamic>> adjustBalance({required double newBalance});
  
  /// Crear nueva transacción manual
  Future<TransactionModel> createTransaction({
    required String type, // 'income' o 'expense'
    required double amount,
    required String description,
    required DateTime date,
    String currency = 'GTQ',
    int? categoryId,
    int? incomeSourceId,
    int? fixedExpenseId,
  });
  
  /// Actualizar una transacción existente
  Future<TransactionModel> updateTransaction({
    required String transactionId,
    String? type,
    double? amount,
    String? description,
    DateTime? date,
    int? categoryId,
    int? incomeSourceId,
  });
}

/// Implementación del datasource remoto del Dashboard
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<BudgetSummaryModel> getBudgetSummary({required String month}) async {
    try {
      print('🔵 [DATASOURCE] Solicitando resumen de presupuesto para mes: $month');
      final response = await apiClient.get(
        '${AppConstants.budgetsEndpoint}/$month/summary/',
      );

      print('✅ [DATASOURCE] Respuesta del API recibida');
      print('📦 [DATASOURCE] Status code: ${response.statusCode}');
      print('📦 [DATASOURCE] Data type: ${response.data.runtimeType}');
      print('📦 [DATASOURCE] Data: ${response.data}');

      final budgetSummary = BudgetSummaryModel.fromJson(response.data as Map<String, dynamic>);
      print('✅ [DATASOURCE] Modelo parseado correctamente');
      
      return budgetSummary;
    } on DioException catch (e) {
      print('❌ [DATASOURCE] DioException: ${e.type}');
      print('❌ [DATASOURCE] Error: ${e.error}');
      print('❌ [DATASOURCE] Response: ${e.response?.data}');
      
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al obtener resumen del presupuesto',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('❌ [DATASOURCE] Exception inesperada: $e');
      print('❌ [DATASOURCE] Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al parsear presupuesto',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) async {
    try {
      print('🔵 [DATASOURCE] Solicitando transacciones recientes (limit: $limit)');
      final response = await apiClient.get(
        AppConstants.transactionsEndpoint,
        queryParameters: {
          'limit': limit,
          'ordering': '-date',
        },
      );

      print('✅ [DATASOURCE] Respuesta de transacciones recibida');
      print('📦 [DATASOURCE] Status code: ${response.statusCode}');
      print('📦 [DATASOURCE] Data type: ${response.data.runtimeType}');
      print('📦 [DATASOURCE] Data: ${response.data}');

      final results = response.data['results'] as List<dynamic>;
      print('📦 [DATASOURCE] Número de transacciones: ${results.length}');
      
      final transactions = results
          .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('✅ [DATASOURCE] Transacciones parseadas correctamente');
      return transactions;
    } on DioException catch (e) {
      print('❌ [DATASOURCE] DioException en transacciones: ${e.type}');
      print('❌ [DATASOURCE] Error: ${e.error}');
      print('❌ [DATASOURCE] Response: ${e.response?.data}');
      
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al obtener transacciones',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('❌ [DATASOURCE] Exception inesperada en transacciones: $e');
      print('❌ [DATASOURCE] Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al obtener transacciones',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TransactionModel>> getPendingCategorizationTransactions({String ordering = 'asc'}) async {
    try {
      print('🔵 [DATASOURCE] Solicitando transacciones pendientes de categorización (ordering: $ordering)');
      final response = await apiClient.get(
        '/transactions/pending-categorization/',
        queryParameters: {'ordering': ordering},
      );

      print('✅ [DATASOURCE] Respuesta de transacciones pendientes recibida');
      print('📦 [DATASOURCE] Status code: ${response.statusCode}');
      print('📦 [DATASOURCE] Data type: ${response.data.runtimeType}');

      // El endpoint devuelve una lista directa, no un objeto con 'results'
      final results = response.data as List<dynamic>;
      print('📦 [DATASOURCE] Número de transacciones pendientes: ${results.length}');
      
      final transactions = results
          .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('✅ [DATASOURCE] Transacciones pendientes parseadas correctamente');
      return transactions;
    } on DioException catch (e) {
      print('❌ [DATASOURCE] DioException en transacciones pendientes: ${e.type}');
      print('❌ [DATASOURCE] Error: ${e.error}');
      print('❌ [DATASOURCE] Response: ${e.response?.data}');
      
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al obtener transacciones pendientes',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('❌ [DATASOURCE] Exception inesperada en transacciones pendientes: $e');
      print('❌ [DATASOURCE] Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al obtener transacciones pendientes',
        originalException: e,
      );
    }
  }

  @override
  Future<List<BudgetAdviceModel>> getBudgetAdvice() async {
    try {
      print('[DASHBOARD_DS] 🔵 Obteniendo consejos de presupuesto...');
      final response = await apiClient.get('/onboarding/advice/');

      print('[DASHBOARD_DS] ✅ Consejos recibidos');
      print('[DASHBOARD_DS] 📦 Status code: ${response.statusCode}');
      print('[DASHBOARD_DS] 📦 Data type: ${response.data.runtimeType}');
      print('[DASHBOARD_DS] 📦 Cantidad de consejos: ${(response.data as List).length}');

      final adviceList = (response.data as List<dynamic>)
          .map((json) => BudgetAdviceModel.fromJson(json as Map<String, dynamic>))
          .toList();

      print('[DASHBOARD_DS] ✅ Consejos parseados correctamente');
      return adviceList;
    } on DioException catch (e) {
      print('[DASHBOARD_DS] ❌ DioException en consejos: ${e.type}');
      print('[DASHBOARD_DS] ❌ Error: ${e.error}');
      print('[DASHBOARD_DS] ❌ Response: ${e.response?.data}');

      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al obtener consejos',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('[DASHBOARD_DS] ❌ Exception inesperada en consejos: $e');
      print('[DASHBOARD_DS] ❌ Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al obtener consejos',
        originalException: e,
      );
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      print('🔵 [DATASOURCE] Solicitando categorías');
      final response = await apiClient.get('/categories/');

      print('✅ [DATASOURCE] Respuesta de categorías recibida');
      print('📦 [DATASOURCE] Status code: ${response.statusCode}');
      print('📦 [DATASOURCE] Data type: ${response.data.runtimeType}');

      final results = response.data['results'] as List<dynamic>;
      print('📦 [DATASOURCE] Número de categorías: ${results.length}');
      
      final categories = results
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('✅ [DATASOURCE] Categorías parseadas correctamente');
      return categories;
    } on DioException catch (e) {
      print('❌ [DATASOURCE] DioException en categorías: ${e.type}');
      print('❌ [DATASOURCE] Error: ${e.error}');
      print('❌ [DATASOURCE] Response: ${e.response?.data}');
      
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al obtener categorías',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('❌ [DATASOURCE] Exception inesperada en categorías: $e');
      print('❌ [DATASOURCE] Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al obtener categorías',
        originalException: e,
      );
    }
  }

  @override
  Future<TransactionModel> categorizeTransaction({
    required String transactionId,
    required int categoryId,
    bool updateMerchant = false,
    int? fixedExpenseId,
  }) async {
    try {
      print('🔵 [DATASOURCE] Categorizando transacción $transactionId con categoría $categoryId');
      final data = {
        'category_id': categoryId,
        'update_merchant': updateMerchant,
      };
      
      // Incluir fixed_expense_id si se proporciona
      if (fixedExpenseId != null) {
        data['fixed_expense_id'] = fixedExpenseId;
        print('🔵 [DATASOURCE] Vinculando a gasto fijo $fixedExpenseId');
      }
      
      final response = await apiClient.patch(
        '/transactions/$transactionId/categorize/',
        data: data,
      );

      print('✅ [DATASOURCE] Respuesta de categorización recibida');
      print('📦 [DATASOURCE] Status code: ${response.statusCode}');
      print('📦 [DATASOURCE] Data: ${response.data}');
      
      final transaction = TransactionModel.fromJson(response.data as Map<String, dynamic>);
      print('✅ [DATASOURCE] Transacción categorizada correctamente');
      return transaction;
    } on DioException catch (e) {
      print('❌ [DATASOURCE] DioException en categorización: ${e.type}');
      print('❌ [DATASOURCE] Error: ${e.error}');
      print('❌ [DATASOURCE] Response: ${e.response?.data}');
      
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al categorizar transacción',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('❌ [DATASOURCE] Exception inesperada en categorización: $e');
      print('❌ [DATASOURCE] Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al categorizar transacción',
        originalException: e,
      );
    }
  }

  @override
  Future<List<IncomeSourceModel>> getIncomeSources() async {
    try {
      print('🔵 [DATASOURCE] Obteniendo fuentes de ingreso activas');
      final response = await apiClient.get('/incomes/active/');

      print('✅ [DATASOURCE] Respuesta de fuentes de ingreso recibida');
      print('📦 [DATASOURCE] Status code: ${response.statusCode}');
      print('📦 [DATASOURCE] Data: ${response.data}');

      final List<dynamic> dataList = response.data as List<dynamic>;
      final incomeSources = dataList
          .map((json) => IncomeSourceModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('✅ [DATASOURCE] ${incomeSources.length} fuentes de ingreso parseadas');
      return incomeSources;
    } on DioException catch (e) {
      print('❌ [DATASOURCE] DioException: ${e.type}');
      print('❌ [DATASOURCE] Error: ${e.error}');
      print('❌ [DATASOURCE] Response: ${e.response?.data}');
      
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al obtener fuentes de ingreso',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('❌ [DATASOURCE] Exception inesperada: $e');
      print('❌ [DATASOURCE] Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al obtener fuentes de ingreso',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deactivateIncomeSource({required int incomeSourceId}) async {
    try {
      print('🔵 [DATASOURCE] Desactivando fuente de ingreso $incomeSourceId');
      final response = await apiClient.delete('/incomes/$incomeSourceId/');
      print('✅ [DATASOURCE] Fuente de ingreso desactivada. Status: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ [DATASOURCE] Error desactivando fuente de ingreso: ${e.response?.data}');
      // No hacemos throw duro para no bloquear el UX si falla este paso no-crítico
    } catch (e) {
      print('❌ [DATASOURCE] Excepción inesperada al desactivar fuente: $e');
    }
  }

  @override
  Future<List<FixedExpenseModel>> getFixedExpenses() async {
    try {
      print('🔵 [DATASOURCE] Obteniendo gastos fijos activos');
      final response = await apiClient.get('/fixed-expenses/active/');

      print('✅ [DATASOURCE] Respuesta de gastos fijos recibida');
      print('📦 [DATASOURCE] Status code: ${response.statusCode}');
      print('📦 [DATASOURCE] Data: ${response.data}');

      final List<dynamic> dataList = response.data as List<dynamic>;
      final fixedExpenses = dataList
          .map((json) => FixedExpenseModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('✅ [DATASOURCE] ${fixedExpenses.length} gastos fijos parseados');
      return fixedExpenses;
    } on DioException catch (e) {
      print('❌ [DATASOURCE] DioException: ${e.type}');
      print('❌ [DATASOURCE] Error: ${e.error}');
      print('❌ [DATASOURCE] Response: ${e.response?.data}');
      
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al obtener gastos fijos',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('❌ [DATASOURCE] Exception inesperada: $e');
      print('❌ [DATASOURCE] Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al obtener gastos fijos',
        originalException: e,
      );
    }
  }

  @override
  Future<void> toggleFixedExpenseStatus({
    required int fixedExpenseId,
    required String action,
  }) async {
    try {
      print('[DATASOURCE] Toggling status for fixed expense $fixedExpenseId: $action');
      final response = await apiClient.post(
        '/fixed-expenses/$fixedExpenseId/toggle-status/',
        data: {'action': action},
      );
      print('[DATASOURCE] Status toggled successfully: ${response.statusCode}');
    } on DioException catch (e) {
      print('[DATASOURCE] DioException toggling status: ${e.type}');
      print('[DATASOURCE] Error: ${e.error}');
      print('[DATASOURCE] Response: ${e.response?.data}');
      
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al cambiar estado del gasto',
        originalException: e,
      );
    } catch (e) {
      print('[DATASOURCE] Error inesperado toggling status: $e');
      throw UnexpectedException(
        message: 'Error al cambiar estado del gasto',
        originalException: e,
      );
    }
  }

  @override
  Future<void> resetCategorizations() async {
    try {
      print('🔵 [DATASOURCE] Reseteando categorizaciones de transacciones');
      final response = await apiClient.post('/transactions/reset-categorizations/');
      print('✅ [DATASOURCE] Reset completado. Status: ${response.statusCode}');
      print('📦 [DATASOURCE] Data: ${response.data}');
    } on DioException catch (e) {
      print('❌ [DATASOURCE] DioException en reset categorizaciones: ${e.response?.data}');
      throw UnexpectedException(
        message: 'Error al resetear categorizaciones',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('❌ [DATASOURCE] Exception inesperada en reset categorizaciones: $e');
      print('❌ [DATASOURCE] Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al resetear categorizaciones',
        originalException: e,
      );
    }
  }

  @override
  Future<TransactionModel> categorizeIncomeTransaction({
    required String transactionId,
    required int incomeSourceId,
  }) async {
    try {
      print('🔵 [DATASOURCE] Categorizando ingreso $transactionId con fuente $incomeSourceId');
      final response = await apiClient.patch(
        '/transactions/$transactionId/categorize/',
        data: {
          'income_source_id': incomeSourceId,
        },
      );

      print('✅ [DATASOURCE] Respuesta de categorización de ingreso recibida');
      print('📦 [DATASOURCE] Status code: ${response.statusCode}');
      print('📦 [DATASOURCE] Data: ${response.data}');
      
      final transaction = TransactionModel.fromJson(response.data as Map<String, dynamic>);
      print('✅ [DATASOURCE] Ingreso categorizado correctamente');
      return transaction;
    } on DioException catch (e) {
      print('❌ [DATASOURCE] DioException en categorización de ingreso: ${e.type}');
      print('❌ [DATASOURCE] Error: ${e.error}');
      print('❌ [DATASOURCE] Response: ${e.response?.data}');
      
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al categorizar ingreso',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('❌ [DATASOURCE] Exception inesperada en categorización de ingreso: $e');
      print('❌ [DATASOURCE] Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al categorizar ingreso',
        originalException: e,
      );
    }
  }

  @override
  Future<TransactionModel> categorizeIncomeWithNewSource({
    required String transactionId,
    required String name,
    required double amount,
    required String frequency,
    bool isNetAmount = true,
    String taxContext = 'other',
  }) async {
    try {
      print('🔵 [DATASOURCE] Creando nueva fuente de ingreso y categorizando transacción $transactionId');
      final response = await apiClient.patch(
        '/transactions/$transactionId/categorize-with-new-income/',
        data: {
          'name': name,
          'amount': amount,
          'frequency': frequency,
          'is_net_amount': isNetAmount,
          'tax_context': taxContext,
        },
      );

      print('✅ [DATASOURCE] Respuesta de categorización con nueva fuente recibida');
      print('📦 [DATASOURCE] Status code: ${response.statusCode}');
      print('📦 [DATASOURCE] Data: ${response.data}');
      
      final transaction = TransactionModel.fromJson(response.data as Map<String, dynamic>);
      print('✅ [DATASOURCE] Ingreso categorizado con nueva fuente correctamente');
      return transaction;
    } on DioException catch (e) {
      print('❌ [DATASOURCE] DioException: ${e.type}');
      print('❌ [DATASOURCE] Error: ${e.error}');
      print('❌ [DATASOURCE] Response: ${e.response?.data}');
      
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al crear fuente de ingreso y categorizar',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('❌ [DATASOURCE] Exception inesperada: $e');
      print('❌ [DATASOURCE] Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al crear fuente de ingreso',
        originalException: e,
      );
    }
  }

  @override
  Future<TransactionModel> uncategorizeTransaction({
    required String transactionId,
  }) async {
    try {
      print('[DATASOURCE] Descategorizando transacción $transactionId');
      final response = await apiClient.patch(
        '/transactions/$transactionId/uncategorize/',
      );

      print('[DATASOURCE] Respuesta de descategorización recibida');
      print('[DATASOURCE] Status code: ${response.statusCode}');
      
      final transaction = TransactionModel.fromJson(response.data as Map<String, dynamic>);
      print('[DATASOURCE] Transacción descategorizada correctamente');
      return transaction;
    } on DioException catch (e) {
      print('[DATASOURCE] DioException en descategorización: ${e.type}');
      print('[DATASOURCE] Error: ${e.error}');
      print('[DATASOURCE] Response: ${e.response?.data}');
      
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al descategorizar transacción',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('[DATASOURCE] Exception inesperada en descategorización: $e');
      print('[DATASOURCE] Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al descategorizar transacción',
        originalException: e,
      );
    }
  }

  @override
  Future<TransactionModel> ignoreTransaction({
    required String transactionId,
    bool isIgnored = true,
  }) async {
    try {
      print('🔵 [DATASOURCE] Marcando transacción $transactionId como ignorada: $isIgnored');
      final response = await apiClient.patch(
        '/transactions/$transactionId/ignore/',
        data: {
          'is_ignored': isIgnored,
        },
      );

      print('✅ [DATASOURCE] Respuesta de ignorar transacción recibida');
      print('📦 [DATASOURCE] Status code: ${response.statusCode}');
      print('📦 [DATASOURCE] Data: ${response.data}');
      
      final transaction = TransactionModel.fromJson(response.data as Map<String, dynamic>);
      print('✅ [DATASOURCE] Transacción marcada como ignorada correctamente');
      return transaction;
    } on DioException catch (e) {
      print('❌ [DATASOURCE] DioException: ${e.type}');
      print('❌ [DATASOURCE] Error: ${e.error}');
      print('❌ [DATASOURCE] Response: ${e.response?.data}');
      
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al ignorar transacción',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('❌ [DATASOURCE] Exception inesperada: $e');
      print('❌ [DATASOURCE] Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al ignorar transacción',
        originalException: e,
      );
    }
  }

  @override
  Future<List<CategoryBudgetTrackingModel>> getCategoryBudgetTrackings({String? month}) async {
    try {
      print('🔵 [DATASOURCE] Getting category budget trackings...');
      
      final Map<String, dynamic>? queryParams = month != null ? {'month': month} : null;
      
      final response = await apiClient.get(
        '/category-tracking/',
        queryParameters: queryParams,
      );
      
      print('✅ [DATASOURCE] Response type: ${response.data.runtimeType}');
      print('📦 [DATASOURCE] Response data: ${response.data}');
      
      // Check if response is paginated or direct list
      final List<dynamic> trackingsList;
      if (response.data is List) {
        trackingsList = response.data as List;
      } else if (response.data is Map && response.data['results'] != null) {
        // Paginated response
        trackingsList = response.data['results'] as List;
      } else {
        throw UnexpectedException(
          message: 'Formato de respuesta inesperado',
          originalException: Exception('Response is neither List nor paginated Map'),
        );
      }
      
      print('✅ [DATASOURCE] Got ${trackingsList.length} trackings');
      
      return trackingsList
          .map((json) => CategoryBudgetTrackingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('❌ [DATASOURCE] DioException: ${e.type}');
      print('❌ [DATASOURCE] Error: ${e.error}');
      print('❌ [DATASOURCE] Response: ${e.response?.data}');
      
      throw UnexpectedException(
        message: 'Error al obtener trackings de categorías',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('❌ [DATASOURCE] Exception inesperada: $e');
      print('❌ [DATASOURCE] Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al obtener trackings',
        originalException: e,
      );
    }
  }

  @override
  Future<CategoryBudgetTrackingModel> toggleCategoryTrackingClosed({required int trackingId}) async {
    try {
      print('🔵 [DATASOURCE] Toggling tracking $trackingId closed status...');
      
      final response = await apiClient.post(
        '/category-tracking/$trackingId/toggle-closed/',
      );
      
      print('✅ [DATASOURCE] Tracking toggled successfully');
      
      return CategoryBudgetTrackingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ [DATASOURCE] DioException: ${e.type}');
      print('❌ [DATASOURCE] Error: ${e.error}');
      print('❌ [DATASOURCE] Response: ${e.response?.data}');
      
      throw UnexpectedException(
        message: 'Error al cambiar estado de categoría',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('❌ [DATASOURCE] Exception inesperada: $e');
      print('❌ [DATASOURCE] Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al cambiar estado',
        originalException: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> adjustBalance({required double newBalance}) async {
    try {
      print('🔵 [DATASOURCE] Ajustando balance a: $newBalance');
      
      final response = await apiClient.post(
        '/transactions/adjust-balance/',
        data: {
          'expected_balance': newBalance,
        },
      );
      
      print('✅ [DATASOURCE] Balance ajustado exitosamente');
      print('📊 [DATASOURCE] Respuesta: ${response.data}');
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('❌ [DATASOURCE] DioException: ${e.type}');
      print('❌ [DATASOURCE] Error: ${e.error}');
      print('❌ [DATASOURCE] Response: ${e.response?.data}');
      
      throw UnexpectedException(
        message: 'Error al ajustar balance',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('❌ [DATASOURCE] Exception inesperada: $e');
      print('❌ [DATASOURCE] Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al ajustar balance',
        originalException: e,
      );
    }
  }

  @override
  Future<TransactionModel> createTransaction({
    required String type,
    required double amount,
    required String description,
    required DateTime date,
    String currency = 'GTQ',
    int? categoryId,
    int? incomeSourceId,
    int? fixedExpenseId,
  }) async {
    try {
      print('🔵 [DATASOURCE] Creando transacción: $type, $amount $currency, $description');
      
      final data = <String, dynamic>{
        'transaction_type': type == 'expense' ? 'expense' : 'income',
        'amount': amount.toString(),
        'description': description,
        'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
        'source': 'MANUAL',
        'status': 'PENDING_CATEGORY',
      };

      // Agregar moneda si no es GTQ (el backend hará la conversión)
      if (currency != 'GTQ') {
        data['original_currency'] = currency;
        data['original_amount'] = amount.toString();
      }

      if (categoryId != null) {
        data['category_id'] = categoryId;
        data['status'] = 'COMPLETED';
      }

      if (incomeSourceId != null) {
        data['income_source_id'] = incomeSourceId;
        data['status'] = 'COMPLETED';
      }

      if (fixedExpenseId != null) {
        data['fixed_expense_id'] = fixedExpenseId;
        // Si hay fixed expense, la transacción está completamente categorizada
        if (categoryId != null) {
          data['status'] = 'COMPLETED';
        }
      }

      final response = await apiClient.post(
        '/transactions/',
        data: data,
      );
      
      print('✅ [DATASOURCE] Transacción creada exitosamente');
      print('📊 [DATASOURCE] Transacción ID: ${response.data['id']}');
      
      return TransactionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ [DATASOURCE] DioException: ${e.type}');
      print('❌ [DATASOURCE] Error: ${e.error}');
      print('❌ [DATASOURCE] Response: ${e.response?.data}');
      
      throw UnexpectedException(
        message: 'Error al crear transacción',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('❌ [DATASOURCE] Exception inesperada: $e');
      print('❌ [DATASOURCE] Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al crear transacción',
        originalException: e,
      );
    }
  }

  @override
  Future<TransactionModel> updateTransaction({
    required String transactionId,
    String? type,
    double? amount,
    String? description,
    DateTime? date,
    int? categoryId,
    int? incomeSourceId,
  }) async {
    try {
      print('🔵 [DATASOURCE] Actualizando transacción $transactionId');
      
      final data = <String, dynamic>{};

      if (type != null) {
        data['transaction_type'] = type == 'expense' ? 'expense' : 'income';
      }

      if (amount != null) {
        data['amount'] = amount.toString();
      }

      if (description != null) {
        data['description'] = description;
      }

      if (date != null) {
        data['date'] = date.toIso8601String().split('T')[0]; // YYYY-MM-DD
      }

      if (categoryId != null) {
        data['category_id'] = categoryId;
      }

      if (incomeSourceId != null) {
        data['income_source_id'] = incomeSourceId;
      }

      final response = await apiClient.patch(
        '/transactions/$transactionId/',
        data: data,
      );
      
      print('✅ [DATASOURCE] Transacción actualizada exitosamente');
      print('📊 [DATASOURCE] Transacción ID: ${response.data['id']}');
      
      return TransactionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ [DATASOURCE] DioException: ${e.type}');
      print('❌ [DATASOURCE] Error: ${e.error}');
      print('❌ [DATASOURCE] Response: ${e.response?.data}');
      
      throw UnexpectedException(
        message: 'Error al actualizar transacción',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('❌ [DATASOURCE] Exception inesperada: $e');
      print('❌ [DATASOURCE] Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al actualizar transacción',
        originalException: e,
      );
    }
  }
}

