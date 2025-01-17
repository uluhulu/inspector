import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inspector/infospect/features/launch/screen/infospect_launch_screen.dart';
import 'package:inspector/infospect/features/network/models/infospect_network_call.dart';
import 'package:inspector/infospect/features/network/ui/details/bloc/interceptor_details_bloc.dart';
import 'package:inspector/infospect/features/network/ui/details/screen/interceptor_details_screen.dart';
import 'package:inspector/infospect/features/network/ui/raw_data_viewer/screen/raw_data_viewer_screen.dart';
import 'package:inspector/infospect/helpers/infospect_helper.dart';
import 'package:inspector/infospect/styling/themes/infospect_theme.dart';

class MobileRoutes {
  ThemeData? _themeData;
  set themeData(ThemeData themeData) => _themeData = themeData;

  MobileRoutes._();

  /// launch screen
  Widget launch(Infospect infospect) =>
      _themeWidget(InfospectLaunchScreen(infospect));

  /// network details list
  Future<void> logsList(BuildContext context, Infospect infospect,
          InfospectNetworkCall call) =>
      Navigator.push<void>(
        infospect.context ?? context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => InterceptorDetailsBloc(),
            child: _themeWidget(
              InterceptorDetailsScreen(infospect, call),
            ),
          ),
        ),
      );

  /// raw data screen
  Future<void> rawData(BuildContext context, Map<String, dynamic> data,
          bool beautificationRequired) =>
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) {
            return _themeWidget(
              RawDataViewerScreen(
                data: data,
                beautificationRequired: beautificationRequired,
              ),
            );
          },
        ),
      );

  Widget _themeWidget(Widget widget) {
    if (_themeData == null) {
      final Brightness brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      _themeData = InfospectTheme.darkTheme;
      if (brightness == Brightness.light) {
        _themeData = InfospectTheme.lightTheme;
      }
    }

    return Theme(
      data: _themeData!,
      child: widget,
    );
  }
}

final mobileRoutes = MobileRoutes._();
