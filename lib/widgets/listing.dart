import "package:flutter/material.dart";

class Listing extends StatelessWidget {
  final Widget? Function(BuildContext ctx, int index) builder;
  final Widget? filter;

  const Listing({required this.builder, required this.filter, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        if (index == 0 && filter != null) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: filter!,
          );
        }

        return builder(context, index - (filter != null ? 1 : 0));
      },
    );
  }
}
