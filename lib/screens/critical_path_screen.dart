import 'package:flutter/material.dart';

import '../algorithms/critical_path.dart';
import '../algorithms/JohnsonAlgorithm.dart';

/// Pantalla de ruta crítica. Muestra, por nodo, [más temprano | más tardío]
/// y, por arista, la holgura h = latest[destino] - earliest[origen] - peso.
///
/// Sin parámetros usa un grafo de ejemplo para poder probarla de inmediato.
class CriticalPathScreen extends StatelessWidget {
  final List<String>? labels;
  final List<JohnsonEdge>? edges;

  const CriticalPathScreen({super.key, this.labels, this.edges});

  // Ejemplo: 0→1 (2), 0→2 (3), 1→2 (5), 1→3 (6), 2→4 (9), 4→3 (0),
  // 3→5 (7), 4→5 (2), 5→6 (3).  Duración esperada: 26.
  static const _demoLabels = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
  static const _demoEdges = [
    JohnsonEdge(0, 1, 2),
    JohnsonEdge(0, 2, 3),
    JohnsonEdge(1, 2, 5),
    JohnsonEdge(1, 3, 6),
    JohnsonEdge(2, 4, 9),
    JohnsonEdge(4, 3, 0),
    JohnsonEdge(3, 5, 7),
    JohnsonEdge(4, 5, 2),
    JohnsonEdge(5, 6, 3),
  ];

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final names = labels ?? _demoLabels;
    final edgeList = edges ?? _demoEdges;
    final result = CriticalPathAlgorithm.run(
      nodeCount: names.length,
      edges: edgeList,
    );
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ruta crítica')),
      body: names.isEmpty
          ? const Center(child: Text('El grafo no tiene nodos.'))
          : result.hasCycle
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    color: scheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'El grafo tiene un ciclo. La ruta crítica solo se '
                        'puede calcular en grafos dirigidos sin ciclos.',
                        style: TextStyle(color: scheme.onErrorContainer),
                      ),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _summary(context, result, names),
                    const SizedBox(height: 24),
                    Text('Nodos  [más temprano | más tardío]',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _nodesTable(context, result, names),
                    const SizedBox(height: 24),
                    Text('Aristas y holgura (h)',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _edgesTable(context, result, names, edgeList),
                    const SizedBox(height: 16),
                    const Text(
                      'Las aristas con h = 0 son críticas: cualquier retraso '
                      'en ellas retrasa todo el proyecto. Las demás pueden '
                      'retrasarse hasta h unidades sin afectar la duración '
                      'total.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
    );
  }

  Widget _summary(
      BuildContext context, CriticalPathResult r, List<String> names) {
    final route = r.criticalPath.isEmpty
        ? 'No se encontró una ruta crítica.'
        : r.criticalPath.map((i) => names[i]).join(' → ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duración total: ${_fmt(r.duration)}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Ruta crítica: $route'),
          ],
        ),
      ),
    );
  }

  Widget _nodesTable(
      BuildContext context, CriticalPathResult r, List<String> names) {
    final highlight = Theme.of(context).colorScheme.primaryContainer;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Nodo')),
          DataColumn(label: Text('Más temprano')),
          DataColumn(label: Text('Más tardío')),
          DataColumn(label: Text('Holgura')),
        ],
        rows: [
          for (var v = 0; v < names.length; v++)
            DataRow(
              color: r.isCriticalNode(v)
                  ? WidgetStateProperty.all(highlight)
                  : null,
              cells: [
                DataCell(Text(names[v],
                    style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(_fmt(r.earliest[v]))),
                DataCell(Text(_fmt(r.latest[v]))),
                DataCell(Text(_fmt(r.nodeSlack(v)))),
              ],
            ),
        ],
      ),
    );
  }

  Widget _edgesTable(BuildContext context, CriticalPathResult r,
      List<String> names, List<JohnsonEdge> edgeList) {
    final highlight = Theme.of(context).colorScheme.primaryContainer;
    final criticalSet = r.criticalEdges.toSet();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Arista')),
          DataColumn(label: Text('Peso')),
          DataColumn(label: Text('h')),
          DataColumn(label: Text('Crítica')),
        ],
        rows: [
          for (var i = 0; i < edgeList.length; i++)
            DataRow(
              color: criticalSet.contains(i)
                  ? WidgetStateProperty.all(highlight)
                  : null,
              cells: [
                DataCell(Text(
                    '${names[edgeList[i].from]} → ${names[edgeList[i].to]}')),
                DataCell(Text(_fmt(edgeList[i].weight))),
                DataCell(Text(_fmt(r.edgeSlack[i]))),
                DataCell(Text(criticalSet.contains(i) ? 'Sí' : 'No')),
              ],
            ),
        ],
      ),
    );
  }
}