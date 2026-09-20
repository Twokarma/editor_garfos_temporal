import 'package:graph_maker_app_2/models/node.dart';

class MatrixData{
  final List<Node> nodes;
  final List<Node> rowHeaders;
  final List<Node> colHeaders;
  final List<List<double>> matrix;
  final List<double> rowSum;
  final List<double> colSum;
  final List<int> rowDegree;
  final List<int> colDegree;

  MatrixData({
    required this.nodes,
    required this.rowHeaders,
    required this.colHeaders,
    required this.matrix,
    required this.rowSum,
    required this.colSum,
    required this.rowDegree,
    required this.colDegree,
  });
}