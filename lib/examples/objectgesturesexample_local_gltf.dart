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
import 'package:vector_math/vector_math_64.dart';

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
  Offset initialFocalPoint = const Offset(0, 0);
  Offset currentFocalPoint = const Offset(0, 0);

  double? rotationY;
  double? rotationZ;
  @override
  void initState() {
    rotationY = 0.02;
    rotationZ = 0.02;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oobject Transformation Gestures'),
      ),
      body: GestureDetector(
        onScaleStart: (ScaleStartDetails scaleStartDetails) {
          if (scaleStartDetails.pointerCount != 1) {
            initialScale = currentScale;
          } else {
            // initialFocalPoint = scaleStartDetails.focalPoint;
          }
        },
        onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
          if (scaleDetails.scale != 1.0) {
            setState(() {
              currentScale = initialScale * scaleDetails.scale;
              if (nodes.isNotEmpty) {
                increaseOne();
              }
            });
          } else {
            setState(() {
              if ((currentFocalPoint.dx - scaleDetails.focalPoint.dx).abs() >
                  (currentFocalPoint.dy - scaleDetails.focalPoint.dy).abs()) {
                rotateHorizontallyYaxis(
                    currentFocalPoint.dy, scaleDetails.focalPoint.dy);
              } else {
                rotateXaxis(currentFocalPoint.dx, scaleDetails.focalPoint.dx);
              }

              if (nodes.isNotEmpty) {
                final pannedNode = nodes
                    .firstWhere((element) => element.name == globalNodeName);

                // Combine rotations
                pannedNode.rotation = Matrix3.rotationY(rotationY!) *
                    Matrix3.rotationX(rotationZ!);
              }

              currentFocalPoint = scaleDetails.focalPoint;
            });
          }
        },
        onScaleEnd: (ScaleEndDetails scaleEndDetails) {
          if (scaleEndDetails.pointerCount != 1) {
            initialScale = currentScale;
          } else {
            //initialFocalPoint = currentFocalPoint;
          }
        },
        child: Stack(
          children: [
            ARView(
              onARViewCreated: onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            ),
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: removeOne,
                      child: const Text("Remove when tap")),
                  /*ElevatedButton(
                      onPressed: rotateHorizontallyYaxisButton(),
                      child: const Text("increase when tap")),*/
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
    log('onPlaneOrPointTapped');
    var singleHitTestResult = hitTestResults.firstWhere(
        (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    var newAnchor =
        ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
    bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);
    if (didAddAnchor!) {
      anchors.add(newAnchor);
      // Add note to anchor
      var newNode = ARNode(
          type: NodeType.localGLTF2,
          uri: "assets/Chicken_01/Chicken_01.gltf",
          scale: Vector3(0.2, 0.2, 0.2),
          position: Vector3(0.0, 0.0, 0.0),
          rotation: Vector4(1.0, 0.0, 0.0, 0.0));
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

  onPanStarted(String nodeName) {
    log('onPanStarted');
    log("Started panning node $nodeName");
  }

  onNodeTap(List nodeName) {
    log('onNodeTap');
    log(":${nodeName.length}:Started panning node :${nodeName.first}:${nodeName.runtimeType}");
    globalNodeName = nodeName.first;
  }

  removeOne() {
    final pannedNode =
        nodes.indexWhere((element) => element.name == globalNodeName);
    ARAnchor anchorsRemove = anchors.removeAt(pannedNode);
    arAnchorManager!.removeAnchor(anchorsRemove);
  }

  onPanChanged(String nodeName) {
    print('\n\n\naaaaaaaaaaa\n\n\n');
    /*  setState(() {
      final pannedNode =
          nodes.firstWhere((element) => element.name == globalNodeName);
      pannedNode.scale = Vector3(currentScale, currentScale, currentScale);

      AnimationController controller = AnimationController(
          vsync: this, duration: const Duration(seconds: 1));
      Animation<double> animation =
          Tween<double>(begin: .5 * math.pi, end: 0).animate(controller);

      pannedNode.transform = Matrix4.identity()..rotateX(animation.value);
      pannedNode.transform = Matrix4.identity()..rotateY(animation.value);
      pannedNode.transform = Matrix4.identity()..rotateZ(animation.value);
    });
*/
    log("Continued panning node $nodeName");
  }

  rotateHorizontallyYaxis(double initialYValue, double finalYValue) {
    if (initialYValue < finalYValue) {
      rotationY = rotationY! + .03;
    } else {
      rotationY = rotationY! - .03;
    }
    if (nodes.isNotEmpty) {
      final pannedNode =
          nodes.firstWhere((element) => element.name == globalNodeName);

      pannedNode.rotation = Matrix3.rotationY(rotationY!);
    }
  }

  rotateXaxis(double initialXValue, double finalXValue) {
    if (initialXValue < finalXValue) {
      rotationZ = rotationZ! + .03;
    } else {
      rotationZ = rotationZ! - .03;
    }
    if (nodes.isNotEmpty) {
      final pannedNode =
          nodes.firstWhere((element) => element.name == globalNodeName);
      pannedNode.rotation = Matrix3.rotationX(rotationZ!);

      // pannedNode.transform = Matrix4.rotationX(rotationZ);
    }
  }

  increaseOne() {
    if (nodes.isNotEmpty) {
      final pannedNode =
          nodes.firstWhere((element) => element.name == globalNodeName);
      pannedNode.scale = Vector3(currentScale, currentScale, currentScale);
    }
  }

  onPanEnded(String nodeName, Matrix4 newTransform) {
    log("Ended panning node $nodeName");
    final pannedNode = nodes.firstWhere((element) => element.name == nodeName);
  }
}

/*import 'dart:developer';

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
import 'package:vector_math/vector_math_64.dart';

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
  Offset initialFocalPoint = const Offset(0, 0);
  Offset currentFocalPoint = const Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oobject Transformation Gestures'),
      ),
      body: GestureDetector(
        onScaleStart: (ScaleStartDetails scaleStartDetails) {
          if (scaleStartDetails.pointerCount != 1) {
            initialScale = currentScale;
          } else {
            initialFocalPoint = scaleStartDetails.focalPoint;
          }
        },
        onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
          //scaleDetails.globalPosition > 0;
          if (scaleDetails.scale != 1.0) {
            setState(() {
              currentScale = initialScale * scaleDetails.scale;
              if (nodes.isNotEmpty) {
                increaseOne();
              }
            });
          } else {
            currentFocalPoint = scaleDetails.focalPoint;
          }
        },
        onScaleEnd: (ScaleEndDetails scaleEndDetails) {
          if (scaleEndDetails.pointerCount != 1) {
            initialScale = currentScale;
          } else {
            initialFocalPoint = currentFocalPoint;
          }
        },
        /* onPanUpdate: (details) {
          print("Continue${details.globalPosition.dx}");

          // Detecting drag/pan
          if (details.delta.dx > 0) {
            // print(details.delta.dx);
          } else {
            //print("Dragging in -X direction");
          }
          if (details.delta.dy > 0) {
            //print("Dragging in -Y direction");
          } else {
            //print("Dragging in +Y direction");
          }
        },*/

        child: Stack(
          children: [
            ARView(
              onARViewCreated: onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            ),
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: removeOne,
                      child: const Text("Remove when tap")),
                  ElevatedButton(
                      onPressed: increaseOne(),
                      child: const Text("increase when tap")),
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
    log('onPlaneOrPointTapped');
    var singleHitTestResult = hitTestResults.firstWhere(
        (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    var newAnchor =
        ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
    bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);
    if (didAddAnchor!) {
      anchors.add(newAnchor);
      // Add note to anchor
      var newNode = ARNode(
          type: NodeType.localGLTF2,
          uri: "assets/Chicken_01/Chicken_01.gltf",
          scale: Vector3(0.2, 0.2, 0.2),
          position: Vector3(0.0, 0.0, 0.0),
          rotation: Vector4(1.0, 0.0, 0.0, 0.0));
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

  onPanStarted(String nodeName) {
    log('onPanStarted');
    log("Started panning node $nodeName");
  }

  onNodeTap(List nodeName) {
    log('onNodeTap');
    log(":${nodeName.length}:Started panning node :${nodeName.first}:${nodeName.runtimeType}");
    globalNodeName = nodeName.first;
  }

  removeOne() {
    final pannedNode =
        nodes.indexWhere((element) => element.name == globalNodeName);
    ARAnchor anchorsRemove = anchors.removeAt(pannedNode);
    arAnchorManager!.removeAnchor(anchorsRemove);
  }

  onPanChanged(String nodeName) {
    print('\n\n\naaaaaaaaaaa\n\n\n');
    /*  setState(() {
      final pannedNode =
          nodes.firstWhere((element) => element.name == globalNodeName);
      pannedNode.scale = Vector3(currentScale, currentScale, currentScale);

      AnimationController controller = AnimationController(
          vsync: this, duration: const Duration(seconds: 1));
      Animation<double> animation =
          Tween<double>(begin: .5 * math.pi, end: 0).animate(controller);

      pannedNode.transform = Matrix4.identity()..rotateX(animation.value);
      pannedNode.transform = Matrix4.identity()..rotateY(animation.value);
      pannedNode.transform = Matrix4.identity()..rotateZ(animation.value);
    });
*/
    log("Continued panning node $nodeName");
  }

  rotateOne() {}

  increaseOne() {
    if (nodes.isNotEmpty) {
      final pannedNode =
          nodes.firstWhere((element) => element.name == globalNodeName);
      pannedNode.scale = Vector3(currentScale, currentScale, currentScale);
    }

    /*AnimationController controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    Animation<double> animation = Tween<double>(begin: .5 * math.pi, end: 0).animate(controller);

    pannedNode.transform = Matrix4.identity()..rotateX(animation.value);
    pannedNode.transform = Matrix4.identity()..rotateY(animation.value);
    pannedNode.transform = Matrix4.identity()..rotateZ(animation.value);*/
  }

  onPanEnded(String nodeName, Matrix4 newTransform) {
    log("Ended panning node $nodeName");
    final pannedNode = nodes.firstWhere((element) => element.name == nodeName);
  }
}
*/
/*
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
import 'package:vector_math/vector_math_64.dart';

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
  Offset initialFocalPoint = const Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oobject Transformation Gestures'),
      ),
      body: GestureDetector(
        onScaleStart: (ScaleStartDetails scaleStartDetails) {
          /*  if (scaleStartDetails.pointerCount == 1) {
            initialFocalPoint = scaleStartDetails.focalPoint;
          }*/
          initialScale = currentScale;
        },
        onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
          //scaleDetails.globalPosition > 0;
          if (scaleDetails.scale != 1.0) {
            setState(() {
              currentScale = initialScale * scaleDetails.scale;
              if (nodes.isNotEmpty) {
                increaseOne();
              }
            });
          }
        },
        onScaleEnd: (ScaleEndDetails scaleEndDetails) {
          initialScale = currentScale;
        },
        /* onPanUpdate: (details) {
          print("Continue${details.globalPosition.dx}");

          // Detecting drag/pan
          if (details.delta.dx > 0) {
            // print(details.delta.dx);
          } else {
            //print("Dragging in -X direction");
          }
          if (details.delta.dy > 0) {
            //print("Dragging in -Y direction");
          } else {
            //print("Dragging in +Y direction");
          }
        },*/

        child: Stack(
          children: [
            ARView(
              onARViewCreated: onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            ),
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: removeOne,
                      child: const Text("Remove when tap")),
                  ElevatedButton(
                      onPressed: increaseOne(),
                      child: const Text("increase when tap")),
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
    log('onPlaneOrPointTapped');
    var singleHitTestResult = hitTestResults.firstWhere(
        (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    var newAnchor =
        ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
    bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);
    if (didAddAnchor!) {
      anchors.add(newAnchor);
      // Add note to anchor
      var newNode = ARNode(
          type: NodeType.localGLTF2,
          uri: "assets/Chicken_01/Chicken_01.gltf",
          scale: Vector3(0.2, 0.2, 0.2),
          position: Vector3(0.0, 0.0, 0.0),
          rotation: Vector4(1.0, 0.0, 0.0, 0.0));
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

  onPanStarted(String nodeName) {
    log('onPanStarted');
    log("Started panning node $nodeName");
  }

  onNodeTap(List nodeName) {
    log('onNodeTap');
    log(":${nodeName.length}:Started panning node :${nodeName.first}:${nodeName.runtimeType}");
    globalNodeName = nodeName.first;
  }

  removeOne() {
    final pannedNode =
        nodes.indexWhere((element) => element.name == globalNodeName);
    ARAnchor anchorsRemove = anchors.removeAt(pannedNode);
    arAnchorManager!.removeAnchor(anchorsRemove);
  }

  onPanChanged(String nodeName) {
    log('onPanChanged');

    log("Continued panning node $nodeName");
  }

  rotateOne() {}

  increaseOne() {
    if (nodes.isNotEmpty) {
      final pannedNode =
          nodes.firstWhere((element) => element.name == globalNodeName);
      pannedNode.scale = Vector3(0.2, currentScale, 0.2);
    }

    /*AnimationController controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    Animation<double> animation = Tween<double>(begin: .5 * math.pi, end: 0).animate(controller);

    pannedNode.transform = Matrix4.identity()..rotateX(animation.value);
    pannedNode.transform = Matrix4.identity()..rotateY(animation.value);
    pannedNode.transform = Matrix4.identity()..rotateZ(animation.value);*/
  }

  onPanEnded(String nodeName, Matrix4 newTransform) {
    log("Ended panning node $nodeName");
    final pannedNode = nodes.firstWhere((element) => element.name == nodeName);
  }
}
*/

/*

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
import 'package:vector_math/vector_math_64.dart';

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
  Offset initialFocalPoint = const Offset(0, 0);
  Offset currentFocalPoint = const Offset(0, 0);
  double rotationY = 0.02;
  double rotationZ = 0.02;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oobject Transformation Gestures'),
      ),
      body: GestureDetector(
        onScaleStart: (ScaleStartDetails scaleStartDetails) {
          if (scaleStartDetails.pointerCount != 1) {
            initialScale = currentScale;
          } else {
            initialFocalPoint = scaleStartDetails.focalPoint;
          }
        },
        onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
          if (scaleDetails.scale != 1.0) {
            setState(() {
              currentScale = initialScale * scaleDetails.scale;
              if (nodes.isNotEmpty) {
                //increaseOne();
              }
            });
          } else {
            setState(() {
              if ((currentFocalPoint.dx - scaleDetails.focalPoint.dx).abs() >
                  (currentFocalPoint.dy - scaleDetails.focalPoint.dy).abs()) {
                rotateHorizontallyYaxis(
                    currentFocalPoint.dy, scaleDetails.focalPoint.dy);
              } else {
                rotateXaxis(currentFocalPoint.dx, scaleDetails.focalPoint.dx);
              }
              currentFocalPoint = scaleDetails.focalPoint;
            });
          }
        },
        onScaleEnd: (ScaleEndDetails scaleEndDetails) {
          if (scaleEndDetails.pointerCount != 1) {
            initialScale = currentScale;
          } else {
            //initialFocalPoint = currentFocalPoint;
          }
        },
        child: Stack(
          children: [
            ARView(
              onARViewCreated: onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            ),
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: removeOne,
                      child: const Text("Remove when tap")),
                  */
/*ElevatedButton(
                      onPressed: rotateHorizontallyYaxisButton(),
                      child: const Text("increase when tap")),*/ /*

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
    log('onPlaneOrPointTapped');
    var singleHitTestResult = hitTestResults.firstWhere(
            (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
    var newAnchor =
    ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
    bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);
    if (didAddAnchor!) {
      anchors.add(newAnchor);
      // Add note to anchor
      var newNode = ARNode(
          type: NodeType.localGLTF2,
          uri: "assets/Chicken_01/Chicken_01.gltf",
          scale: Vector3(0.2, 0.2, 0.2),
          position: Vector3(0.0, 0.0, 0.0),
          rotation: Vector4(1.0, 0.0, 0.0, 0.0));
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

  onPanStarted(String nodeName) {
    log('onPanStarted');
    log("Started panning node $nodeName");
  }

  onNodeTap(List nodeName) {
    log('onNodeTap');
    log(":${nodeName.length}:Started panning node :${nodeName.first}:${nodeName.runtimeType}");
    globalNodeName = nodeName.first;
  }

  removeOne() {
    final pannedNode =
    nodes.indexWhere((element) => element.name == globalNodeName);
    ARAnchor anchorsRemove = anchors.removeAt(pannedNode);
    arAnchorManager!.removeAnchor(anchorsRemove);
  }

  onPanChanged(String nodeName) {
    print('\n\n\naaaaaaaaaaa\n\n\n');
    */
/*  setState(() {
      final pannedNode =
          nodes.firstWhere((element) => element.name == globalNodeName);
      pannedNode.scale = Vector3(currentScale, currentScale, currentScale);

      AnimationController controller = AnimationController(
          vsync: this, duration: const Duration(seconds: 1));
      Animation<double> animation =
          Tween<double>(begin: .5 * math.pi, end: 0).animate(controller);

      pannedNode.transform = Matrix4.identity()..rotateX(animation.value);
      pannedNode.transform = Matrix4.identity()..rotateY(animation.value);
      pannedNode.transform = Matrix4.identity()..rotateZ(animation.value);
    });
*/ /*

    log("Continued panning node $nodeName");
  }

  rotateHorizontallyYaxis(double initialYValue, double finalYValue) {
    if (initialYValue > finalYValue) {
      rotationY = rotationY + .03;
    } else {
      rotationY = rotationY - .03;
    }
    if (nodes.isNotEmpty) {
      final pannedNode =
      nodes.firstWhere((element) => element.name == globalNodeName);

      pannedNode.transform = Matrix4.rotationY(rotationY);
    }
  }

  rotateXaxis(double initialXValue, double finalXValue) {
    if (initialXValue > finalXValue) {
      rotationZ = rotationZ + .03;
    } else {
      rotationZ = rotationZ - .03;
    }
    if (nodes.isNotEmpty) {
      final pannedNode =
      nodes.firstWhere((element) => element.name == globalNodeName);
      pannedNode.transform = Matrix4.rotationX(rotationZ);
    }
  }

  increaseOne() {
    if (nodes.isNotEmpty) {
      final pannedNode =
      nodes.firstWhere((element) => element.name == globalNodeName);
      pannedNode.scale = Vector3(currentScale, currentScale, currentScale);
    }
  }

  onPanEnded(String nodeName, Matrix4 newTransform) {
    log("Ended panning node $nodeName");
    final pannedNode = nodes.firstWhere((element) => element.name == nodeName);
  }
}
*/
