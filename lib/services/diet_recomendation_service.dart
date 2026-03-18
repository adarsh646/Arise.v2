import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final int age;
  final String? gender;
  final double heightCm;
  final double weightKg;
  final String activityLevel;
  final String goal;
  final int mealsPerDay;
  final String dietType;

  const UserProfile({
    required this.uid,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.goal,
    required this.mealsPerDay,
    required this.dietType,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: (map['uid'] ?? '').toString(),
      age: _toInt(map['age']),
      gender: map['gender']?.toString().trim().isEmpty == true
          ? null
          : map['gender']?.toString(),
      heightCm: _toDouble(map['heightCm']),
      weightKg: _toDouble(map['weightKg']),
      activityLevel: (map['activityLevel'] ?? 'moderate').toString(),
      goal: (map['goal'] ?? 'maintain').toString(),
      mealsPerDay: _toInt(map['mealsPerDay'], fallback: 3).clamp(3, 5),
      dietType: (map['dietType'] ?? 'nonveg').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activityLevel': activityLevel,
      'goal': goal,
      'mealsPerDay': mealsPerDay,
      'dietType': dietType,
    };
  }
}

class HealthProfile {
  final String diabetesStatus;
  final String bpStatus;
  final List<String> conditions;
  final List<String> allergies;
  final List<String> intolerances;
  final bool pregnantOrBreastfeeding;
  final double? fastingSugarMgDl;
  final double? hba1cPercent;
  final int? bpSystolic;
  final int? bpDiastolic;
  final double? ldl;
  final double? hdl;
  final double? triglycerides;
  final double? egfr;
  final double? creatinine;
  final List<String> medications;

  const HealthProfile({
    required this.diabetesStatus,
    required this.bpStatus,
    required this.conditions,
    required this.allergies,
    required this.intolerances,
    required this.pregnantOrBreastfeeding,
    required this.fastingSugarMgDl,
    required this.hba1cPercent,
    required this.bpSystolic,
    required this.bpDiastolic,
    required this.ldl,
    required this.hdl,
    required this.triglycerides,
    required this.egfr,
    required this.creatinine,
    required this.medications,
  });

  factory HealthProfile.empty() {
    return const HealthProfile(
      diabetesStatus: 'none',
      bpStatus: 'none',
      conditions: <String>[],
      allergies: <String>[],
      intolerances: <String>[],
      pregnantOrBreastfeeding: false,
      fastingSugarMgDl: null,
      hba1cPercent: null,
      bpSystolic: null,
      bpDiastolic: null,
      ldl: null,
      hdl: null,
      triglycerides: null,
      egfr: null,
      creatinine: null,
      medications: <String>[],
    );
  }

  factory HealthProfile.fromMap(Map<String, dynamic> map) {
    return HealthProfile(
      diabetesStatus: (map['diabetesStatus'] ?? 'none').toString(),
      bpStatus: (map['bpStatus'] ?? 'none').toString(),
      conditions: _toStringList(map['conditions']),
      allergies: _toStringList(map['allergies']),
      intolerances: _toStringList(map['intolerances']),
      pregnantOrBreastfeeding: map['pregnantOrBreastfeeding'] == true,
      fastingSugarMgDl: _toNullableDouble(map['fastingSugarMgDl']),
      hba1cPercent: _toNullableDouble(map['hba1cPercent']),
      bpSystolic: _toNullableInt(map['bpSystolic']),
      bpDiastolic: _toNullableInt(map['bpDiastolic']),
      ldl: _toNullableDouble(map['ldl']),
      hdl: _toNullableDouble(map['hdl']),
      triglycerides: _toNullableDouble(map['triglycerides']),
      egfr: _toNullableDouble(map['egfr']),
      creatinine: _toNullableDouble(map['creatinine']),
      medications: _toStringList(map['medications']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'diabetesStatus': diabetesStatus,
      'bpStatus': bpStatus,
      'conditions': conditions,
      'allergies': allergies,
      'intolerances': intolerances,
      'pregnantOrBreastfeeding': pregnantOrBreastfeeding,
      'fastingSugarMgDl': fastingSugarMgDl,
      'hba1cPercent': hba1cPercent,
      'bpSystolic': bpSystolic,
      'bpDiastolic': bpDiastolic,
      'ldl': ldl,
      'hdl': hdl,
      'triglycerides': triglycerides,
      'egfr': egfr,
      'creatinine': creatinine,
      'medications': medications,
    };
  }
}

class FoodItem {
  final String id;
  final String name;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double? fiberPer100g;
  final String category;
  final List<String> tags;
  final String? imageUrl;
  final double minServingG;
  final double maxServingG;

  const FoodItem({
    required this.id,
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.fiberPer100g,
    required this.category,
    required this.tags,
    this.imageUrl,
    required this.minServingG,
    required this.maxServingG,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? 'Unknown').toString(),
      caloriesPer100g: _toDouble(
        map['caloriesPer100g'] ?? map['calories'],
      ),
      proteinPer100g: _toDouble(
        map['proteinPer100g'] ?? map['protein'],
      ),
      carbsPer100g: _toDouble(
        map['carbsPer100g'] ?? map['carbs'],
      ),
      fatPer100g: _toDouble(
        map['fatPer100g'] ?? map['fat'],
      ),
      fiberPer100g: _toNullableDouble(
        map['fiberPer100g'] ?? map['fiber'],
      ),
      category: (map['category'] ?? 'other').toString(),
      tags: _normalizeTags(map),
      imageUrl: map['imageUrl']?.toString(),
      minServingG: _toDouble(map['minServingG'], fallback: 30),
      maxServingG: max(
        _toDouble(map['maxServingG'], fallback: 350),
        _toDouble(map['minServingG'], fallback: 30),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'fiberPer100g': fiberPer100g,
      'category': category,
      'tags': tags,
      'imageUrl': imageUrl,
      'minServingG': minServingG,
      'maxServingG': maxServingG,
    };
  }

  factory FoodItem.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data();
    return FoodItem.fromMap(<String, dynamic>{...map, 'id': doc.id});
  }
}

class Targets {
  final double bmi;
  final double bmr;
  final double tdee;
  final double targetCalories;
  final double targetProteinG;
  final double minFatG;
  final double targetCarbsG;

  const Targets({
    required this.bmi,
    required this.bmr,
    required this.tdee,
    required this.targetCalories,
    required this.targetProteinG,
    required this.minFatG,
    required this.targetCarbsG,
  });

  factory Targets.fromMap(Map<String, dynamic> map) {
    return Targets(
      bmi: _toDouble(map['bmi']),
      bmr: _toDouble(map['bmr']),
      tdee: _toDouble(map['tdee']),
      targetCalories: _toDouble(map['targetCalories']),
      targetProteinG: _toDouble(map['targetProteinG']),
      minFatG: _toDouble(map['minFatG']),
      targetCarbsG: _toDouble(map['targetCarbsG']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bmi': bmi,
      'bmr': bmr,
      'tdee': tdee,
      'targetCalories': targetCalories,
      'targetProteinG': targetProteinG,
      'minFatG': minFatG,
      'targetCarbsG': targetCarbsG,
    };
  }
}

class NutritionTotals {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double? fiberG;

  const NutritionTotals({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
  });

  factory NutritionTotals.zero() {
    return const NutritionTotals(
      calories: 0,
      proteinG: 0,
      carbsG: 0,
      fatG: 0,
      fiberG: 0,
    );
  }

  factory NutritionTotals.fromMap(Map<String, dynamic> map) {
    return NutritionTotals(
      calories: _toDouble(map['calories']),
      proteinG: _toDouble(map['proteinG']),
      carbsG: _toDouble(map['carbsG']),
      fatG: _toDouble(map['fatG']),
      fiberG: _toNullableDouble(map['fiberG']) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calories': calories,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
      'fiberG': fiberG,
    };
  }

  NutritionTotals copyWith({
    double? calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    double? fiberG,
  }) {
    return NutritionTotals(
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      fiberG: fiberG ?? this.fiberG,
    );
  }

  NutritionTotals plus(NutritionTotals other) {
    return NutritionTotals(
      calories: calories + other.calories,
      proteinG: proteinG + other.proteinG,
      carbsG: carbsG + other.carbsG,
      fatG: fatG + other.fatG,
      fiberG: (fiberG ?? 0) + (other.fiberG ?? 0),
    );
  }
}

class MealItem {
  final String foodId;
  final String name;
  final double grams;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double? fiberG;
  final String category;
  final List<String> tags;
  final String? imageUrl;

  const MealItem({
    required this.foodId,
    required this.name,
    required this.grams,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    required this.category,
    required this.tags,
    required this.imageUrl,
  });

  factory MealItem.fromMap(Map<String, dynamic> map) {
    return MealItem(
      foodId: (map['foodId'] ?? '').toString(),
      name: (map['name'] ?? 'Food').toString(),
      grams: _toDouble(map['grams']),
      calories: _toDouble(map['calories']),
      proteinG: _toDouble(map['proteinG']),
      carbsG: _toDouble(map['carbsG']),
      fatG: _toDouble(map['fatG']),
      fiberG: _toNullableDouble(map['fiberG']) ?? 0,
      category: (map['category'] ?? 'other').toString(),
      tags: _toStringList(map['tags']),
      imageUrl: map['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'name': name,
      'grams': grams,
      'calories': calories,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
      'fiberG': fiberG,
      'category': category,
      'tags': tags,
      'imageUrl': imageUrl,
    };
  }
}

class MealPlan {
  final String name;
  final double targetCalories;
  final List<MealItem> items;
  final NutritionTotals totals;

  const MealPlan({
    required this.name,
    required this.targetCalories,
    required this.items,
    required this.totals,
  });

  factory MealPlan.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((e) => MealItem.fromMap(e.cast<String, dynamic>()))
              .toList()
        : <MealItem>[];
    return MealPlan(
      name: (map['name'] ?? 'Meal').toString(),
      targetCalories: _toDouble(map['targetCalories']),
      items: items,
      totals: NutritionTotals.fromMap(
        (map['totals'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'targetCalories': targetCalories,
      'items': items.map((e) => e.toMap()).toList(),
      'totals': totals.toMap(),
    };
  }
}

class ValidationReport {
  final bool passed;
  final List<String> warnings;
  final List<String> errors;

  const ValidationReport({
    required this.passed,
    required this.warnings,
    required this.errors,
  });

  factory ValidationReport.fromMap(Map<String, dynamic> map) {
    return ValidationReport(
      passed: map['passed'] == true,
      warnings: _toStringList(map['warnings']),
      errors: _toStringList(map['errors']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'passed': passed,
      'warnings': warnings,
      'errors': errors,
    };
  }
}

class DietPlanDay {
  final String dateIso;
  final String? generatedAtIso;
  final String? expiresAtIso;
  final Targets targets;
  final List<MealPlan> meals;
  final NutritionTotals totals;
  final ValidationReport validation;

  const DietPlanDay({
    required this.dateIso,
    this.generatedAtIso,
    this.expiresAtIso,
    required this.targets,
    required this.meals,
    required this.totals,
    required this.validation,
  });

  factory DietPlanDay.fromMap(Map<String, dynamic> map) {
    final rawMeals = map['meals'];
    final meals = rawMeals is List
        ? rawMeals
              .whereType<Map>()
              .map((e) => MealPlan.fromMap(e.cast<String, dynamic>()))
              .toList()
        : <MealPlan>[];
    return DietPlanDay(
      dateIso: (map['dateIso'] ?? '').toString(),
      generatedAtIso: map['generatedAtIso']?.toString(),
      expiresAtIso: map['expiresAtIso']?.toString(),
      targets: Targets.fromMap(
        (map['targets'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      ),
      meals: meals,
      totals: NutritionTotals.fromMap(
        (map['totals'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      ),
      validation: ValidationReport.fromMap(
        (map['validation'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateIso': dateIso,
      'generatedAtIso': generatedAtIso,
      'expiresAtIso': expiresAtIso,
      'targets': targets.toMap(),
      'meals': meals.map((e) => e.toMap()).toList(),
      'totals': totals.toMap(),
      'validation': validation.toMap(),
    };
  }

  DietPlanDay copyWith({
    String? dateIso,
    String? generatedAtIso,
    String? expiresAtIso,
    Targets? targets,
    List<MealPlan>? meals,
    NutritionTotals? totals,
    ValidationReport? validation,
  }) {
    return DietPlanDay(
      dateIso: dateIso ?? this.dateIso,
      generatedAtIso: generatedAtIso ?? this.generatedAtIso,
      expiresAtIso: expiresAtIso ?? this.expiresAtIso,
      targets: targets ?? this.targets,
      meals: meals ?? this.meals,
      totals: totals ?? this.totals,
      validation: validation ?? this.validation,
    );
  }

  DateTime? get generatedAt => generatedAtIso == null ? null : DateTime.tryParse(generatedAtIso!);

  DateTime? get expiresAt => expiresAtIso == null ? null : DateTime.tryParse(expiresAtIso!);

  bool get isExpired {
    final exp = expiresAt;
    if (exp == null) return false;
    return DateTime.now().isAfter(exp);
  }
}

class FoodRepository {
  final FirebaseFirestore _db;

  FoodRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Future<List<FoodItem>> fetchFoods() async {
    final primary = await _db.collection('foods').get();
    if (primary.docs.isNotEmpty) {
      return primary.docs.map(FoodItem.fromDoc).toList();
    }
    final fallback = await _db.collection('food_item').get();
    return fallback.docs.map(FoodItem.fromDoc).toList();
  }
}

class DietPlanRepository {
  final FirebaseFirestore _db;

  DietPlanRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Future<void> savePlan(String uid, DietPlanDay plan) async {
    final dayId = plan.dateIso.split('T').first;
    await _db.collection('dietPlans').doc(uid).collection('days').doc(dayId).set(
          plan.toMap(),
          SetOptions(merge: true),
        );
    await _db.collection('diet_plans').doc(uid).set(
          {
            ...plan.toMap(),
            'userId': uid,
            'updatedAt': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
  }

  Future<DietPlanDay?> fetchLatestPlan(String uid) async {
    final fallback = await _db.collection('diet_plans').doc(uid).get();
    if (fallback.exists && fallback.data() != null) {
      return DietPlanDay.fromMap(fallback.data()!);
    }
    final latest = await _db
        .collection('dietPlans')
        .doc(uid)
        .collection('days')
        .orderBy('dateIso', descending: true)
        .limit(1)
        .get();
    if (latest.docs.isNotEmpty) {
      return DietPlanDay.fromMap(latest.docs.first.data());
    }
    return null;
  }

  Future<void> deletePlan(String uid, DateTime date) async {
    final id = _toDayId(date);
    final dayRef = _db.collection('dietPlans').doc(uid).collection('days').doc(id);
    final day = await dayRef.get();
    if (day.exists) {
      await dayRef.delete();
    }
    await _db.collection('diet_plans').doc(uid).delete();
  }

  String _toDayId(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class DietEngine {
  Targets computeTargets(UserProfile user, HealthProfile health) {
    final heightM = user.heightCm / 100;
    final bmi = user.weightKg / (heightM * heightM);
    final base = 10 * user.weightKg + 6.25 * user.heightCm - 5 * user.age;
    final gender = user.gender?.toLowerCase();
    double bmr = base - 78;
    if (gender == 'male') {
      bmr = base + 5;
    } else if (gender == 'female') {
      bmr = base - 161;
    }

    final tdee = bmr * _activityMultiplier(user.activityLevel);
    var targetCalories = tdee;
    final goal = user.goal.toLowerCase();
    if (goal == 'fat_loss') {
      targetCalories = tdee - 400;
    } else if (goal == 'muscle_gain') {
      targetCalories = tdee + 300;
    }

    var floor = 1150.0;
    if (gender == 'male') floor = 1200;
    if (gender == 'female') floor = 1100;
    targetCalories = max(targetCalories, floor);

    var targetProteinG = user.weightKg * 1.4;
    if (goal == 'fat_loss') targetProteinG = user.weightKg * 2.0;
    if (goal == 'muscle_gain') targetProteinG = user.weightKg * 1.7;
    if (_needsKidneyProteinCap(health)) {
      targetProteinG = min(targetProteinG, user.weightKg * 1.2);
    }

    final minFatG = min(user.weightKg * 0.8, 100).toDouble();
    final targetCarbsG =
        max(0, (targetCalories - targetProteinG * 4 - minFatG * 9) / 4)
            .toDouble();

    return Targets(
      bmi: _round(bmi, 2),
      bmr: _round(bmr, 1),
      tdee: _round(tdee, 1),
      targetCalories: _round(targetCalories, 0),
      targetProteinG: _round(targetProteinG, 1),
      minFatG: _round(minFatG, 1),
      targetCarbsG: _round(targetCarbsG, 1),
    );
  }

  Future<DietPlanDay> generateDailyPlan({
    required DateTime date,
    required UserProfile user,
    required HealthProfile health,
    required List<FoodItem> foods,
    int? seed,
  }) async {
    DietPlanDay? best;
    for (var attempt = 0; attempt < 3; attempt++) {
      final plan = _buildSinglePlan(
        date: date,
        user: user,
        health: health,
        foods: foods,
        seed: seed == null ? null : seed + attempt,
      );
      if (best == null || _validationScore(plan.validation) > _validationScore(best.validation)) {
        best = plan;
      }
      if (plan.validation.passed) {
        return plan;
      }
    }
    return best!;
  }

  DietPlanDay _buildSinglePlan({
    required DateTime date,
    required UserProfile user,
    required HealthProfile health,
    required List<FoodItem> foods,
    int? seed,
  }) {
    final targets = computeTargets(user, health);
    final warnings = <String>[];
    final errors = <String>[];
    if (_needsKidneyProteinCap(health)) {
      warnings.add('Kidney constraint applied: protein target capped to 1.2 g/kg.');
      warnings.add('Consult clinician.');
    }
    if (_hasCondition(health, 'gout')) {
      warnings.add('Hydration reminder for gout-sensitive planning.');
    }

    final filtered = _filterFoods(foods, user, health);
    if (filtered.isEmpty) {
      return DietPlanDay(
        dateIso: date.toIso8601String(),
        targets: targets,
        meals: const <MealPlan>[],
        totals: NutritionTotals.zero(),
        validation: ValidationReport(
          passed: false,
          warnings: warnings,
          errors: <String>['No eligible foods available after constraints.'],
        ),
      );
    }

    final mealDefs = _mealDefinitions(user.mealsPerDay);
    final mealPlans = <MealPlan>[];
    final usageCount = <String, int>{};
    final rng = seed == null ? null : Random(seed);
    var remainingCalories = targets.targetCalories;
    var remainingProtein = targets.targetProteinG;
    var remainingCarbs = targets.targetCarbsG;
    var adjustBudget = 20;

    for (final def in mealDefs) {
      final mealCalories = targets.targetCalories * def.allocation;
      final picks = _pickMealFoods(
        foods: filtered,
        user: user,
        health: health,
        mealName: def.name,
        mealTargetCalories: mealCalories,
        remainingProtein: remainingProtein,
        remainingCarbs: remainingCarbs,
        usageCount: usageCount,
        rng: rng,
      );

      final items = <MealItem>[];
      final mealItemCount = max(1, picks.length);
      for (final pick in picks) {
        items.add(_portionForFood(pick, mealCalories / mealItemCount));
      }

      while (adjustBudget > 0) {
        adjustBudget--;
        final totals = _sumMeal(items);
        final low = totals.calories < mealCalories * 0.9;
        final high = totals.calories > mealCalories * 1.1;
        if (!low && !high) break;
        if (low) {
          _increaseMeal(items, picks);
        } else {
          _decreaseMeal(items);
        }
      }

      final mealTotals = _sumMeal(items);
      remainingCalories -= mealTotals.calories;
      remainingProtein -= mealTotals.proteinG;
      remainingCarbs -= mealTotals.carbsG;

      mealPlans.add(
        MealPlan(
          name: def.name,
          targetCalories: _round(mealCalories, 0),
          items: items,
          totals: mealTotals,
        ),
      );
    }

    if (remainingProtein > 5) {
      final snackIndex =
          mealPlans.indexWhere((m) => m.name.toLowerCase().contains('snack'));
      if (snackIndex >= 0) {
        final snackFood = _bestFood(
          candidates: filtered,
          user: user,
          health: health,
          mealName: mealPlans[snackIndex].name,
          usageCount: usageCount,
          mustBeProtein: true,
          rng: rng,
        );
        if (snackFood != null) {
          final add = _portionForFood(
            snackFood,
            min(220, remainingCalories > 0 ? remainingCalories : 220),
          );
          final merged = <MealItem>[...mealPlans[snackIndex].items, add];
          mealPlans[snackIndex] = MealPlan(
            name: mealPlans[snackIndex].name,
            targetCalories: mealPlans[snackIndex].targetCalories,
            items: merged,
            totals: _sumMeal(merged),
          );
        }
      }
    }

    final dayTotals = _sumDay(mealPlans);
    final validation = _validate(
      meals: mealPlans,
      totals: dayTotals,
      targets: targets,
      user: user,
      health: health,
      warnings: warnings,
      errors: errors,
    );

    return DietPlanDay(
      dateIso: date.toIso8601String(),
      targets: targets,
      meals: mealPlans,
      totals: dayTotals,
      validation: validation,
    );
  }

  List<FoodItem> _filterFoods(
    List<FoodItem> foods,
    UserProfile user,
    HealthProfile health,
  ) {
    final allergies = health.allergies.map((e) => e.toLowerCase()).toSet();
    final intolerances = health.intolerances.map((e) => e.toLowerCase()).toSet();
    final excluded = <String>{
      ...allergies.map((e) => 'contains_$e'),
      ...intolerances.map((e) => 'contains_$e'),
    };
    if (allergies.contains('milk') || intolerances.contains('lactose')) {
      excluded.addAll(<String>['dairy', 'contains_milk']);
    }
    if (allergies.contains('peanut')) {
      excluded.add('contains_peanut');
    }
    if (intolerances.contains('gluten_sensitivity')) {
      excluded.addAll(<String>['contains_wheat', 'gluten']);
    }

    final diabetes = _hasDiabetes(health);
    final bp = _hasHighBp(health);
    final heartRisk = _hasCondition(health, 'heart_risk') || ((health.ldl ?? 0) >= 130);

    return foods.where((food) {
      if (!_matchesDietType(food, user.dietType)) return false;
      if (food.tags.any(excluded.contains)) return false;
      if (diabetes &&
          (food.tags.contains('added_sugar') || food.tags.contains('sugary_drink'))) {
        return false;
      }
      if (bp && food.tags.contains('high_sodium')) return false;
      if (heartRisk && food.tags.contains('trans_fat')) return false;
      return true;
    }).toList();
  }

  List<_MealDefinition> _mealDefinitions(int mealsPerDay) {
    final count = mealsPerDay.clamp(3, 5);
    if (count == 3) {
      return const <_MealDefinition>[
        _MealDefinition(name: 'Breakfast', allocation: 0.30),
        _MealDefinition(name: 'Lunch', allocation: 0.40),
        _MealDefinition(name: 'Dinner', allocation: 0.30),
      ];
    }
    if (count == 4) {
      return const <_MealDefinition>[
        _MealDefinition(name: 'Breakfast', allocation: 0.25),
        _MealDefinition(name: 'Lunch', allocation: 0.35),
        _MealDefinition(name: 'Snack', allocation: 0.25),
        _MealDefinition(name: 'Dinner', allocation: 0.15),
      ];
    }
    return const <_MealDefinition>[
      _MealDefinition(name: 'Breakfast', allocation: 0.22),
      _MealDefinition(name: 'Lunch', allocation: 0.28),
      _MealDefinition(name: 'Snack', allocation: 0.22),
      _MealDefinition(name: 'Dinner', allocation: 0.15),
      _MealDefinition(name: 'Snack2', allocation: 0.13),
    ];
  }

  List<FoodItem> _pickMealFoods({
    required List<FoodItem> foods,
    required UserProfile user,
    required HealthProfile health,
    required String mealName,
    required double mealTargetCalories,
    required double remainingProtein,
    required double remainingCarbs,
    required Map<String, int> usageCount,
    required Random? rng,
  }) {
    final picks = <FoodItem>[];
    final isSnack = mealName.toLowerCase().contains('snack');
    if (!isSnack) {
      final protein = _bestFood(
        candidates: foods.where(_isHighProtein).toList(),
        user: user,
        health: health,
        mealName: mealName,
        usageCount: usageCount,
        mustBeProtein: true,
        rng: rng,
      );
      if (protein != null) picks.add(protein);

      final fiber = _bestFood(
        candidates: foods.where(_isFiberFood).toList(),
        user: user,
        health: health,
        mealName: mealName,
        usageCount: usageCount,
        rng: rng,
      );
      if (fiber != null && picks.every((p) => p.id != fiber.id)) picks.add(fiber);

      if (remainingCarbs > mealTargetCalories / 8) {
        final carb = _bestFood(
          candidates: foods.where(_isCarbFood).toList(),
          user: user,
          health: health,
          mealName: mealName,
          usageCount: usageCount,
          rng: rng,
        );
        if (carb != null && picks.every((p) => p.id != carb.id)) picks.add(carb);
      }
    } else {
      final primary = _bestFood(
        candidates: foods,
        user: user,
        health: health,
        mealName: mealName,
        usageCount: usageCount,
        mustBeProtein: user.goal.toLowerCase() == 'fat_loss' || remainingProtein > 0,
        rng: rng,
      );
      if (primary != null) picks.add(primary);
      if (user.goal.toLowerCase() != 'fat_loss') {
        final extra = _bestFood(
          candidates: foods.where(_isFruitOrNut).toList(),
          user: user,
          health: health,
          mealName: mealName,
          usageCount: usageCount,
          rng: rng,
        );
        if (extra != null && picks.every((p) => p.id != extra.id)) picks.add(extra);
      }
    }

    if (picks.isEmpty) {
      final fallback = _bestFood(
        candidates: foods,
        user: user,
        health: health,
        mealName: mealName,
        usageCount: usageCount,
        rng: rng,
      );
      if (fallback != null) picks.add(fallback);
    }
    for (final p in picks) {
      usageCount[p.id] = (usageCount[p.id] ?? 0) + 1;
    }
    return picks;
  }

  FoodItem? _bestFood({
    required List<FoodItem> candidates,
    required UserProfile user,
    required HealthProfile health,
    required String mealName,
    required Map<String, int> usageCount,
    bool mustBeProtein = false,
    Random? rng,
  }) {
    final available = candidates.where((food) {
      if ((usageCount[food.id] ?? 0) >= 2) return false;
      if (mustBeProtein && !_isHighProtein(food)) return false;
      return true;
    }).toList();
    if (available.isEmpty) return null;

    available.sort((a, b) {
      final cmp = scoreFood(b, user.goal, health, mealName).compareTo(
        scoreFood(a, user.goal, health, mealName),
      );
      if (cmp != 0) return cmp;
      return a.id.compareTo(b.id);
    });

    if (rng == null || available.length == 1) return available.first;
    return available[rng.nextInt(min(3, available.length))];
  }

  double scoreFood(
    FoodItem food,
    String goal,
    HealthProfile health,
    String mealName,
  ) {
    final protein = food.proteinPer100g;
    final carbs = food.carbsPer100g;
    final fat = food.fatPer100g;
    final calories = food.caloriesPer100g;
    final fiber = food.fiberPer100g ?? 0;
    final tags = food.tags;

    var score = 0.0;
    switch (goal.toLowerCase()) {
      case 'fat_loss':
        score += protein * 2 + fiber * 1.5 - calories * 0.02 - fat * 0.3;
        break;
      case 'muscle_gain':
        score += protein * 1.5 + carbs * 0.7 + calories * 0.01;
        break;
      default:
        score += protein * 1.2 + fiber * 1.0 - calories * 0.01;
    }

    if (_hasDiabetes(health)) {
      score += fiber * 0.8;
      if (tags.contains('high_sugar')) score -= 25;
      if (tags.contains('low_gi')) score += 8;
      if (tags.contains('high_fiber')) score += 4;
    }
    if (_hasHighBp(health) && tags.contains('high_sodium')) {
      score -= 18;
    }
    if (_hasCondition(health, 'heart_risk') || ((health.ldl ?? 0) >= 130)) {
      if (tags.contains('trans_fat')) score -= 25;
      if (tags.contains('deep_fried')) score -= 15;
      if (tags.contains('high_fiber')) score += 4;
      if (tags.contains('oats')) score += 6;
    }
    if (_hasCondition(health, 'gout') && tags.contains('high_purine')) {
      score -= 14;
    }
    if (_hasCondition(health, 'gerd')) {
      if (mealName.toLowerCase() == 'dinner') score -= fat * 0.4;
      if (tags.contains('spicy')) score -= 10;
      if (tags.contains('caffeine')) score -= 8;
      if (tags.contains('very_fatty')) score -= 10;
    }
    return score;
  }

  MealItem _portionForFood(FoodItem food, double desiredCalories) {
    final cal = max(food.caloriesPer100g, 1);
    var grams = (desiredCalories / cal) * 100;
    grams = grams.clamp(food.minServingG, food.maxServingG).toDouble();
    return _itemFromFoodAndGrams(food, grams);
  }

  MealItem _itemFromFoodAndGrams(FoodItem food, double grams) {
    final ratio = grams / 100;
    return MealItem(
      foodId: food.id,
      name: food.name,
      grams: _round(grams, 1),
      calories: _round(food.caloriesPer100g * ratio, 1),
      proteinG: _round(food.proteinPer100g * ratio, 1),
      carbsG: _round(food.carbsPer100g * ratio, 1),
      fatG: _round(food.fatPer100g * ratio, 1),
      fiberG: _round((food.fiberPer100g ?? 0) * ratio, 1),
      category: food.category,
      tags: food.tags,
      imageUrl: food.imageUrl,
    );
  }

  void _increaseMeal(List<MealItem> items, List<FoodItem> picks) {
    if (items.isEmpty || picks.isEmpty) return;
    var idx = 0;
    for (var i = 1; i < items.length; i++) {
      if (items[i].carbsG + items[i].fatG > items[idx].carbsG + items[idx].fatG) {
        idx = i;
      }
    }
    final item = items[idx];
    final food = picks.firstWhere((f) => f.id == item.foodId, orElse: () => picks.first);
    items[idx] = _itemFromFoodAndGrams(food, min(food.maxServingG, item.grams * 1.15));
  }

  void _decreaseMeal(List<MealItem> items) {
    if (items.isEmpty) return;
    var idx = 0;
    for (var i = 1; i < items.length; i++) {
      if (items[i].carbsG + items[i].fatG > items[idx].carbsG + items[idx].fatG) {
        idx = i;
      }
    }
    final current = items[idx];
    final nextGrams = max(20, current.grams * 0.88).toDouble();
    final ratio = nextGrams / current.grams;
    items[idx] = MealItem(
      foodId: current.foodId,
      name: current.name,
      grams: _round(nextGrams, 1),
      calories: _round(current.calories * ratio, 1),
      proteinG: _round(current.proteinG * ratio, 1),
      carbsG: _round(current.carbsG * ratio, 1),
      fatG: _round(current.fatG * ratio, 1),
      fiberG: _round((current.fiberG ?? 0) * ratio, 1),
      category: current.category,
      tags: current.tags,
      imageUrl: current.imageUrl,
    );
  }

  NutritionTotals _sumMeal(List<MealItem> items) {
    var total = NutritionTotals.zero();
    for (final i in items) {
      total = total.plus(
        NutritionTotals(
          calories: i.calories,
          proteinG: i.proteinG,
          carbsG: i.carbsG,
          fatG: i.fatG,
          fiberG: i.fiberG ?? 0,
        ),
      );
    }
    return total.copyWith(
      calories: _round(total.calories, 1),
      proteinG: _round(total.proteinG, 1),
      carbsG: _round(total.carbsG, 1),
      fatG: _round(total.fatG, 1),
      fiberG: _round(total.fiberG ?? 0, 1),
    );
  }

  NutritionTotals _sumDay(List<MealPlan> meals) {
    var total = NutritionTotals.zero();
    for (final meal in meals) {
      total = total.plus(meal.totals);
    }
    return total.copyWith(
      calories: _round(total.calories, 1),
      proteinG: _round(total.proteinG, 1),
      carbsG: _round(total.carbsG, 1),
      fatG: _round(total.fatG, 1),
      fiberG: _round(total.fiberG ?? 0, 1),
    );
  }

  ValidationReport _validate({
    required List<MealPlan> meals,
    required NutritionTotals totals,
    required Targets targets,
    required UserProfile user,
    required HealthProfile health,
    required List<String> warnings,
    required List<String> errors,
  }) {
    final lowCalories = targets.targetCalories * 0.95;
    final highCalories = targets.targetCalories * 1.05;
    if (totals.calories < lowCalories || totals.calories > highCalories) {
      errors.add('Total calories are outside the +/-5% target range.');
    }
    if (totals.proteinG + 0.1 < targets.targetProteinG) {
      errors.add('Could not reach protein target with available foods.');
    }
    if (totals.fatG + 0.1 < targets.minFatG) {
      errors.add('Could not reach minimum fat target with available foods.');
    }

    if (_hasDiabetes(health)) {
      final dayCarbs = max(1, totals.carbsG);
      for (final meal in meals) {
        if (meal.totals.carbsG > dayCarbs * 0.45) {
          errors.add('Diabetes carb split failed: ${meal.name} exceeds 45% of daily carbs.');
        }
        final sugarByName = meal.items.any((i) => i.name.toLowerCase().contains('sugar'));
        if (sugarByName) {
          warnings.add('Potential added-sugar item detected in ${meal.name}.');
        }
      }
    }

    if (_hasCondition(health, 'gerd')) {
      final dinner = meals.where((m) => m.name.toLowerCase() == 'dinner');
      if (dinner.isNotEmpty && dinner.first.totals.fatG > totals.fatG * 0.4) {
        warnings.add('Dinner fat is high for GERD-sensitive planning.');
      }
    }
    if (user.mealsPerDay < 3 || user.mealsPerDay > 5) {
      warnings.add('Meal count was clamped to supported range (3-5).');
    }
    return ValidationReport(
      passed: errors.isEmpty,
      warnings: warnings,
      errors: errors,
    );
  }

  int _validationScore(ValidationReport report) {
    if (report.passed) return 1000 - report.warnings.length;
    return -(report.errors.length * 10 + report.warnings.length);
  }

  bool _matchesDietType(FoodItem food, String dietType) {
    final type = dietType.toLowerCase();
    if (type == 'nonveg') return true;
    if (type == 'vegan') return food.tags.contains('vegan');
    if (type == 'veg') return food.tags.contains('veg') || food.tags.contains('vegan');
    if (type == 'eggetarian') {
      return food.tags.contains('veg') ||
          food.tags.contains('vegan') ||
          food.tags.contains('egg');
    }
    return true;
  }

  bool _isHighProtein(FoodItem food) =>
      food.tags.contains('high_protein') || food.proteinPer100g >= 12;

  bool _isFiberFood(FoodItem food) {
    final category = food.category.toLowerCase();
    return food.tags.contains('high_fiber') ||
        category.contains('veg') ||
        category.contains('vegetable') ||
        category.contains('fruit') ||
        (food.fiberPer100g ?? 0) >= 3;
  }

  bool _isCarbFood(FoodItem food) {
    final category = food.category.toLowerCase();
    return category.contains('carb') ||
        category.contains('grain') ||
        food.carbsPer100g >= 20;
  }

  bool _isFruitOrNut(FoodItem food) {
    final category = food.category.toLowerCase();
    return category.contains('fruit') ||
        category.contains('nut') ||
        food.tags.contains('fruit') ||
        food.tags.contains('nuts');
  }

  bool _hasDiabetes(HealthProfile health) {
    const statuses = <String>{'prediabetes', 'type1', 'type2', 'gestational'};
    return statuses.contains(health.diabetesStatus.toLowerCase());
  }

  bool _hasHighBp(HealthProfile health) {
    const statuses = <String>{'elevated', 'stage1', 'stage2'};
    return statuses.contains(health.bpStatus.toLowerCase());
  }

  bool _needsKidneyProteinCap(HealthProfile health) {
    return _hasCondition(health, 'kidney_disease') || ((health.egfr ?? 999) < 60);
  }

  bool _hasCondition(HealthProfile health, String key) {
    return health.conditions.map((e) => e.toLowerCase()).contains(key.toLowerCase());
  }

  double _activityMultiplier(String activityLevel) {
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        return 1.2;
      case 'light':
        return 1.375;
      case 'moderate':
        return 1.55;
      case 'active':
        return 1.725;
      case 'very_active':
        return 1.9;
      default:
        return 1.55;
    }
  }
}

class DietRecommendationService {
  final FirebaseFirestore _db;
  final FoodRepository _foodRepository;
  final DietPlanRepository _planRepository;
  final DietEngine _engine;

  DietRecommendationService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance,
        _foodRepository = FoodRepository(db: db),
        _planRepository = DietPlanRepository(db: db),
        _engine = DietEngine();

  Future<DietPlanDay?> fetchDietPlan({required String userId}) async {
    final plan = await _planRepository.fetchLatestPlan(userId);
    if (plan == null) return null;
    final normalized = _ensureLifecycle(plan);
    if (normalized.isExpired) {
      await deleteDietPlan(userId: userId);
      return null;
    }
    return _enrichPlanVisuals(normalized);
  }

  Future<void> saveDietPlan({
    required String userId,
    required DietPlanDay plan,
  }) {
    return _planRepository.savePlan(userId, _ensureLifecycle(plan));
  }

  Future<void> deleteDietPlan({required String userId}) {
    return _planRepository.deletePlan(userId, DateTime.now());
  }

  Future<DietPlanDay> generateDietPlan({
    required String userId,
    required String dietType,
    required HealthProfile healthProfile,
    int mealsPerDay = 4,
    int? seed,
  }) async {
    final surveyDoc = await _db.collection('surveys').doc(userId).get();
    final profileDoc = await _db
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('current')
        .get();
    final surveyData = surveyDoc.data() ?? <String, dynamic>{};
    final profileData = profileDoc.data() ?? <String, dynamic>{};

    final user = _buildUserProfile(
      uid: userId,
      survey: surveyData,
      profile: profileData,
      mealsPerDay: mealsPerDay,
      dietType: dietType,
    );

    await _db.collection('users').doc(userId).collection('profile').doc('current').set(
          user.toMap(),
          SetOptions(merge: true),
        );
    await _db.collection('users').doc(userId).collection('healthProfile').doc('current').set(
          healthProfile.toMap(),
          SetOptions(merge: true),
        );

    final foods = await _foodRepository.fetchFoods();
    final generated = await _engine.generateDailyPlan(
      date: DateTime.now(),
      user: user,
      health: healthProfile,
      foods: foods,
      seed: seed,
    );
    return _ensureLifecycle(generated);
  }

  UserProfile _buildUserProfile({
    required String uid,
    required Map<String, dynamic> survey,
    required Map<String, dynamic> profile,
    required int mealsPerDay,
    required String dietType,
  }) {
    final gender = ((profile['gender'] ?? survey['gender']) ?? '').toString().toLowerCase();
    final normalizedGender = gender.contains('male')
        ? 'male'
        : gender.contains('female')
            ? 'female'
            : null;

    return UserProfile(
      uid: uid,
      age: _toInt(profile['age'] ?? survey['age'], fallback: 25),
      gender: normalizedGender,
      heightCm: _toDouble(
        profile['heightCm'] ?? profile['height'] ?? survey['height'],
        fallback: 170,
      ),
      weightKg: _toDouble(
        profile['weightKg'] ?? profile['weight'] ?? survey['weight'],
        fallback: 70,
      ),
      activityLevel: _mapActivity((profile['activityLevel'] ?? survey['activityLevel']).toString()),
      goal: _mapGoal((profile['goal'] ?? survey['goal']).toString()),
      mealsPerDay: mealsPerDay.clamp(3, 5),
      dietType: dietType.toLowerCase(),
    );
  }

  String _mapActivity(String raw) {
    final v = raw.toLowerCase();
    if (v.contains('sedentary')) return 'sedentary';
    if (v.contains('light') || v.contains('beginner')) return 'light';
    if (v.contains('moderate') || v.contains('intermediate')) return 'moderate';
    if (v.contains('active')) return 'active';
    if (v.contains('very') || v.contains('advanced')) return 'very_active';
    return 'moderate';
  }

  String _mapGoal(String raw) {
    final v = raw.toLowerCase();
    if (v.contains('loss')) return 'fat_loss';
    if (v.contains('gain') || v.contains('muscle') || v.contains('build')) {
      return 'muscle_gain';
    }
    return 'maintain';
  }

  DietPlanDay _ensureLifecycle(DietPlanDay plan) {
    final now = DateTime.now();
    final generatedAt = plan.generatedAt ?? DateTime.tryParse(plan.dateIso) ?? now;
    final expiresAt = plan.expiresAt ?? generatedAt.add(const Duration(days: 30));
    return plan.copyWith(
      generatedAtIso: generatedAt.toIso8601String(),
      expiresAtIso: expiresAt.toIso8601String(),
    );
  }

  Future<DietPlanDay> _enrichPlanVisuals(DietPlanDay plan) async {
    final hasMissingVisuals = plan.meals.any(
      (m) => m.items.any((i) => i.imageUrl == null || i.imageUrl!.isEmpty),
    );
    if (!hasMissingVisuals) {
      return plan;
    }

    final foods = await _foodRepository.fetchFoods();
    final byId = <String, FoodItem>{for (final f in foods) f.id: f};
    final updatedMeals = plan.meals.map((meal) {
      final updatedItems = meal.items.map((item) {
        final food = byId[item.foodId];
        if (food == null) return item;
        return MealItem(
          foodId: item.foodId,
          name: item.name,
          grams: item.grams,
          calories: item.calories,
          proteinG: item.proteinG,
          carbsG: item.carbsG,
          fatG: item.fatG,
          fiberG: item.fiberG,
          category: item.category.isEmpty ? food.category : item.category,
          tags: item.tags.isEmpty ? food.tags : item.tags,
          imageUrl: (item.imageUrl == null || item.imageUrl!.isEmpty)
              ? food.imageUrl
              : item.imageUrl,
        );
      }).toList();
      return MealPlan(
        name: meal.name,
        targetCalories: meal.targetCalories,
        items: updatedItems,
        totals: meal.totals,
      );
    }).toList();

    return plan.copyWith(meals: updatedMeals);
  }
}

class _MealDefinition {
  final String name;
  final double allocation;

  const _MealDefinition({
    required this.name,
    required this.allocation,
  });
}

double _toDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}

double? _toNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

int? _toNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

List<String> _toStringList(dynamic value) {
  if (value is List) {
    return value.map((e) => e.toString().toLowerCase()).toList();
  }
  return <String>[];
}

List<String> _normalizeTags(Map<String, dynamic> map) {
  final tags = _toStringList(map['tags']).toSet();
  final veg = map['veg'] == true;
  if (veg) tags.add('veg');
  return tags.toList();
}

double _round(double value, int decimals) {
  final factor = pow(10, decimals).toDouble();
  return (value * factor).roundToDouble() / factor;
}

void dietEngineSampleMain() {
  final engine = DietEngine();
  final user = UserProfile(
    uid: 'sample-user',
    age: 28,
    gender: 'female',
    heightCm: 165,
    weightKg: 65,
    activityLevel: 'moderate',
    goal: 'fat_loss',
    mealsPerDay: 4,
    dietType: 'veg',
  );
  final health = HealthProfile.empty();
  final foods = <FoodItem>[
    const FoodItem(
      id: 'oats',
      name: 'Oats',
      caloriesPer100g: 389,
      proteinPer100g: 17,
      carbsPer100g: 66,
      fatPer100g: 7,
      fiberPer100g: 10,
      category: 'carb',
      tags: <String>['veg', 'vegan', 'high_fiber', 'low_gi', 'oats'],
      minServingG: 30,
      maxServingG: 90,
    ),
    const FoodItem(
      id: 'milk',
      name: 'Milk',
      caloriesPer100g: 60,
      proteinPer100g: 3.2,
      carbsPer100g: 5,
      fatPer100g: 3.4,
      fiberPer100g: 0,
      category: 'protein',
      tags: <String>['veg', 'dairy'],
      minServingG: 100,
      maxServingG: 300,
    ),
    const FoodItem(
      id: 'banana',
      name: 'Banana',
      caloriesPer100g: 89,
      proteinPer100g: 1.1,
      carbsPer100g: 23,
      fatPer100g: 0.3,
      fiberPer100g: 2.6,
      category: 'fruit',
      tags: <String>['veg', 'vegan', 'fruit'],
      minServingG: 80,
      maxServingG: 180,
    ),
    const FoodItem(
      id: 'dal',
      name: 'Dal',
      caloriesPer100g: 116,
      proteinPer100g: 9,
      carbsPer100g: 20,
      fatPer100g: 0.4,
      fiberPer100g: 8,
      category: 'protein',
      tags: <String>['veg', 'vegan', 'high_fiber', 'low_gi'],
      minServingG: 100,
      maxServingG: 300,
    ),
    const FoodItem(
      id: 'tofu',
      name: 'Tofu',
      caloriesPer100g: 144,
      proteinPer100g: 15,
      carbsPer100g: 3.5,
      fatPer100g: 8.7,
      fiberPer100g: 1.2,
      category: 'protein',
      tags: <String>['veg', 'vegan', 'high_protein'],
      minServingG: 80,
      maxServingG: 220,
    ),
    const FoodItem(
      id: 'rice',
      name: 'Rice',
      caloriesPer100g: 130,
      proteinPer100g: 2.7,
      carbsPer100g: 28,
      fatPer100g: 0.3,
      fiberPer100g: 0.4,
      category: 'carb',
      tags: <String>['veg', 'vegan'],
      minServingG: 100,
      maxServingG: 280,
    ),
    const FoodItem(
      id: 'veg_curry',
      name: 'Veg Curry',
      caloriesPer100g: 95,
      proteinPer100g: 3,
      carbsPer100g: 10,
      fatPer100g: 5,
      fiberPer100g: 4,
      category: 'veg',
      tags: <String>['veg', 'vegan', 'high_fiber'],
      minServingG: 120,
      maxServingG: 260,
    ),
    const FoodItem(
      id: 'curd',
      name: 'Curd',
      caloriesPer100g: 98,
      proteinPer100g: 11,
      carbsPer100g: 4,
      fatPer100g: 4,
      fiberPer100g: 0,
      category: 'protein',
      tags: <String>['veg', 'high_protein', 'dairy'],
      minServingG: 80,
      maxServingG: 220,
    ),
    const FoodItem(
      id: 'paneer',
      name: 'Paneer',
      caloriesPer100g: 265,
      proteinPer100g: 18,
      carbsPer100g: 2,
      fatPer100g: 21,
      fiberPer100g: 0,
      category: 'protein',
      tags: <String>['veg', 'high_protein', 'dairy'],
      minServingG: 60,
      maxServingG: 180,
    ),
    const FoodItem(
      id: 'apple',
      name: 'Apple',
      caloriesPer100g: 52,
      proteinPer100g: 0.3,
      carbsPer100g: 14,
      fatPer100g: 0.2,
      fiberPer100g: 2.4,
      category: 'fruit',
      tags: <String>['veg', 'vegan', 'fruit'],
      minServingG: 80,
      maxServingG: 200,
    ),
    const FoodItem(
      id: 'nuts',
      name: 'Mixed Nuts',
      caloriesPer100g: 607,
      proteinPer100g: 20,
      carbsPer100g: 22,
      fatPer100g: 54,
      fiberPer100g: 7,
      category: 'fat',
      tags: <String>['veg', 'vegan', 'high_protein', 'nuts'],
      minServingG: 15,
      maxServingG: 45,
    ),
    const FoodItem(
      id: 'roti',
      name: 'Roti',
      caloriesPer100g: 297,
      proteinPer100g: 9.6,
      carbsPer100g: 58,
      fatPer100g: 3.7,
      fiberPer100g: 10,
      category: 'carb',
      tags: <String>['veg', 'vegan', 'high_fiber'],
      minServingG: 40,
      maxServingG: 140,
    ),
    const FoodItem(
      id: 'chickpeas',
      name: 'Chickpeas',
      caloriesPer100g: 164,
      proteinPer100g: 9,
      carbsPer100g: 27,
      fatPer100g: 2.6,
      fiberPer100g: 7.6,
      category: 'protein',
      tags: <String>['veg', 'vegan', 'high_fiber', 'low_gi'],
      minServingG: 70,
      maxServingG: 220,
    ),
  ];

  engine
      .generateDailyPlan(
        date: DateTime.now(),
        user: user,
        health: health,
        foods: foods,
      )
      .then((plan) {
    // ignore: avoid_print
    print('Targets: ${plan.targets.toMap()}');
    for (final meal in plan.meals) {
      // ignore: avoid_print
      print('\n${meal.name}:');
      for (final item in meal.items) {
        // ignore: avoid_print
        print('- ${item.name}: ${item.grams}g');
      }
    }
    // ignore: avoid_print
    print('\nDay totals: ${plan.totals.toMap()}');
    // ignore: avoid_print
    print('Validation: ${plan.validation.toMap()}');
  });
}
