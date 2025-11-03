import 'package:quho_app/core/network/api_client.dart';
import 'package:quho_app/features/finances/data/models/finances_overview_model.dart';

/// Remote datasource for finances
abstract class FinancesRemoteDataSource {
  Future<FinancesOverviewModel> getFinancesOverview({required String month});
}

/// Implementation of finances remote datasource
class FinancesRemoteDataSourceImpl implements FinancesRemoteDataSource {
  final ApiClient apiClient;

  FinancesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<FinancesOverviewModel> getFinancesOverview({required String month}) async {
    try {
      print('🔵 [FINANCES_DATASOURCE] Solicitando overview para mes: $month');
      
      final response = await apiClient.get('/finances/overview/$month/');
      
      print('✅ [FINANCES_DATASOURCE] Response received');
      
      return FinancesOverviewModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e, stackTrace) {
      print('❌ [FINANCES_DATASOURCE] Error: $e');
      print('❌ [FINANCES_DATASOURCE] Stack trace: $stackTrace');
      rethrow;
    }
  }
}

