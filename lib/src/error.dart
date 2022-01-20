import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:sdui/sdui.dart' as sdui;

import 'device.dart';

void initError(Device device) {
  sdui.sduiErrorState = (context, error) => _buildErrorWidget('Oops',
      'An unexpected error has occurred', device, error?.toString(), context);
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
      'Resource not Found',
      "The resource your are trying to access doesn't exist",
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
                  fontWeight: FontWeight.bold, color: Color(0xff8B0000))),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                child:
                    const Icon(Icons.error, size: 80, color: Color(0xff8B0000)),
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
                child: FutureBuilder(
                    future: Connectivity().checkConnectivity(),
                    initialData: ConnectivityResult.none,
                    builder: (context, value) => Text('Network: ' +
                        (value.data as ConnectivityResult).toString())),
              )
            ]));
