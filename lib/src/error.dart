import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sdui/sdui.dart' as sdui;

import 'device.dart';

void initError(Device device) {
  sdui.sduiErrorState = (context, error) => Scaffold(
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
                child: const Text('Oops',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 25))),
            Container(
                alignment: Alignment.center,
                child: const Text('An unexpected error has occurred',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18))),
            Container(padding: const EdgeInsets.all(20)),
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
}
