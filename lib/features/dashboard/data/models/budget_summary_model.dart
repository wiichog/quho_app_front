import 'package:json_annotation/json_annotation.dart';
import 'package:quho_app/features/dashboard/domain/entities/budget_summary.dart';

part 'budget_summary_model.g.dart';

@JsonSerializable()
class BudgetSummaryModel extends BudgetSummary {
  const BudgetSummaryModel({
    required super.month,
    required super.theoreticalIncome,
    required super.theoreticalExpenses,
    required super.actualIncome,
    required super.actualExpenses,
    required super.balance,
    required super.savingsRate,
    required super.categoriesBreakdown,
  });

  factory BudgetSummaryModel.fromJson(Map<String, dynamic> json) {
    print('🔵 [MODEL] Parseando BudgetSummaryModel desde JSON');
    print('📦 [MODEL] JSON completo: $json');
    print('📦 [MODEL] JSON keys: ${json.keys.toList()}');
    
    try {
      print('📦 [MODEL] month: ${json['month']} (tipo: ${json['month'].runtimeType})');
      final month = json['month'] as String? ?? 'N/A';
      
      // Extraer datos anidados de la estructura del API
      final theoretical = json['theoretical'] as Map<String, dynamic>?;
      final execution = json['execution'] as Map<String, dynamic>?;
      
      print('📦 [MODEL] theoretical: $theoretical');
      print('📦 [MODEL] execution: $execution');
      
      // Mapear theoretical.total_income.amount -> theoreticalIncome
      final theoreticalIncomeData = theoretical?['total_income'] as Map<String, dynamic>?;
      final theoreticalIncome = (theoreticalIncomeData?['amount'] as num?)?.toDouble() ?? 0.0;
      print('📦 [MODEL] theoretical_income: $theoreticalIncome');
      
      // Mapear theoretical.total_expense.amount -> theoreticalExpenses
      final theoreticalExpenseData = theoretical?['total_expense'] as Map<String, dynamic>?;
      final theoreticalExpenses = (theoreticalExpenseData?['amount'] as num?)?.toDouble() ?? 0.0;
      print('📦 [MODEL] theoretical_expenses: $theoreticalExpenses');
      
      // Mapear execution.total_income.amount -> actualIncome
      final executionIncomeData = execution?['total_income'] as Map<String, dynamic>?;
      final actualIncome = (executionIncomeData?['amount'] as num?)?.toDouble() ?? 0.0;
      print('📦 [MODEL] actual_income: $actualIncome');
      
      // Mapear execution.total_expense.amount -> actualExpenses
      final executionExpenseData = execution?['total_expense'] as Map<String, dynamic>?;
      final actualExpenses = (executionExpenseData?['amount'] as num?)?.toDouble() ?? 0.0;
      print('📦 [MODEL] actual_expenses: $actualExpenses');
      
      // Mapear execution.net.amount -> balance
      final netData = execution?['net'] as Map<String, dynamic>?;
      final balance = (netData?['amount'] as num?)?.toDouble() ?? 0.0;
      print('📦 [MODEL] balance: $balance');
      
      // Calcular savings rate
      final savingsRate = theoreticalIncome > 0 
          ? ((actualIncome - actualExpenses) / theoreticalIncome) 
          : 0.0;
      print('📦 [MODEL] savings_rate (calculado): $savingsRate');
      
      // Mapear category_breakdown
      print('📦 [MODEL] category_breakdown: ${json['category_breakdown']}');
      final categoriesBreakdown = (json['category_breakdown'] as List<dynamic>?)
              ?.map((e) {
                print('📦 [MODEL] Parseando categoría: $e');
                return CategoryBreakdownModel.fromJson(e as Map<String, dynamic>);
              })
              .toList() ??
          [];
      
      print('✅ [MODEL] BudgetSummaryModel parseado correctamente');
      
      return BudgetSummaryModel(
        month: month,
        theoreticalIncome: theoreticalIncome,
        theoreticalExpenses: theoreticalExpenses,
        actualIncome: actualIncome,
        actualExpenses: actualExpenses,
        balance: balance,
        savingsRate: savingsRate,
        categoriesBreakdown: categoriesBreakdown,
      );
    } catch (e, stackTrace) {
      print('❌ [MODEL] Error parseando BudgetSummaryModel: $e');
      print('❌ [MODEL] JSON que causó el error: $json');
      print('❌ [MODEL] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'theoretical_income': theoreticalIncome,
      'theoretical_expenses': theoreticalExpenses,
      'actual_income': actualIncome,
      'actual_expenses': actualExpenses,
      'balance': balance,
      'savings_rate': savingsRate,
      'categories_breakdown': categoriesBreakdown
          .map((e) => (e as CategoryBreakdownModel).toJson())
          .toList(),
    };
  }

  BudgetSummary toEntity() {
    return BudgetSummary(
      month: month,
      theoreticalIncome: theoreticalIncome,
      theoreticalExpenses: theoreticalExpenses,
      actualIncome: actualIncome,
      actualExpenses: actualExpenses,
      balance: balance,
      savingsRate: savingsRate,
      categoriesBreakdown: categoriesBreakdown,
    );
  }
}

@JsonSerializable()
class CategoryBreakdownModel extends CategoryBreakdown {
  const CategoryBreakdownModel({
    required super.category,
    required super.budgeted,
    required super.spent,
    required super.percentage,
  });

  factory CategoryBreakdownModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔵 [MODEL] Parseando CategoryBreakdown - JSON completo: $json');
      
      // Parse category - puede ser String o Map
      String categoryName;
      if (json['category'] is String) {
        categoryName = json['category'] as String;
      } else if (json['category'] is Map) {
        final categoryMap = json['category'] as Map<String, dynamic>;
        categoryName = categoryMap['display_name'] as String? ?? 
                       categoryMap['name'] as String? ?? 
                       'Sin categoría';
      } else {
        categoryName = 'Sin categoría';
      }
      
      // El API puede devolver diferentes estructuras
      // Si tiene 'budgeted_amount', es la estructura anidada del API
      final budgetedData = json['budgeted_amount'] as Map<String, dynamic>?;
      final spentData = json['spent_amount'] as Map<String, dynamic>?;
      
      final budgeted = budgetedData != null 
          ? (budgetedData['amount'] as num?)?.toDouble() ?? 0.0
          : (json['budgeted'] as num?)?.toDouble() ?? 0.0;
          
      final spent = spentData != null 
          ? (spentData['amount'] as num?)?.toDouble() ?? 0.0
          : (json['spent'] as num?)?.toDouble() ?? 0.0;
      
      return CategoryBreakdownModel(
        category: categoryName,
        budgeted: budgeted,
        spent: spent,
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e, stackTrace) {
      print('❌ [MODEL] Error parseando CategoryBreakdown: $e');
      print('❌ [MODEL] JSON: $json');
      print('❌ [MODEL] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'budgeted': budgeted,
      'spent': spent,
      'percentage': percentage,
    };
  }
}

