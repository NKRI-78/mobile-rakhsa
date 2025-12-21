import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
export 'package:lottie/lottie.dart';

class LottieAnimation extends StatelessWidget {
  const LottieAnimation(
    this.asset, {
    super.key,
    this.controller,
    this.animate,
    this.frameRate,
    this.repeat,
    this.reverse,
    this.delegates,
    this.options,
    this.onLoaded,
    this.imageProviderFactory,
    this.bundle,
    this.frameBuilder,
    this.errorBuilder,
    this.width,
    this.height,
    this.fit,
    this.alignment,
    this.package,
    this.addRepaintBoundary,
    this.filterQuality,
    this.onWarning,
    this.decoder,
    this.renderCache,
    this.backgroundLoading,
  });

  final String asset;
  final Animation<double>? controller;
  final bool? animate;
  final FrameRate? frameRate;
  final bool? repeat;
  final bool? reverse;
  final LottieDelegates? delegates;
  final LottieOptions? options;
  final void Function(LottieComposition)? onLoaded;
  final ImageProvider<Object>? Function(LottieImageAsset)? imageProviderFactory;
  final AssetBundle? bundle;
  final Widget Function(BuildContext, Widget, LottieComposition?)? frameBuilder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry? alignment;
  final String? package;
  final bool? addRepaintBoundary;
  final FilterQuality? filterQuality;
  final void Function(String)? onWarning;
  final Future<LottieComposition?> Function(List<int>)? decoder;
  final RenderCache? renderCache;
  final bool? backgroundLoading;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      asset,
      controller: controller,
      animate: animate,
      frameRate: frameRate,
      repeat: repeat,
      reverse: reverse,
      delegates: delegates,
      options: options,
      onLoaded: onLoaded,
      imageProviderFactory: imageProviderFactory,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      package: package,
      addRepaintBoundary: addRepaintBoundary,
      onWarning: onWarning,
      renderCache: renderCache,
      backgroundLoading: backgroundLoading,
      decoder: decoder ?? _customDecoder,
    );
  }

  Future<LottieComposition?> _customDecoder(List<int> bytes) {
    return LottieComposition.decodeZip(
      bytes,
      filePicker: (files) {
        return files.firstWhere(
          (f) => f.name.startsWith('animations/') && f.name.endsWith('.json'),
        );
      },
    );
  }
}
