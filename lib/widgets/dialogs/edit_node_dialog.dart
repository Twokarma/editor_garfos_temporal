import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../providers/graph_provider.dart';


Future<void> showEditNodeDialog(BuildContext context, GraphProvider provider, String nodeId) {
  final node = provider.graphGetter().nodes[nodeId]!;
  final controller = TextEditingController(text: node.name);
  int selectedColor = node.color;

  return showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text("Edit node"),
            content: SizedBox(
              width: 320,
              height: 380,
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: "Name"),
                        Tab(text: "Color"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextField(
                              controller: controller,
                              autofocus: true,
                              decoration: const InputDecoration(hintText: "Node name"),
                            ),
                          ),
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: ColorPicker(
                                pickerColor: Color(selectedColor),
                                onColorChanged: (color) {
                                  setDialogState(() {
                                    selectedColor = color.toARGB32();
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  provider.updateNode(nodeId, newName: controller.text, newColor: selectedColor);
                  Navigator.of(dialogContext).pop();
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
