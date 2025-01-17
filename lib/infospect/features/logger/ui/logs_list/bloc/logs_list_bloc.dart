import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:equatable/equatable.dart';
import 'package:inspector/infospect/features/logger/infospect_logger.dart';
import 'package:inspector/infospect/features/logger/models/infospect_log.dart';
import 'package:inspector/infospect/helpers/infospect_helper.dart';
import 'package:inspector/infospect/utils/infospect_util.dart';
import 'package:inspector/infospect/utils/models/action_model.dart';

part 'logs_list_event.dart';
part 'logs_list_state.dart';

/// `LogsListBloc` is responsible for managing the state of the logs list.
///
/// This Bloc responds to various events to filter logs, search for text within logs,
/// add or remove filters, share logs, and clear logs.
///
/// - The `_infospectLogger` instance provides logs for the application.
/// - The `_isMultiWindow` flag checks if the app runs in a multi-window environment.
class LogsListBloc extends Bloc<LogsListEvent, LogsListState> {
  final InfospectLogger _infospectLogger;
  final bool _isMultiWindow;

  /// Creates a new instance of `LogsListBloc`.
  ///
  /// - [infospectLogger]: The logger instance used to fetch logs.
  /// - [isMultiWindow]: Indicates whether the application is running in a multi-window environment.
  LogsListBloc(
      {required InfospectLogger infospectLogger, required bool isMultiWindow})
      : _infospectLogger = infospectLogger,
        _isMultiWindow = isMultiWindow,
        super(const LogsListState()) {
    /// Listen to the logs changes
    on<LogsChanged>(_onLogsChanged);

    /// Listen to the text searched
    on<TextSearched>(_onTextSearched);

    /// Listen to the logs filter added
    on<LogsFilterAdded>(_onLogsFilterAdded);

    /// Listen to the logs filter removed
    on<LogsFilterRemoved>(_onLogsFilterRemoved);

    /// Listen to the share all logs clicked
    on<ShareAllLogsClicked>(_onShareAllLogsClicked);

    /// Listen to the clear all logs clicked
    on<ClearAllLogsClicked>(_onClearAllLogsClicked);

    _onStarted();
  }

  /// Handles the initialization logic when the Bloc starts.
  void _onStarted() {
    add(LogsChanged(logs: _infospectLogger.callsSubject.value));
  }

  /// Responds to the `LogsChanged` event by updating the current logs list.
  FutureOr<void> _onLogsChanged(
      LogsChanged event, Emitter<LogsListState> emit) async {
    await emit.forEach(
      _infospectLogger.callsSubject,
      onData: (value) {
        return _filterLogs(state.filters, value.reversed.toList());
      },
    );
  }

  /// Responds to the `TextSearched` event to filter logs based on the searched text.
  FutureOr<void> _onTextSearched(
      TextSearched event, Emitter<LogsListState> emit) async {
    emit(state.copyWith(searchedText: event.text));

    emit(_filterLogs(List.from(state.filters)));
  }

  /// Handles the addition of a log filter based on the `LogsFilterAdded` event.
  FutureOr<void> _onLogsFilterAdded(
      LogsFilterAdded event, Emitter<LogsListState> emit) {
    final List<PopupAction> finalFilters = List.from(state.filters);

    if (finalFilters
            .firstWhereOrNull((element) => element.name == event.action.name) !=
        null) {
      finalFilters.remove(event.action);
    } else {
      finalFilters.add(event.action);
    }
    emit(state.copyWith(filters: finalFilters));

    emit(_filterLogs(finalFilters));
  }

  /// Handles the removal of a log filter based on the `LogsFilterRemoved` event.
  FutureOr<void> _onLogsFilterRemoved(
      LogsFilterRemoved event, Emitter<LogsListState> emit) {
    final List<PopupAction> finalFilters = List.from(state.filters);
    if (finalFilters
            .firstWhereOrNull((element) => element.name == event.action.name) !=
        null) {
      finalFilters.remove(event.action);
      emit(state.copyWith(filters: finalFilters));

      emit(_filterLogs(finalFilters));
    }
  }

  /// Returns a state containing logs filtered based on the provided criteria.
  LogsListState _filterLogs(
    List<PopupAction> filter, [
    List<InfospectLog>? totalLogs,
  ]) {
    List<InfospectLog> filteredList = [];
    final List<InfospectLog> logs = totalLogs ?? state.logs;

    final searched = state.searchedText.toLowerCase();

    if (searched.isNotEmpty) {
      filteredList = logs.where(
        (element) {
          return element.error.toString().toLowerCase().contains(searched) ||
              element.message.toLowerCase().contains(searched) ||
              element.stackTrace.toString().toLowerCase().contains(searched) ||
              element.timestamp.toString().toLowerCase().contains(searched);
        },
      ).toList();
    }

    if (filter.isEmpty) {
      final logsToShow = searched.isEmpty ? logs : filteredList;
      return state.copyWith(filteredLogs: logsToShow, logs: totalLogs);
    }

    final listToCheck =
        filteredList.isEmpty && searched.isEmpty ? logs : filteredList;

    final list = listToCheck
        .where((element) => filter
            .map((e) => e.id.toString().toLowerCase())
            .contains(element.level.name.toString().toLowerCase()))
        .toList();

    return state.copyWith(
      logs: logs.toList(),
      filteredLogs: list,
    );
  }

  /// Shares all logs based on the `ShareAllLogsClicked` event.
  FutureOr<void> _onShareAllLogsClicked(
      ShareAllLogsClicked event, Emitter<LogsListState> emit) async {
    if (_isMultiWindow) {
      DesktopMultiWindow.invokeMethod(
        0,
        'onSend',
        MainWindowArguments.shareLogs.name,
      );
      return;
    }
    final File? logsFile = await InfospectUtil.shareLogs();
    if (logsFile != null) {
      emit(
        CompressedLogsFile(
          sharableFile: logsFile,
          logs: state.logs,
          filteredLogs: state.filteredLogs,
          filters: state.filters,
          searchedText: state.searchedText,
        ),
      );
    }
  }

  /// Clears all logs based on the `ClearAllLogsClicked` event.
  FutureOr<void> _onClearAllLogsClicked(
      ClearAllLogsClicked event, Emitter<LogsListState> emit) {
    if (_isMultiWindow) {
      DesktopMultiWindow.invokeMethod(
        0,
        'onSend',
        MainWindowArguments.clearLogs.name,
      );
    }
    Infospect.instance.clearAllLogs();
  }
}
