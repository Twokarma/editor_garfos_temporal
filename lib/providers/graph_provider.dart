import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graph_maker_app_2/models/graph.dart';
import 'package:graph_maker_app_2/services/graph_storage_service.dart';

import '../models/edge.dart';
import '../models/matrix_data.dart';

class GraphProvider extends ChangeNotifier{
  Graph _graph = Graph();
  final GraphStorageService _storage = GraphStorageService();
  static const int _maxHistory = 20;
  final List<Graph> _history = [];

  Graph graphGetter(){
    return _graph;
  }

  void addNode(double x,double y){
    _pushHistory();
    _graph.addNode(x, y);
    notifyListeners();
  }

  void removeNode(String id){
    _pushHistory();
    _graph.removeNode(id);
    notifyListeners();
  }

  void addEdge(String sourceNode,String targetNode, double weight, bool directed) {
    _pushHistory();
    _graph.addEdge(sourceNode, targetNode, weight, directed: directed);
    notifyListeners();
  }

  void removeEdge(String id){
    _pushHistory();
    _graph.removeEdge(id);
    notifyListeners();
  }

  void renameNode(String id, String newName){
    _pushHistory();
    _graph.renameNode(id, newName);
    notifyListeners();
  }

  void recolorNode(String id, int color){
    _pushHistory();
    _graph.recolorNode(id, color);
    notifyListeners();
  }

  void updateNode(String id,{String? newName, int? newColor}){
    _pushHistory();
    renameNode(id, newName!);
    recolorNode(id, newColor!);
  }

  void updateEdgeWeight(String id, double newWeight) {
    _pushHistory();
    _graph.updateEdgeWeight(id, newWeight);
    notifyListeners();
  }

  String findEdgeAt(double x, double y) {
      return _graph.findEdgeAt(x, y);
  }

  Edge? findReverseEdge(String sourceNode, String targetNode){
    return _graph.findReverseEdge(sourceNode, targetNode);
  }

  bool addEdgeResolvingReverseConflict(String sourceNode, String targetNode, double weight, {required bool directed}) {
    final reverse = findReverseEdge(sourceNode, targetNode);
    if(reverse != null && !reverse.directed) return false;

    _pushHistory();
    if(reverse != null && !directed) removeEdge(reverse.id);
      addEdge(sourceNode, targetNode, weight, directed);
    notifyListeners();
    return true;
  }

  List<List<double>> adjacencyMatrix(MatrixData matrixData){
      return _graph.adjacencyMatrix(matrixData);
  }

  MatrixData buildMatrixData(){
      return _graph.buildMatrixData();
  }

  String graphSummaryJson() {
    return jsonEncode(_graph.toSummaryMap());
  }

  bool moveNode(String id, double x, double y){
    _pushHistory();
    bool move = _graph.moveNode(id, x, y);
    if(!move) _history.removeLast();
    notifyListeners();
    return move;
  }

  String findNodeAt(double x, double y) {
    return _graph.findNodeAt(x, y);
  }

  bool edgeExists(String sourceNode, String tap) {
    return _graph.edgeExists(sourceNode, tap);
  }

  void clearGraph(){
    _pushHistory();
    _graph.clear();
    notifyListeners();
  }

   bool get canUndo => _history.isNotEmpty;

   void _pushHistory(){
      _history.add(_graph.clone());
      if (_history.length > _maxHistory) {
        _history.removeAt(0);
      }
   }

   void undo(){
     if (_history.isEmpty) return;
     _graph = _history.removeLast();
     notifyListeners();
   }

  Future<List<String>> listSavedGraphs() => _storage.listNames();

  Future<bool> savedGraphExists(String name) => _storage.exists(name);

  Future<void> saveGraph(String name) async {
   await _storage.save(name, _graph.toJson());
  }

  Future<void> loadGraph(String name) async{
    final json = await _storage.load(name);
    if(json == null) return;
    _pushHistory();
    _graph = Graph.fromJson(json);
    notifyListeners();
  }

  Future<void> deleteGraph(String name) async {
    await _storage.delete(name);
  }

}
