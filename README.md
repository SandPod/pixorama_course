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
