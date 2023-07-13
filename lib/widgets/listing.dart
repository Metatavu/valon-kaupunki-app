import "package:flutter/material.dart";

class Listing extends StatefulWidget {
  final Widget? Function(BuildContext ctx, int index) builder;
  const Listing({required this.builder, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ListingState();
}

class _ListingState extends State<Listing> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: widget.builder,
    );
  }
}
