import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'fullscreen_player.dart';
import 'quality_links.dart';
import 'video_controller_theme.dart';

class VimeoPlayer extends StatefulWidget {
  final String id;
  final bool autoPlay;
  final bool looping;
  final bool enableTwoDigitsDuration;
  final bool enableFullScreen;
  final bool enableSettings;
  final int position;
  final VideoControllerTheme videoControllerTheme;

  VimeoPlayer({
    @required this.id,
    this.autoPlay,
    this.looping,
    this.position,
    this.enableTwoDigitsDuration = false,
    this.enableFullScreen = true,
    this.enableSettings = true,
    this.videoControllerTheme = const VideoControllerTheme(),
    Key key,
  }) : super(key: key);

  @override
  _VimeoPlayerState createState() => _VimeoPlayerState(id, autoPlay, looping, position);
}

class _VimeoPlayerState extends State<VimeoPlayer> {
  String _id;
  bool autoPlay = false;
  bool looping = false;
  bool _overlay = true;
  bool fullScreen = false;
  int position;

  _VimeoPlayerState(this._id, this.autoPlay, this.looping, this.position);

  VideoPlayerController _controller;
  Future<void> initFuture;

  QualityLinks _quality;
  Map _qualityValues;
  var _qualityValue;
  bool _seek = false;

  double videoHeight;
  double videoWidth;
  double videoMargin;

  double doubleTapRMargin = 36;
  double doubleTapRWidth = 400;
  double doubleTapRHeight = 160;
  double doubleTapLMargin = 10;
  double doubleTapLWidth = 400;
  double doubleTapLHeight = 160;

  @override
  void initState() {
    _quality = QualityLinks(_id);
    _quality.getQualitiesSync().then((value) {
      _qualityValues = value;
      _qualityValue = value[value.lastKey()];
      _controller = VideoPlayerController.network(_qualityValue);
      _controller.setLooping(looping);
      if (autoPlay) _controller.play();
      initFuture = _controller.initialize();

      setState(() {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
      });
    });

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          GestureDetector(
            child: FutureBuilder(
              future: initFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  double delta = MediaQuery.of(context).size.width - MediaQuery.of(context).size.height * _controller.value.aspectRatio;

                  videoHeight = MediaQuery.of(context).size.width / _controller.value.aspectRatio;
                  videoWidth = MediaQuery.of(context).size.width;
                  videoMargin = 0;

                  doubleTapRWidth = videoWidth;
                  doubleTapRHeight = videoHeight - 60;
                  doubleTapLWidth = videoWidth;
                  doubleTapLHeight = videoHeight;
                  doubleTapLMargin = videoMargin;
                  doubleTapRMargin = videoMargin;

                  if (_seek && _controller.value.duration.inSeconds > 2) {
                    _controller.seekTo(Duration(seconds: position));
                    _seek = false;
                  }
                  return Stack(
                    children: <Widget>[
                      Container(
                        height: videoHeight,
                        width: videoWidth,
                        margin: EdgeInsets.only(left: videoMargin),
                        child: VideoPlayer(_controller),
                      ),
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
                  doubleTapLHeight = videoHeight + 16;
                  doubleTapRMargin = 0;
                  doubleTapLMargin = 0;
                }
              });
            },
          ),
          GestureDetector(
            child: Container(
              width: doubleTapLWidth / 2 - 30,
              height: doubleTapLHeight - 46,
              margin: EdgeInsets.fromLTRB(0, 10, doubleTapLWidth / 2 + 30, doubleTapLMargin + 20),
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
                  doubleTapLHeight = videoHeight + 16;
                  doubleTapRMargin = 0;
                  doubleTapLMargin = 0;
                }
              });
            },
            onDoubleTap: () {
              setState(() {
                _controller.seekTo(Duration(seconds: _controller.value.position.inSeconds - 10));
              });
            },
          ),
          GestureDetector(
            child: Container(
              width: doubleTapRWidth / 2 - 45,
              height: doubleTapRHeight - 60,
              margin: EdgeInsets.fromLTRB(doubleTapRWidth / 2 + 45, doubleTapRMargin, 0, doubleTapRMargin + 20),
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
                  doubleTapLHeight = videoHeight + 16;
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
    );
  }

  //================================ Quality ================================//
  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        final children = <Widget>[];
        _qualityValues.forEach((elem, value) => children.add(
              new ListTile(
                title: new Text(" ${elem.toString()} fps"),
                onTap: () => {
                  setState(() {
                    _controller.pause();
                    _qualityValue = value;
                    _controller = VideoPlayerController.network(_qualityValue);
                    _controller.setLooping(true);
                    _seek = true;
                    initFuture = _controller.initialize();
                    _controller.play();
                  }),
                },
              ),
            ));

        return Container(
          child: Wrap(
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
                      width: videoWidth,
                      height: videoHeight,
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
                    right: 8,
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
                  left: 0,
                  right: 0,
                  child: _videoOverlaySlider(),
                )
              ],
            )
          : Center(
              child: Container(
                height: 5,
                width: videoWidth,
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
                        Icons.fullscreen,
                        size: 30.0,
                        color: widget.videoControllerTheme.iconColor,
                      ),
                    ),
                    onTap: () async {
                      /*setState(() {
                        _controller.pause();
                      });*/
                      await Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (BuildContext context, _, __) => FullscreenPlayer(
                            id: _id,
                            autoPlay: true,
                            controller: _controller,
                            position: _controller.value.position.inSeconds,
                            initFuture: initFuture,
                            qualityValue: _qualityValue,
                            enableTwoDigitsDuration: widget.enableTwoDigitsDuration,
                            looping: widget.looping,
                            enableFullScreen: widget.enableFullScreen,
                            enableSettings: widget.enableSettings,
                            videoControllerTheme: widget.videoControllerTheme,
                          ),
                          transitionsBuilder: (___, Animation<double> animation, ____, Widget child) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(scale: animation, child: child),
                            );
                          },
                        ),
                      ).then((value) {
                        setState(() {
                          position = value;
                        });
                        Future.delayed(Duration(milliseconds: 100)).then((value) => setState(() {}));
                      });
                      setState(() {
                        _controller.play();
                        _seek = true;
                      });
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
