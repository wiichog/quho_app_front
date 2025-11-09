import 'package:equatable/equatable.dart';

/// Consejo de presupuesto generado por Claude
class BudgetAdvice extends Equatable {
  final int id;
  final String title;
  final String description;
  final String category; // saving, expense, income, debt, habit
  final String priority; // high, medium, low
  final String estimatedImpact;
  final bool isRead;
  final bool? isHelpful;
  final DateTime createdAt;

  const BudgetAdvice({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.estimatedImpact,
    required this.isRead,
    this.isHelpful,
    required this.createdAt,
  });

  /// Obtiene el icono según la categoría
  String get categoryIcon {
    switch (category) {
      case 'saving':
        return '💰';
      case 'expense':
        return '💳';
      case 'income':
        return '💵';
      case 'debt':
        return '📊';
      case 'habit':
        return '🎯';
      default:
        return '💡';
    }
  }

  /// Obtiene el color según la prioridad
  String get priorityColor {
    switch (priority) {
      case 'high':
        return 'red';
      case 'medium':
        return 'orange';
      case 'low':
        return 'green';
      default:
        return 'gray';
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        priority,
        estimatedImpact,
        isRead,
        isHelpful,
        createdAt,
      ];
}








