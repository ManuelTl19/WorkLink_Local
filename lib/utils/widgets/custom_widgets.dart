import 'dart:ui';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/utils.dart';
import 'package:shimmer/shimmer.dart';

import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

class CustomWidgets {
  static Widget imageLoader({required Color color}) {
    return SizedBox.expand(child: LinearProgressIndicator(color: color));
  }

  static Widget mProgress(Color color) {
    return Center(
      key: const Key('loading'),
      child: SpinKitThreeBounce(
        color: color,
        size: 30.w,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static isNetwork(String path) {
    if (path.contains('http')) {
      return true;
    } else {
      return false;
    }
  }

  static Widget lottieIcon({
    required String path,
    bool repeat = true,
    reverse = false,
    animate = true,
    Duration? repeatAfter,
    BoxFit boxFit = BoxFit.contain,
    double? width,
    height,
    AnimationController? controller,
    Color? color,
  }) {
    if (isNetwork(path)) {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(
          color ?? Style.getPrimaryColor(),
          BlendMode.srcATop,
        ),
        child: Lottie.network(
          path,
          controller: controller,
          width: width,
          height: height,
          fit: boxFit,
          repeat: repeat,
          reverse: reverse,
          animate: animate,
          onLoaded: (composition) {
            if (repeatAfter != null && controller != null) {
              controller
                ..duration = composition.duration
                ..addStatusListener((status) async {
                  if (status == AnimationStatus.completed) {
                    await Future.delayed(repeatAfter);
                    controller.reset();
                    controller.forward();
                  }
                });
              controller.forward();
            }
          },
          delegates: LottieDelegates(
            values: [
              ValueDelegate.color(
                // keyPath order: ['layer name', 'group name', 'shape name']
                const ['**', 'Path 1', '**'],
                value: color ?? Style.getPrimaryColor(),
              ),
            ],
          ),
        ),
      );
    } else {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(
          color ?? Style.getPrimaryColor(),
          BlendMode.srcATop,
        ),
        child: Lottie.asset(
          path,
          controller: controller,
          width: width,
          height: height,
          fit: boxFit,
          repeat: repeat,
          reverse: reverse,
          animate: animate,
          onLoaded: (composition) {
            if (repeatAfter != null && controller != null) {
              controller
                ..duration = composition.duration
                ..addStatusListener((status) async {
                  if (status == AnimationStatus.completed) {
                    await Future.delayed(repeatAfter);
                    try {
                      controller.reset();
                      controller.forward();
                    } catch (e) {
                      logWarning('AnimationController ya fue disposeado: $e');
                    }
                  }
                });
              try {
                controller.forward();
              } catch (e) {
                logWarning('Error al iniciar animación: $e');
              }
            }
          },

          delegates: LottieDelegates(
            values: [
              ValueDelegate.color(const [
                '**',
                'Path 1',
                '**',
              ], value: color ?? Style.getPrimaryColor()),
            ],
          ),
        ),
      );
    }
  }

  static Widget blurEffect({required Widget child, required double sigma}) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: child,
    );
  }

  static Widget button({
    required Function onTap,
    required Widget child,
    required Color color,
    int shape = 0,
    Color? backgroundColor,
    bool isFilled = true,
    bool withBorder = false,
    bool elevation = true,
    double height = 50,
  }) {
    OutlinedBorder outline = RoundedRectangleBorder(
      borderRadius: Style.getButtonBorderRadius(),
    );
    if (shape == 1) {
      outline = RoundedRectangleBorder(borderRadius: Style.getBorderRadius());
    } else if (shape == 2) {
      outline = CircleBorder();
    }

    return SizedBox(
      child: ElevatedButton(
        onPressed: () => onTap(),
        style: ElevatedButton.styleFrom(
          backgroundColor: isFilled ? color : backgroundColor,
          padding: EdgeInsets.all(8.w),
          elevation: elevation ? 5 : 0,
          shadowColor: Style.getShadowColor(),
          shape: outline,
          alignment: Alignment.center,
          side: withBorder
              ? BorderSide(color: color, width: 1.w)
              : BorderSide.none,
        ),
        child: child,
      ),
    );
  }

  static Widget box({
    IconData? icon,
    String? asset,
    bool? animate,
    int maxlines = 1,
    required Color color,
    required String title,
    required int quantity,
    Function()? onTap,
  }) {
    Widget? graphic;

    if (icon != null) {
      graphic = Icon(icon, color: color);
    }

    if (asset != null) {
      if (asset.endsWith('.json') || asset.endsWith('.lottie')) {
        graphic = lottieIcon(
          path: asset,
          color: color,
          width: 20.w,
          height: 20.w,
          animate: animate,
        );
      } else {
        graphic = Image.asset(
          asset,
          width: 20.w,
          fit: BoxFit.contain,
          color: color,
        );
      }
    }

    return Card(
      color: Style.getCardColor(),
      surfaceTintColor: color,
      shape: RoundedRectangleBorder(borderRadius: Style.getBorderRadius()),
      elevation: 4,
      shadowColor: Style.getShadowColor(),
      child: InkWell(
        onTap: onTap,
        borderRadius: Style.getBorderRadius(),
        child: Padding(
          padding: Style.getCardPadding(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (graphic != null)
                Container(
                  padding: Style.getPaddingAll(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(100),
                    borderRadius: Style.getBorderRadius(),
                  ),
                  child: Center(child: graphic),
                ),
              SizedBox(width: 10.w),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: maxlines == 1 ? null : 25.h,
                      child: Center(
                        child: Text(
                          title,
                          maxLines: maxlines,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: Style.getTextStyle(),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(6.h),
                      decoration: BoxDecoration(
                        color: Style.getTextColor().withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$quantity',
                        style: TextStyle(
                          color: Style.getTextColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget boxLoader({required Color color}) {
    return Card(
      color: Style.getCardColor(),
      surfaceTintColor: color,
      shape: RoundedRectangleBorder(borderRadius: Style.getBorderRadius()),
      elevation: 4,
      shadowColor: Style.getShadowColor(),
      child: Shimmer.fromColors(
        baseColor: Style.getCardColor(),
        highlightColor: color.withValues(alpha: 0.2),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: Style.getBorderRadius(),
            color: Style.getCardColor(),
          ),
        ),
      ),
    );
  }

  static Widget wipBadge() {
    return Transform.rotate(
      angle: 25 * 3.1415926535897932 / 180,
      child: Opacity(
        opacity: 0.7,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange.withAlpha(200),
            borderRadius: Style.getBorderRadius(),
          ),
          child: Text(
            'Pronto',
            style: Style.getTextStyle(color: Style.white, fontSize: 5),
          ),
        ),
      ),
    );
  }
}

class VideoItemWidget extends StatefulWidget {
  final int pageIndex;
  final int currentPageIndex;
  final bool isPaused;
  final bool repeat;
  final String video;
  final void Function()? videoEnded;

  const VideoItemWidget({
    super.key,
    required this.video,
    required this.pageIndex,
    required this.currentPageIndex,
    required this.isPaused,
    this.repeat = true,
    this.videoEnded,
  });

  @override
  State<StatefulWidget> createState() => _VideoItemWidgetState();
}

class _VideoItemWidgetState extends State<VideoItemWidget> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    try {
      _videoPlayerController = VideoPlayerController.asset(widget.video);

      logImportant('Video: ${widget.video}');

      _videoPlayerController.addListener(() {
        setState(() {});
      });
      _videoPlayerController.setVolume(0);
      _videoPlayerController.setLooping(true);
      _videoPlayerController.initialize().then(
        (_) => setState(() {
          _videoPlayerController.play();
          logInfo('Video Initialized');
        }),
      );

      _videoPlayerController.addListener(() {
        if (_videoPlayerController.value.position ==
            _videoPlayerController.value.duration) {
          if (widget.videoEnded != null) {
            widget.videoEnded!();
          }
          if (widget.repeat) {
            _videoPlayerController.seekTo(Duration.zero);
          }
        }
      });

      _videoPlayerController.play();
    } on Exception catch (e) {
      logError('Video Error: $e');
    }
  }

  @override
  setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _videoPlayerController.value.isInitialized
          ? Stack(
              fit: StackFit.expand,
              children: [
                AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoPlayerController.value.size.width,
                      height: _videoPlayerController.value.size.height,
                      child: VideoPlayer(_videoPlayerController),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              height: 100.h,
              width: 100.h,
              alignment: Alignment.center,
              child: Image.asset(Assets.companyHorDarkLogo, fit: BoxFit.cover),
            ),
    );
  }
}

class PopupAction {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  PopupAction({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
}

class CustomPopupActions extends StatelessWidget {
  final List<PopupAction> actions;
  final Color? backgroundColor;

  const CustomPopupActions({
    super.key,
    required this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: backgroundColor ?? Style.getCardColor().darken(.1),
      onSelected: (value) {
        final action = actions.firstWhere((a) => a.value == value);
        action.onPressed.call();
      },
      itemBuilder: (context) => actions.map((action) {
        return PopupMenuItem(
          value: action.value,
          child: Row(
            children: [
              Icon(action.icon, size: 18, color: action.color),
              const SizedBox(width: 8),
              Text(action.label, style: Style.getTextStyle()),
            ],
          ),
        );
      }).toList(),
      icon: Icon(Icons.more_vert, color: Style.getTextColor()),
      shape: RoundedRectangleBorder(borderRadius: Style.getBorderRadius()),
    );
  }
}
