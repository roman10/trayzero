import 'dart:math' as math;

import 'package:flutter/material.dart';

const _workspaceMinHeight = 480.0;
const _scrollableKeyboardMinHeight = 320.0;

double _workspaceTextScale(MediaQueryData media) =>
    math.max(1.0, media.textScaler.scale(14) / 14);

/// Choose the rail from the window dimensions. Its scrollable viewport can
/// shrink independently when the keyboard takes up part of the window.
bool hasNavigationRailRoom(
  BuildContext context,
  BoxConstraints constraints, {
  required double railWidth,
  required double detailWidth,
}) {
  final media = MediaQuery.of(context);
  final scale = _workspaceTextScale(media);
  final width = constraints.maxWidth - media.padding.horizontal;
  final height = math.min(
    constraints.maxHeight,
    media.size.height - media.viewPadding.vertical,
  );
  return width >= (railWidth + detailWidth) * scale + 1 &&
      height >= _workspaceMinHeight * scale;
}

/// Use content budgets to keep short windows and large text usable.
bool hasWorkspaceRoom(
  BuildContext context,
  BoxConstraints constraints, {
  double primaryWidth = 240,
  double detailWidth = 320,
  double gap = 1,
  bool scrollablePanes = false,
}) {
  final media = MediaQuery.of(context);
  final scale = _workspaceTextScale(media);
  final keyboard = media.viewInsets.bottom;
  final usableHeight = math.min(
    constraints.maxHeight,
    media.size.height - media.padding.vertical - keyboard,
  );
  final windowHeight = math.min(
    constraints.maxHeight,
    media.size.height - media.viewPadding.vertical,
  );
  // An editor and its list can scroll in a shorter viewport while typing.
  // The full window still needs room for both panes before the keyboard opens.
  final minHeight =
      scrollablePanes &&
          keyboard > 0 &&
          windowHeight >= _workspaceMinHeight * scale
      ? _scrollableKeyboardMinHeight
      : _workspaceMinHeight;
  return constraints.maxWidth >= (primaryWidth + detailWidth) * scale + gap &&
      usableHeight >= minHeight * scale;
}

/// The detail always occupies the same element slot. Hiding the primary pane
/// therefore does not recreate editors, focus nodes, controllers or routes.
class AdaptiveWorkspace extends StatelessWidget {
  const AdaptiveWorkspace({
    required this.primary,
    required this.detail,
    this.minPrimaryWidth = 240,
    this.scrollablePanes = false,
    super.key,
  });
  final Widget primary;
  final Widget detail;
  final double minPrimaryWidth;
  final bool scrollablePanes;

  @override
  Widget build(BuildContext context) => Material(
    // The route owns the surface even where system insets exclude its panes.
    color: Theme.of(context).scaffoldBackgroundColor,
    child: SafeArea(
      top: false,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = hasWorkspaceRoom(
            context,
            constraints,
            primaryWidth: minPrimaryWidth,
            scrollablePanes: scrollablePanes,
          );
          final scale = _workspaceTextScale(MediaQuery.of(context));
          final width = wide
              ? (constraints.maxWidth * .4).clamp(
                  minPrimaryWidth * scale,
                  constraints.maxWidth - 320 * scale - 1,
                )
              : minPrimaryWidth * scale;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Offstage(
                offstage: !wide,
                child: SizedBox(
                  width: width,
                  child: ExcludeFocus(
                    excluding: !wide,
                    child: ScaffoldMessenger(
                      child: TickerMode(
                        enabled: wide,
                        child: HeroMode(enabled: false, child: primary),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: wide ? 1 : 0,
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              Expanded(child: detail),
            ],
          );
        },
      ),
    ),
  );
}

/// One scrollable reading order in compact windows; two content columns when
/// space permits. Flex retains children when its direction changes.
class AdaptiveWorkbench extends StatelessWidget {
  const AdaptiveWorkbench({
    required this.primary,
    required this.detail,
    this.padding = EdgeInsets.zero,
    super.key,
  });
  final Widget primary;
  final Widget detail;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, viewport) => SingleChildScrollView(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, content) {
          // Measure before introducing the scroll view's unbounded height. The
          // app bar, safe areas and content padding all consume usable room.
          final insets = padding.resolve(Directionality.of(context));
          final constraints = BoxConstraints(
            maxWidth: content.maxWidth,
            maxHeight: math.max(0, viewport.maxHeight - insets.vertical),
          );
          final wide = hasWorkspaceRoom(context, constraints, gap: 20);
          final scale = _workspaceTextScale(MediaQuery.of(context));
          final primaryWidth = wide
              ? (content.maxWidth * .42).clamp(
                  240 * scale,
                  content.maxWidth - 320 * scale - 20,
                )
              : content.maxWidth;
          return Flex(
            direction: wide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: primaryWidth, child: primary),
              SizedBox(width: wide ? 20 : 0, height: wide ? 0 : 20),
              SizedBox(
                width: wide
                    ? content.maxWidth - primaryWidth - 20
                    : content.maxWidth,
                child: detail,
              ),
            ],
          );
        },
      ),
    ),
  );
}
