import 'package:quho_app/core/network/api_client.dart';
import 'package:quho_app/core/constants/app_constants.dart';
import 'package:quho_app/core/errors/exceptions.dart';
import 'package:quho_app/features/dashboard/data/models/transaction_model.dart';
import 'package:quho_app/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:dio/dio.dart';

/// Data source remoto para transacciones
abstract class TransactionsRemoteDataSource {
  Future<PaginatedTransactions> getTransactions(GetTransactionsParams params);
}

class TransactionsRemoteDataSourceImpl implements TransactionsRemoteDataSource {
  final ApiClient apiClient;

  TransactionsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PaginatedTransactions> getTransactions(GetTransactionsParams params) async {
    try {
      print('🔵 [DATASOURCE] Solicitando transacciones con filtros');
      print('📦 [DATASOURCE] Params: page=${params.page}, limit=${params.limit}, type=${params.type}, category=${params.category}, search=${params.search}');

      // Construir query parameters
      final queryParams = <String, dynamic>{
        'page': params.page,
        'limit': params.limit,
        'ordering': '-date',
      };

      if (params.type != null) {
        queryParams['transaction_type'] = params.type;
        print('✅ [DATASOURCE] Filtro tipo agregado: ${params.type}');
      }

      if (params.category != null) {
        queryParams['category'] = params.category;
        print('✅ [DATASOURCE] Filtro categoría agregado: ${params.category}');
      }

      if (params.startDate != null) {
        queryParams['start_date'] = params.startDate!.toIso8601String().split('T')[0];
        print('✅ [DATASOURCE] Filtro fecha inicio agregado: ${queryParams['start_date']}');
      }

      if (params.endDate != null) {
        queryParams['end_date'] = params.endDate!.toIso8601String().split('T')[0];
        print('✅ [DATASOURCE] Filtro fecha fin agregado: ${queryParams['end_date']}');
      }

      if (params.search != null && params.search!.isNotEmpty) {
        queryParams['search'] = params.search;
        print('✅ [DATASOURCE] Filtro búsqueda agregado: ${params.search}');
      }

      print('📦 [DATASOURCE] Query params finales: $queryParams');

      final response = await apiClient.get(
        AppConstants.transactionsEndpoint,
        queryParameters: queryParams,
      );

      print('✅ [DATASOURCE] Respuesta de transacciones recibida');
      print('📦 [DATASOURCE] Status code: ${response.statusCode}');

      final data = response.data;
      final results = data['results'] as List<dynamic>;
      final count = data['count'] as int;
      final next = data['next'];
      final previous = data['previous'];

      print('📦 [DATASOURCE] Número de transacciones: ${results.length}');
      print('📦 [DATASOURCE] Total count: $count');

      final transactions = results
          .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final hasNext = next != null && next.toString().trim().isNotEmpty;
      final hasPrevious = previous != null && previous.toString().trim().isNotEmpty;

      final paginatedResult = PaginatedTransactions(
        transactions: transactions,
        count: count,
        hasNext: hasNext,
        hasPrevious: hasPrevious,
      );

      print('✅ [DATASOURCE] Transacciones parseadas correctamente');
      return paginatedResult;
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
}

