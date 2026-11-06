import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/common/adaptive_workspace.dart';
import '../features/item_edit/item_edit_controller.dart';
import '../features/item_edit/item_edit_screen.dart';
import '../features/shell/app_shell.dart';
import '../l10n/gen/app_localizations.dart';

/// Route-level composition keeps sibling feature dependencies out of screens.
class ItemWorkspace extends ConsumerStatefulWidget {
  const ItemWorkspace({
    required this.itemId,
    required this.queryParameters,
    required this.primaryBuilder,
    this.routeExtra,
    this.minPrimaryWidth = 240,
    this.navigationLocation,
    super.key,
  });
  final String itemId;
  final Map<String, String> queryParameters;
  final Widget Function(ValueChanged<String> onSelected) primaryBuilder;
  final Object? routeExtra;
  final double minPrimaryWidth;
  final String? navigationLocation;

  @override
  ConsumerState<ItemWorkspace> createState() => _ItemWorkspaceState();
}

class _ItemWorkspaceState extends ConsumerState<ItemWorkspace> {
  bool _switching = false;

  void _select(String nextId) {
    if (nextId == widget.itemId) return;
    _leaveEditor(() {
      // Replace the visit so repeated selections do not accumulate stale
      // editors or change where Back/completion returns.
      context.replace(
        Uri(
          path: '/item/$nextId',
          queryParameters: widget.queryParameters,
        ).toString(),
        extra: widget.routeExtra,
      );
    });
  }

  Future<void> _leaveEditor(VoidCallback navigate) async {
    if (_switching) return;
    _switching = true;
    final previousId = widget.itemId;
    try {
      await ref.read(itemEditControllerProvider(previousId).notifier).commit();
      if (mounted &&
          previousId == widget.itemId &&
          ModalRoute.of(context)?.isCurrent == true) {
        navigate();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).saveError)),
        );
      }
    } finally {
      _switching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final workspace = AdaptiveWorkspace(
      minPrimaryWidth: widget.minPrimaryWidth,
      scrollablePanes: true,
      primary: widget.primaryBuilder(_select),
      detail: ItemEditScreen(
        key: ValueKey(widget.itemId),
        itemId: widget.itemId,
      ),
    );
    final location = widget.navigationLocation;
    if (location == null) return workspace;
    return AppShell(
      location: location,
      detailBodyWidth: widget.minPrimaryWidth + 320,
      onNavigate: (target) => _leaveEditor(() => context.go(target)),
      child: workspace,
    );
  }
}
