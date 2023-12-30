import 'dart:async';
import 'dart:developer';

import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vectorMath;

class ObjectGesturesWidgetLocalGltf extends StatefulWidget {
  const ObjectGesturesWidgetLocalGltf({super.key});
  @override
  _ObjectGesturesWidgetState createState() => _ObjectGesturesWidgetState();
}

class _ObjectGesturesWidgetState extends State<ObjectGesturesWidgetLocalGltf>
    with TickerProviderStateMixin {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];

  @override
  void dispose() {
    super.dispose();
    arSessionManager!.dispose();
  }

  double initialScale = 0.2;
  double currentScale = 0.2;
  Offset currentFocalPoint = const Offset(0, 0);

  double? displacementInX;
  double? positionChangedInX;
  double? positionChangedInY;
  @override
  void initState() {
    displacementInX = 0.02;
    positionChangedInX = 0.0;
    positionChangedInY = 0.0;
    super.initState();
  }

  bool isLongPressActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oobject Transformation Gestures'),
      ),
      body: GestureDetector(
        //taps, long-presses, double-taps, pans, scales, vertical and horizontal drags, and many more.
        onLongPress: () {
          setState(() {
            isLongPressActive = !isLongPressActive;
          });
        },
        onScaleStart: (ScaleStartDetails scaleStartDetails) {
          if (scaleStartDetails.pointerCount != 1) {
            initialScale = currentScale;
          }
        },
        onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
          if (isLongPressActive) {
            setState(() {
              changeObjectsPosition(
                  currentFocalPoint.dx,
                  scaleDetails.focalPoint.dx,
                  currentFocalPoint.dy,
                  scaleDetails.focalPoint.dy);
              currentFocalPoint = scaleDetails.focalPoint;
            });
          } else {
            if (scaleDetails.scale != 1.0) {
              setState(() {
                currentScale = initialScale * scaleDetails.scale;
                if (nodes.isNotEmpty) {
                  pinchZoom();
                }
              });
            } else {
              setState(() {
                rotateHorizontallyYaxis(
                    currentFocalPoint.dx, scaleDetails.focalPoint.dx);
                currentFocalPoint = scaleDetails.focalPoint;
              });
            }
          }
        },

        onScaleEnd: (ScaleEndDetails scaleEndDetails) {
          if (scaleEndDetails.pointerCount != 1) {
            initialScale = currentScale;
          }
        },
        child: Stack(
          children: [
            ARView(
              onARViewCreated: onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            ),
            Align(
              alignment: FractionalOffset.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ActionButtons(
                    onTap: removeAnObject,
                    icon: Icons.delete,
                  ),
                  ActionButtons(
                    onTap: removeAnObject,
                    icon: Icons.rotate_90_degrees_ccw,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager!.onInitialize(
          showFeaturePoints: false,
          showPlanes: true,
          customPlaneTexturePath: "assets/triangle.png",
          showWorldOrigin: true,
          handlePans: true,
          handleRotation: true,
        );

    this.arObjectManager!.onInitialize();
    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arObjectManager!.onPanStart = onPanStarted;
    this.arObjectManager!.onPanChange = onPanChanged;
    this.arObjectManager!.onPanEnd = onPanEnded;
    this.arObjectManager!.onNodeTap = onNodeTap;
  }

  Future<void> onRemoveEverything() async {
    for (var anchor in anchors) {
      arAnchorManager!.removeAnchor(anchor);
    }
    anchors = [];
  }

  Future<void> onPlaneOrPointTapped(
      List<ARHitTestResult> hitTestResults) async {
    var singleHitTestResult = hitTestResults.firstWhere(
        (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    var newAnchor =
        ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
    bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);
    if (didAddAnchor!) {
      anchors.add(newAnchor);
      var newNode = ARNode(
          type: NodeType.localGLTF2,
          uri: "assets/Chicken_01/Chicken_01.gltf",
          scale: vectorMath.Vector3(0.2, 0.2, 0.2),
          position: vectorMath.Vector3(0.0, 0.0, 0.0),
          rotation: vectorMath.Vector4(1.0, 0.0, 0.0, 0.0));
      bool? didAddNodeToAnchor =
          await arObjectManager!.addNode(newNode, planeAnchor: newAnchor);
      if (didAddNodeToAnchor!) {
        nodes.add(newNode);
      } else {
        arSessionManager!.onError("Adding Node to Anchor failed");
      }
    } else {
      arSessionManager!.onError("Adding Anchor failed");
    }
  }

  dynamic globalNodeName;

  void onPanStarted(String nodeName) {
    log('onPanStarted');
    log("Started panning node $nodeName");
  }

  void onNodeTap(List nodeName) {
    log('onNodeTap');
    globalNodeName = nodeName.first;
  }

  void removeAnObject() {
    if (nodes.isNotEmpty) {
      final pannedNode =
          nodes.indexWhere((element) => element.name == globalNodeName);
      ARAnchor anchorsRemove = anchors.removeAt(pannedNode);
      arAnchorManager!.removeAnchor(anchorsRemove);
    }
  }

  void onPanChanged(String nodeName) {
    log("Continued panning node $nodeName");
  }

  void changeObjectsPosition(double initialXValue, double finalXValue,
      double initialYValue, double finalYValue) {
    double changeFactor = 0.004;
    if (initialXValue > finalXValue) {
      positionChangedInX = positionChangedInX! - changeFactor;
    } else {
      positionChangedInX = positionChangedInX! + changeFactor;
    }

    if (initialYValue > finalYValue) {
      positionChangedInY = positionChangedInY! - changeFactor;
    } else {
      positionChangedInY = positionChangedInY! + changeFactor;
    }
    if (nodes.isNotEmpty) {
      final draggedNode =
          nodes.firstWhere((element) => element.name == globalNodeName);
      draggedNode.position = vectorMath.Vector3(
        draggedNode.position.x = positionChangedInX!,
        draggedNode.position.y,
        draggedNode.position.z =
            positionChangedInY!, // x and y because of the way the axis are disposed in the scene
      );
    }
  }

  void rotateHorizontallyYaxis(double initialYValue, double finalYValue) {
    if (initialYValue > finalYValue) {
      displacementInX = displacementInX! + .04;
    } else {
      displacementInX = displacementInX! - .04;
    }
    if (nodes.isNotEmpty) {
      final pannedNode =
          nodes.firstWhere((element) => element.name == globalNodeName);

      pannedNode.rotation = vectorMath.Matrix3.rotationY(displacementInX!);
    }
  }

  void pinchZoom() {
    if (nodes.isNotEmpty) {
      final pannedNode =
          nodes.firstWhere((element) => element.name == globalNodeName);
      pannedNode.scale =
          vectorMath.Vector3(currentScale, currentScale, currentScale);
    }
  }

  onPanEnded(String nodeName, Matrix4 newTransform) {
    log("Ended panning node $nodeName");
    final pannedNode = nodes.firstWhere((element) => element.name == nodeName);
  }
}

class ActionButtons extends StatelessWidget {
  final Function onTap;
  final IconData icon;
  const ActionButtons({super.key, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap.call(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.all(16.0),
      ),
      child: Icon(
        icon,
        size: 28.0,
        color: Colors.white,
      ),
    );
  }
}
