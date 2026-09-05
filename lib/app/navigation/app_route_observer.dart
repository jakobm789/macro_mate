import 'package:flutter/widgets.dart';

/// Global RouteObserver used to detect when routes are pushed on top of
/// or popped back to pages (e.g. [TodayPage]).
final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();
