import 'package:flutter/material.dart';
  import '../algorithms/JohnsonAlgorithm.dart';
  import '../models/jhonson_result.dart';

/// Pantalla para ejecutar Johnson y ver la matriz de distancias.
///
/// Si no se pasan [labels] y [edges], usa un grafo de ejemplo para poder
/// probarla de inmediato.
class JohnsonScreen extends StatefulWidget {
  final List<String>? labels;
  final List<JohnsonEdge>? edges;

  const JohnsonScreen({super.key, this.labels, this.edges});

  @override
  State<JohnsonScreen> createState() => _JohnsonScreenState();
}

class _JohnsonScreenState extends State<JohnsonScreen> {
  // Grafo de ejemplo (DAG con una arista negativa): A→B 3, A→C 2, C→B -1,
  // B→D 4, C→D 6. Funciona tanto para mínimo como para máximo.
  static const _demoLabels = ['A', 'B', 'C', 'D'];
  static const _demoEdges = [
    JohnsonEdge(0, 1, 3),
    JohnsonEdge(0, 2, 2),
    JohnsonEdge(2, 1, -1),
    JohnsonEdge(1, 3, 4),
    JohnsonEdge(2, 3, 6),
  ];

  PathObjective _objective = PathObjective.minimize;
  late JohnsonResult _result;
  int _origin = 0;
  int _destination = 0;

  List<String> get _labels => widget.labels ?? _demoLabels;
  List<JohnsonEdge> get _edges => widget.edges ?? _demoEdges;

  @override
  void initState() {
    super.initState();
    _destination = _labels.length > 1 ? _labels.length - 1 : 0;
    _calculate();
  }

  void _calculate() {
    _result = JohnsonAlgorithm.run(
      nodeCount: _labels.length,
      edges: _edges,
      objective: _objective,
    );
  }

  String _fmt(double v) {
    if (!v.isFinite) return '—';
    return v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Algoritmo de Johnson')),
      body: _labels.isEmpty
          ? const Center(child: Text('El grafo no tiene nodos.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildObjectiveSelector(),
                const SizedBox(height: 16),
                if (_result.hasNegativeCycle)
                  _buildCycleWarning()
                else ...[
                  Text('Matriz de distancias',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _buildMatrix(),
                  const SizedBox(height: 4),
                  const Text('— significa que no hay camino.',
                      style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 24),
                  _buildPathSection(),
                ],
              ],
            ),
    );
  }

  Widget _buildObjectiveSelector() {
    return SegmentedButton<PathObjective>(
      segments: const [
        ButtonSegment(
          value: PathObjective.minimize,
          label: Text('Mínimo'),
          icon: Icon(Icons.trending_down),
        ),
        ButtonSegment(
          value: PathObjective.maximize,
          label: Text('Máximo'),
          icon: Icon(Icons.trending_up),
        ),
      ],
      selected: {_objective},
      onSelectionChanged: (s) {
        setState(() {
          _objective = s.first;
          _calculate();
        });
      },
    );
  }

  Widget _buildCycleWarning() {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _result.cycleMessage,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrix() {
    final n = _labels.length;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('')),
          for (final l in _labels) DataColumn(label: Text(l)),
        ],
        rows: [
          for (var i = 0; i < n; i++)
            DataRow(cells: [
              DataCell(Text(_labels[i],
                  style: const TextStyle(fontWeight: FontWeight.bold))),
              for (var j = 0; j < n; j++) DataCell(Text(_fmt(_result.dist[i][j]))),
            ]),
        ],
      ),
    );
  }

  Widget _buildPathSection() {
    final path = _result.pathBetween(_origin, _destination);
    final kind = _objective == PathObjective.minimize ? 'mínimo' : 'máximo';

    String text;
    if (path.isEmpty) {
      text = 'No hay camino de ${_labels[_origin]} a ${_labels[_destination]}.';
    } else {
      final route = path.map((i) => _labels[i]).join(' → ');
      text = 'Camino $kind: $route\n'
          'Costo: ${_fmt(_result.dist[_origin][_destination])}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Consultar un camino',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _nodeDropdown('Origen', _origin, (v) {
              setState(() => _origin = v);
            })),
            const SizedBox(width: 12),
            Expanded(child: _nodeDropdown('Destino', _destination, (v) {
              setState(() => _destination = v);
            })),
          ],
        ),
        const SizedBox(height: 12),
        Text(text, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  Widget _nodeDropdown(String label, int value, ValueChanged<int> onChanged) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (var i = 0; i < _labels.length; i++)
          DropdownMenuItem(value: i, child: Text(_labels[i])),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}