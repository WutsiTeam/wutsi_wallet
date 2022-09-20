import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sdui/sdui.dart' as sdui;
import 'package:http/http.dart';
import 'package:wutsi_wallet/src/environment.dart';
import 'package:wutsi_wallet/src/login.dart';
import 'package:wutsi_wallet/src/access_token.dart';

import 'device.dart';

Environment environment = Environment(Environment.defaultEnvironment);

void initError() async {
  environment = await Environment.get();
  sdui.sduiErrorState = (context, error) => SDUIErrorWidget(error: error).build(context);
}

///
/// This is the replacement of the Flutter Red Screen of Death
///
class FlutterErrorWidget extends StatelessWidget{
  final FlutterErrorDetails? details;

  const FlutterErrorWidget({this.details, Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                  'Error',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff8B0000))
              ),
              foregroundColor: const Color(0xff8B0000),
              backgroundColor: Colors.white,
            ),
            body:SingleChildScrollView(
            child: _toErrorWidget(
                const Icon(Icons.error, size: 80, color: Color(0xff8B0000)),
                'Error',
                'An unexpected error has occurred',
                null,
                details.toString(),
                context
            )
        )));
}

///
/// This is the replacement of the Flutter Red Screen of Death
///
class SDUIErrorWidget extends StatelessWidget{
  final Object? error;

  const SDUIErrorWidget({this.error, Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) => _is401Error()
      ? FutureBuilder<AccessToken>(
          future: AccessToken.get(),
          builder: (BuildContext context, AsyncSnapshot<AccessToken> snapshot){
            if (snapshot.hasData){
              return sdui.DynamicRoute(
                provider: LoginContentProvider(context,
                    environment,
                    phoneNumber: snapshot.data?.phoneNumber(),
                    hideBackButton: true
                ),
                handleFirebaseMessages: false
              );
            } else{
              return Container();
            }
          }
      )
      : SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Error'),
              automaticallyImplyLeading: !_is401Error(),
            ),
            body: SingleChildScrollView(
                child: _toErrorWidget(
                    const Icon(Icons.error, color: Color(0xff8B0000), size: 80),
                    'Error',
                    'An unexpected error has occurred.',
                    null,
                    null,
                    context
                )
            )
          ),
      );

  bool _is401Error() => (error is ClientException) && ((error as ClientException).message == '401');
}

Widget _toErrorWidget(
    Icon? icon,
    String title,
    String message,
    Widget? button,
    String? error,
    BuildContext context,
) => Container(
    padding: const EdgeInsets.all(10),
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            child:icon,
          ),
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25
                  )
              )
          ),
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xff8B0000),
                      fontSize: 18
                  )
              )
          ),

          Container(
              alignment: Alignment.center,
              child: button == null ? null: Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                child: button
              )
          ),

          Container(
              alignment: Alignment.centerLeft,
              child: error == null ? null: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(padding: const EdgeInsets.all(20)),
                  Container(
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.centerLeft,
                      child: Text(error)
                  )
                ],
              )
          ),

          Container(padding: const EdgeInsets.all(20)),
          FutureBuilder<Device>(
              future: Device.get(),
              builder: (BuildContext context, AsyncSnapshot<Device> snapshot){
                if (snapshot.hasData){
                  return Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          'Device ID: ${snapshot.data?.id}',
                          style: const TextStyle(
                              fontSize: 12
                          )
                      )
                  );
                } else{
                  return Container();
                }
              }
          ),

          FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot){
                if (snapshot.hasData){
                  return Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          'Version: ${snapshot.data?.version}.${snapshot.data?.buildNumber}',
                          style: const TextStyle(
                              fontSize: 12
                          )
                      )
                  );
                } else{
                  return Container();
                }
              }
          ),

          Container(
              alignment: Alignment.centerLeft,
              child: Text(
                  'Date: ${DateTime.now()}',
                  style: const TextStyle(
                      fontSize: 12
                  )
              )
          ),
        ]));
