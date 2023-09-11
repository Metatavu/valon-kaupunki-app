import "package:flutter/material.dart";

class SmallListCard extends StatelessWidget {
  final int index;
  final Widget leftIcon;
  final String title;
  final String text;
  final Widget proceedIcon;
  final void Function()? onTap;
  final Widget? secondaryLabel;

  const SmallListCard({
    required this.index,
    required this.leftIcon,
    required this.title,
    required this.text,
    required this.proceedIcon,
    this.onTap,
    this.secondaryLabel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 60.0,
        child: Container(
          height: 60,
          decoration: const BoxDecoration(
            color: Colors.black38,
          ),
          padding: EdgeInsets.only(top: index == 0 ? 0.0 : 4.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: leftIcon,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
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
              const Spacer(),
              if (secondaryLabel != null) secondaryLabel!,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: proceedIcon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
