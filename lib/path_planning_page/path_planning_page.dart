import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_planning_app/path_extraction_page/models/open_node.dart';
import 'package:path_planning_app/path_extraction_page/models/pixel.dart';

import '../models/dio_model.dart';
import '../path_extraction_page/models/coordinate.dart';

class PathPlanningPage extends StatefulWidget {
  const PathPlanningPage({super.key});

  @override
  State<PathPlanningPage> createState() => _PathPlanningPageState();
}

class _PathPlanningPageState extends State<PathPlanningPage> {
  late XFile currentImage;
  late Uint8List currentImageBytes;
  late Uint8List resultImageBytes;

  late Offset dragStartOffset;
  late double verticalControllerOffsetOnDragStart;
  late double horizontalControllerOffsetOnDragStart;

  bool isShowingResultImage = true;

  final DioModel dioModel = DioModel();

  PainterController painterController = PainterController();

  getRoadNetwork() async {
    try {
      Response response;

      response = await dioModel.dio.post(
        '/roadNetworkConstruction',
        data: "\"data:image/png;base64,${base64Encode(resultImageBytes)}\"",
      );
      for (var point in response.data) {
        painterController.roadNetworkPoints.add(
          Offset(
            (point['y'] as int).toDouble(),
            (point['x'] as int).toDouble(),
          ),
        );
      }
    } catch (e) {}
  }

  late List<List<Pixel>> pixelsMatrix = [];
  late List<Coordinate> pendingPixelsArray = [];
  int field = 1;

  initPathPlanningArea() {
    img.Image? pixels = img.decodeImage(resultImageBytes);
    for (int i = 0; i < 1024; i++) {
      List<Pixel> pixelsRow = [];
      for (int j = 0; j < 1024; j++) {
        pixelsRow.add(
          Pixel(
            pixels!.getPixel(i, j).r.toInt(),
          ),
        );
      }
      pixelsMatrix.add(pixelsRow);
    }
    for (int i = 0; i < 1024; i++) {
      for (int j = 0; j < 1024; j++) {
        if (pixelsMatrix[i][j].color == 255) {
          int depth = 1;
          int weight = 1;
          while (true) {
            if (i - depth >= 0 && j - depth >= 0) {
              if (pixelsMatrix[i - depth][j - depth].color == 0) {
                break;
              }
            }
            if (i - depth >= 0) {
              if (pixelsMatrix[i - depth][j].color == 0) {
                break;
              }
            }
            if (i - depth >= 0 && j + depth < 1024) {
              if (pixelsMatrix[i - depth][j + depth].color == 0) {
                break;
              }
            }
            if (j - depth >= 0) {
              if (pixelsMatrix[i][j - depth].color == 0) {
                break;
              }
            }
            if (j + depth < 1024) {
              if (pixelsMatrix[i][j + depth].color == 0) {
                break;
              }
            }
            if (i + depth < 1024 && j - depth >= 0) {
              if (pixelsMatrix[i + depth][j - depth].color == 0) {
                break;
              }
            }
            if (i + depth < 1024) {
              if (pixelsMatrix[i + depth][j].color == 0) {
                break;
              }
            }
            if (i + depth < 1024 && j + depth < 1024) {
              if (pixelsMatrix[i + depth][j + depth].color == 0) {
                break;
              }
            }
            depth++;
            if (depth % 2 == 0) {
              weight += 2;
            }
          }
          pixelsMatrix[i][j].weight = weight;
        }
        if (pixelsMatrix[i][j].color == 255 && pixelsMatrix[i][j].field == 0) {
          pendingPixelsArray.add(
            Coordinate(i, j),
          );
          while (pendingPixelsArray.isNotEmpty) {
            int i = pendingPixelsArray[0].x;
            int j = pendingPixelsArray[0].y;
            infectField(i, j);
            pendingPixelsArray.removeAt(0);
          }
          field++;
        }
      }
    }
  }

  infectField(int i, int j) {
    if (pixelsMatrix[i][j].color == 255 && pixelsMatrix[i][j].field == 0) {
      pixelsMatrix[i][j].field = field;
    }
    if (i - 1 >= 0 && j - 1 >= 0) {
      if (pixelsMatrix[i - 1][j - 1].color == 255 && pixelsMatrix[i - 1][j - 1].field == 0) {
        pixelsMatrix[i - 1][j - 1].field = field;
        pendingPixelsArray.add(
          Coordinate(
            i - 1,
            j - 1,
          ),
        );
      }
    }
    if (i - 1 >= 0) {
      if (pixelsMatrix[i - 1][j].color == 255 && pixelsMatrix[i - 1][j].field == 0) {
        pixelsMatrix[i - 1][j].field = field;
        pendingPixelsArray.add(
          Coordinate(
            i - 1,
            j,
          ),
        );
      }
    }
    if (i - 1 >= 0 && j + 1 < 1024) {
      if (pixelsMatrix[i - 1][j + 1].color == 255 && pixelsMatrix[i - 1][j + 1].field == 0) {
        pixelsMatrix[i - 1][j + 1].field = field;
        pendingPixelsArray.add(
          Coordinate(
            i - 1,
            j + 1,
          ),
        );
      }
    }
    if (j - 1 >= 0) {
      if (pixelsMatrix[i][j - 1].color == 255 && pixelsMatrix[i][j - 1].field == 0) {
        pixelsMatrix[i][j - 1].field = field;
        pendingPixelsArray.add(
          Coordinate(
            i,
            j - 1,
          ),
        );
      }
    }
    if (j + 1 < 1024) {
      if (pixelsMatrix[i][j + 1].color == 255 && pixelsMatrix[i][j + 1].field == 0) {
        pixelsMatrix[i][j + 1].field = field;
        pendingPixelsArray.add(
          Coordinate(
            i,
            j + 1,
          ),
        );
      }
    }
    if (i + 1 < 1024 && j - 1 >= 0) {
      if (pixelsMatrix[i + 1][j - 1].color == 255 && pixelsMatrix[i + 1][j - 1].field == 0) {
        pixelsMatrix[i + 1][j - 1].field = field;
        pendingPixelsArray.add(
          Coordinate(
            i + 1,
            j - 1,
          ),
        );
      }
    }
    if (i + 1 < 1024) {
      if (pixelsMatrix[i + 1][j].color == 255 && pixelsMatrix[i + 1][j].field == 0) {
        pixelsMatrix[i + 1][j].field = field;
        pendingPixelsArray.add(
          Coordinate(
            i + 1,
            j,
          ),
        );
      }
    }
    if (i + 1 < 1024 && j + 1 < 1024) {
      if (pixelsMatrix[i + 1][j + 1].color == 255 && pixelsMatrix[i + 1][j + 1].field == 0) {
        pixelsMatrix[i + 1][j + 1].field = field;
        pendingPixelsArray.add(
          Coordinate(
            i + 1,
            j + 1,
          ),
        );
      }
    }
  }

  int selectedField = 0;
  bool isSelectedInvalid = false;

  getClickPixel(Offset clickPosition) {
    int x = clickPosition.dx.toInt();
    int y = clickPosition.dy.toInt();

    for (int i = 0; i < painterController.roadNetworkPoints.length; i++) {
      double distance = sqrt(
        pow(x - painterController.roadNetworkPoints[i].dx.toInt(), 2) + pow(y - painterController.roadNetworkPoints[i].dy.toInt(), 2),
      );
      if (distance < 6) {
        x = painterController.roadNetworkPoints[i].dx.toInt();
        y = painterController.roadNetworkPoints[i].dy.toInt();
      }
    }

    if (pixelsMatrix[x][y].color == 0) {
      int depth = 1;
      while (depth < 10) {
        if (x - depth >= 0 && y - depth >= 0) {
          if (pixelsMatrix[x - depth][y - depth].color == 255) {
            x = x - depth;
            y = y - depth;
            break;
          }
        }
        if (x - depth >= 0) {
          if (pixelsMatrix[x - depth][y].color == 255) {
            x = x - depth;
            y = y;
            break;
          }
        }
        if (x - depth >= 0 && y + depth < 1024) {
          if (pixelsMatrix[x - depth][y + depth].color == 255) {
            x = x - depth;
            y = y + depth;
            break;
          }
        }
        if (y - depth >= 0) {
          if (pixelsMatrix[x][y - depth].color == 255) {
            x = x;
            y = y - depth;
            break;
          }
        }
        if (y + depth < 1024) {
          if (pixelsMatrix[x][y + depth].color == 255) {
            x = x;
            y = y + depth;
            break;
          }
        }
        if (x + depth < 1024 && y - depth >= 0) {
          if (pixelsMatrix[x + depth][y - depth].color == 255) {
            x = x + depth;
            y = y - depth;
            break;
          }
        }
        if (x + depth < 1024) {
          if (pixelsMatrix[x + depth][y].color == 255) {
            x = x + depth;
            y = y;
            break;
          }
        }
        if (x + depth < 1024 && y + depth < 1024) {
          if (pixelsMatrix[x + depth][y + depth].color == 255) {
            x = x + depth;
            y = y + depth;
            break;
          }
        }
        depth++;
      }
    }

    if (pixelsMatrix[x][y].color == 255) {
      if (selectedField == 0) {
        selectedField = pixelsMatrix[x][y].field;
        painterController.selectedPoints.add(
          Offset(
            x.toDouble(),
            y.toDouble(),
          ),
        );
        isSelectedInvalid = false;
        hasPlanned = false;
      } else if (pixelsMatrix[x][y].field == selectedField) {
        painterController.selectedPoints.add(
          Offset(
            x.toDouble(),
            y.toDouble(),
          ),
        );
        isSelectedInvalid = false;
        hasPlanned = false;
      } else {
        isSelectedInvalid = true;
      }
    } else {
      isSelectedInvalid = true;
    }
    setState(() {});
  }

  double finalDistance = 0;
  bool hasPlanned = false;

  pathPlanning() {
    for (int i = 0; i < painterController.selectedPoints.length - 1; i++) {
      AStarAlgorithm(painterController.selectedPoints[i], painterController.selectedPoints[i + 1]);
    }
  }

  double calculateDistance(double g, Coordinate position, Coordinate destination) {
    double distance = sqrt(
      pow(destination.x - position.x, 2) + pow(destination.y - position.y, 2),
    );
    return g + distance - (pixelsMatrix[position.x][position.y].weight * 8);
  }

  repaintPath(List<Coordinate> path) {
    for (Coordinate point in path) {
      painterController.path.add(
        Offset(
          point.x.toDouble(),
          point.y.toDouble(),
        ),
      );
    }
    double distance = 0;
    for (int k = 0; k < path.length - 1; k++) {
      distance += sqrt(
        pow(path[k + 1].x - path[k].x, 2) + pow(path[k + 1].y - path[k].y, 2),
      );
    }
    finalDistance = distance;
    hasPlanned = true;
    setState(() {});
  }

  AStarAlgorithm(Offset start, Offset destination) {
    Coordinate startPoint = Coordinate(
      start.dx.toInt(),
      start.dy.toInt(),
    );
    Coordinate destinationPoint = Coordinate(
      destination.dx.toInt(),
      destination.dy.toInt(),
    );
    int i = startPoint.x;
    int j = startPoint.y;
    double g = 0;
    List<OpenNode> open = [];
    Set<Pixel> openSet = {};
    Set<Pixel> close = {};
    List<Coordinate> passedPointsArray = [];

    search(int pending_i, int pending_j) {
      if (pixelsMatrix[pending_i][pending_j].color == 255 && !openSet.contains(pixelsMatrix[pending_i][pending_j]) && !close.contains(pixelsMatrix[pending_i][pending_j])) {
        int temp_next_i = pending_i;
        int temp_next_j = pending_j;
        double temp_g = g + sqrt(pow(temp_next_i - i, 2) + pow(temp_next_j - j, 2));
        double distance = calculateDistance(temp_g, Coordinate(temp_next_i, temp_next_j), destinationPoint);
        List<Coordinate> copyPassedState = passedPointsArray.toList();
        copyPassedState.add(Coordinate(temp_next_i, temp_next_j));
        open.add(OpenNode(Coordinate(temp_next_i, temp_next_j), distance, copyPassedState));
        openSet.add(pixelsMatrix[pending_i][pending_j]);
      }
    }

    openSet.add(pixelsMatrix[i][j]);
    while (i != destinationPoint.x || j != destinationPoint.y) {
      close.add(pixelsMatrix[i][j]);
      openSet.remove(pixelsMatrix[i][j]);
      double minDistance = -1;
      int next_i = -1;
      int next_j = -1;
      if (i - 1 >= 0 && j - 1 >= 0) {
        search(i - 1, j - 1);
      }
      if (i - 1 >= 0) {
        search(i - 1, j);
      }
      if (i - 1 >= 0 && j + 1 < 1024) {
        search(i - 1, j + 1);
      }
      if (j - 1 >= 0) {
        search(i, j - 1);
      }
      if (j + 1 < 1024) {
        search(i, j + 1);
      }
      if (i + 1 < 1024 && j - 1 >= 0) {
        search(i + 1, j - 1);
      }
      if (i + 1 < 1024) {
        search(i + 1, j);
      }
      if (i + 1 < 1024 && j + 1 < 1024) {
        search(i + 1, j + 1);
      }
      int n = 0;
      for (int k = 0; k < open.length; k++) {
        minDistance = open[0].distance;
        n = 0;
        if (minDistance > open[k].distance) {
          n = k;
          minDistance = open[k].distance;
        }
      }
      next_i = open[n].point.x;
      next_j = open[n].point.y;
      passedPointsArray = open[n].passedState.toList();
      double distance = sqrt(pow(destination.dx.toInt() - next_i, 2) + pow(destination.dy.toInt() - next_j, 2));
      g = minDistance - distance + (pixelsMatrix[next_i][next_j].weight * 8);
      open.removeAt(n);
      i = next_i;
      j = next_j;
      passedPointsArray.add(Coordinate(i, j));
    }
    repaintPath(passedPointsArray);
  }

  late Future<dynamic> performInitActions;

  _performInitActions() async {
    currentImageBytes = await currentImage.readAsBytes();
    await getRoadNetwork();
    initPathPlanningArea();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Map<String, Object> arguments = ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    currentImage = arguments['currentImage'] as XFile;
    resultImageBytes = arguments['resultImageBytes'] as Uint8List;
    performInitActions = _performInitActions();
  }

  ScrollController verticalController = ScrollController();
  ScrollController horizontalController = ScrollController();

  @override
  void dispose() {
    verticalController.dispose();
    horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("路径规划"),
      ),
      body: FutureBuilder(
          future: performInitActions,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              case ConnectionState.active:
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              case ConnectionState.waiting:
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: SingleChildScrollView(
                                  physics: const ClampingScrollPhysics(),
                                  controller: verticalController,
                                  child: SingleChildScrollView(
                                    physics: const ClampingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    controller: horizontalController,
                                    child: SizedBox(
                                      height: 1024,
                                      width: 1024,
                                      child: GestureDetector(
                                        onTapUp: (tapDownDetails) {
                                          getClickPixel(tapDownDetails.localPosition);
                                        },
                                        onVerticalDragStart: (details) {
                                          dragStartOffset = details.localPosition;
                                          verticalControllerOffsetOnDragStart = verticalController.offset;
                                          horizontalControllerOffsetOnDragStart = horizontalController.offset;
                                        },
                                        onVerticalDragUpdate: (details) {
                                          double deltaY = details.localPosition.dy - dragStartOffset.dy;
                                          double deltaX = details.localPosition.dx - dragStartOffset.dx;

                                          verticalController.jumpTo(verticalControllerOffsetOnDragStart + deltaY);
                                          horizontalController.jumpTo(horizontalControllerOffsetOnDragStart + deltaX);
                                        },
                                        onHorizontalDragStart: (details) {
                                          dragStartOffset = details.localPosition;
                                          verticalControllerOffsetOnDragStart = verticalController.offset;
                                          horizontalControllerOffsetOnDragStart = horizontalController.offset;
                                        },
                                        onHorizontalDragUpdate: (details) {
                                          double deltaY = details.localPosition.dy - dragStartOffset.dy;
                                          double deltaX = details.localPosition.dx - dragStartOffset.dx;

                                          verticalController.jumpTo(verticalControllerOffsetOnDragStart + deltaY);
                                          horizontalController.jumpTo(horizontalControllerOffsetOnDragStart + deltaX);
                                        },
                                        child: CustomPaint(
                                          foregroundPainter: PathPlanningPainter(painterController),
                                          child: isShowingResultImage ? Image.memory(resultImageBytes) : Image.memory(currentImageBytes),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: painterController.selectedPoints.isEmpty
                                    ? null
                                    : () {
                                        selectedField = 0;
                                        painterController.selectedPoints = [];
                                        painterController.path = [];
                                        isSelectedInvalid = false;
                                        finalDistance = 0;
                                        hasPlanned = false;
                                        setState(() {});
                                      },
                                child: const Text("重新选择"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  isShowingResultImage = !isShowingResultImage;
                                  setState(() {});
                                },
                                child: const Text("切换背景图"),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              hasPlanned ? Text("总距离：$finalDistance") : Text("您已选择${painterController.selectedPoints.length}个点"),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: painterController.selectedPoints.isEmpty
                                    ? null
                                    : () {
                                        pathPlanning();
                                      },
                                child: const Text("路径规划"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              default:
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
            }
          }),
    );
  }
}

class PathPlanningPainter extends CustomPainter {
  PainterController painterController;

  PathPlanningPainter(this.painterController);

  Paint pointsPaint = Paint()
    ..color = Colors.green
    ..style = PaintingStyle.fill;

  Paint networkPointsPaint = Paint()
    ..color = Colors.red
    ..strokeWidth = 3.0
    ..style = PaintingStyle.stroke;

  Paint pathPaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    for (Offset point in painterController.selectedPoints) {
      canvas.drawCircle(point, 6, pointsPaint);
    }
    for (Offset point in painterController.roadNetworkPoints) {
      canvas.drawCircle(point, 6, networkPointsPaint);
    }
    for (Offset point in painterController.path) {
      canvas.drawCircle(point, 1, pathPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}

class PainterController {
  List<Offset> selectedPoints = [];
  List<Offset> roadNetworkPoints = [];
  List<Offset> path = [];
}
