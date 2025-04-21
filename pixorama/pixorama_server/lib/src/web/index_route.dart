import 'dart:io';

import 'package:serverpod/serverpod.dart';

/// A route that serves the index page of the web application.
/// The route is registered as a route in the web server.
/// The name of the widget should correspond to a template file in the server's
/// web/templates directory. The template is loaded when the server starts.
class IndexRoute extends WidgetRoute {
  @override
  Future<Widget> build(Session session, HttpRequest request) async {
    return Widget(name: 'index');
  }
}
