import 'package:flutter/material.dart';

import 'choose_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ChooseScreen(),
    );
  }
}

//The basics are placing, sizing, rotation,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oobject Transformation Gestures'),
      ),
      body: Stack(
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
                /*ElevatedButton(
                    onPressed: onRemoveEverything,
                    child: const Text("Remove Everything")),*/
                ElevatedButton(
                    onPressed: removeOne, child: const Text("Remove when tap")),
                ElevatedButton(
                    onPressed: increaseOne,
                    child: const Text("increase when tap")),
              ],
            ),
          )
        ],
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

  increaseOne() {
    final pannedNode =
        nodes.firstWhere((element) => element.name == globalNodeName);

    pannedNode.scale = Vector3(0.2, pannedNode.scale.y + 0.2, 0.2);
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
