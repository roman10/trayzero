import 'dart:async';
import 'package:cleartray/application/app_icon_controller.dart';
import 'package:cleartray/core/app_icon.dart';
import 'package:cleartray/core/appearance_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

class ControlledIconGateway implements AppIconGateway {
  AppIconState current = const AppIconState(supported: true);
  final calls = <AppPalette>[];
  Completer<AppIconState>? pending;
  @override
  Future<AppIconState> load() async => current;
  @override
  Future<AppIconState> setIcon(AppPalette palette) {
    calls.add(palette);
    return (pending = Completer<AppIconState>()).future;
  }
}

void main() {
  test(
    'reads OS selection; serializes changes and only confirms native success',
    () async {
      final gateway = ControlledIconGateway();
      final controller = AppIconController(gateway);
      addTearDown(controller.dispose);
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.value!.palette, AppPalette.amber);
      final first = controller.select(AppPalette.cyan);
      expect(controller.state.isLoading, isTrue);
      expect(controller.state.value!.palette, AppPalette.amber);
      expect(await controller.select(AppPalette.rose), isFalse);
      expect(gateway.calls, [AppPalette.cyan]);
      gateway.pending!.complete(
        const AppIconState(supported: true, palette: AppPalette.cyan),
      );
      expect(await first, isTrue);
      expect(controller.state.value!.palette, AppPalette.cyan);
      expect(await controller.select(AppPalette.cyan), isTrue);
      expect(gateway.calls, [AppPalette.cyan]);
    },
  );

  test(
    'native failure retains current icon and permits retry/default restore',
    () async {
      final gateway = ControlledIconGateway()
        ..current = const AppIconState(
          supported: true,
          palette: AppPalette.blue,
        );
      final controller = AppIconController(gateway);
      addTearDown(controller.dispose);
      await Future<void>.delayed(Duration.zero);
      final failed = controller.select(AppPalette.violet);
      gateway.pending!.completeError(StateError('OS denied change'));
      expect(await failed, isFalse);
      expect(controller.state.value!.palette, AppPalette.blue);
      final reset = controller.select(AppPalette.amber);
      gateway.pending!.complete(const AppIconState(supported: true));
      expect(await reset, isTrue);
      expect(controller.state.value!.palette, AppPalette.amber);
    },
  );

  test('completion after disposal does not update disposed state', () async {
    final gateway = ControlledIconGateway();
    final controller = AppIconController(gateway);
    await Future<void>.delayed(Duration.zero);
    final change = controller.select(AppPalette.blue);
    controller.dispose();
    gateway.pending!.complete(
      const AppIconState(supported: true, palette: AppPalette.blue),
    );
    expect(await change, isTrue);
  });
}
