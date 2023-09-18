import "package:flutter/material.dart";

class Listing extends StatelessWidget {
  final int itemCount;
  final Widget? Function(BuildContext ctx, int index) builder;
  final Widget? filter;
  final String emptyMessage;
  final String? errorMessage;

  const Listing({
    required this.itemCount,
    required this.builder,
    required this.emptyMessage,
    this.filter,
    this.errorMessage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage.toString(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    if (itemCount == 0 && filter != null) {
      return ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: filter!,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Text(
                emptyMessage,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == 0 && filter != null) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: filter!,
              ),
              builder(context, index)!
            ],
          );
        } else {
          return builder(context, index);
        }
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8.0),
    );
  }
}
