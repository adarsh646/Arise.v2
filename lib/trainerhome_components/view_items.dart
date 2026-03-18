import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewItemsPage extends StatefulWidget {
  const ViewItemsPage({super.key});

  @override
  State<ViewItemsPage> createState() => _ViewItemsPageState();
}

class _ViewItemsPageState extends State<ViewItemsPage> {
  String _formatMacro(Map<String, dynamic> data, String key) {
    final value = data[key] ?? 0;
    final unit = (data['${key}Unit'] ?? 'g').toString();
    return '$value$unit';
  }

  Future<void> _deleteItem(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this food item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('food_item')
            .doc(docId)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting item: $e')),
          );
        }
      }
    }
  }

  void _editItem(String docId, Map<String, dynamic> data) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: data['name']?.toString());
    final categoryController =
        TextEditingController(text: data['category']?.toString());
    final caloriesController =
        TextEditingController(text: data['calories']?.toString());
    final proteinController =
        TextEditingController(text: data['protein']?.toString());
    final carbsController =
        TextEditingController(text: data['carbs']?.toString());
    final fatController = TextEditingController(text: data['fat']?.toString());
    final fiberController =
        TextEditingController(text: data['fiber']?.toString());
    final alternatesController =
        TextEditingController(text: (data['alternates'] as List?)?.join(', '));
    bool isVeg = data['veg'] == true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Food Item'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  SwitchListTile(
                    title: const Text('Vegetarian'),
                    value: isVeg,
                    onChanged: (v) => setDialogState(() => isVeg = v),
                  ),
                  TextFormField(
                    controller: caloriesController,
                    decoration: const InputDecoration(labelText: 'Calories'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: proteinController,
                    decoration:
                        const InputDecoration(labelText: 'Protein', suffixText: 'g'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: carbsController,
                    decoration:
                        const InputDecoration(labelText: 'Carbs', suffixText: 'g'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: fatController,
                    decoration:
                        const InputDecoration(labelText: 'Fat', suffixText: 'g'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: fiberController,
                    decoration:
                        const InputDecoration(labelText: 'Fiber', suffixText: 'g'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: alternatesController,
                    decoration: const InputDecoration(
                        labelText: 'Alternates (comma separated)'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final alternates = alternatesController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  await FirebaseFirestore.instance
                      .collection('food_item')
                      .doc(docId)
                      .update({
                    'name': nameController.text.trim(),
                    'category': categoryController.text.trim().toLowerCase(),
                    'veg': isVeg,
                    'calories': double.tryParse(caloriesController.text) ?? 0,
                    'protein': double.tryParse(proteinController.text) ?? 0,
                    'carbs': double.tryParse(carbsController.text) ?? 0,
                    'fat': double.tryParse(fatController.text) ?? 0,
                    'fiber': double.tryParse(fiberController.text) ?? 0,
                    'proteinUnit': 'g',
                    'carbsUnit': 'g',
                    'fatUnit': 'g',
                    'fiberUnit': 'g',
                    'alternates': alternates,
                  });
                  if (mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Items'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 238, 255, 65),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('food_item')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Failed to load items.'));
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(child: Text('No food items found.'));
            }
            return ListView.separated(
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final docId = doc.id;
                void showDetails() {
                  final alternates = (data['alternates'] as List?)
                          ?.map((item) => item.toString())
                          .toList() ??
                      [];
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: Text(data['name']?.toString() ?? 'Food Details'),
                        content: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (data['imageUrl'] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      height: 160,
                                      width: double.infinity,
                                      child: Image.network(
                                        data['imageUrl'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                if (data['imageUrl'] != null)
                                  const SizedBox(height: 12),
                                _DetailRow(
                                  label: 'Category',
                                  value: data['category']?.toString() ?? '-',
                                ),
                                _DetailRow(
                                  label: 'Vegetarian',
                                  value: (data['veg'] == true) ? 'Yes' : 'No',
                                ),
                                _DetailRow(
                                  label: 'Calories',
                                  value: '${data['calories'] ?? 0}',
                                ),
                                _DetailRow(
                                  label: 'Protein',
                                  value: _formatMacro(data, 'protein'),
                                ),
                                _DetailRow(
                                  label: 'Carbs',
                                  value: _formatMacro(data, 'carbs'),
                                ),
                                _DetailRow(
                                  label: 'Fat',
                                  value: _formatMacro(data, 'fat'),
                                ),
                                _DetailRow(
                                  label: 'Fiber',
                                  value: _formatMacro(data, 'fiber'),
                                ),
                                _DetailRow(
                                  label: 'Alternates',
                                  value: alternates.isEmpty
                                      ? '-'
                                      : alternates.join(', '),
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              _editItem(docId, data);
                            },
                            child: const Text('Edit'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              _deleteItem(docId);
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                }

                return Card(
                  child: InkWell(
                    onTap: showDetails,
                    child: ListTile(
                      leading: data['imageUrl'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                data['imageUrl'],
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.restaurant_menu),
                      title: Text(data['name']?.toString() ?? 'Unnamed'),
                      subtitle: Text(
                        '${data['category'] ?? 'category'} - '
                        '${(data['calories'] ?? 0).toString()} cal',
                      ),
                      trailing: Icon(
                        (data['veg'] == true) ? Icons.eco : Icons.set_meal,
                        color:
                            (data['veg'] == true) ? Colors.green : Colors.brown,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
