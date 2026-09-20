  class HungarianAssignment {
    int n = 0;

    HungarianResult solve(List<List<double>> matrix, bool min) {
      final rows = matrix.length;
      final cols = rows == 0 ? 0 : matrix[0].length;
      n = rows > cols ? rows : cols;

      final result = HungarianResult();
      if (n == 0) return result;

      final padded = addDummies(matrix, rows, cols);
      final cost = min ? padded : _negate(padded);
      final assignment = _kuhnMunkres(cost);

      for (int i = 0; i < rows; i++) {
        final j = assignment[i];
        if (j < cols) {
          result.assignment.add(j);
          result.totalCost += matrix[i][j];
        } else {
          result.assignment.add(-1);
        }
      }
      return result;
    }

    List<List<double>> addDummies(List<List<double>> matrix, int rows, int cols) {
      return List.generate(n, (i) {
        return List.generate(n, (j) {
          if (i < rows && j < cols) return matrix[i][j];
          return 0.0;
        });
      });
    }

    List<List<double>> _negate(List<List<double>> matrix) {
      double maxValue = 0;
      for (final row in matrix) {
        for (final value in row) {
          if (value > maxValue) maxValue = value;
        }
      }
      return List.generate(n, (i) {
        return List.generate(n, (j) => maxValue - matrix[i][j]);
      });
    }

    List<int> _kuhnMunkres(List<List<double>> a) {
      const double inf = double.infinity;
      final u = List<double>.filled(n + 1, 0);
      final v = List<double>.filled(n + 1, 0);
      final p = List<int>.filled(n + 1, 0);
      final way = List<int>.filled(n + 1, 0);

      for (int i = 1; i <= n; i++) {
        p[0] = i;
        int j0 = 0;
        final minv = List<double>.filled(n + 1, inf);
        final used = List<bool>.filled(n + 1, false);

        do {
          used[j0] = true;
          final i0 = p[j0];
          double delta = inf;
          int j1 = -1;

          for (int j = 1; j <= n; j++) {
            if (used[j]) continue;
            final cur = a[i0 - 1][j - 1] - u[i0] - v[j];
            if (cur < minv[j]) {
              minv[j] = cur;
              way[j] = j0;
            }
            if (minv[j] < delta) {
              delta = minv[j];
              j1 = j;
            }
          }

          for (int j = 0; j <= n; j++) {
            if (used[j]) {
              u[p[j]] += delta;
              v[j] -= delta;
            } else {
              minv[j] -= delta;
            }
          }

          j0 = j1;
        } while (p[j0] != 0);

        do {
          final j1 = way[j0];
          p[j0] = p[j1];
          j0 = j1;
        } while (j0 != 0);
      }

      final assignment = List<int>.filled(n, -1);
      for (int j = 1; j <= n; j++) {
        if (p[j] != 0) assignment[p[j] - 1] = j - 1;
      }
      return assignment;
    }
  }

  class HungarianResult {
    List<int> assignment = [];
    double totalCost = 0;
  }
