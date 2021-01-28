library vimeoplayer;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:vimeoplayer/src/video_controller_theme.dart';

import 'quality_links.dart';

// ignore: must_be_immutable
class FullscreenPlayer extends StatefulWidget {
  final String id;
  final bool autoPlay;
  final bool looping;
  final VideoPlayerController controller;
  final bool enableTwoDigitsDuration;
  final bool enableFullScreen;
  final bool enableSettings;
  final VideoControllerTheme videoControllerTheme;
  int position;
  Future<void> initFuture;
  var qualityValue;

  FullscreenPlayer({
    @required this.id,
    this.autoPlay,
    this.looping,
    this.controller,
    this.position,
    this.initFuture,
    this.qualityValue,
    this.enableTwoDigitsDuration,
    this.enableFullScreen,
    this.enableSettings,
    this.videoControllerTheme,
    Key key,
  }) : super(key: key);

  @override
  _FullscreenPlayerState createState() => _FullscreenPlayerState(id, autoPlay, looping, controller, position, initFuture, qualityValue);
}

class _FullscreenPlayerState extends State<FullscreenPlayer> {
  String _id;
  bool autoPlay = false;
  bool looping = false;
  bool _overlay = true;
  bool fullScreen = true;

  VideoPlayerController controller;
  VideoPlayerController _controller;

  int position;

  Future<void> initFuture;
  var qualityValue;

  _FullscreenPlayerState(this._id, this.autoPlay, this.looping, this.controller, this.position, this.initFuture, this.qualityValue);

  QualityLinks _quality;
  Map _qualityValues;
  bool _seek = true;

  double videoHeight;
  double videoWidth;
  double videoMargin;

  double doubleTapMargin = 40;
  double doubleTapWidth = 400;
  double doubleTapHeight = 200;

  double doubleTapRMargin = 36;
  double doubleTapRWidth = 700;
  double doubleTapRHeight = 300;
  double doubleTapLMargin = 10;
  double doubleTapLWidth = 700;
  double doubleTapLHeight = 400;

  @override
  void initState() {
    _controller = controller;
    if (autoPlay) _controller.play();
    _quality = QualityLinks(_id);
    _quality.getQualitiesSync().then((value) {
      _qualityValues = value;
    });

    setState(() {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            GestureDetector(
              child: FutureBuilder(
                future: initFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    double delta = MediaQuery.of(context).size.width - MediaQuery.of(context).size.height * _controller.value.aspectRatio;
                    if (MediaQuery.of(context).orientation == Orientation.portrait || delta < 0) {
                      videoHeight = MediaQuery.of(context).size.width / _controller.value.aspectRatio;
                      videoWidth = MediaQuery.of(context).size.width;
                      videoMargin = 0;
                    } else {
                      videoHeight = MediaQuery.of(context).size.height;
                      videoWidth = videoHeight * _controller.value.aspectRatio;
                      videoMargin = (MediaQuery.of(context).size.width - videoWidth) / 2;
                    }

                    doubleTapRWidth = videoWidth;
                    doubleTapRHeight = videoHeight - 36;
                    doubleTapLWidth = videoWidth;
                    doubleTapLHeight = videoHeight;

                    if (_seek && fullScreen) {
                      _controller.seekTo(Duration(seconds: position));
                      _seek = false;
                    }
                    if (_seek && _controller.value.duration.inSeconds > 2) {
                      _controller.seekTo(Duration(seconds: position));
                      _seek = false;
                    }
                    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
                    return Stack(
                      children: <Widget>[
                        VideoPlayer(_controller),
                        _videoOverlay(),
                      ],
                    );
                  } else {
                    return Center(
                      heightFactor: 6,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(widget.videoControllerTheme.progressColor),
                      ),
                    );
                  }
                },
              ),
              onTap: () {
                setState(() {
                  _overlay = !_overlay;
                  if (_overlay) {
                    doubleTapRHeight = videoHeight - 36;
                    doubleTapLHeight = videoHeight - 10;
                    doubleTapRMargin = 36;
                    doubleTapLMargin = 10;
                  } else if (!_overlay) {
                    doubleTapRHeight = videoHeight + 36;
                    doubleTapLHeight = videoHeight;
                    doubleTapRMargin = 0;
                    doubleTapLMargin = 0;
                  }
                });
              },
            ),
            GestureDetector(
                child: Container(
                  width: doubleTapLWidth / 2 - 30,
                  height: doubleTapLHeight - 44,
                  margin: EdgeInsets.fromLTRB(0, 0, doubleTapLWidth / 2 + 30, 40),
                ),
                onTap: () {
                  setState(() {
                    _overlay = !_overlay;
                    if (_overlay) {
                      doubleTapRHeight = videoHeight - 36;
                      doubleTapLHeight = videoHeight - 10;
                      doubleTapRMargin = 36;
                      doubleTapLMargin = 10;
                    } else if (!_overlay) {
                      doubleTapRHeight = videoHeight + 36;
                      doubleTapLHeight = videoHeight;
                      doubleTapRMargin = 0;
                      doubleTapLMargin = 0;
                    }
                  });
                },
                onDoubleTap: () {
                  setState(() {
                    _controller.seekTo(Duration(seconds: _controller.value.position.inSeconds - 10));
                  });
                }),
            GestureDetector(
              child: Container(
                width: doubleTapRWidth / 2 - 45,
                height: doubleTapRHeight - 80,
                margin: EdgeInsets.fromLTRB(doubleTapRWidth / 2 + 45, 0, 0, doubleTapLMargin + 20),
              ),
              onTap: () {
                setState(() {
                  _overlay = !_overlay;
                  if (_overlay) {
                    doubleTapRHeight = videoHeight - 36;
                    doubleTapLHeight = videoHeight - 10;
                    doubleTapRMargin = 36;
                    doubleTapLMargin = 10;
                  } else if (!_overlay) {
                    doubleTapRHeight = videoHeight + 36;
                    doubleTapLHeight = videoHeight;
                    doubleTapRMargin = 0;
                    doubleTapLMargin = 0;
                  }
                });
              },
              onDoubleTap: () {
                setState(() {
                  _controller.seekTo(Duration(seconds: _controller.value.position.inSeconds + 10));
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  //================================ Quality ================================//
  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        final children = <Widget>[];
        _qualityValues.forEach(
          (elem, value) => children.add(
            new ListTile(
              title: new Text(" ${elem.toString()} fps"),
              onTap: () => {
                setState(() {
                  _controller.pause();
                  _controller = VideoPlayerController.network(value);
                  _controller.setLooping(true);
                  _seek = true;
                  initFuture = _controller.initialize();
                  _controller.play();
                }),
              },
            ),
          ),
        );

        return Container(
          height: videoHeight,
          child: ListView(
            children: children,
          ),
        );
      },
    );
  }

  //================================ OVERLAY ================================//
  Widget _videoOverlay() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: _overlay
          ? Stack(
              children: <Widget>[
                GestureDetector(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            widget.videoControllerTheme.backgroundPlayer,
                            widget.videoControllerTheme.backgroundPlayer,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      child: _controller.value.isPlaying
                          ? Icon(
                              Icons.pause,
                              size: 60.0,
                              color: widget.videoControllerTheme.iconColor,
                            )
                          : Icon(
                              Icons.play_arrow,
                              size: 60.0,
                              color: widget.videoControllerTheme.iconColor,
                            ),
                      onTap: () {
                        setState(() {
                          _controller.value.isPlaying ? _controller.pause() : _controller.play();
                        });
                      },
                    ),
                  ),
                ),
                if (widget.enableSettings)
                  Positioned(
                    right: 8 + MediaQuery.of(context).padding.bottom,
                    top: 16,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      child: Icon(
                        Icons.settings,
                        size: 26.0,
                        color: widget.videoControllerTheme.iconColor,
                      ),
                      onTap: () {
                        position = _controller.value.position.inSeconds;
                        _seek = true;
                        _settingModalBottomSheet(context);
                        setState(() {});
                      },
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  left: MediaQuery.of(context).padding.bottom,
                  right: MediaQuery.of(context).padding.bottom,
                  child: _videoOverlaySlider(),
                )
              ],
            )
          : Center(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(top: videoHeight - 5),
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: widget.videoControllerTheme.progressColor,
                    backgroundColor: widget.videoControllerTheme.backgroundProgressColor,
                    bufferedColor: widget.videoControllerTheme.bufferedProgressColor,
                  ),
                  padding: EdgeInsets.only(top: 2),
                ),
              ),
            ),
    );
  }

  //=================== Overlay Controller ===================//
  Widget _videoOverlaySlider() {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (context, VideoPlayerValue value, child) {
        if (!value.hasError && value.initialized) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Text(
                          _getTime(value.position),
                          style: widget.videoControllerTheme.durationStyle,
                        ),
                        Expanded(
                          child: VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: widget.videoControllerTheme.progressColor,
                              backgroundColor: widget.videoControllerTheme.backgroundProgressColor,
                              bufferedColor: widget.videoControllerTheme.bufferedProgressColor,
                            ),
                            padding: EdgeInsets.all(8),
                          ),
                        ),
                        Text(
                          _getTime(value.duration),
                          style: widget.videoControllerTheme.durationStyle,
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.enableFullScreen)
                  InkWell(
                    child: Center(
                        child: Icon(
                      Icons.fullscreen_exit,
                      size: 30.0,
                      color: widget.videoControllerTheme.iconColor,
                    )),
                    onTap: () async {
                      setState(() {
                        _controller.pause();
                        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
                        SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);
                      });
                      Navigator.pop(context, _controller.value.position.inSeconds);
                    },
                  ),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  String _getTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(widget.enableTwoDigitsDuration ? 2 : 1, "0");
    String twoDigitsSecond(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigitsSecond(duration.inSeconds.remainder(60));

    if (duration.inHours != 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }
}
