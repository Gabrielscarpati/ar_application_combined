import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

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

class ArViewProvider with ChangeNotifier {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];

  double initialScale = 0.2;
  double currentScale = 0.2;
  Offset currentFocalPoint = const Offset(0, 0);

  double? displacementInX;
  double? positionChangedInX;
  double? positionChangedInY;

  Map<String, double> nodeRotations = {};

  bool isLongPressActive = false;
  dynamic globalNodeName = "";
  String current3dModelUrl = '';

  void onLongPress(BuildContext context) {
    isLongPressActive = !isLongPressActive;

    Future.microtask(() {
      notifyListeners();
    });
  }

  void onScaleStart(ScaleStartDetails scaleStartDetails) {
    if (scaleStartDetails.pointerCount != 1) {
      initialScale = currentScale;
    }
  }

  void onScaleUpdate(ScaleUpdateDetails scaleDetails, BuildContext context) {
    if (isLongPressActive) {
      changeObjectsPosition(currentFocalPoint.dx, scaleDetails.focalPoint.dx,
          currentFocalPoint.dy, scaleDetails.focalPoint.dy);
      currentFocalPoint = scaleDetails.focalPoint;
      Future.microtask(() {
        notifyListeners();
      });
    } else {
      if (scaleDetails.scale != 1.0) {
        currentScale = initialScale * scaleDetails.scale;
        if (nodes.isNotEmpty) {
          pinchResize();
        }
        Future.microtask(() {
          notifyListeners();
        });
      } else {
        rotateHorizontallyYaxis(
            currentFocalPoint.dx, scaleDetails.focalPoint.dx);
        currentFocalPoint = scaleDetails.focalPoint;
        Future.microtask(() {
          notifyListeners();
        });
      }
    }
  }

  void onScaleEnd(ScaleEndDetails scaleEndDetails) {
    if (scaleEndDetails.pointerCount != 1) {
      initialScale = currentScale;
    }
  }

  void setCurrent3dModelUrl(String url, BuildContext context) {
    current3dModelUrl = url;
    print('aaaaaaaaaa' + current3dModelUrl);

    Future.microtask(() {
      notifyListeners();
    });
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
          showWorldOrigin: false,
          handlePans: true,
          handleRotation: true,
        );

    this.arObjectManager!.onInitialize();
    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
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
    print('bbbbbbbbbbbb' + current3dModelUrl);

    var singleHitTestResult = hitTestResults.firstWhere(
        (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    var newAnchor =
        ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
    bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);
    if (didAddAnchor!) {
      anchors.add(newAnchor);
      var newNode = ARNode(
          type: NodeType.webGLB,
          uri: current3dModelUrl,
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

  void onNodeTap(List nodeName) {
    log('onNodeTap');
    // Your implementation
  }

  void removeAnObject() {
    if (nodes.isNotEmpty) {
      final pannedNode =
          nodes.indexWhere((element) => element.name == globalNodeName);
      ARAnchor anchorsRemove = anchors.removeAt(pannedNode);
      arAnchorManager!.removeAnchor(anchorsRemove);
    }
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
        draggedNode.position.z = positionChangedInY!,
      );
    }
  }

  void rotate90degreesLeft() {
    if (nodes.isNotEmpty) {
      final rotatedNode =
          nodes.firstWhere((element) => element.name == globalNodeName);
      double currentRotation = nodeRotations[rotatedNode.name] ?? 0.0;
      double nextRotation = (currentRotation - math.pi / 2) % (2 * math.pi);
      nodeRotations[rotatedNode.name] = nextRotation;

      vectorMath.Matrix3 rotationMatrix =
          vectorMath.Matrix3.rotationY(nextRotation);

      rotatedNode.rotation = rotationMatrix;
    }
  }

  void rotate90degreesRight() {
    if (nodes.isNotEmpty) {
      final rotatedNode =
          nodes.firstWhere((element) => element.name == globalNodeName);
      double currentRotation = nodeRotations[rotatedNode.name] ?? 0.0;
      double nextRotation = (currentRotation + math.pi / 2) % (2 * math.pi);
      nodeRotations[rotatedNode.name] = nextRotation;

      vectorMath.Matrix3 rotationMatrix =
          vectorMath.Matrix3.rotationY(nextRotation);

      rotatedNode.rotation = rotationMatrix;
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

  void pinchResize() {
    if (nodes.isNotEmpty) {
      final pannedNode =
          nodes.firstWhere((element) => element.name == globalNodeName);
      pannedNode.scale =
          vectorMath.Vector3(currentScale, currentScale, currentScale);
    }
  }
}
