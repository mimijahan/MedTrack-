// lib/widgets/add_dependent_modal.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/dependent_model.dart';

// Define a callback function signature for when the form is submitted
typedef OnDependentAdded = void Function(Dependent dependent);

class AddDependentModal extends StatefulWidget {
  final OnDependentAdded onDependentAdded;

  const AddDependentModal({super.key, required this.onDependentAdded});

  @override
  State<AddDependentModal> createState() => _AddDependentModalState();
}

class _AddDependentModalState extends State<AddDependentModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  // --- Form Data State ---
  DependentType _selectedType = DependentType.person;
  Color _selectedColor = Colors.purple; // Default color
  final Uuid _uuid = const Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- Helper Functions ---

  // Color picker for a unique dependent color
  void _selectColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  // Final validation and submission
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();

      // 1. Generate a unique ID
      final newId = _uuid.v4();

      // 2. Determine initial (first letter)
      final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

      // 3. Create the Dependent object
      final newDependent = Dependent(
        id: newId,
        name: name,
        type: _selectedType,
        initial: initial,
        color: _selectedColor,
      );

      // 4. Call the external callback
      widget.onDependentAdded(newDependent);
    }
  }

  // Simplified color list for selection
  final List<Color> availableColors = [
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    // Padding to account for the keyboard
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: keyboardPadding + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Title ---
              Text(
                'Add New Dependent/Care Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 30),

              // --- 1. Dependent Name Field ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Dependent Name (e.g., Claire, Luna)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- 2. Dependent Type Selector (Person/Pet) ---
              Row(
                children: [
                  const Text(
                    'Type: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: DependentType.values.map((type) {
                        final isSelected = _selectedType == type;
                        return ChoiceChip(
                          label: Text(type.name.toUpperCase()),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedType = type;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- 3. Color Picker ---
              const Text(
                'Profile Color:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10.0,
                children: availableColors.map((color) {
                  return GestureDetector(
                    onTap: () => _selectColor(color),
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: _selectedColor == color ? 18 : 14,
                      child: _selectedColor == color
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // --- 4. Submit Button ---
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Create Dependent',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
