import 'package:quho_app/features/dashboard/domain/entities/budget_advice.dart';

class BudgetAdviceModel extends BudgetAdvice {
  const BudgetAdviceModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.priority,
    required super.estimatedImpact,
    required super.isRead,
    super.isHelpful,
    required super.createdAt,
  });

  factory BudgetAdviceModel.fromJson(Map<String, dynamic> json) {
    return BudgetAdviceModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      estimatedImpact: json['estimated_impact'] as String,
      isRead: json['is_read'] as bool? ?? false,
      isHelpful: json['is_helpful'] as bool?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'estimated_impact': estimatedImpact,
      'is_read': isRead,
      'is_helpful': isHelpful,
      'created_at': createdAt.toIso8601String(),
    };
  }

  BudgetAdvice toEntity() {
    return BudgetAdvice(
      id: id,
      title: title,
      description: description,
      category: category,
      priority: priority,
      estimatedImpact: estimatedImpact,
      isRead: isRead,
      isHelpful: isHelpful,
      createdAt: createdAt,
    );
  }
}


