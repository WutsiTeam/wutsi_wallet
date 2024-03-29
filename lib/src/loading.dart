import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sdui/sdui.dart' as sdui;

void initLoadingState() {
  sdui.sduiProgressIndicator =
      (context) => const SpinKitCubeGrid(size: 120.0, color: Color(0xFF1D7EDF));

  sdui.sduiLoadingState = (context) => Scaffold(
      appBar: AppBar(
        foregroundColor: const Color(0xFF1D7EDF),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Center(child: sdui.sduiProgressIndicator(context)));
}
