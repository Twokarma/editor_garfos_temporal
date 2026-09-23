import 'JohnsonAlgorithm.dart';

/// Resultado del cálculo de la ruta crítica.
class CriticalPathResult {
  /// true si el grafo tiene un ciclo (la ruta crítica solo existe en grafos
  /// dirigidos sin ciclos).
  final bool hasCycle;

  /// earliest[v]: instante más temprano en que puede ocurrir el nodo v
  /// (pasada hacia adelante, se toma el MÁXIMO).
  final List<double> earliest;

  /// latest[v]: instante más tardío sin retrasar el proyecto
  /// (pasada hacia atrás, se toma el MÍNIMO).
  final List<double> latest;

  /// Holgura de cada arista: h = latest[destino] - earliest[origen] - peso.
  /// Mismo orden que la lista de aristas de entrada.
  final List<double> edgeSlack;

  /// Índices (en la lista de entrada) de las aristas críticas (h = 0).
  final List<int> criticalEdges;

  /// Una ruta crítica completa, como lista de nodos.
  final List<int> criticalPath;

  /// Duración total del proyecto.
  final double duration;

  const CriticalPathResult({
    required this.hasCycle,
    required this.earliest,
    required this.latest,
    required this.edgeSlack,
    required this.criticalEdges,
    required this.criticalPath,
    required this.duration,
  });

  factory CriticalPathResult.cycle() => const CriticalPathResult(
        hasCycle: true,
        earliest: [],
        latest: [],
        edgeSlack: [],
        criticalEdges: [],
        criticalPath: [],
        duration: 0,
      );

  double nodeSlack(int v) => latest[v] - earliest[v];

  bool isCriticalNode(int v) => nodeSlack(v).abs() < 1e-9;
}

/// Método de la ruta crítica sobre un grafo dirigido acíclico.
///
///  1. Pasada hacia adelante: earliest[v] = máx(earliest[u] + peso).
///  2. Pasada hacia atrás:   latest[u]   = mín(latest[v] - peso).
///  3. Holgura de arista:    h = latest[destino] - earliest[origen] - peso.
///  4. Ruta crítica: aristas con h = 0.
class CriticalPathAlgorithm {
  static const double _eps = 1e-9;

  static CriticalPathResult run({
    required int nodeCount,
    required List<JohnsonEdge> edges,
  }) {
    final n = nodeCount;
    if (n == 0) {
      return const CriticalPathResult(
        hasCycle: false,
        earliest: [],
        latest: [],
        edgeSlack: [],
        criticalEdges: [],
        criticalPath: [],
        duration: 0,
      );
    }

    // Aristas salientes por nodo (guardamos índices) y grados de entrada.
    final out = List.generate(n, (_) => <int>[]);
    final indeg = List<int>.filled(n, 0);
    for (var i = 0; i < edges.length; i++) {
      out[edges[i].from].add(i);
      indeg[edges[i].to]++;
    }

    // Orden topológico (Kahn). Si no cubre todos los nodos, hay ciclo.
    final deg = List<int>.from(indeg);
    final order = <int>[];
    final queue = <int>[
      for (var v = 0; v < n; v++)
        if (deg[v] == 0) v
    ];
    var head = 0;
    while (head < queue.length) {
      final u = queue[head++];
      order.add(u);
      for (final ei in out[u]) {
        final v = edges[ei].to;
        deg[v]--;
        if (deg[v] == 0) queue.add(v);
      }
    }
    if (order.length < n) return CriticalPathResult.cycle();

    // Pasada hacia adelante (máximo).
    final earliest = List<double>.filled(n, 0.0);
    for (final u in order) {
      for (final ei in out[u]) {
        final e = edges[ei];
        final t = earliest[u] + e.weight;
        if (t > earliest[e.to]) earliest[e.to] = t;
      }
    }
    var duration = 0.0;
    for (final t in earliest) {
      if (t > duration) duration = t;
    }

    // Pasada hacia atrás (mínimo).
    final latest = List<double>.filled(n, duration);
    for (final u in order.reversed) {
      for (final ei in out[u]) {
        final e = edges[ei];
        final t = latest[e.to] - e.weight;
        if (t < latest[u]) latest[u] = t;
      }
    }

    // Holguras de arista y aristas críticas.
    final slack = <double>[];
    final critical = <int>[];
    for (var i = 0; i < edges.length; i++) {
      final e = edges[i];
      final h = latest[e.to] - earliest[e.from] - e.weight;
      slack.add(h.abs() < _eps ? 0.0 : h);
      if (h.abs() < _eps) critical.add(i);
    }

    // Una ruta crítica: desde un nodo inicial crítico, siguiendo aristas h = 0.
    final criticalSet = critical.toSet();
    final path = <int>[];
    var start = -1;
    for (var v = 0; v < n; v++) {
      if (indeg[v] == 0 && (latest[v] - earliest[v]).abs() < _eps) {
        start = v;
        break;
      }
    }
    if (start != -1) {
      var current = start;
      path.add(current);
      while (true) {
        int? next;
        for (final ei in out[current]) {
          if (criticalSet.contains(ei)) {
            next = edges[ei].to;
            break;
          }
        }
        if (next == null) break;
        current = next;
        path.add(current);
      }
    }

    return CriticalPathResult(
      hasCycle: false,
      earliest: earliest,
      latest: latest,
      edgeSlack: slack,
      criticalEdges: critical,
      criticalPath: path,
      duration: duration,
    );
  }
}