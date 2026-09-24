import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graph_maker_app_2/algorithms/hungarian_assignment.dart';
import 'package:graph_maker_app_2/models/edge.dart';
import 'package:graph_maker_app_2/models/matrix_data.dart';
import 'package:graph_maker_app_2/models/node.dart';

import 'package:graph_maker_app_2/algorithms/JohnsonAlgorithm.dart';

class Graph {
  Map<String, Node> nodes = {};
  Map<String, Edge> edges = {};
  int currentNode = 0;
  int currentEdge = 0;
  double radius = 30;
  static const double selfLoopRadius = 20;
  static const int overLapDistance = 10;

  void addNode(double x,double y) {
    String id = "n$currentNode";
    nodes[id] = Node(id, generateNodeName(), x, y, radius);
    currentNode++;
  }

  void removeNode(String id){
    List<String> edgesToRemove = [];
    edges.forEach((key, edge) {
      if (edge.sourceNodeId == id || edge.targetNodeId == id) {
        edgesToRemove.add(key);
      }
    });
    for (String key in edgesToRemove) {
      removeEdge(key);
    }
    nodes.remove(id);
  }

  void addEdge(String sourceNode,String targetNode, double weight, {bool directed = true}) {
    String id = "e$currentEdge";
    edges[id] = Edge(id, sourceNode, targetNode, weight, directed);
    currentEdge++;
  }

  void removeEdge(String id){
    edges.remove(id);
  }

  static double selfLoopCenterDistance(double radius){
    return radius + selfLoopRadius - overLapDistance;
  }

  bool moveNode(String id, double x, double y){
    final node = nodes[id];
    if (node == null) return false;

    for (final entry in nodes.entries) {
      if (entry.key == id) continue;
      final dx = entry.value.x - x;
      final dy = entry.value.y - y;
      if ((dx * dx + dy * dy) <= (radius + radius + 3) * (radius + radius + 3)) {
        return false;
      }
    }

    node.x = x;
    node.y = y;
    return true;
  }

  Node? findNode(String id){
    return nodes[id];
  }

  String findNodeAt(double x, double y) {
    String nodeId = "";
    nodes.forEach((id, node){
      double dx = node.x - x;
      double dy = node.y - y;
      double d = (dx * dx) + (dy * dy);
      if( d <= (radius+radius+3) * (radius+radius+3)) {
        if( d <= radius * radius) {
          nodeId = id;
        } else {
          nodeId = "tooClose";
        }
      }
    });
    return nodeId;
  }

  List<Edge> findEdges(String id) {
    List<Edge> xEdges = [];
    edges.forEach((key, edge){
      if(edge.sourceNodeId == id) xEdges.add(edge);
    });
    return xEdges;
  }

  String findEdgeAt(double x, double y) {
    String edgeId = "";
    double tolerance = 10;
    edges.forEach((id, edge){
      Node sourceNode = nodes[edge.sourceNodeId]!;
      Node targetNode = nodes[edge.targetNodeId]!;
      if(sourceNode.id == targetNode.id){
        Offset loopEdgeCenter = Offset(sourceNode.x + selfLoopCenterDistance(sourceNode.radius), sourceNode.y);
        double dx = loopEdgeCenter.dx - x;
        double dy = loopEdgeCenter.dy - y;
        double d = sqrt(dx*dx + dy*dy);
        if((d - selfLoopRadius).abs() <= tolerance) edgeId = id;
      }

      if(_distanceToSegment(x, y, sourceNode.x, sourceNode.y, targetNode.x, targetNode.y) <= tolerance*tolerance) edgeId = id;
    });
    return edgeId;
  }

  double _distanceToSegment(double px, double py, double x1, double y1, double x2, double y2) {
    double dx = x2 - x1;
    double dy = y2 - y1;
    double lengthSquared = dx * dx + dy * dy;
    double t = lengthSquared == 0 ? 0 : (((px - x1) * dx + (py - y1) * dy) / lengthSquared).clamp(0.0, 1.0);
    double closestX = x1 + t * dx;
    double closestY = y1 + t * dy;
    double distX = px - closestX;
    double distY = py - closestY;
    return distX * distX + distY * distY;
  }

  Edge? findReverseEdge(String sourceNode, String targetNode){
    Edge? found;
    edges.forEach((id, edge){
      if(edge.sourceNodeId == targetNode && edge.targetNodeId == sourceNode) {
        found = edge;
      }
    });
    return found;
  }

  Graph clone(){
    final copy = Graph();
    copy.currentNode = currentNode;
    copy.currentEdge = currentEdge;
    copy.radius = radius;
    nodes.forEach((id, node){
      copy.nodes[id] = Node(node.id, node.name, node.x, node.y, node.radius, color: node.color);
    });
    edges.forEach((id, edge) {
      copy.edges[id] = Edge(edge.id, edge.sourceNodeId, edge.targetNodeId, edge.weight, edge.directed);
    });
    return copy;
  }

  void clear(){
    edges.clear();
    nodes.clear();
    currentEdge = 0;
    currentNode = 0;
  }

  Map<String, dynamic> toJson() {
    return {
      "currentNode": currentNode,
      "currentEdge": currentEdge,
      "radius": radius,
      "nodes": nodes.values.map((n) => {
        "id": n.id,
        "name": n.name,
        "x": n.x,
        "y": n.y,
        "radius": n.radius,
        "color": n.color,
      }).toList(),
      "edges": edges.values.map((e) => {
        "id": e.id,
        "sourceNodeId": e.sourceNodeId,
        "targetNodeId": e.targetNodeId,
        "weight": e.weight,
        "directed": e.directed,
      }).toList(),
    };
  }

  static Graph fromJson(Map<String, dynamic> json) {
    final graph = Graph();

    graph.currentNode = json["currentNode"] as int? ?? 0;
    graph.currentEdge = json["currentEdge"] as int? ?? 0;
    graph.radius = (json["radius"] as num?)?.toDouble() ?? graph.radius;

    final nodesJson = json["nodes"] as List<dynamic>? ?? [];
    for (final entry in nodesJson) {
      final map = entry as Map<String, dynamic>;
      final node = Node(
        map["id"] as String,
        map["name"] as String,
        (map["x"] as num).toDouble(),
        (map["y"] as num).toDouble(),
        (map["radius"] as num).toDouble(),
        color: map["color"] as int? ?? Node.defaultColor,
      );
      graph.nodes[node.id] = node;
    }

    final edgesJson = json["edges"] as List<dynamic>? ?? [];
    for (final entry in edgesJson) {
      final map = entry as Map<String, dynamic>;
      final edge = Edge(
        map["id"] as String,
        map["sourceNodeId"] as String,
        map["targetNodeId"] as String,
        (map["weight"] as num).toDouble(),
        map["directed"] as bool,
      );
      graph.edges[edge.id] = edge;
    }

    return graph;
  }

  Map<String, dynamic> toSummaryMap() {
      return{
        "nodes" : nodes.values.map((n) => n.name).toList(),
        "edges" : edges.values.map((e) => {
          "from" : e.sourceNodeId,
          "to" : e.targetNodeId,
          "weight" : e.weight,
        }).toList(),
      };
  }
 MatrixData buildMatrixData(){
    final orderedNodes = nodes.values.toList();

    // Qué nodos tienen salidas / entradas. Las aristas no dirigidas
    // cuentan en ambos sentidos.
    final hasOut = <String>{};
    final hasIn = <String>{};
    edges.forEach((id, edge){
      hasOut.add(edge.sourceNodeId);
      hasIn.add(edge.targetNodeId);
      if(!edge.directed){
        hasOut.add(edge.targetNodeId);
        hasIn.add(edge.sourceNodeId);
      }
    });

    final rowHeaders = orderedNodes.where((n) => hasOut.contains(n.id)).toList();
    final colHeaders = orderedNodes.where((n) => hasIn.contains(n.id)).toList();

    final rows = rowHeaders.length;
    final cols = colHeaders.length;
    final rowIndex = <String, int>{
      for(int i = 0; i < rows; i++) rowHeaders[i].id: i
    };
    final colIndex = <String, int>{
      for(int j = 0; j < cols; j++) colHeaders[j].id: j
    };

    final matrix = List.generate(rows, (_) => List.filled(cols, 0.0));
    final rowDegree = List.filled(rows, 0);
    final colDegree = List.filled(cols, 0);

    edges.forEach((id, edge){
      final i = rowIndex[edge.sourceNodeId];
      final j = colIndex[edge.targetNodeId];
      if(i != null && j != null){
        matrix[i][j] = edge.weight;
        rowDegree[i] += 1;
        colDegree[j] += 1;
      }
      if(!edge.directed && edge.sourceNodeId != edge.targetNodeId){
        final i2 = rowIndex[edge.targetNodeId];
        final j2 = colIndex[edge.sourceNodeId];
        if(i2 != null && j2 != null){
          matrix[i2][j2] = edge.weight;
          rowDegree[i2] += 1;
          colDegree[j2] += 1;
        }
      }
    });

    final rowSum = List.filled(rows, 0.0);
    final colSum = List.filled(cols, 0.0);
    for(int i = 0; i < rows; i++){
      for(int j = 0; j < cols; j++){
        rowSum[i] += matrix[i][j];
        colSum[j] += matrix[i][j];
      }
    }

    return MatrixData(
      nodes: orderedNodes,
      rowHeaders: rowHeaders,
      colHeaders: colHeaders,
      matrix: matrix,
      rowSum: rowSum,
      colSum: colSum,
      rowDegree: rowDegree,
      colDegree: colDegree,
    );
 }

 List<List<double>> adjacencyMatrix(MatrixData matrixData){
    return matrixData.matrix;
 }

 static const double _forbiddenAssignmentCost = 1e9;

 List<String> hungarianSolutionEdgeIds({bool min = true}) {
    final data = buildMatrixData();
    final rows = data.rowHeaders.length;
    final cols = data.colHeaders.length;
    if (rows == 0 || cols == 0) return [];

    final costMatrix = min
        ? List.generate(rows, (i) => List.generate(cols, (j) => data.matrix[i][j] > 0 ? data.matrix[i][j] : _forbiddenAssignmentCost))
        : data.matrix;

    final result = HungarianAssignment().solve(costMatrix, min);

    List<String> solutionEdgeIds = [];
    for (int i = 0; i < rows && i < result.assignment.length; i++) {
      final j = result.assignment[i];
      if (j < 0 || j >= cols) continue;
      if (data.matrix[i][j] <= 0) continue;

      final sourceId = data.rowHeaders[i].id;
      final targetId = data.colHeaders[j].id;
      edges.forEach((id, edge) {
        final forward = edge.sourceNodeId == sourceId && edge.targetNodeId == targetId;
        final mirrored = !edge.directed && edge.sourceNodeId == targetId && edge.targetNodeId == sourceId;
        if (forward || mirrored) solutionEdgeIds.add(id);
      });
    }
    return solutionEdgeIds;
 }

  String generateNodeName(){
    List<int> stack = [];
    int id = currentNode + 1;
    while(id>0){
      id -= 1;
      int r = id % 26;
      stack.add(r);
      //id = ((id-r)/26) as int;
      id = (id - r) ~/ 26;
    }

    String name = "";
    while(stack.isNotEmpty){
      name = name + String.fromCharCode(stack.removeLast()+65);
    }
    return name;
  }

  void renameNode(String id, String newName){
    nodes[id]!.rename(newName);
  }

  void recolorNode(String id, int color){
    nodes[id]!.reColor(color);
  }

  void updateEdgeWeight(String id, double newWeight) {
    edges[id]!.weight = newWeight;
  }

  bool edgeExists(String sourceNode, String tap) {
    bool exists = false;
    edges.forEach((id, edge){
      if(edge.sourceNodeId == sourceNode && edge.targetNodeId == tap) exists = true;
    });
    return exists;
  }


  ///
  ///  /// Nombres de los nodos, en el mismo orden que los índices de Johnson.
  List<String> johnsonLabels() => nodes.values.map((n) => n.name).toList();

  /// Aristas convertidas a índices. Las no dirigidas se agregan en ambos sentidos.
  List<JohnsonEdge> johnsonEdges() {
    final index = <String, int>{};
    var i = 0;
    for (final id in nodes.keys) {
      index[id] = i++;
    }

    final result = <JohnsonEdge>[];
    edges.forEach((_, e) {
      final from = index[e.sourceNodeId]!;
      final to = index[e.targetNodeId]!;
      result.add(JohnsonEdge(from, to, e.weight));
      if (!e.directed && from != to) {
        result.add(JohnsonEdge(to, from, e.weight));
      }
    });
    return result;
  }
  List<JohnsonEdge> cpmEdges() {
    final index = <String, int>{};
    var i = 0;
    for (final id in nodes.keys) {
      index[id] = i++;
    }
    return edges.values
        .map((e) => JohnsonEdge(index[e.sourceNodeId]!, index[e.targetNodeId]!, e.weight))
        .toList();
  }
}
