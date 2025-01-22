import 'dart:ui';

class Recognition {
  String userId;
  String name;
  String createdAt;
  Rect location;
  List<double> embeddings;
  double distance;
  Recognition(this.userId, this.name, this.createdAt, this.location,this.embeddings,this.distance);
}