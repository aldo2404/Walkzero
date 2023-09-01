import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:walkzero/screens/walkzeromeet/web_rtc.dart';

import 'ScreenSelectDialog.dart';

// ignore: must_be_immutable
class MeetPage extends StatefulWidget {
  MeetPage(
      {required this.roomId,
      super.key,
      required this.localRenderer,
      required this.remoteRenderer});
  String roomId;
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;

  @override
  State<MeetPage> createState() => _MeetPageState();
}

class _MeetPageState extends State<MeetPage> {
  // final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  // final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _screenShareRenderer = RTCVideoRenderer();
  Signaling signaling = Signaling();
  TextEditingController textEditingController = TextEditingController(text: '');

  DesktopCapturerSource? selectedSource;
  //MediaStream? _localStream;
  MediaRecorder? _mediaRecorder;

  bool _isMute = false, _isVideo = true, isFrontCameraSelected = false;
  bool _isScreenShare = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    textEditingController.text = widget.roomId;
    widget.localRenderer.initialize();
    widget.remoteRenderer.initialize();
    _screenShareRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      widget.remoteRenderer.srcObject = stream;
      setState(() {});
    });
    signaling.openUserMedia(widget.localRenderer, widget.remoteRenderer);
  }

  void _toggleCamera() async {
    if (_isVideo) {
      // Disable the camera by removing the local video track
      signaling.localStream!.getVideoTracks().forEach((track) {
        track.enabled = false;
      });
    } else {
      // Enable the camera by enabling the local video track
      signaling.localStream!.getVideoTracks().forEach((track) {
        track.enabled = true;
      });
    }

    setState(() {
      _isVideo = !_isVideo;
    });
  }

  void _toggleMic() async {
    if (_isMute) {
      // Disable the microphone by muting the local audio track
      signaling.localStream!.getAudioTracks().forEach((track) {
        track.enabled = false;
      });
    } else {
      // Enable the microphone by enabling the local audio track
      signaling.localStream!.getAudioTracks().forEach((track) {
        track.enabled = true;
      });
    }
    setState(() {
      _isMute = !_isMute;
    });
  }

  _switchCamera() {
    // change status
    isFrontCameraSelected = !isFrontCameraSelected;

    // switch camera
    signaling.localStream!.getVideoTracks().forEach((track) {
      // ignore: deprecated_member_use
      track.switchCamera();
    });
    setState(() {});
  }

  void screenSharing() {
    if (_isScreenShare) {
      selectScreenSourceDialog(context);
    } else {
      _stop();
    }
  }

  Future<void> _stop() async {
    try {
      if (kIsWeb) {
        signaling.localStream?.getTracks().forEach((track) => track.stop());
      }
      await signaling.localStream?.dispose();
      signaling.localStream = null;
      _screenShareRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> selectScreenSourceDialog(BuildContext context) async {
    if (WebRTC.platformIsDesktop) {
      final source = await showDialog<DesktopCapturerSource>(
        context: context,
        builder: (context) => ScreenSelectDialog(),
      );
      if (source != null) {
        await _makeCall(source);
      }
    } else {
      if (WebRTC.platformIsAndroid) {
        // Android specific
        Future<void> requestBackgroundPermission([bool isRetry = false]) async {
          // Required for android screenshare.
          try {
            var hasPermissions = await FlutterBackground.hasPermissions;
            if (!isRetry) {
              const androidConfig = FlutterBackgroundAndroidConfig(
                notificationTitle: 'Screen Sharing',
                notificationText: 'LiveKit Example is sharing the screen.',
                notificationImportance: AndroidNotificationImportance.Default,
                notificationIcon: AndroidResource(
                    name: 'livekit_ic_launcher', defType: 'mipmap'),
              );
              hasPermissions = await FlutterBackground.initialize(
                  androidConfig: androidConfig);
            }
            if (hasPermissions &&
                !FlutterBackground.isBackgroundExecutionEnabled) {
              await FlutterBackground.enableBackgroundExecution();
            }
          } catch (e) {
            if (!isRetry) {
              return await Future<void>.delayed(const Duration(seconds: 1),
                  () => requestBackgroundPermission(true));
            }
            print('could not publish video: $e');
          }
        }

        await requestBackgroundPermission();
      }
      await _makeCall(null);
    }
  }

  Future<void> _makeCall(DesktopCapturerSource? source) async {
    setState(() {
      selectedSource = source;
    });

    try {
      var stream =
          await navigator.mediaDevices.getDisplayMedia(<String, dynamic>{
        'video': selectedSource == null
            ? true
            : {
                'deviceId': {'exact': selectedSource!.id},
                'mandatory': {'frameRate': 30.0}
              }
      });
      stream.getVideoTracks()[0].onEnded = () {
        print(
            'By adding a listener on onEnded you can: 1) catch stop video sharing on Web');
      };

      signaling.localStream = stream;
      _screenShareRenderer.srcObject = signaling.localStream;
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      //_inCalling = true;
    });
  }

  void _startRecording() async {
    if (signaling.localStream == null)
      throw Exception('Stream is not initialized');
    if (Platform.isIOS) {
      print('Recording is not available on iOS');
      return;
    }
    print("recordeing started");
    // TODO(rostopira): request write storage permission
    final storagePath = await getExternalStorageDirectory();
    if (storagePath == null) throw Exception('Can\'t find storagePath');

    final filePath = storagePath.path + '/webrtc_sample/test.mp4';
    _mediaRecorder = MediaRecorder();
    setState(() {});

    final videoTrack = signaling.localStream!
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    final audioTrack = signaling.localStream!
        .getAudioTracks()
        .firstWhere((track) => track.kind == 'audio');
    await _mediaRecorder!.start(
      filePath,
      videoTrack: videoTrack,
     // audioChannel: audioTrack,
    );
    print("file_path: $filePath");
  }

  void _stopRecording() async {
    await _mediaRecorder?.stop();
    setState(() {
      _mediaRecorder = null;
    });
  }

  // @override
  // void dispose() {
  //   widget.localRenderer.dispose();
  //   widget.remoteRenderer.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            meetCallScreen(),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
              child: Row(children: [
                _isRecording
                    ? Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20)),
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _isRecording = false;
                              });
                              _stopRecording();
                            },
                            icon: const Icon(
                              Icons.stop,
                              color: Colors.red,
                            ),
                            iconSize: 15,
                          ),
                        ),
                      )
                    : Container(
                        width: 0,
                        height: 0,
                      ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "RoomID: ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: TextFormField(
                    readOnly: true,
                    style: const TextStyle(color: Colors.white),
                    controller: textEditingController,
                  ),
                )
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Align(
                alignment: Alignment.topRight,
                child: popUpMenu(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget meetCallScreen() {
    return Column(
      children: [
        _isScreenShare
            ? Container(
                color: Colors.black26,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.7,
                child: RTCVideoView(_screenShareRenderer),
              )
            : Expanded(
                child: Stack(children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: RTCVideoView(
                      widget.remoteRenderer,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: Container(
                      height: 150,
                      width: 120,
                      decoration: BoxDecoration(
                          border: Border.all(), color: Colors.white),
                      child: _isVideo
                          ? RTCVideoView(
                              widget.localRenderer,
                              mirror: isFrontCameraSelected,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            )
                          : const CircleAvatar(
                              radius: 20,
                              child: Text(
                                'AN',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 30),
                              ),
                            ),
                    ),
                  )
                ]),
              ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(_isMute ? Icons.mic : Icons.mic_off),
                onPressed: _toggleMic,
              ),
              IconButton(
                icon: Icon(_isVideo ? Icons.videocam : Icons.videocam_off),
                onPressed: _toggleCamera,
              ),
              IconButton(
                icon: const Icon(Icons.cameraswitch),
                onPressed: _switchCamera,
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isScreenShare = !_isScreenShare;
                  });
                  screenSharing();
                  _toggleCamera();
                  if (_isScreenShare == false) {
                    signaling.openUserMedia(
                        widget.localRenderer, widget.remoteRenderer);
                  }
                },
                icon: const Icon(Icons.ios_share_outlined),
                iconSize: 30,
              ),
              IconButton(
                icon: const Icon(Icons.call_end),
                iconSize: 30,
                onPressed: () {
                  signaling.hangUp(widget.localRenderer);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget popUpMenu(BuildContext context) {
    return PopupMenuButton(
        color: Colors.white,
        itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  setState(() {
                    _isRecording = true;
                  });
                  _startRecording();
                },
                child: const Text("Start Screen Record"),
              ),
              PopupMenuItem(
                enabled: _isRecording,
                onTap: () {
                  setState(() {
                    _isRecording = false;
                  });
                },
                child: const Text("Stop Recording"),
              )
            ]);
  }

  Widget iconButton(Function() onTap, IconData icon, Color color) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: color),
        child: Icon(icon),
      ),
    );
  }
}
