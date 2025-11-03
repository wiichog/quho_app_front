import 'package:quho_app/features/finances/domain/entities/finances_overview.dart';

/// Model for finances overview
class FinancesOverviewModel extends FinancesOverview {
  const FinancesOverviewModel({
    required super.month,
    required super.summary,
    required super.categoryBreakdown,
    required super.idealBudgetBreakdown,
  });

  factory FinancesOverviewModel.fromJson(Map<String, dynamic> json) {
    return FinancesOverviewModel(
      month: json['month'] as String,
      summary: FinancesSummaryModel.fromJson(json['summary'] as Map<String, dynamic>),
      categoryBreakdown: (json['category_breakdown'] as List)
          .map((e) => CategoryComparisonModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      idealBudgetBreakdown: (json['ideal_budget_breakdown'] as List)
          .map((e) => BudgetCategoryItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Model for finances summary
class FinancesSummaryModel extends FinancesSummary {
  const FinancesSummaryModel({
    required super.ideal,
    required super.execution,
    required super.delta,
  });

  factory FinancesSummaryModel.fromJson(Map<String, dynamic> json) {
    return FinancesSummaryModel(
      ideal: BudgetSummarySectionModel.fromJson(json['ideal'] as Map<String, dynamic>, isIdeal: true),
      execution: BudgetSummarySectionModel.fromJson(json['execution'] as Map<String, dynamic>, isIdeal: false),
      delta: BudgetDeltaModel.fromJson(json['delta'] as Map<String, dynamic>),
    );
  }
}

/// Model for budget summary section
class BudgetSummarySectionModel extends BudgetSummarySection {
  const BudgetSummarySectionModel({
    required super.income,
    required super.expenses,
    super.savingsTarget,
    super.net,
    super.totalBudgeted,
  });

  factory BudgetSummarySectionModel.fromJson(Map<String, dynamic> json, {required bool isIdeal}) {
    return BudgetSummarySectionModel(
      income: (json['income'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      savingsTarget: isIdeal ? (json['savings_target'] as num?)?.toDouble() : null,
      net: !isIdeal ? (json['net'] as num?)?.toDouble() : null,
      totalBudgeted: isIdeal ? (json['total_budgeted'] as num?)?.toDouble() : null,
    );
  }
}

/// Model for budget delta
class BudgetDeltaModel extends BudgetDelta {
  const BudgetDeltaModel({
    required super.income,
    required super.expenses,
    required super.savings,
  });

  factory BudgetDeltaModel.fromJson(Map<String, dynamic> json) {
    return BudgetDeltaModel(
      income: (json['income'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      savings: (json['savings'] as num).toDouble(),
    );
  }
}

/// Model for category comparison
class CategoryComparisonModel extends CategoryComparison {
  const CategoryComparisonModel({
    required super.category,
    required super.budgeted,
    required super.spent,
    required super.remaining,
    required super.percentageUsed,
    required super.slug,
    required super.icon,
    required super.color,
    required super.transactionCount,
  });

  factory CategoryComparisonModel.fromJson(Map<String, dynamic> json) {
    return CategoryComparisonModel(
      category: json['category'] as String,
      budgeted: (json['budgeted'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
      percentageUsed: (json['percentage_used'] as num).toDouble(),
      slug: json['slug'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      transactionCount: json['transaction_count'] as int,
    );
  }
}

/// Model for budget category item
class BudgetCategoryItemModel extends BudgetCategoryItem {
  const BudgetCategoryItemModel({
    super.categoryId,
    required super.category,
    required super.budgeted,
    required super.percentage,
    required super.slug,
    required super.icon,
    required super.color,
  });

  factory BudgetCategoryItemModel.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryItemModel(
      categoryId: json['category_id'] as int?,
      category: json['category'] as String,
      budgeted: (json['budgeted'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      slug: json['slug'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
    );
  }
}

