import 'package:augmented_reality/provider/ar_mobile_view_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/bottom_sheet_provider.dart';
import '../../../widgets/custom_bottom_sheet.dart';

class ArBottomSheet extends StatefulWidget {
  const ArBottomSheet({super.key});

  @override
  State<ArBottomSheet> createState() => _ArBottomSheetState();
}

class _ArBottomSheetState extends State<ArBottomSheet> {
  @override
  Widget build(BuildContext context) {
    BottomSheetProvider bottomSheetProvider =
        context.watch<BottomSheetProvider>();
    List<ModelsListViewModel> currentViewModelsList =
        bottomSheetProvider.getModelsListViewModel();

    double screenWidth = MediaQuery.of(context).size.width;
    double amountOfRows = ((currentViewModelsList.length / 3).ceil()) * 1.0;
    double widthPerTile = amountOfRows * ((screenWidth) / 3).floor() * 1.0;
    double gridviewWidth = screenWidth - 32;
    ScrollController scrollController = ScrollController();
    ArViewProvider arMobileViewProvider = context.watch<ArViewProvider>();

    return CustomBottomSheet(
      onTapCloseIcon: () {
        bottomSheetProvider.hideAddModelBottomSheet();
      },
      header: const Text(
        'Current Models',
      ),
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: SizedBox(
              height: amountOfRows * widthPerTile,
              width: gridviewWidth,
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(
                  currentViewModelsList.length,
                  (index) {
                    return bottomSheetProvider.displayAvailableModelsButton(
                        currentViewModelsList[index].image, () {
                      arMobileViewProvider.setCurrent3dModelUrl(
                          currentViewModelsList[index].modelUrl);
                      bottomSheetProvider.hideAddModelBottomSheet();
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      maxChildSize: 0.8,
      scrollController: scrollController,
    );
  }
}
