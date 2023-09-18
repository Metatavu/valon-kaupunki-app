import "package:flutter/material.dart";
import "package:valon_kaupunki_app/assets.dart";
import "package:valon_kaupunki_app/custom_theme_values.dart";

import "height_constrained_image.dart";

class SmallListCard extends StatelessWidget {
  final int index;
  final Widget leftIcon;
  final String title;
  final String text;
  final Widget proceedIcon;
  final void Function()? onTap;
  final Widget? secondaryLabel;
  final String? imageUrl;

  const SmallListCard({
    required this.index,
    required this.leftIcon,
    required this.title,
    required this.text,
    required this.proceedIcon,
    this.onTap,
    this.secondaryLabel,
    this.imageUrl,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Card(
        color: const Color.fromARGB(0x77, 0x00, 0x00, 0x00),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: CustomThemeValues.appOrange,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            imageUrl != null
                ? HeightConstrainedImage.network(
                    height: 200,
                    radius: 5,
                    url: imageUrl!,
                  )
                : Image.asset(
                    Assets.valonKaupunkiBackground,
                    height: 200,
                    width: Size.infinite.width,
                    fit: BoxFit.cover,
                  ),
            ListTile(
              leading: leftIcon,
              title: Text(
                title,
                overflow: TextOverflow.fade,
                style: theme.textTheme.bodyMedium!.copyWith(fontSize: 14.0),
              ),
              subtitle: Text(
                text,
                overflow: TextOverflow.fade,
                style: theme.textTheme.bodySmall,
              ),
              trailing: proceedIcon,
            ),
          ],
        ),
      ),
    );
  }
}
