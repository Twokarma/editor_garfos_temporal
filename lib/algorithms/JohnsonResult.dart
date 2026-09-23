/// Objetivo del cálculo: camino mínimo o camino máximo.
enum PathObjective { minimize, maximize }

/// Resultado de ejecutar Johnson sobre un grafo de [nodeCount] nodos.
///
/// Los nodos se identifican por índice (0 .. nodeCount - 1).
class JohnsonResult {
  final PathObjective objective;
  final int nodeCount;

  /// dist[u][v] = costo del mejor camino de u a v (mínimo o máximo según
  /// [objective]). Vale [double.infinity] si v no es alcanzable desde u.
  final List<List<double>> dist;

  /// pred[u][v] = nodo anterior a v en el mejor camino desde u (-1 si no hay).
  final List<List<int>> pred;

  /// Potenciales h(v) calculados con Bellman-Ford (útil para mostrar el paso 1).
  final List<double> potentials;

  /// true si se detectó un ciclo que hace el problema no acotado:
  /// ciclo negativo al minimizar, ciclo positivo al maximizar.
  final bool hasNegativeCycle;

  const JohnsonResult({
    required this.objective,
    required this.nodeCount,
    required this.dist,
    required this.pred,
    required this.potentials,
    required this.hasNegativeCycle,
  });

  /// Resultado vacío para el caso de ciclo detectado.
  factory JohnsonResult.cycle(PathObjective objective, int nodeCount) {
    return JohnsonResult(
      objective: objective,
      nodeCount: nodeCount,
      dist: const [],
      pred: const [],
      potentials: const [],
      hasNegativeCycle: true,
    );
  }

  /// Mensaje legible cuando hay ciclo.
  String get cycleMessage => objective == PathObjective.minimize
      ? 'El grafo tiene un ciclo negativo: no existe camino mínimo.'
      : 'El grafo tiene un ciclo positivo: no existe camino máximo.';

  bool isReachable(int from, int to) =>
      !hasNegativeCycle && dist[from][to].isFinite;

  /// Devuelve la lista de nodos del mejor camino de [from] a [to],
  /// o una lista vacía si no hay camino.
  List<int> pathBetween(int from, int to) {
    if (!isReachable(from, to)) return [];
    final path = <int>[to];
    var current = to;
    while (current != from) {
      current = pred[from][current];
      if (current == -1) return [];
      path.add(current);
    }
    return path.reversed.toList();
  }
}