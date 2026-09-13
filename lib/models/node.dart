class Node {
  String id;
  String name;
  double x;
  double y;
  double radius;
  int color;

  static const defaultColor = 0xFF2196F3;

  Node (this.id, this.name, this.x, this.y, this.radius,{this.color = defaultColor});

  void rename(String newName){
    name = newName;
  }

  void reColor(int newColor){
    color = newColor;
  }

}