class ApiConstants {
  // Backend API URL
  static const String baseUrl = 'https://expensense-tracker-api.onrender.com/api';
  
  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String signup = '$baseUrl/auth/signup';
  
  // Expense endpoints
  static const String expenses = '$baseUrl/expenses';
  static const String statistics = '$baseUrl/expenses/statistics';
  
  // Budget endpoints
  static const String budgets = '$baseUrl/budgets';
  static const String me = '$baseUrl/auth/me';
  
  // Additional endpoints
  static const String categories = '$baseUrl/categories';
}

class StorageKeys {
  static const String token = 'auth_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
}

class CategoryData {
  static const List<Map<String, dynamic>> categories = [
    // Housing & Utilities (🏠) - 7 categories
    {'name': 'Rent/Mortgage', 'icon': '🏠', 'color': 0xFF6B5CE7, 'group': 'Housing'},
    {'name': 'Electricity', 'icon': '💡', 'color': 0xFFFFA726, 'group': 'Housing'},
    {'name': 'Water', 'icon': '💧', 'color': 0xFF42A5F5, 'group': 'Housing'},
    {'name': 'Gas', 'icon': '🔥', 'color': 0xFFEF5350, 'group': 'Housing'},
    {'name': 'Internet', 'icon': '📡', 'color': 0xFF26A69A, 'group': 'Housing'},
    {'name': 'Maintenance', 'icon': '🔧', 'color': 0xFF78909C, 'group': 'Housing'},
    {'name': 'Property Tax', 'icon': '🏛️', 'color': 0xFF8D6E63, 'group': 'Housing'},
    
    // Transportation (🚗) - 7 categories
    {'name': 'Fuel', 'icon': '⛽', 'color': 0xFFFF7043, 'group': 'Transport'},
    {'name': 'Vehicle Maintenance', 'icon': '🔧', 'color': 0xFF546E7A, 'group': 'Transport'},
    {'name': 'Vehicle Insurance', 'icon': '🛡️', 'color': 0xFF5C6BC0, 'group': 'Transport'},
    {'name': 'Parking', 'icon': '🅿️', 'color': 0xFF7E57C2, 'group': 'Transport'},
    {'name': 'Public Transport', 'icon': '🚌', 'color': 0xFF26C6DA, 'group': 'Transport'},
    {'name': 'Taxi/Ride', 'icon': '🚕', 'color': 0xFFFFCA28, 'group': 'Transport'},
    {'name': 'Vehicle Loan', 'icon': '🚗', 'color': 0xFFEC407A, 'group': 'Transport'},
    
    // Food & Dining (🍔) - 5 categories
    {'name': 'Groceries', 'icon': '🛒', 'color': 0xFF66BB6A, 'group': 'Food'},
    {'name': 'Restaurants', 'icon': '🍽️', 'color': 0xFFFF6B6B, 'group': 'Food'},
    {'name': 'Snacks', 'icon': '🍿', 'color': 0xFFFFB74D, 'group': 'Food'},
    {'name': 'Coffee/Beverages', 'icon': '☕', 'color': 0xFF8D6E63, 'group': 'Food'},
    {'name': 'Food Delivery', 'icon': '🛵', 'color': 0xFFEF5350, 'group': 'Food'},
    
    // Shopping (🛍️) - 5 categories
    {'name': 'Clothing', 'icon': '👕', 'color': 0xFFAB47BC, 'group': 'Shopping'},
    {'name': 'Accessories', 'icon': '👜', 'color': 0xFFEC407A, 'group': 'Shopping'},
    {'name': 'Electronics', 'icon': '📱', 'color': 0xFF42A5F5, 'group': 'Shopping'},
    {'name': 'Home Decor', 'icon': '🛋️', 'color': 0xFF8BC34A, 'group': 'Shopping'},
    {'name': 'Online Shopping', 'icon': '📦', 'color': 0xFFFF7043, 'group': 'Shopping'},
    
    // Health & Fitness (💊) - 5 categories
    {'name': 'Medical', 'icon': '🏥', 'color': 0xFFEF5350, 'group': 'Health'},
    {'name': 'Medicines', 'icon': '💊', 'color': 0xFFE57373, 'group': 'Health'},
    {'name': 'Gym/Fitness', 'icon': '💪', 'color': 0xFFFF6F00, 'group': 'Health'},
    {'name': 'Health Insurance', 'icon': '🩺', 'color': 0xFF5C6BC0, 'group': 'Health'},
    {'name': 'Wellness/Spa', 'icon': '🧖', 'color': 0xFF9575CD, 'group': 'Health'},
    
    // Education (🎓) - 4 categories
    {'name': 'School/College Fees', 'icon': '🎓', 'color': 0xFF5C6BC0, 'group': 'Education'},
    {'name': 'Books', 'icon': '📚', 'color': 0xFF7E57C2, 'group': 'Education'},
    {'name': 'Online Courses', 'icon': '💻', 'color': 0xFF42A5F5, 'group': 'Education'},
    {'name': 'Coaching', 'icon': '👨‍🏫', 'color': 0xFF66BB6A, 'group': 'Education'},
    
    // Bills & Subscriptions (🧾) - 4 categories
    {'name': 'Mobile Recharge', 'icon': '📱', 'color': 0xFF26A69A, 'group': 'Bills'},
    {'name': 'Streaming Services', 'icon': '📺', 'color': 0xFFEF5350, 'group': 'Bills'},
    {'name': 'Software Subscriptions', 'icon': '💻', 'color': 0xFF42A5F5, 'group': 'Bills'},
    {'name': 'Cloud Storage', 'icon': '☁️', 'color': 0xFF78909C, 'group': 'Bills'},
    
    // Work/Business (💼) - 5 categories
    {'name': 'Office Rent', 'icon': '🏢', 'color': 0xFF546E7A, 'group': 'Business'},
    {'name': 'Business Supplies', 'icon': '📎', 'color': 0xFF8D6E63, 'group': 'Business'},
    {'name': 'Work Travel', 'icon': '✈️', 'color': 0xFF26C6DA, 'group': 'Business'},
    {'name': 'Tools/Software', 'icon': '🛠️', 'color': 0xFF7E57C2, 'group': 'Business'},
    {'name': 'Contractors', 'icon': '👷', 'color': 0xFFFF9800, 'group': 'Business'},
    
    // Finance (🏦) - 5 categories
    {'name': 'Loan Payments', 'icon': '💳', 'color': 0xFF5C6BC0, 'group': 'Finance'},
    {'name': 'Credit Card Bills', 'icon': '💳', 'color': 0xFFEF5350, 'group': 'Finance'},
    {'name': 'Investments', 'icon': '📈', 'color': 0xFF66BB6A, 'group': 'Finance'},
    {'name': 'Insurance', 'icon': '🛡️', 'color': 0xFF42A5F5, 'group': 'Finance'},
    {'name': 'Savings', 'icon': '💰', 'color': 0xFF9CCC65, 'group': 'Finance'},
    
    // Personal & Family (🧍‍♂️) - 5 categories
    {'name': 'Child Care', 'icon': '👶', 'color': 0xFFFFB74D, 'group': 'Personal'},
    {'name': 'Elder Care', 'icon': '👴', 'color': 0xFF8D6E63, 'group': 'Personal'},
    {'name': 'Gifts', 'icon': '🎁', 'color': 0xFFEC407A, 'group': 'Personal'},
    {'name': 'Donations', 'icon': '🤝', 'color': 0xFF66BB6A, 'group': 'Personal'},
    {'name': 'Events', 'icon': '🎉', 'color': 0xFFAB47BC, 'group': 'Personal'},
    
    // Travel & Leisure (✈️) - 4 categories
    {'name': 'Flights/Trains', 'icon': '✈️', 'color': 0xFF42A5F5, 'group': 'Travel'},
    {'name': 'Hotels', 'icon': '🏨', 'color': 0xFF7E57C2, 'group': 'Travel'},
    {'name': 'Tours/Activities', 'icon': '🎭', 'color': 0xFFFFCA28, 'group': 'Travel'},
    {'name': 'Entertainment', 'icon': '🎬', 'color': 0xFFE57373, 'group': 'Travel'},
    
    // Others (🐾) - 3 categories
    {'name': 'Pet Care', 'icon': '🐾', 'color': 0xFFFF9800, 'group': 'Others'},
    {'name': 'Emergency', 'icon': '🚨', 'color': 0xFFEF5350, 'group': 'Others'},
    {'name': 'Miscellaneous', 'icon': '📦', 'color': 0xFF78909C, 'group': 'Others'},
  ];

  // Helper Methods
  
  /// Get all unique group names
  static List<String> getGroups() {
    return categories
        .map((cat) => cat['group'] as String)
        .toSet()
        .toList()
      ..sort();
  }

  /// Get categories filtered by group
  static List<Map<String, dynamic>> getCategoriesByGroup(String group) {
    return categories.where((cat) => cat['group'] == group).toList();
  }

  /// Find a category by its name
  static Map<String, dynamic>? getCategoryByName(String name) {
    try {
      return categories.firstWhere(
        (cat) => cat['name'] == name,
        orElse: () => categories.last, // Default to Miscellaneous
      );
    } catch (e) {
      return categories.last; // Return Miscellaneous as fallback
    }
  }

  /// Get all category names as a list
  static List<String> getCategoryNames() {
    return categories.map((cat) => cat['name'] as String).toList();
  }

  /// Get icon for a specific category
  static String getCategoryIcon(String categoryName) {
    final category = getCategoryByName(categoryName);
    return category?['icon'] ?? '📦';
  }

  /// Get color for a specific category
  static int getCategoryColor(String categoryName) {
    final category = getCategoryByName(categoryName);
    return category?['color'] ?? 0xFF78909C;
  }

  /// Get group name for a specific category
  static String getCategoryGroup(String categoryName) {
    final category = getCategoryByName(categoryName);
    return category?['group'] ?? 'Others';
  }

  /// Search categories by name
  static List<Map<String, dynamic>> searchCategories(String query) {
    if (query.isEmpty) return categories;
    
    final lowerQuery = query.toLowerCase();
    return categories.where((cat) {
      final name = (cat['name'] as String).toLowerCase();
      return name.contains(lowerQuery);
    }).toList();
  }

  /// Get categories count by group
  static Map<String, int> getCategoriesCountByGroup() {
    final Map<String, int> counts = {};
    for (var cat in categories) {
      final group = cat['group'] as String;
      counts[group] = (counts[group] ?? 0) + 1;
    }
    return counts;
  }
}
