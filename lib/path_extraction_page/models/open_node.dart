import 'package:path_planning_app/path_extraction_page/models/coordinate.dart';

class OpenNode{
  Coordinate point;
  double distance;
  List<Coordinate> passedState;

  OpenNode(this.point, this.distance, this.passedState);
}