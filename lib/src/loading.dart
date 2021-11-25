import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sdui/sdui.dart' as sdui;

void initLoadingState(){
  sdui.sduiLoadingState = (context) => const Scaffold(body: Center(
    child: SpinKitCubeGrid(
      size: 120.0,
      color: Color(0xFF1D7EDF),
    ),
  ));
}

