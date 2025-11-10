import 'package:equatable/equatable.dart';

/// Resumen del presupuesto mensual
class BudgetSummary extends Equatable {
  final String month; // YYYY-MM
  final double theoreticalIncome;
  final double theoreticalExpenses;
  final double actualIncome;
  final double actualExpenses;
  final double totalSavings; // Total guardado en cuentas de ahorro
  final double balance;
  final double savingsRate;
  final List<CategoryBreakdown> categoriesBreakdown;

  const BudgetSummary({
    required this.month,
    required this.theoreticalIncome,
    required this.theoreticalExpenses,
    required this.actualIncome,
    required this.actualExpenses,
    required this.totalSavings,
    required this.balance,
    required this.savingsRate,
    required this.categoriesBreakdown,
  });

  /// Progreso del presupuesto (0.0 a 1.0)
  double get budgetProgress {
    if (theoreticalExpenses == 0) return 0.0;
    return (actualExpenses / theoreticalExpenses).clamp(0.0, 1.0);
  }

  /// Indica si se excedió el presupuesto
  bool get isOverBudget => actualExpenses > theoreticalExpenses;

  /// Diferencia entre ingreso y gasto real
  double get netIncome => actualIncome - actualExpenses;

  /// Dinero disponible para lo que resta del mes
  double get remainingForMonth {
    // Calculamos cuánto nos queda basado en el balance actual
    // y lo que se espera gastar el resto del mes
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day;
    final dailyBudget = theoreticalExpenses / daysInMonth;
    final projectedExpenseRemaining = dailyBudget * daysRemaining;
    
    return balance - projectedExpenseRemaining;
  }

  /// Porcentaje de avance del mes (0.0 a 1.0)
  double get monthProgress {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return now.day / daysInMonth;
  }

  /// Estado del presupuesto (semáforo)
  BudgetStatus get budgetStatus {
    if (actualExpenses == 0 && theoreticalExpenses == 0) {
      return BudgetStatus.neutral;
    }

    final spendingRate = actualExpenses / theoreticalExpenses;
    final timeRate = monthProgress;

    // Si gastamos menos de lo esperado según el avance del mes, vamos bien
    if (spendingRate < timeRate - 0.1) {
      return BudgetStatus.good;
    }
    // Si gastamos más o menos lo esperado, vamos ok
    else if (spendingRate <= timeRate + 0.1) {
      return BudgetStatus.warning;
    }
    // Si gastamos más de lo esperado, vamos mal
    else {
      return BudgetStatus.danger;
    }
  }

  @override
  List<Object?> get props => [
        month,
        theoreticalIncome,
        theoreticalExpenses,
        actualIncome,
        actualExpenses,
        totalSavings,
        balance,
        savingsRate,
        categoriesBreakdown,
      ];
}

/// Estado del presupuesto (semáforo)
enum BudgetStatus {
  good, // Verde - Vamos bien
  warning, // Amarillo - Atención
  danger, // Rojo - Peligro
  neutral, // Gris - Sin datos
}

/// Desglose por categoría
class CategoryBreakdown extends Equatable {
  final String category;
  final double budgeted;
  final double spent;
  final double percentage;

  const CategoryBreakdown({
    required this.category,
    required this.budgeted,
    required this.spent,
    required this.percentage,
  });

  /// Monto restante
  double get remaining => budgeted - spent;

  /// Indica si se excedió el presupuesto de la categoría
  bool get isOverBudget => spent > budgeted;

  /// Porcentaje gastado (0.0 a 1.0+)
  double get spentPercentage {
    if (budgeted == 0) {
      // Si hay gasto sin presupuesto, mostramos 100% (lleno)
      return spent > 0 ? 1.0 : 0.0;
    }
    return (spent / budgeted).clamp(0.0, double.infinity);
  }

  /// Estado de la categoría (semáforo)
  CategoryStatus get status {
    // Si no hay presupuesto pero sí hay gasto, es PELIGRO (rojo)
    if (budgeted == 0) {
      return spent > 0 ? CategoryStatus.danger : CategoryStatus.neutral;
    }
    
    final percentage = spent / budgeted;
    
    if (percentage <= 0.7) {
      return CategoryStatus.good;
    } else if (percentage <= 0.9) {
      return CategoryStatus.warning;
    } else {
      return CategoryStatus.danger;
    }
  }

  @override
  List<Object?> get props => [category, budgeted, spent, percentage];
}

/// Estado de una categoría (semáforo)
enum CategoryStatus {
  good, // Verde - Menos del 70%
  warning, // Amarillo - 70-90%
  danger, // Rojo - Más del 90%
  neutral, // Gris - Sin presupuesto
}

