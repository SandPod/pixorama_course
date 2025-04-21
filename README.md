# Pixorama Course

This is a step by step course to learn how to create a collaborative drawing app using Serverpod and the Pixel package.

## Prerequisites

- Basic knowledge of Dart and Flutter.
- Flutter SDK installed.

## Steps

These are the steps to create a collaborative drawing app using Serverpod and the Pixel package.

### Step 1:

Install the serverpod cli globally using the following command:

```bash
dart pub global activate serverpod_cli
```

Validate the installation by running the following command:

```bash
serverpod version
```

### Step 2: Create a Serverpod mini project

Create a new Serverpod mini project using the following command:

```bash
serverpod create pixorama --mini
```

Inspect the contents of the `pixorama` folder. You should see three directories created:
- `pixorama_flutter`: This is the Flutter application where you will implement the drawing functionality.
- `pixorama_server`: This is the server application that will handle communication between different flutter applications.
- `pixorama_client`: This is the client application that will handle communication with the server.

Start the server by running the following command:

```bash
cd pixorama_server
dart bin/main.dart
```

Then start the flutter application by running the following command in a different terminal:

```bash
cd pixorama_flutter
flutter run -d chrome
```

The example application should now be running in your browser.

### Step 3: Build the pixel drawing canvas

In the `pixorama_flutter` directory, add the `pixel` package dependency by running the following command:

```bash
# In the pixorama_flutter directory
flutter pub add pixel
```

Replace `MyHomePage` and `MyHomePageState` with the example provided in the `pixels` package documentation on [pub.dev](https://pub.dev/packages/pixels).

Start the app by running the following command:

```bash
# In the pixorama_flutter directory
flutter run -d chrome
```

You should now be able to run the app and see a blank canvas. You can draw on the canvas by selecting a color and clicking on a pixel.

### Step 4: Serve app from Serverpod Server

#### 4.1 Prepare flutter assets 
In order to serve the app from the Serverpod server, you first need to build the app. Run the following command in the `pixorama_flutter` directory:

```bash
# In the pixorama_flutter directory
flutter build web
```

This will create a `build/web` directory containing the built ready to be served. 

Create a new directory called `web` in the `pixorama_server` directory. This is where the built app will be served from.

```bash
# In the pixorama_server directory
mkdir -p web/app
```

Copy the contents of the `pixorama_flutter/build/web` directory to the `pixorama_server/web/app` directory.

```bash
# In the serverpod project directory
cp -r pixorama_flutter/build/web/ pixorama_server/web/app
```

As a last step we need to configure a template file. Create a new directory called `templates` in the `pixorama_server/web` directory. This is where the template file will be served from.

```bash
# In the pixorama_server directory
mkdir -p web/templates
```

Then move the `index.html` file from the `web/app` directory to the `web/templates` directory.

```bash
# In the pixorama_server directory
mv web/app/index.html web/templates
```

This file is needed to serve the app.

#### 4.2 Configure serverpod to serve the app

To serve the app we need the web server running in Serverpod. This is done by adding configuration for the web server in `pixorama_server/lib/serer.dart` file.

Add a config for the web server to Serverpod:

```dart
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
```

Now that we have the web server configured, we will add a route to serve the app.

First we create the route in `lib/src/web/index_route.dart` file:

```dart
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
```

The route serves the `index.html` file from the `web/templates` directory. The name of the widget should correspond to a template file in the server's web/templates directory. The template is loaded when the server starts.

Now we need to register the route in Serverpod. Open the `lib/src/server.dart` file and add the following code before starting the server:

```dart
  // Setup a default page at the web root.
  pod.webServer.addRoute(IndexRoute(), '/');
  pod.webServer.addRoute(IndexRoute(), '/index.html');
```

But if we start the server now, we will get an error becuase the assets are not served from the `app` directory. To fix this we need to also serve the assets through a `routeStaticDirectory` route.

Add the following code to the `lib/src/server.dart` file:

```dart
  // Serve all files in the /app directory.
  pod.webServer.addRoute(
    RouteStaticDirectory(serverDirectory: 'app', basePath: '/'),
    '/*',
  );
```

Now start the server by running the following command in the `pixorama_server` directory:

```bash
# In the pixorama_server directory
dart bin/main.dart
```

Then open your browser and go to `http://localhost:8081`. You should see the app running. You can draw on the canvas by selecting a color and clicking on a pixel.

### Step 5: Share state between apps

#### 5.1 Create models

In order to share the state between apps, we need our server to become authoritative over the state. This means that the server will be responsible for storing the state and sending it to the clients.

To allow the server to share state with the apps we will introduce two models:

- `ImageData`: This model will be used to share the full image data with the clients. It will be used to send the full image data to the clients when they connect to the server.
- `ImageUpdate`: This model will be used to communicate a single pixel update to and from clients.

We will add these as models to the `pixorama_server` project. Open the `lib/src/protocol/models` directory and create two new files, `image_data.spy.yaml` and `image_update.spy.yaml`.

Add the following code to the `image_update.spy.yaml` file:

```yaml
class: ImageData
fields:
  pixels: ByteData
  width: int
  height: int
```

Add the following code to the `image_update.spy.yaml` file:

```yaml
class: ImageUpdate
fields:
  pixelIndex: int
  colorIndex: int
```

Now we need to generate the models. Run the following command in the `pixorama_server` directory:

```bash
# In the pixorama_server directory
serverpod generate
```

The files will be generated in the `lib/src/protocol/generated` directory. You should see two new files, `image_data.dart` and `image_update.dart`. These files contain the generated code for the models.
