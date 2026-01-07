// lib/widgets/dependent_switcher.dart
import 'package:flutter/material.dart';
import '../models/dependent_model.dart';

class DependentSwitcher extends StatelessWidget {
  final List<Dependent> dependents;
  final String activeDependentId;
  final ValueChanged<String> onDependentChanged;

  const DependentSwitcher({
    super.key,
    required this.dependents,
    required this.activeDependentId,
    required this.onDependentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: dependents.map((dependent) {
            final isSelected = dependent.id == activeDependentId;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(dependent.name),
                selected: isSelected,
                selectedColor: dependent.color.withOpacity(0.8),
                backgroundColor: Colors.grey.shade100,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                avatar: CircleAvatar(
                  backgroundColor: isSelected
                      ? Colors.white
                      : dependent.color.withOpacity(0.2),
                  child: Text(
                    dependent.initial,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? dependent.color : Colors.black,
                    ),
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    onDependentChanged(dependent.id);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
