import 'package:flutter/material.dart';
import 'package:vimeoplayer/vimeoplayer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      //primarySwatch: Colors.red,
      theme: ThemeData.dark().copyWith(
        accentColor: Color(0xFF22A3D2),
      ),
      home: VideoScreen(),
    );
  }
}

class VideoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Color(0xFF15162B),
      appBar: MediaQuery.of(context).orientation == Orientation.portrait
          ? AppBar(
              title: Text("Vimeo Player"),
              centerTitle: true,
              backgroundColor: Color(0xAA15162B),
            )
          : PreferredSize(
              child: Container(
                color: Colors.transparent,
              ),
              preferredSize: Size(0.0, 0.0),
            ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  "Default Player",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            VimeoPlayer(
              id: '395212534',
              autoPlay: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  "Custom Player",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            VimeoPlayer(
              id: '395212534',
              autoPlay: true,
              enableTwoDigitsDuration: true,
              enableSettings: false,
              enableFullScreen: false,
              videoControllerTheme: VideoControllerTheme(
                progressColor: Colors.green,
                bufferedProgressColor: Colors.green.withOpacity(0.2),
                iconColor: Colors.blue,
                durationStyle: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
