import 'package:flutter/material.dart';

import '../../providers/graph_provider.dart';


void showEdgeDialog(
    BuildContext context,
    GraphProvider provider, {
      required String source,
      required String target,
    }) {
  final controller = TextEditingController();
  bool isDirected = true;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text("Set weight"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ToggleButtons(
                  isSelected: [isDirected, !isDirected],
                  onPressed: (index) {
                    setDialogState(() {
                      isDirected = index == 0;
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("Directed"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("Non-directed"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: "6.54"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  final weight = double.tryParse(controller.text);
                  if (weight != null) {
                    final added = provider.addEdgeResolvingReverseConflict(
                      source,
                      target,
                      weight,
                      directed: isDirected,
                    );
                    Navigator.of(dialogContext).pop();
                    if (!added) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("An edge already exists between these nodes")),
                      );
                    }
                  }

                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    },
  );
}
