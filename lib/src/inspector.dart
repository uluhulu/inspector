import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import './widgets/panel/inspector_panel.dart';
import 'utils.dart';
import 'widgets/color_picker/color_picker_overlay.dart';
import 'widgets/color_picker/color_picker_snackbar.dart';
import 'widgets/color_picker/utils.dart';
import 'widgets/inspector/box_info.dart';
import 'widgets/inspector/overlay.dart';
import 'widgets/multi_value_listenable.dart';

/// [Inspector] can wrap any [child], and will display its control panel and
/// information overlay on top of that [child].
///
/// You should use [Inspector] as a wrapper to [WidgetsApp.builder] or
/// [MaterialApp.builder].
///
/// If [isEnabled] is [null], then [Inspector] is automatically disabled on
/// production builds (i.e. [kReleaseMode] is [true]).
class Inspector extends StatefulWidget {
  const Inspector({
    Key? key,
    required this.child,
    this.isEnabled,
  }) : super(key: key);

  final Widget child;
  final bool? isEnabled;

  @override
  _InspectorState createState() => _InspectorState();
}

class _InspectorState extends State<Inspector> {
  final _repaintBoundaryKey = GlobalKey();
  final _absorbPointerKey = GlobalKey();
  ui.Image? _image;

  final _byteDataStateNotifier = ValueNotifier<ByteData?>(null);

  final _currentRenderBoxNotifier = ValueNotifier<BoxInfo?>(null);

  final _inspectorStateNotifier = ValueNotifier<bool>(false);
  final _colorPickerStateNotifier = ValueNotifier<bool>(false);

  final _selectedColorOffsetNotifier = ValueNotifier<Offset?>(null);
  final _selectedColorStateNotifier = ValueNotifier<Color?>(null);

  // Gestures

  void _onTap(Offset? pointerOffset) {
    if (_colorPickerStateNotifier.value) {
      if (pointerOffset != null) {
        _onHover(pointerOffset);
      }

      _onColorPickerStateChanged(false);
    }

    if (!_inspectorStateNotifier.value) {
      return;
    }

    if (pointerOffset == null) return;

    final boxes = InspectorUtils.onTap(
      _absorbPointerKey.currentContext!,
      pointerOffset,
    );

    if (boxes.isEmpty) return;
    _currentRenderBoxNotifier.value = BoxInfo.fromHitTestResults(boxes);
  }

  void _onPointerMove(Offset pointerOffset) {
    if (_colorPickerStateNotifier.value) {
      _onHover(pointerOffset);
    }
  }

  // Inspector

  void _onInspectorStateChanged(bool isEnabled) {
    _inspectorStateNotifier.value = isEnabled;

    if (isEnabled) {
      _onColorPickerStateChanged(false);
    } else {
      _currentRenderBoxNotifier.value = null;
    }
  }

  // Color picker

  void _onColorPickerStateChanged(bool isEnabled) {
    _colorPickerStateNotifier.value = isEnabled;

    if (isEnabled) {
      _onInspectorStateChanged(false);
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _extractByteData();
      });
    } else {
      if (_selectedColorStateNotifier.value != null) {
        showColorPickerResultSnackbar(
          context: context,
          color: _selectedColorStateNotifier.value!,
        );
      }

      _image?.dispose();
      _image = null;
      _byteDataStateNotifier.value = null;

      _selectedColorOffsetNotifier.value = null;
      _selectedColorStateNotifier.value = null;
    }
  }

  Future<void> _extractByteData() async {
    final boundary = _repaintBoundaryKey.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;

    _image = await boundary.toImage();
    _byteDataStateNotifier.value = await _image!.toByteData();
  }

  void _onHover(Offset offset) {
    if (_image == null || _byteDataStateNotifier.value == null) return;

    final _x = offset.dx.round();
    final _y = offset.dy.round();

    _selectedColorStateNotifier.value = getPixelFromByteData(
      _byteDataStateNotifier.value!,
      width: _image!.width,
      x: _x,
      y: _y,
    );

    _selectedColorOffsetNotifier.value = offset;
  }

  @override
  void dispose() {
    _image?.dispose();
    _byteDataStateNotifier.value = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEnabled == null && kReleaseMode) {
      return widget.child;
    }

    if (widget.isEnabled != null && !widget.isEnabled!) {
      return widget.child;
    }

    return Stack(
      children: [
        MultiValueListenableBuilder(
          valueListenables: [
            _colorPickerStateNotifier,
            _inspectorStateNotifier,
          ],
          builder: (context) {
            Widget _child = widget.child;

            if (_colorPickerStateNotifier.value ||
                _inspectorStateNotifier.value) {
              _child = AbsorbPointer(
                key: _absorbPointerKey,
                child: _child,
              );
            }

            if (_colorPickerStateNotifier.value) {
              _child = RepaintBoundary(
                key: _repaintBoundaryKey,
                child: _child,
              );
            }

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: (e) => _onTap(e.globalPosition),
              onPanDown: (e) => _onPointerMove(e.globalPosition),
              onPanUpdate: (e) => _onPointerMove(e.globalPosition),
              onPanEnd: (e) => _onTap(null),
              child: _child,
            );
          },
        ),
        MultiValueListenableBuilder(
          valueListenables: [
            _selectedColorOffsetNotifier,
            _selectedColorStateNotifier,
          ],
          builder: (context) {
            final offset = _selectedColorOffsetNotifier.value;
            final color = _selectedColorStateNotifier.value;

            if (offset == null || color == null) return const SizedBox.shrink();

            return Positioned(
              left: offset.dx + 8.0,
              top: offset.dy - 64.0,
              child: ColorPickerOverlay(
                color: color,
              ),
            );
          },
        ),
        MultiValueListenableBuilder(
          valueListenables: [
            _currentRenderBoxNotifier,
            _inspectorStateNotifier,
          ],
          builder: (context) => LayoutBuilder(
            builder: (context, constraints) => _inspectorStateNotifier.value
                ? InspectorOverlay(
                    size: constraints.biggest,
                    boxInfo: _currentRenderBoxNotifier.value,
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: MultiValueListenableBuilder(
            valueListenables: [
              _inspectorStateNotifier,
              _colorPickerStateNotifier,
              _byteDataStateNotifier,
            ],
            builder: (context) => InspectorPanel(
              isInspectorEnabled: _inspectorStateNotifier.value,
              isColorPickerEnabled: _colorPickerStateNotifier.value,
              onInspectorStateChanged: _onInspectorStateChanged,
              onColorPickerStateChanged: _onColorPickerStateChanged,
              isColorPickerLoading: _byteDataStateNotifier.value == null &&
                  _colorPickerStateNotifier.value,
            ),
          ),
        ),
      ],
    );
  }
}
