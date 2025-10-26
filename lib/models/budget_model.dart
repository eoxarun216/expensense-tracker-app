class BudgetModel {
  final String? id;
  final String userId;
  final String category;
  final double limit;
  final double spent;
  final String period;
  final DateTime? createdAt;

  BudgetModel({
    this.id,
    required this.userId,
    required this.category,
    required this.limit,
    this.spent = 0.0,
    required this.period,
    this.createdAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['_id'] ?? json['id'],
      userId: json['user'] ?? json['userId'] ?? '',
      category: json['category'],
      limit: (json['limit'] as num).toDouble(),
      spent: json['spent'] != null ? (json['spent'] as num).toDouble() : 0.0,
      period: json['period'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      // ❌ DON'T send userId - backend adds it from token
      'category': category,
      'limit': limit,
      'period': period,
    };
  }

  BudgetModel copyWith({
    String? id,
    String? userId,
    String? category,
    double? limit,
    double? spent,
    String? period,
    DateTime? createdAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
      period: period ?? this.period,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper method to calculate budget usage percentage
  double get usagePercentage {
    if (limit == 0) return 0.0;
    return (spent / limit) * 100;
  }

  // Helper method to get remaining budget
  double get remaining {
    final rem = limit - spent;
    return rem > 0 ? rem : 0.0;
  }

  // Helper method to check if budget is exceeded
  bool get isExceeded => spent > limit;

  // Helper method to check if approaching limit (>80%)
  bool get isApproachingLimit => spent >= (limit * 0.8) && spent <= limit;

  // Helper method to get budget status
  String get status {
    if (isExceeded) return 'exceeded';
    if (isApproachingLimit) return 'warning';
    return 'safe';
  }
}
