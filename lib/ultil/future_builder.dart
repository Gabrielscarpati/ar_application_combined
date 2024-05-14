import 'package:flutter/material.dart';

class DSFutureBuilder<T> extends StatelessWidget {
  final Future<T>? future;
  final Widget messageWhenEmpty;
  final Widget Function(BuildContext, AsyncSnapshot<T>) builder;

  const DSFutureBuilder({
    Key? key,
    required this.future,
    required this.builder,
    required this.messageWhenEmpty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        } else if (snapshot.hasData) {
          if (_isDataEmpty(snapshot.data)) {
            return messageWhenEmpty;
          } else {
            return builder(context, snapshot);
          }
        } else {
          return const Text('No data available');
        }
      },
    );
  }

  bool _isDataEmpty(dynamic data) {
    if (data is Iterable) {
      return data.isEmpty;
    }
    return false;
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: SizedBox(
        width: 100,
        height: 100,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Text('Error: $error'),
    );
  }
}
