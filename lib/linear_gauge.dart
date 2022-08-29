import 'package:flutter/material.dart';

// ignore: must_be_immutable
class LinearGauge extends StatefulWidget {
  ///fraction value
  late final double fraction;

  // Width of the linear_gauge
  final double? width;

  // Max number to reach
  final double max;

  ///Height of the line
  final double gaugeHeight;

  ///Color of the background of the Line , default = transparent
  final Color barColor;

  ///First color applied to the complete the gauge
  Color get backgroundColor => _backgroundColor;
  late Color _backgroundColor;

  Color get progressColor => _progressColor;

  late Color _progressColor;

  ///true if you want the Line to have animation
  final bool animation;

  ///duration of the animation in milliseconds, It only applies if animation attribute is true
  final int animationDuration;

  ///widget inside the gauge status
  final Widget? gaugeStatus;

  /// The border radius of the gauge
  final Radius? barRadius;

  ///alignment of the Row
  final MainAxisAlignment alignment;

  ///padding to the LinearGauge
  final EdgeInsets padding;

  /// set false if you don't want to preserve the state of the widget
  final bool addAutomaticKeepAlive;

  /// set a linear curve animation type
  final Curve curve;

  /// set true when you want to restart the animation
  /// defaults to false
  final bool restartAnimation;

  /// Callback called when the animation ends (only if `animation` is true)
  final VoidCallback? onAnimationEnd;

  /// Display a widget indicator at the end of the progress. It only works when `animation` is true
  final Widget? widgetIndicator;

  LinearGauge({
    Key? key,
    this.barColor = Colors.transparent,
    this.fraction = 0.0,
    this.gaugeHeight = 5.0,
    this.width,
    Color? backgroundColor,
    Color? progressColor,
    this.animation = false,
    this.animationDuration = 500,
    this.gaugeStatus,
    this.addAutomaticKeepAlive = true,
    this.barRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 10.0),
    this.alignment = MainAxisAlignment.start,
    this.curve = Curves.linear,
    this.restartAnimation = false,
    this.onAnimationEnd,
    this.widgetIndicator,
    this.max = 100.0,
  }) : super(key: key) {
    _progressColor = progressColor ?? Colors.deepOrangeAccent;
    _backgroundColor = backgroundColor ?? const Color(0xFFB8C7CB);


  }

  @override
  // ignore: library_private_types_in_public_api
  _LinearGaugeState createState() => _LinearGaugeState();
}

class _LinearGaugeState extends State<LinearGauge>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController? _animationController;
  Animation? _animation;
  double _fraction = 0.0;
  final _wholeContainerKey = GlobalKey();
  final _indicatorKey = GlobalKey();
  double _wholeContainerWidth = 0.0;
  double _wholeContainerHeight = 0.0;
  double _indicatorWidth = 0.0;
  double _indicatorHeight = 0.0;

  List<Widget> _children = List.empty(growable: true);

//big scale 5 small 5
  void _generateScale() async {
    var tickSpacing;
    if (mounted) {
      print(_wholeContainerWidth);
      tickSpacing = _wholeContainerWidth / widget.max;
      print("tick $tickSpacing");
    }

    for (int i = 0; i < 40; ++i) {
      _children.add(Container(
        margin: EdgeInsets.all(await tickSpacing),
        color: Colors.black,
        width: 1.5,
        height: 25,
      ));

      for (int j = 1; j <= 4; ++j) {
        _children.add(Container(
          margin: EdgeInsets.all(await tickSpacing),
          color: Colors.black,
          width: 1.5,
          height: 12.5,
        ));
      }
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _wholeContainerWidth =
              _wholeContainerKey.currentContext?.size?.width ?? 0.0;
          _wholeContainerHeight =
              _wholeContainerKey.currentContext?.size?.height ?? 0.0;
          if (_indicatorKey.currentContext != null) {
            _indicatorWidth = _indicatorKey.currentContext?.size?.width ?? 0.0;
            _indicatorHeight =
                _indicatorKey.currentContext?.size?.height ?? 0.0;
          }
          _generateScale();
        });
      }
    });
    if (widget.animation) {
      _animationController = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.animationDuration));
      _animation = Tween(begin: 0.0, end: widget.fraction).animate(
        CurvedAnimation(parent: _animationController!, curve: widget.curve),
      )..addListener(() {
          setState(() {
            _fraction = _animation!.value / widget.max;
          });
          if (widget.restartAnimation && _fraction == 1.0) {
            _animationController!.repeat(min: 0.0, max: widget.max);
          }
        });
      _animationController!.addStatusListener((status) {
        if (widget.onAnimationEnd != null &&
            status == AnimationStatus.completed) {
          widget.onAnimationEnd!();
        }
      });
      _animationController!.forward();
    } else {
      _updateProgress();
    }
    super.initState();
  }

  void _checkIfNeedCancelAnimation(LinearGauge oldWidget) {
    if (oldWidget.animation &&
        !widget.animation &&
        _animationController != null) {
      _animationController!.stop();
    }
  }

  @override
  void didUpdateWidget(LinearGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fraction != widget.fraction) {
      if (_animationController != null) {
        _animationController!.duration =
            Duration(milliseconds: widget.animationDuration);
        _animation =
            Tween(begin: oldWidget.fraction, end: widget.fraction).animate(
          CurvedAnimation(parent: _animationController!, curve: widget.curve),
        );
        _animationController!.forward(from: 0);
      } else {
        _updateProgress();
      }
    }
    _checkIfNeedCancelAnimation(oldWidget);
  }

  _updateProgress() {
    setState(() {
      _fraction = widget.fraction / widget.max;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var items = List<Widget>.empty(growable: true);
    final hasSetWidth = widget.width != null;
    final percentPositionedHorizontal =
        _wholeContainerWidth * _fraction - _indicatorWidth / 1.9;
    var containerWidget = Container(
      width: hasSetWidth ? widget.width : double.infinity,
      height: widget.gaugeHeight,
      padding: widget.padding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            key: _wholeContainerKey,
            painter: _LinearPainter(
              progress: _fraction,
              progressColor: widget.progressColor,
              backgroundColor: widget.backgroundColor,
              barRadius: widget.barRadius ?? Radius.zero,
            ),
            child: (widget.gaugeStatus != null)
                ? Center(child: widget.gaugeStatus)
                : Container(),
          ),
          if (widget.widgetIndicator != null && _indicatorWidth == 0)
            Opacity(
              opacity: 0.0,
              key: _indicatorKey,
              child: widget.widgetIndicator,
            ),
          if (widget.widgetIndicator != null &&
              _wholeContainerWidth > 0 &&
              _indicatorWidth > 0)
            Positioned(
              right: null,
              left: percentPositionedHorizontal,
              bottom: _wholeContainerHeight + .1,
              child: widget.widgetIndicator!,
            ),
          if (_wholeContainerWidth > 0)
            Positioned(
              bottom: _wholeContainerHeight,
              child: SizedBox(
                child: Row(children: _children),
              ),
            ),
        ],
      ),
    );

    if (hasSetWidth) {
      items.add(containerWidget);
    } else {
      items.add(
        Expanded(child: containerWidget),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        color: widget.barColor,
        child: Row(
          mainAxisAlignment: widget.alignment,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: items,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => widget.addAutomaticKeepAlive;
}

class _LinearPainter extends CustomPainter {
  final Paint _paintBackground = Paint();
  final Paint _paintLine = Paint();
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final Radius barRadius;

  _LinearPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.barRadius,
  }) {
    _paintBackground.color = backgroundColor;

    _paintLine.color = progress.toString() == "0.0"
        ? progressColor.withOpacity(0.0)
        : progressColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Path backgroundPath = Path();
    backgroundPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), barRadius));
    canvas.drawPath(backgroundPath, _paintBackground);
    canvas.clipPath(backgroundPath);

    final progressLine = size.width * progress;
    Path linePath = Path();
    print(size.width);
    print(progressLine);

    linePath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, progressLine, size.height), barRadius));

    canvas.drawPath(linePath, _paintLine);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
