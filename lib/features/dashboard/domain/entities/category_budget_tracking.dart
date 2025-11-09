import 'package:equatable/equatable.dart';

/// Entity for tracking budget consumption per category or fixed expense
class CategoryBudgetTracking extends Equatable {
  final int id;
  final int? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final int? fixedExpenseId;
  final String? fixedExpenseName;
  final double budgetedAmount;
  final double spentAmount;
  final double remainingAmount;
  final bool isClosed;
  final bool isOverBudget;

  const CategoryBudgetTracking({
    required this.id,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.fixedExpenseId,
    this.fixedExpenseName,
    required this.budgetedAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.isClosed,
    required this.isOverBudget,
  });

  String get displayName => categoryName ?? fixedExpenseName ?? 'Sin nombre';

  @override
  List<Object?> get props => [
        id,
        categoryId,
        categoryName,
        categoryIcon,
        categoryColor,
        fixedExpenseId,
        fixedExpenseName,
        budgetedAmount,
        spentAmount,
        remainingAmount,
        isClosed,
        isOverBudget,
      ];
}

