import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/graph.dart';
import '../providers/graph_provider.dart';
import '../widgets/graph_painter.dart';

class HungarianScreen extends StatefulWidget {
  const HungarianScreen({super.key});

  @override
  State<HungarianScreen> createState() => _HungarianScreenState();
}

class _HungarianScreenState extends State<HungarianScreen> {
  late final Graph _graphCopy;
  Set<String> _solutionEdgeIds = {};

  @override
  void initState() {
    super.initState();
    _graphCopy = context.read<GraphProvider>().graphGetter().clone();
    WidgetsBinding.instance.addPostFrameCallback((_) => _askGoal());
  }

    Future<void> _askGoal() async {
    final min = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Hungarian assignment"),
          content: const Text("Choose the optimization goal"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text("Minimize"),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Maximize"),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (min == null) {
      Navigator.of(context).pop();
      return;
    }

    try {
      final solution = _graphCopy.hungarianSolutionEdgeIds(min: min).toSet();
      if (!mounted) return;
      setState(() => _solutionEdgeIds = solution);

      if (solution.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No assignment found in this graph")),
        );
      }
    } catch (e, st) {
      debugPrint('Hungarian error: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hungarian Assignment")),
      body: SizedBox.expand(
        child: CustomPaint(
          painter: GraphPainter(
            nodes: _graphCopy.nodes,
            edges: _graphCopy.edges,
            dragSourceId: "",
            dragCurrentPosition: null,
            highlightedEdgeIds: _solutionEdgeIds,
          ),
        ),
      ),
    );
  }
}
