import 'package:flutter/material.dart';

/// Keeps single-column page content readable on wide windows. The child keeps
/// the full safe viewport height for scrolling and pinned actions.
class ReadablePageBody extends StatelessWidget {
  const ReadablePageBody({required this.child, this.top = true, super.key});

  final Widget child;
  final bool top;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: top,
    child: Align(
      alignment: Alignment.topCenter,
      child: SizedBox(width: 640, height: double.infinity, child: child),
    ),
  );
}
