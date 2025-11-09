import 'package:quho_app/features/dashboard/domain/entities/category_budget_tracking.dart';

class CategoryBudgetTrackingModel extends CategoryBudgetTracking {
  const CategoryBudgetTrackingModel({
    required super.id,
    super.categoryId,
    super.categoryName,
    super.categoryIcon,
    super.categoryColor,
    super.fixedExpenseId,
    super.fixedExpenseName,
    required super.budgetedAmount,
    required super.spentAmount,
    required super.remainingAmount,
    required super.isClosed,
    required super.isOverBudget,
  });

  factory CategoryBudgetTrackingModel.fromJson(Map<String, dynamic> json) {
    final categoryDisplay = json['category_display'] as Map<String, dynamic>?;
    final fixedExpenseDisplay = json['fixed_expense_display'] as Map<String, dynamic>?;
    
    // Helper para parsear amount que puede venir como string o num
    double parseAmount(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.parse(value);
      return 0.0;
    }
    
    return CategoryBudgetTrackingModel(
      id: json['id'] as int,
      categoryId: categoryDisplay?['id'] as int?,
      categoryName: categoryDisplay?['display_name'] as String?,
      categoryIcon: categoryDisplay?['icon'] as String?,
      categoryColor: categoryDisplay?['color'] as String?,
      fixedExpenseId: fixedExpenseDisplay?['id'] as int?,
      fixedExpenseName: fixedExpenseDisplay?['name'] as String?,
      budgetedAmount: parseAmount(json['budgeted_amount_display']['amount']),
      spentAmount: parseAmount(json['spent_amount_display']['amount']),
      remainingAmount: parseAmount(json['remaining_amount_display']['amount']),
      isClosed: json['is_closed'] as bool,
      isOverBudget: json['is_over_budget'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': categoryId,
      'fixed_expense': fixedExpenseId,
      'budgeted_amount': budgetedAmount,
      'spent_amount': spentAmount,
      'is_closed': isClosed,
    };
  }
}

