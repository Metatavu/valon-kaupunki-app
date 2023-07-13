import "package:flutter/material.dart";

class SmallListCard extends StatefulWidget {
  final int index;
  final Widget leftIcon;
  final String title;
  final String text;
  final Widget proceedIcon;

  const SmallListCard(
      {required this.index,
      required this.leftIcon,
      required this.title,
      required this.text,
      required this.proceedIcon,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SmallListCardState();
  }
}

class _SmallListCardState extends State<SmallListCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 60.0,
      child: Padding(
        padding: EdgeInsets.only(top: widget.index == 0 ? 0.0 : 4.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black38,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: widget.leftIcon,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      widget.text,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              widget.proceedIcon,
            ],
          ),
        ),
      ),
    );
  }
}