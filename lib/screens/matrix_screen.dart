import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/matrix_data.dart';
import '../providers/graph_provider.dart';
import '../theme/app_colors.dart';

class MatrixScreen extends StatelessWidget {
  const MatrixScreen({super.key});

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  Widget _cell(String text, {bool header = false, Color? background}) {
    return Container(
      width: 64,
      height: 48,
      alignment: Alignment.center,
      color: background,
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: header ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final graphProvider = context.watch<GraphProvider>();
    final MatrixData data = graphProvider.buildMatrixData();
    final n = data.nodes.length;
    final r = data.rowHeaders.length;
    final c = data.colHeaders.length;

    final headerBg = AppColors.headerBk;
    final summaryBg = AppColors.summaryBk;

    List<TableRow> rows = [];

    rows.add(TableRow(children: [
      _cell("", background: headerBg),
      for (final node in data.colHeaders) _cell(node.name, header: true, background: headerBg),
      _cell("Attributes\nleaving", header: true, background: headerBg),
      _cell("Grade", header: true, background: headerBg),
    ]));

    for (int i = 0; i < r; i++) {
      rows.add(TableRow(children: [
        _cell(data.rowHeaders[i].name, header: true, background: headerBg),
        for (int j = 0; j < c; j++) _cell(_fmt(data.matrix[i][j])),
        _cell(_fmt(data.rowSum[i]), background: summaryBg),
        _cell(data.rowDegree[i].toString(), background: summaryBg),
      ]));
    }

    rows.add(TableRow(children: [
      _cell("Attributes\narriving", header: true, background: headerBg),
      for (int j = 0; j < c; j++) _cell(_fmt(data.colSum[j]), background: summaryBg),
      _cell("", background: headerBg),
      _cell("", background: headerBg),
    ]));

    rows.add(TableRow(children: [
      _cell("Grade", header: true, background: headerBg),
      for (int j = 0; j < c; j++) _cell(data.colDegree[j].toString(), background: summaryBg),
      _cell("", background: headerBg),
      _cell("", background: headerBg),
    ]));

    return Scaffold(
      appBar: AppBar(title: const Text("Adjacency Matrix")),
      body: n == 0
          ? const Center(child: Text("No nodes yet"))
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            border: TableBorder.all(color: AppColors.matrixBorders),
            defaultColumnWidth: const FixedColumnWidth(64),
            children: rows,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        shape: const CircleBorder(),
        child: const Text(
          "M[x]",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11),
        ),
      ),
    );
  }
}
