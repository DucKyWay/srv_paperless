import 'package:flutter/material.dart';

class CustomModalSheet<T> extends StatelessWidget {
  final List<T> items;
  final String label;
  final String Function(T) labelBuilder;
  final T? currentValue;

  const CustomModalSheet({
    super.key,
    required this.items,
    required this.label,
    required this.labelBuilder,
    this.currentValue,
  });

  // Generic
  static Future<T?> show<T>({
    required BuildContext context,
    required List<T> items,
    required String title,
    required String Function(T) labelBuilder,
    T? currentValue,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.grey.shade50,
      builder:
          (_) => CustomModalSheet<T>(
            items: items,
            label: title,
            labelBuilder: labelBuilder,
            currentValue: currentValue,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  final isSelected = item == currentValue;

                  return ListTile(
                    title: Text(labelBuilder(item)),
                    trailing:
                        isSelected
                            ? const Icon(Icons.check, color: Colors.blue)
                            : null,
                    onTap: () {
                      Navigator.pop(context, item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
