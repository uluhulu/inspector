import 'package:flutter/material.dart';
import 'package:inspector/infospect/features/invoker/infospect_invoker.dart';

class InspectorPanel extends StatefulWidget {
  const InspectorPanel({
    Key? key,
    required this.isInspectorEnabled,
    required this.isColorPickerEnabled,
    this.onInspectorStateChanged,
    this.onColorPickerStateChanged,
    required this.isColorPickerLoading,
    required this.isZoomEnabled,
    this.onZoomStateChanged,
    required this.isZoomLoading,
    required this.isTestStagesEnabled,
    required this.isVisible,
    required this.toggleVisibility,
    required this.testStagesCallback,
    required this.isInfospecEnabled,
  }) : super(key: key);

  final bool isInspectorEnabled;
  final ValueChanged<bool>? onInspectorStateChanged;

  final bool isColorPickerEnabled;
  final ValueChanged<bool>? onColorPickerStateChanged;

  final bool isZoomEnabled;
  final ValueChanged<bool>? onZoomStateChanged;

  final bool isColorPickerLoading;
  final bool isZoomLoading;
  final bool isTestStagesEnabled;
  final bool isVisible;
  final bool isInfospecEnabled;
  final VoidCallback toggleVisibility;
  final VoidCallback testStagesCallback;

  @override
  _InspectorPanelState createState() => _InspectorPanelState();
}

class _InspectorPanelState extends State<InspectorPanel> {
  bool get _isInspectorEnabled => widget.onInspectorStateChanged != null;

  bool get _isColorPickerEnabled => widget.onColorPickerStateChanged != null;

  bool get _isZoomEnabled => widget.onZoomStateChanged != null;

  void _toggleInspectorState() {
    assert(_isInspectorEnabled);
    widget.onInspectorStateChanged!(!widget.isInspectorEnabled);
  }

  void _toggleColorPickerState() {
    assert(_isColorPickerEnabled);
    widget.onColorPickerStateChanged!(!widget.isColorPickerEnabled);
  }

  void _toogleZoomState() {
    assert(_isZoomEnabled);
    widget.onZoomStateChanged!(!widget.isZoomEnabled);
  }

  IconData get _visibilityButtonIcon {
    if (widget.isVisible) return Icons.chevron_right;

    if (widget.isInspectorEnabled) {
      return Icons.format_shapes;
    } else if (widget.isColorPickerEnabled) {
      return Icons.colorize;
    } else if (widget.isZoomEnabled) {
      return Icons.zoom_in;
    }

    return Icons.chevron_left;
  }

  Color get _visibilityButtonBackgroundColor {
    if (widget.isVisible) return Colors.white;

    if (widget.isInspectorEnabled ||
        widget.isColorPickerEnabled ||
        widget.isZoomEnabled) {
      return Colors.blue;
    }

    return Colors.white;
  }

  Color get _visibilityButtonForegroundColor {
    if (widget.isVisible) return Colors.black54;

    if (widget.isInspectorEnabled ||
        widget.isColorPickerEnabled ||
        widget.isZoomEnabled) {
      return Colors.white;
    }

    return Colors.black54;
  }

  @override
  Widget build(BuildContext context) {
    final _height = 16.0 +
        (_isInspectorEnabled ? 56.0 : 0.0) +
        (_isColorPickerEnabled ? 64.0 : 0.0) +
        (_isZoomEnabled ? 64.0 : 0.0);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            mini: true,
            onPressed: widget.toggleVisibility,
            backgroundColor: _visibilityButtonBackgroundColor,
            foregroundColor: _visibilityButtonForegroundColor,
            child: Icon(_visibilityButtonIcon),
          ),
          if (widget.isVisible) ...[
            const SizedBox(height: 16.0),
            if (_isInspectorEnabled)
              FloatingActionButton(
                onPressed: _toggleInspectorState,
                backgroundColor:
                    widget.isInspectorEnabled ? Colors.blue : Colors.white,
                foregroundColor:
                    widget.isInspectorEnabled ? Colors.white : Colors.black54,
                child: const Icon(Icons.format_shapes),
              ),
            if (_isColorPickerEnabled) ...[
              const SizedBox(height: 8.0),
              FloatingActionButton(
                onPressed: _toggleColorPickerState,
                backgroundColor:
                    widget.isColorPickerEnabled ? Colors.blue : Colors.white,
                foregroundColor:
                    widget.isColorPickerEnabled ? Colors.white : Colors.black54,
                child: widget.isColorPickerLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.colorize),
              ),
              if (_isZoomEnabled) ...[
                const SizedBox(height: 8.0),
                FloatingActionButton(
                  onPressed: _toogleZoomState,
                  backgroundColor:
                      widget.isZoomEnabled ? Colors.blue : Colors.white,
                  foregroundColor:
                      widget.isZoomEnabled ? Colors.white : Colors.black54,
                  child: widget.isZoomLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.zoom_in),
                ),
              ],
              if (widget.isTestStagesEnabled) ...[
                const SizedBox(height: 8.0),
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: widget.testStagesCallback,
                  child: Icon(
                    Icons.network_check,
                    color:
                        Theme.of(context).buttonTheme.colorScheme?.background,
                  ),
                ),
              ],
              if (widget.isInfospecEnabled) ...[
                const SizedBox(height: 8.0),
                const InfospectInvoker()
              ]
            ],
          ] else
            SizedBox(height: _height),
        ],
      ),
    );
  }
}
