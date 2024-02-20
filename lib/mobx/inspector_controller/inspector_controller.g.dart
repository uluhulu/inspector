// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspector_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$InspectorController on _InspectorControllerBase, Store {
  late final _$_inspectorOffsetAtom =
      Atom(name: '_InspectorControllerBase._inspectorOffset', context: context);

  @override
  AsyncValue<Offset> get _inspectorOffset {
    _$_inspectorOffsetAtom.reportRead();
    return super._inspectorOffset;
  }

  @override
  set _inspectorOffset(AsyncValue<Offset> value) {
    _$_inspectorOffsetAtom.reportWrite(value, super._inspectorOffset, () {
      super._inspectorOffset = value;
    });
  }

  late final _$loadPositionAsyncAction =
      AsyncAction('_InspectorControllerBase.loadPosition', context: context);

  @override
  Future<void> loadPosition() {
    return _$loadPositionAsyncAction.run(() => super.loadPosition());
  }

  late final _$writePositionAsyncAction =
      AsyncAction('_InspectorControllerBase.writePosition', context: context);

  @override
  Future<void> writePosition(Offset position) {
    return _$writePositionAsyncAction.run(() => super.writePosition(position));
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
