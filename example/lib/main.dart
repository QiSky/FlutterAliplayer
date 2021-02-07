
import 'package:aliplayer_plugin/aliplayer_widget.dart';
import 'package:flutter/material.dart';
import 'dart:core';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{

  AliplayerController controller;

  @override
  void initState(){
    super.initState();
    controller = AliplayerController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose(){
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch(state){
      case AppLifecycleState.paused:
        if(controller.isPlaying)
          controller?.pause();
        break;
      case AppLifecycleState.resumed:
        controller?.start();
        break;
      case AppLifecycleState.inactive:
        // TODO: Handle this case.
        break;
      case AppLifecycleState.detached:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: AliplayerWidget(
            "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4",
            thumbUrl: "",
            isMute: true,
            isCanStop: true,
            controller: controller,
          )
      )
    );
  }
}
