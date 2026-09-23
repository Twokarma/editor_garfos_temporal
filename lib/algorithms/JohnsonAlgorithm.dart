import 'dart:math' as math;

import '../models/jhonson_result.dart';

/// Arista dirigida con peso. Los nodos son índices 0 .. n-1.
class JohnsonEdge {
  final int from;
  final int to;
  final double weight;

  const JohnsonEdge(this.from, this.to, this.weight);
}

class _Arc {
  final int to;
  final double weight;
  const _Arc(this.to, this.weight);
}

/// Algoritmo de Johnson: caminos entre todos los pares de nodos.
///
/// Pasos:
///  1. Bellman-Ford desde un nodo virtual (arista de peso 0 a todos) para
///     obtener los potenciales h(v) y detectar ciclos.
///  2. Reponderar: w'(u,v) = w(u,v) + h(u) - h(v)  (todos >= 0).
///  3. Dijkstra desde cada nodo con los pesos reponderados.
///  4. Deshacer la reponderación: d(u,v) = d'(u,v) - h(u) + h(v).
///
/// Para el MÁXIMO se invierte el signo de los pesos, se ejecuta lo mismo y se
/// vuelve a invertir el resultado.
class JohnsonAlgorithm {
  static const double _eps = 1e-12;

  static JohnsonResult run({
    required int nodeCount,
    required List<JohnsonEdge> edges,
    PathObjective objective = PathObjective.minimize,
  }) {
    final n = nodeCount;
    final sign = objective == PathObjective.maximize ? -1.0 : 1.0;

    // Pesos con el signo ya aplicado (para maximizar se niegan).
    final work = edges
        .map((e) => JohnsonEdge(e.from, e.to, e.weight * sign))
        .toList();

    // ---- Paso 1: Bellman-Ford con nodo virtual ----
    // Empezar con h = 0 equivale a la primera pasada desde el nodo virtual.
    final h = List<double>.filled(n, 0.0);
    for (var i = 0; i < n - 1; i++) {
      var changed = false;
      for (final e in work) {
        if (h[e.from] + e.weight < h[e.to] - _eps) {
          h[e.to] = h[e.from] + e.weight;
          changed = true;
        }
      }
      if (!changed) break;
    }
    // Pasada extra: si aún se puede relajar, hay ciclo negativo.
    for (final e in work) {
      if (h[e.from] + e.weight < h[e.to] - _eps) {
        return JohnsonResult.cycle(objective, n);
      }
    }

    // ---- Paso 2: reponderar ----
    final adj = List.generate(n, (_) => <_Arc>[]);
    for (final e in work) {
      final w = math.max(0.0, e.weight + h[e.from] - h[e.to]);
      adj[e.from].add(_Arc(e.to, w));
    }

    // ---- Paso 3 y 4: Dijkstra desde cada nodo y deshacer reponderación ----
    final dist = List.generate(n, (_) => List<double>.filled(n, double.infinity));
    final pred = List.generate(n, (_) => List<int>.filled(n, -1));

    for (var s = 0; s < n; s++) {
      final d = List<double>.filled(n, double.infinity);
      final p = List<int>.filled(n, -1);
      final done = List<bool>.filled(n, false);
      d[s] = 0;

      // Dijkstra O(n^2): simple y suficiente para un editor de grafos.
      for (var i = 0; i < n; i++) {
        var u = -1;
        for (var v = 0; v < n; v++) {
          if (!done[v] && d[v].isFinite && (u == -1 || d[v] < d[u])) u = v;
        }
        if (u == -1) break;
        done[u] = true;
        for (final arc in adj[u]) {
          final nd = d[u] + arc.weight;
          if (nd < d[arc.to]) {
            d[arc.to] = nd;
            p[arc.to] = u;
          }
        }
      }

      for (var v = 0; v < n; v++) {
        if (d[v].isFinite) {
          final real = (d[v] - h[s] + h[v]) * sign;
          dist[s][v] = real == 0 ? 0.0 : real; // evita -0.0
        }
        pred[s][v] = p[v];
      }
    }

    return JohnsonResult(
      objective: objective,
      nodeCount: n,
      dist: dist,
      pred: pred,
      potentials: h,
      hasNegativeCycle: false,
    );
  }
}