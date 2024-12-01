

class Food{
  final String name;
  final double calories;
  final double servingSize;
  final double fatTotal;
  final double fatSaturated;
  final double protein;
  final int sodium;
  final int potassium;
  final int cholesterol;
  final double carbohydrates;
  final double fiber;
  final double sugar;

  Food({
    required this.name,
    required this.calories,
    required this.servingSize,
    required this.fatTotal,
    required this.fatSaturated,
    required this.protein,
    required this.sodium,
    required this.potassium,
    required this.cholesterol,
    required this.carbohydrates,
    required this.fiber,
    required this.sugar,
  });

  factory Food.fromJson(Map<String, dynamic> json){
    return Food(
      name: json['name'] ?? 'Unknown',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      servingSize: (json['serving_size_g'] as num?)?.toDouble() ?? 0.0,
      fatTotal: (json['fat_total_g'] as num?)?.toDouble() ?? 0.0,
      fatSaturated: (json['fat_saturated_g'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein_g'] as num?)?.toDouble() ?? 0.0,
      sodium: (json['sodium_mg'] as num?)?.toInt() ?? 0,
      potassium: (json['potassium_mg'] as num?)?.toInt() ?? 0,
      cholesterol: (json['cholesterol_mg'] as num?)?.toInt() ?? 0,
      carbohydrates: (json['carbohydrates_total_g'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber_g'] as num?)?.toDouble() ?? 0.0,
      sugar: (json['sugar_g'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
