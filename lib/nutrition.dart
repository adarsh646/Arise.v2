import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'services/diet_recomendation_service.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  bool _isLoading = false;
  String? _errorMessage;
  DietPlanDay? _dietPlan;
  final DietRecommendationService _dietService = DietRecommendationService();

  @override
  void initState() {
    super.initState();
    _loadStoredPlan();
  }

  Future<void> _loadStoredPlan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final stored = await _dietService.fetchDietPlan(userId: user.uid);
      if (!mounted) return;
      setState(() => _dietPlan = stored);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Failed to load saved plan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generateDietPlan() async {
    final input = await showDialog<_DietInput>(
      context: context,
      builder: (_) => const _DietPreferenceDialog(),
    );
    if (input == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Please log in to generate a diet plan.');
      }
      final plan = await _dietService.generateDietPlan(
        userId: user.uid,
        dietType: input.dietType,
        mealsPerDay: input.mealsPerDay,
        healthProfile: input.healthProfile,
      );
      if (!mounted) return;
      setState(() => _dietPlan = plan);
      await _dietService.saveDietPlan(userId: user.uid, plan: plan);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDietPlan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _dietService.deleteDietPlan(userId: user.uid);
      if (!mounted) return;
      setState(() => _dietPlan = null);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Failed to delete plan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_dietPlan == null) ...[
              const Icon(Icons.restaurant_menu, size: 64, color: Colors.green),
              const SizedBox(height: 12),
            ],
            const Text(
              'Nutrition',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (_dietPlan != null) ...[
              const SizedBox(height: 10),
              _PlanCountdownBanner(plan: _dietPlan!),
            ],
            const SizedBox(height: 6),
            const Text(
              'Generate a personalized diet chart based on your profile and health conditions.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _generateDietPlan,
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(
                        _isLoading
                            ? 'Generating...'
                            : _dietPlan == null
                                ? 'Generate Diet Plan'
                                : 'Regenerate Diet Plan',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 238, 255, 65),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                ),
                if (_dietPlan != null) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _deleteDietPlan,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ),
                ],
              ],
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            if (_dietPlan != null) ...[
              const SizedBox(height: 20),
              _PlanSummaryCard(plan: _dietPlan!),
              const SizedBox(height: 12),
              ..._dietPlan!.meals.map(
                (meal) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MealCard(meal: meal),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard({required this.plan});
  final DietPlanDay plan;

  @override
  Widget build(BuildContext context) {
    final t = plan.targets;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Plan Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _MacroRow(label: 'BMI', value: '${t.bmi}'),
            _MacroRow(label: 'Target Calories', value: '${t.targetCalories} kcal'),
            _MacroRow(label: 'Protein Target', value: '${t.targetProteinG} g'),
            _MacroRow(label: 'Min Fat', value: '${t.minFatG} g'),
            _MacroRow(label: 'Carbs Target', value: '${t.targetCarbsG} g'),
            const SizedBox(height: 8),
            const Text(
              'Validation',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(plan.validation.passed ? 'Passed' : 'Needs review'),
            ...plan.validation.warnings.map((w) => Text('Warning: $w')),
            ...plan.validation.errors.map(
              (e) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCountdownBanner extends StatelessWidget {
  const _PlanCountdownBanner({required this.plan});

  final DietPlanDay plan;

  @override
  Widget build(BuildContext context) {
    final expiresAt = plan.expiresAt;
    if (expiresAt == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final remaining = expiresAt.difference(now);
    final daysLeft = remaining.isNegative
        ? 0
        : (remaining.inHours / 24).ceil();
    final expDate =
        '${expiresAt.year}-${expiresAt.month.toString().padLeft(2, '0')}-${expiresAt.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: daysLeft <= 3 ? Colors.orange.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: daysLeft <= 3 ? Colors.orange.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            daysLeft <= 3 ? Icons.warning_amber_rounded : Icons.timer_outlined,
            color: daysLeft <= 3 ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              daysLeft > 0
                  ? 'Plan valid for $daysLeft day(s). Expires on $expDate.'
                  : 'Plan expired. Generate a new plan with updated inputs.',
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});
  final MealPlan meal;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meal.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Target: ${meal.targetCalories} kcal'),
            const SizedBox(height: 8),
            ...meal.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.restaurant_menu, color: Colors.green),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.category} | ${item.tags.take(3).join(', ')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.grams} g | ${item.calories} kcal | P ${item.proteinG}g C ${item.carbsG}g F ${item.fatG}g',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 16),
            _MacroRow(label: 'Meal Calories', value: '${meal.totals.calories} kcal'),
            _MacroRow(label: 'Protein', value: '${meal.totals.proteinG} g'),
            _MacroRow(label: 'Carbs', value: '${meal.totals.carbsG} g'),
            _MacroRow(label: 'Fat', value: '${meal.totals.fatG} g'),
            _MacroRow(label: 'Fiber', value: '${meal.totals.fiberG ?? 0} g'),
          ],
        ),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}

class _DietInput {
  final String dietType;
  final int mealsPerDay;
  final HealthProfile healthProfile;

  const _DietInput({
    required this.dietType,
    required this.mealsPerDay,
    required this.healthProfile,
  });
}

class _DietPreferenceDialog extends StatefulWidget {
  const _DietPreferenceDialog();

  @override
  State<_DietPreferenceDialog> createState() => _DietPreferenceDialogState();
}

class _DietPreferenceDialogState extends State<_DietPreferenceDialog> {
  String _dietType = 'veg';
  int _mealsPerDay = 4;
  String _diabetes = 'none';
  String _bp = 'none';
  bool _pregnantOrBreastfeeding = false;
  final Set<String> _conditions = <String>{};
  final Set<String> _allergies = <String>{};
  final Set<String> _intolerances = <String>{};
  final _medicationsController = TextEditingController();

  @override
  void dispose() {
    _medicationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Diet Preference & Health'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _dietType,
                decoration: const InputDecoration(labelText: 'Diet Type'),
                items: const ['veg', 'nonveg', 'vegan', 'eggetarian']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _dietType = v ?? 'veg'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _mealsPerDay,
                decoration: const InputDecoration(labelText: 'Meals Per Day'),
                items: const [3, 4, 5]
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                    .toList(),
                onChanged: (v) => setState(() => _mealsPerDay = v ?? 4),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _diabetes,
                decoration: const InputDecoration(labelText: 'Diabetes Status'),
                items: const ['none', 'prediabetes', 'type1', 'type2', 'gestational', 'unknown']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _diabetes = v ?? 'none'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _bp,
                decoration: const InputDecoration(labelText: 'BP Status'),
                items: const ['none', 'elevated', 'stage1', 'stage2', 'unknown']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _bp = v ?? 'none'),
              ),
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Pregnant or Breastfeeding'),
                value: _pregnantOrBreastfeeding,
                onChanged: (v) => setState(() => _pregnantOrBreastfeeding = v ?? false),
              ),
              const SizedBox(height: 8),
              _buildChips(
                'Conditions',
                const [
                  'pcos',
                  'thyroid',
                  'kidney_disease',
                  'gerd',
                  'gout',
                  'heart_risk',
                  'anemia',
                ],
                _conditions,
              ),
              const SizedBox(height: 8),
              _buildChips(
                'Allergies',
                const [
                  'peanut',
                  'milk',
                  'egg',
                  'fish',
                  'shellfish',
                  'wheat',
                  'soy',
                  'sesame',
                ],
                _allergies,
              ),
              const SizedBox(height: 8),
              _buildChips(
                'Intolerances',
                const ['lactose', 'gluten_sensitivity', 'ibs'],
                _intolerances,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _medicationsController,
                decoration: const InputDecoration(
                  labelText: 'Medications (comma separated)',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              _DietInput(
                dietType: _dietType,
                mealsPerDay: _mealsPerDay,
                healthProfile: HealthProfile(
                  diabetesStatus: _diabetes,
                  bpStatus: _bp,
                  conditions: _conditions.toList(),
                  allergies: _allergies.toList(),
                  intolerances: _intolerances.toList(),
                  pregnantOrBreastfeeding: _pregnantOrBreastfeeding,
                  fastingSugarMgDl: null,
                  hba1cPercent: null,
                  bpSystolic: null,
                  bpDiastolic: null,
                  ldl: null,
                  hdl: null,
                  triglycerides: null,
                  egfr: null,
                  creatinine: null,
                  medications: _medicationsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                ),
              ),
            );
          },
          child: const Text('Generate'),
        ),
      ],
    );
  }

  Widget _buildChips(
    String title,
    List<String> values,
    Set<String> selected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: values.map((v) {
            final active = selected.contains(v);
            return FilterChip(
              label: Text(v),
              selected: active,
              onSelected: (s) {
                setState(() {
                  if (s) {
                    selected.add(v);
                  } else {
                    selected.remove(v);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
