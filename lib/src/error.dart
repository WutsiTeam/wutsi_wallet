import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:sdui/sdui.dart' as sdui;
import 'package:wutsi_wallet/src/access_token.dart';

import 'device.dart';

void initError(Device device) {
  sdui.sduiErrorState = (context, error) => _buildErrorWidget(
      'Oops',
      'An unexpected error has occurred',
      device,
      error?.toString(),
      context
  );
}

class Error401 extends StatelessWidget {
  final Device device;
  final AccessToken accessToken;

  const Error401(this.device, this.accessToken, {Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) =>
      Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: const Icon(
                Icons.power_settings_new_outlined,
                color: Color(0xffa9a9a9),
                size: 80,
              ),
            ),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                    'Logged out',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25
                    )
                )
            ),
            Container(
                alignment: Alignment.center,
                child: const Text(
                    'Your session has been terminated. Please sign in again',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xff8B0000),
                        fontSize: 18,
                    )
                )
            ),
            Container(padding: const EdgeInsets.all(20)),
            Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  child: const Text('Sign In'),
                  onPressed: () => _logout(accessToken, context),
                )),
          ]);

  void _logout(AccessToken accessToken, BuildContext context){
    // Remove access token locally
    accessToken.delete();

    // Redirect to home page
    Navigator.popUntil(context, (route) => route.isFirst);
    if (ModalRoute.of(context)?.settings.name != '/') {
      Navigator.pushReplacementNamed(context, '/');
    }
  }
}

class Error403 extends StatelessWidget {
  final Device device;

  const Error403(this.device, {Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => _buildErrorWidget(
      'Security Error',
      'You do not have permission to access this resource',
      device,
      '403',
      context);
}

class Error404 extends StatelessWidget {
  final Device device;

  const Error404(this.device, {Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => _buildErrorWidget(
      'Page not Found',
      "The page your are trying to access doesn't exist",
      device,
      '404',
      context);
}

Widget _buildErrorWidget(String title, String message, Device device,
        String? error, BuildContext context) =>
    Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xff8B0000),
          title: const Text('Error',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff8B0000)
              )
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: FutureBuilder(
            future: Connectivity().checkConnectivity(),
            initialData: ConnectivityResult.none,
            builder: (context, value) => value.data == ConnectivityResult.none
              ? _buildOfflineWidget(context)
                : _buildGenericErrorWidget(title, message, device, error, value.data, context)
    ));

Widget _buildOfflineWidget(BuildContext context) =>
    Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child:
            const Icon(Icons.signal_wifi_statusbar_connected_no_internet_4_outlined, size: 80, color: Colors.grey),
          ),
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text('You are offline',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold
                  )
              )
          ),
          Container(
              alignment: Alignment.center,
              child: const Text('You must connect on Internet to use the App',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xff8B0000),
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  )
              )
          ),
          Container(padding: const EdgeInsets.all(20)),
        ]);

Widget _buildGenericErrorWidget(
    String title,
    String message,
    Device device,
    String? error,
    Object? connectivity,
    BuildContext context
    ) =>
    Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: const Icon(Icons.error, size: 80, color: Color(0xff8B0000)),
          ),
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 25))),
          Container(
              alignment: Alignment.center,
              child: Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18))),
          Container(padding: const EdgeInsets.all(20)),
          Container(
              alignment: Alignment.center,
              child: error != null
                  ? Text(error, textAlign: TextAlign.center)
                  : null),
          Container(
              alignment: Alignment.center,
              child: Text('Device ID: ${device.id}',
                  textAlign: TextAlign.center)),
          Container(
              alignment: Alignment.center,
              child: Text('Date: ${DateTime.now()}',
                  textAlign: TextAlign.center)),
          Container(
            alignment: Alignment.center,
            child: Text('Network: $connectivity')
          )
        ]);

