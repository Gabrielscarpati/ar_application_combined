import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  final VoidCallback onTapCloseIcon;
  final Widget header;
  final Widget body;
  final double maxChildSize;
  final ScrollController scrollController;
  final double? minChildSize;
  final bool isScrollable;

  const CustomBottomSheet({
    Key? key,
    required this.onTapCloseIcon,
    required this.header,
    required this.body,
    required this.maxChildSize,
    required this.scrollController,
    this.minChildSize,
    this.isScrollable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: DraggableScrollableSheet(
        initialChildSize: minChildSize ?? 0.4,
        maxChildSize: maxChildSize,
        builder: (BuildContext context, ScrollController scrollController) {
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: isScrollable
                    ? ListView.builder(
                        controller: scrollController,
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 72),
                            child: body,
                          );
                        },
                      )
                    : ListView(
                        children: [body],
                      ),
              ),
              IgnorePointer(
                child: Container(
                  height: 72,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: 15,
                right: 16,
                child: DSIconButton(
                  color: Colors.grey,
                  height: 28,
                  width: 28,
                  iconSize: 24,
                  icon: Icons.close,
                  onTap: () {
                    onTapCloseIcon();
                  },
                ),
              ),
              Positioned(top: 24, left: 16, child: header),
            ],
          );
        },
      ),
    );
  }
}

class DSIconButton extends StatelessWidget {
  final Color color;
  final double height;
  final double width;
  final double iconSize;
  final IconData icon;
  final VoidCallback onTap;

  const DSIconButton({
    Key? key,
    required this.color,
    required this.height,
    required this.width,
    required this.iconSize,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(2, 2), // Shadow position
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: iconSize,
            color: Colors.white, // Icon color
          ),
        ),
      ),
    );
  }
}
