import "package:flutter/material.dart";

class PropertyInfo extends StatelessWidget {
  final Widget leading;
  final String title;
  final String text;
  final Widget? trailing;

  const PropertyInfo({
    Key? key,
    required this.leading,
    required this.title,
    required this.text,
    required this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              leading,
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          theme.textTheme.bodyMedium!.copyWith(fontSize: 14.0),
                    ),
                    Text(
                      text,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
