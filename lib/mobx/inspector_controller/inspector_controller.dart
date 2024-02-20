import 'dart:ui';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:inspector/inspector/widgets/async_value.dart';
import 'package:inspector/mobx/adapter/offset_adapter.dart';
import 'package:mobx/mobx.dart';

part 'inspector_controller.g.dart';

// ignore: library_private_types_in_public_api
class InspectorController = _InspectorControllerBase with _$InspectorController;

abstract class _InspectorControllerBase with Store {
  static const _inspectorBoxKey = 'inspector_position';

  @observable
  AsyncValue<Offset> _inspectorOffset = const AsyncValue.loading();

  AsyncValue<Offset> get inspectorOffset => _inspectorOffset;

  Future<Box<Offset>> get _inspectorPosition =>
      Hive.openBox<Offset>(_inspectorBoxKey);

  @action
  Future<void> loadPosition() async {
    _inspectorOffset = AsyncValue.loading();
    Hive.registerAdapter(OffsetAdapter());
    final inspectorPosition = await _inspectorPosition;
    print('inspectorPosition ${inspectorPosition.values}');
    if (inspectorPosition.isNotEmpty) {
      _inspectorOffset =
          AsyncValue.value(value: inspectorPosition.values.first);
    } else {
      inspectorPosition.add(Offset(20, 100));
      _inspectorOffset =
          AsyncValue.value(value: inspectorPosition.values.first);
    }
  }

  @action
  Future<void> writePosition(Offset position) async {
    final inspectorPosition = await _inspectorPosition;
    inspectorPosition.clear();
    inspectorPosition.add(position);
    _inspectorOffset = AsyncValue.value(value: position);
  }
}
