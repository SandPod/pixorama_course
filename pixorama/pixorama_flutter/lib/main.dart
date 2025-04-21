import 'package:pixels/pixels.dart';
import 'package:pixorama_client/pixorama_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

// Sets up a singleton client object that can be used to talk to the server from
// anywhere in our app. The client is generated from your server code.
// The client is set up to connect to a Serverpod running on a local server on
// the default port. You will need to modify this to connect to staging or
// production servers.
var client = Client('http://$localhost:8080/')
  ..connectivityMonitor = FlutterConnectivityMonitor();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serverpod Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PixelImageController? _controller;

  @override
  void initState() {
    super.initState();

    // Connect to the server and start listening to updates.
    _listenToUpdates();
  }

  Future<void> _listenToUpdates() async {
    // Indefinitely try to connect and listen to updates from the server.
    while (true) {
      try {
        // Get the stream of updates from the server.
        final imageUpdates = client.pixorama.imageUpdates();

        // Listen for updates from the stream. The await for construct will
        // wait for a message to arrive from the server, then run through the
        // body of the loop.
        await for (final update in imageUpdates) {
          // Check which type of update we have received.
          if (update is ImageData) {
            // This is a complete image update, containing all pixels in the
            // image. Create a new PixelImageController with the pixel data.
            setState(() {
              _controller = PixelImageController(
                pixels: update.pixels,
                palette: PixelPalette.rPlace(),
                width: update.width,
                height: update.height,
              );
            });
          } else if (update is ImageUpdate) {
            // Got an incremental update of the image. Just set the single
            // pixel.
            _controller?.setPixelIndex(
              pixelIndex: update.pixelIndex,
              colorIndex: update.colorIndex,
            );
          }
        }
      } on MethodStreamException catch (_) {
        // We lost the connection to the server, or failed to connect.
        setState(() {
          _controller = null;
        });
      }

      // Wait 5 seconds until we try to connect again.
      await Future.delayed(Duration(seconds: 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller == null
            ? const CircularProgressIndicator()
            : PixelEditor(
                controller: _controller!,
                onSetPixel: (details) {
                  // When a user clicks a pixel we will get a callback from the
                  // PixelImageController, with information about the changed
                  // pixel. When that happens we call the setPixels method on
                  // the server.
                  client.pixorama.setPixel(
                    pixelIndex: details.tapDetails.index,
                    colorIndex: details.colorIndex,
                  );
                },
              ),
      ),
    );
  }
}
