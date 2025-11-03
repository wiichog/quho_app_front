import 'package:dio/dio.dart';
import 'package:quho_app/core/constants/app_constants.dart';
import 'package:quho_app/core/errors/exceptions.dart';
import 'package:quho_app/core/network/api_client.dart';
import 'package:quho_app/features/dashboard/data/models/budget_summary_model.dart';
import 'package:quho_app/features/dashboard/data/models/transaction_model.dart';
import 'package:quho_app/features/dashboard/data/models/budget_advice_model.dart';

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

/// Modelo simple para fuentes de ingreso (para INGRESOS)
class IncomeSourceModel {
  final int id;
  final String name;
  final double amount;
  final String frequency;

  IncomeSourceModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.frequency,
  });

  factory IncomeSourceModel.fromJson(Map<String, dynamic> json) {
    return IncomeSourceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      amount: double.parse(json['amount'].toString()),
      frequency: json['frequency'] as String,
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

  FixedExpenseModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.frequency,
    required this.categoryId,
    required this.categoryName,
  });

  factory FixedExpenseModel.fromJson(Map<String, dynamic> json) {
    return FixedExpenseModel(
      id: json['id'] as int,
      name: json['name'] as String,
      amount: double.parse(json['amount'].toString()),
      frequency: json['frequency'] as String,
      categoryId: json['category_id'] as int,
      categoryName: json['category_name'] as String,
    );
  }
}

/// Interfaz del datasource remoto del Dashboard
abstract class DashboardRemoteDataSource {
  Future<BudgetSummaryModel> getBudgetSummary({required String month});
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5});
  Future<List<TransactionModel>> getPendingCategorizationTransactions();
  Future<List<BudgetAdviceModel>> getBudgetAdvice();
  Future<List<CategoryModel>> getCategories();
  Future<List<IncomeSourceModel>> getIncomeSources();
  Future<List<FixedExpenseModel>> getFixedExpenses();
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
  Future<List<TransactionModel>> getPendingCategorizationTransactions() async {
    try {
      print('🔵 [DATASOURCE] Solicitando transacciones pendientes de categorización');
      final response = await apiClient.get(
        '/transactions/pending-categorization/',
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
}

