import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';
import 'view_items.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

enum _DietView { home, addItem }

class _DietPageState extends State<DietPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _alternatesController = TextEditingController();

  _DietView _view = _DietView.home;
  bool _isVeg = false;
  bool _isSaving = false;
  XFile? _imageFile;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _alternatesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = picked);
    }
  }

  String? _requiredTextValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  bool _hasAtMostFiveDigits(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length <= 5;
  }

  String? _numberValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    if (!_hasAtMostFiveDigits(value)) {
      return '$label must not exceed 5 digits';
    }
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return '$label must be a number';
    }
    if (parsed < 0) {
      return '$label must be positive';
    }
    return null;
  }

  String? _alternatesValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Alternates are required';
    }
    final items = value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (items.isEmpty) {
      return 'Alternates are required';
    }
    if (items.length > 5) {
      return 'Alternates must not exceed 5 items';
    }
    return null;
  }

  List<String> _parseAlternates(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .take(5)
        .toList();
  }

  Future<String?> _uploadToCloudinary(XFile imageFile) async {
    try {
      final cloudinary = CloudinaryService.fromEnvironment();
      final result = await cloudinary.uploadFile(
        File(imageFile.path),
        resourceType: 'image',
        folderOverride: 'food_items',
      );
      return result.secureUrl;
    } catch (e) {
      throw Exception('Cloudinary upload failed: $e');
    }
  }

  Future<void> _saveFoodItem() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final foodRef =
          FirebaseFirestore.instance.collection('food_item').doc();

      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadToCloudinary(_imageFile!);
      }

      await foodRef.set({
        'name': _nameController.text.trim(),
        'category': _categoryController.text.trim().toLowerCase(),
        'veg': _isVeg,
        'calories': double.parse(_caloriesController.text.trim()),
        'protein': double.parse(_proteinController.text.trim()),
        'carbs': double.parse(_carbsController.text.trim()),
        'fat': double.parse(_fatController.text.trim()),
        'fiber': double.parse(_fiberController.text.trim()),
        'proteinUnit': 'g',
        'carbsUnit': 'g',
        'fatUnit': 'g',
        'fiberUnit': 'g',
        'alternates': _parseAlternates(_alternatesController.text.trim()),
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food item saved.')),
      );
      _formKey.currentState!.reset();
      _nameController.clear();
      _categoryController.clear();
      _caloriesController.clear();
      _proteinController.clear();
      _carbsController.clear();
      _fatController.clear();
      _fiberController.clear();
      _alternatesController.clear();
      setState(() {
        _imageFile = null;
        _isVeg = false;
        _view = _DietView.home;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save item: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_view) {
      case _DietView.addItem:
        return _buildAddItemForm();
      case _DietView.home:
        return _buildHomeTiles();
    }
  }

  Widget _buildHomeTiles() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionTile(
            icon: Icons.add_circle,
            title: 'Add Item',
            subtitle: 'Create a new food item',
            onTap: () => setState(() => _view = _DietView.addItem),
          ),
          const SizedBox(height: 16),
          _ActionTile(
            icon: Icons.list_alt,
            title: 'View Items',
            subtitle: 'Browse saved food items',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ViewItemsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _view = _DietView.home),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              const Text(
                'Add Food Item',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _requiredTextValidator(value, 'Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    hintText: 'protein, carbs, fat, etc.',
                  ),
                  validator: (value) =>
                      _requiredTextValidator(value, 'Category'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Vegetarian'),
                  value: _isVeg,
                  onChanged: (value) => setState(() => _isVeg = value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _caloriesController,
                        decoration: const InputDecoration(
                          labelText: 'Calories',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}$'),
                          ),
                        ],
                        validator: (value) =>
                            _numberValidator(value, 'Calories'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _proteinController,
                        decoration: const InputDecoration(
                          labelText: 'Protein',
                          border: OutlineInputBorder(),
                          suffixText: 'g',
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}$'),
                          ),
                        ],
                        validator: (value) =>
                            _numberValidator(value, 'Protein'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _carbsController,
                        decoration: const InputDecoration(
                          labelText: 'Carbs',
                          border: OutlineInputBorder(),
                          suffixText: 'g',
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}$'),
                          ),
                        ],
                        validator: (value) =>
                            _numberValidator(value, 'Carbs'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _fatController,
                        decoration: const InputDecoration(
                          labelText: 'Fat',
                          border: OutlineInputBorder(),
                          suffixText: 'g',
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}$'),
                          ),
                        ],
                        validator: (value) => _numberValidator(value, 'Fat'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fiberController,
                  decoration: const InputDecoration(
                    labelText: 'Fiber',
                    border: OutlineInputBorder(),
                    suffixText: 'g',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}$'),
                    ),
                  ],
                  validator: (value) => _numberValidator(value, 'Fiber'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _alternatesController,
                  decoration: const InputDecoration(
                    labelText: 'Alternates (comma separated, max 5)',
                    border: OutlineInputBorder(),
                  ),
                  validator: _alternatesValidator,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Add Image'),
                    ),
                    const SizedBox(width: 12),
                    if (_imageFile != null)
                      Expanded(
                        child: Text(
                          _imageFile!.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveFoodItem,
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Item'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 40, color: Colors.green),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(subtitle),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
