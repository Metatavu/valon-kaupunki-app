import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

class FilterButton extends StatelessWidget {
  final String iconAsset;
  final String label;
  final Color color;
  final bool state;
  final bool noPad;

  final void Function()? onMarkerFilterUpdate;
  final void Function() onClick;

  const FilterButton({
    required this.iconAsset,
    required this.label,
    required this.color,
    required this.state,
    required this.onClick,
    this.onMarkerFilterUpdate,
    this.noPad = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var style = theme.outlinedButtonTheme.style!.copyWith(
      padding: const MaterialStatePropertyAll(
        EdgeInsets.only(left: 8.0, right: 8.0),
      ),
      side: MaterialStatePropertyAll(theme.outlinedButtonTheme.style!.side!
          .resolve({})!.copyWith(color: color)),
    );

    var textStyle = theme.outlinedButtonTheme.style!.textStyle!
        .resolve({})!.copyWith(color: color);
    var svgColor = color;

    if (state) {
      style = style.copyWith(
        backgroundColor: MaterialStatePropertyAll(color),
      );

      textStyle = textStyle.copyWith(
        color: Colors.black,
      );

      svgColor = Colors.black;
    }

    return Padding(
      padding: EdgeInsets.only(right: noPad ? 0.0 : 8.0),
      child: OutlinedButton(
        onPressed: () {
          onClick();
          onMarkerFilterUpdate?.call();
        },
        style: style,
        child: Row(
          children: [
            SvgPicture.asset(
              iconAsset,
              colorFilter: ColorFilter.mode(svgColor, BlendMode.srcIn),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                label,
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
