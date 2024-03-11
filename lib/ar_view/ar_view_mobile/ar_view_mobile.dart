import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/ar_mobile_view_provider.dart';
import '../../provider/bottom_sheet_provider.dart';
import 'actionButton.dart';
import 'ar_bottom_sheet.dart';

class ArViewMobile extends StatefulWidget {
  const ArViewMobile({
    super.key,
  });
  @override
  _ObjectGesturesWidgetState createState() => _ObjectGesturesWidgetState();
}

class _ObjectGesturesWidgetState extends State<ArViewMobile>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    ArViewProvider arViewProvider = context.watch<ArViewProvider>();
    BottomSheetProvider bottomSheetProvider =
        context.watch<BottomSheetProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Object Display'),
      ),
      body: GestureDetector(
        onLongPress: () {
          arViewProvider.onLongPress(context);
        },
        onScaleStart: (ScaleStartDetails scaleStartDetails) {
          arViewProvider.onScaleStart(scaleStartDetails);
        },
        onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
          arViewProvider.onScaleUpdate(scaleDetails, context);
        },
        onScaleEnd: (ScaleEndDetails scaleEndDetails) {
          arViewProvider.onScaleEnd(scaleEndDetails);
        },
        child: Stack(
          children: [
            ARView(
              onARViewCreated: arViewProvider.onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            ),
            Align(
              alignment: FractionalOffset.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ActionButtons(
                    onTap: () {
                      arViewProvider.removeAnObject();
                    },
                    icon: Icons.delete,
                  ),
                  ActionButtons(
                    onTap: () {
                      arViewProvider.rotate90degreesLeft();
                    },
                    icon: Icons.rotate_90_degrees_ccw,
                  ),
                  ActionButtons(
                    onTap: () {
                      arViewProvider.rotate90degreesRight();
                    },
                    icon: Icons.rotate_90_degrees_cw,
                  ),
                  ActionButtons(
                    onTap: () {
                      bottomSheetProvider.showAddModelBottomSheet();
                    },
                    icon: Icons.settings,
                  ),
                ],
              ),
            ),
            if (bottomSheetProvider.isShowingAddModelBottomSheet)
              const ArBottomSheet()
          ],
        ),
      ),
    );
  }
}
