import 'package:pixorama_server/src/web/index_route.dart';
import 'package:serverpod/serverpod.dart';

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';

// This is the starting point of your Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    config: ServerpodConfig(
      // Api server configuration
      apiServer: ServerConfig(
        port: 8080,
        publicScheme: 'http',
        publicHost: 'localhost',
        publicPort: 8080,
      ),
      // Add a web server to serve static files.
      webServer: ServerConfig(
        port: 8081,
        publicScheme: 'http',
        publicHost: 'localhost',
        publicPort: 8081,
      ),
    ),
  );

  // Setup a default page at the web root.
  pod.webServer.addRoute(IndexRoute(), '/');
  pod.webServer.addRoute(IndexRoute(), '/index.html');

  // Serve all files in the /app directory.
  pod.webServer.addRoute(
    RouteStaticDirectory(serverDirectory: 'app', basePath: '/'),
    '/*',
  );

  // Start the server.
  await pod.start();
}
