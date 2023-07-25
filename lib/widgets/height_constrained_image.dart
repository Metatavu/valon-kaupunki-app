import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";

/// An image constrained only by height, without distorting its aspect ratio.
class HeightConstrainedImage extends StatelessWidget {
  final double height;
  final double radius;
  late final Widget image;

  HeightConstrainedImage({
    super.key,
    required this.height,
    required this.radius,
    required String asset,
  }) {
    image = asset.endsWith(".svg")
        ? SvgPicture.asset(
            asset,
            placeholderBuilder: (context) =>
                _loadingBuilder(context, null, null),
          )
        : Image.asset(asset);
  }

  HeightConstrainedImage.network({
    super.key,
    required this.height,
    required this.radius,
    required String url,
  }) {
    image = Image.network(
      url,
      loadingBuilder: _loadingBuilder,
      errorBuilder: (context, _, __) => _errorBuilder(context),
    );
  }

  Widget _errorBuilder(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: height,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Text(
            localizations.errorLoadingImageText,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }

  Widget _loadingBuilder(
      BuildContext context, Widget? child, ImageChunkEvent? event) {
    final placeholder = SizedBox(
      width: MediaQuery.of(context).size.width,
      height: height,
      child: Container(
        color: Colors.black38,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    if (child == null && event == null) {
      return placeholder;
    }

    return event == null ? child! : placeholder;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: image,
        ),
      ),
    );
  }
}
