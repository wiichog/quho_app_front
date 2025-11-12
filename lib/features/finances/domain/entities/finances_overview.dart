/// Entity for finances overview
class FinancesOverview {
  final String month;
  final FinancesSummary summary;
  final List<CategoryComparison> categoryBreakdown;
  final List<BudgetCategoryItem> idealBudgetBreakdown;

  const FinancesOverview({
    required this.month,
    required this.summary,
    required this.categoryBreakdown,
    required this.idealBudgetBreakdown,
  });
}

/// Summary comparing ideal vs execution
class FinancesSummary {
  final BudgetSummarySection ideal;
  final BudgetSummarySection execution;
  final BudgetDelta delta;

  const FinancesSummary({
    required this.ideal,
    required this.execution,
    required this.delta,
  });
}

/// Budget summary section (ideal or execution)
class BudgetSummarySection {
  final double income;
  final double expenses;
  final double? savingsTarget; // Only for ideal
  final double? net; // Only for execution
  final double? totalBudgeted; // Only for ideal

  const BudgetSummarySection({
    required this.income,
    required this.expenses,
    this.savingsTarget,
    this.net,
    this.totalBudgeted,
  });
}

/// Delta between ideal and execution
class BudgetDelta {
  final double income;
  final double expenses;
  final double savings;

  const BudgetDelta({
    required this.income,
    required this.expenses,
    required this.savings,
  });
}

/// Category comparison (ideal vs actual)
class CategoryComparison {
  final int? categoryId;
  final String category;
  final double budgeted;
  final double spent;
  final double remaining;
  final double percentageUsed;
  final String slug;
  final String icon;
  final String color;
  final int transactionCount;

  const CategoryComparison({
    this.categoryId,
    required this.category,
    required this.budgeted,
    required this.spent,
    required this.remaining,
    required this.percentageUsed,
    required this.slug,
    required this.icon,
    required this.color,
    required this.transactionCount,
  });

  bool get isOverBudget => percentageUsed > 100;
  bool get isNearLimit => percentageUsed >= 80 && percentageUsed <= 100;
  bool get hasNoBudget => budgeted == 0;
}

/// Ideal budget category item
class BudgetCategoryItem {
  final int? categoryId;
  final String category;
  final double budgeted;
  final double percentage;
  final String slug;
  final String icon;
  final String color;

  const BudgetCategoryItem({
    this.categoryId,
    required this.category,
    required this.budgeted,
    required this.percentage,
    required this.slug,
    required this.icon,
    required this.color,
  });

  bool get isSavings => slug == 'savings';
}

