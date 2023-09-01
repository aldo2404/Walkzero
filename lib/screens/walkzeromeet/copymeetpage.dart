import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:walkzero/screens/walkzeromeet/meetpage.dart';
import 'package:walkzero/screens/walkzeromeet/screenselectdialog.dart';
import 'package:walkzero/screens/walkzeromeet/web_rtc.dart';

import '../../constwidget/reusewidget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Walkzero Meet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CopyMeetPage(),
    );
  }
}

class CopyMeetPage extends StatefulWidget {
  const CopyMeetPage({Key? key}) : super(key: key);

  @override
  _CopyMeetPageState createState() => _CopyMeetPageState();
}

class _CopyMeetPageState extends State<CopyMeetPage> {
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _screenShareRenderer = RTCVideoRenderer();

  MediaStream? _localStream;
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');

  DesktopCapturerSource? selected_source_;

  bool _isMute = true, _isVideo = true, isFrontCameraSelected = true;
  bool _isScreenShare = false;
  bool _ishiden = false;

  int roomNumber = 12345;

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    //startForegroundService();

    super.initState();
  }

  Future<bool> startForegroundService() async {
    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: 'Title of the notification',
      notificationText: 'Text of the notification',
      notificationImportance: AndroidNotificationImportance.Default,
      notificationIcon: AndroidResource(
          name: 'background_icon',
          defType: 'drawable'), // Default is ic_launcher from folder mipmap
    );
    await FlutterBackground.initialize(androidConfig: androidConfig);
    return FlutterBackground.enableBackgroundExecution();
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

  _switchCamera() {
    // change status
    isFrontCameraSelected = !isFrontCameraSelected;

    // switch camera
    _localStream?.getVideoTracks().forEach((track) {
      // ignore: deprecated_member_use
      track.switchCamera();
    });
    setState(() {});
  }

  void screenSharing() {
    //_screenShareRenderer.initialize();
    if (_isScreenShare) {
      //signaling.shareScreening(_localRenderer);
      selectScreenSourceDialog(context);
    } else {
      _stop();
    }
  }

  Future<void> _stop() async {
    try {
      if (kIsWeb) {
        _localStream?.getTracks().forEach((track) => track.stop());
      }
      await _localStream?.dispose();
      _localStream = null;
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
      selected_source_ = source;
    });

    try {
      var stream =
          await navigator.mediaDevices.getDisplayMedia(<String, dynamic>{
        'video': selected_source_ == null
            ? true
            : {
                'deviceId': {'exact': selected_source_!.id},
                'mandatory': {'frameRate': 30.0}
              }
      });
      stream.getVideoTracks()[0].onEnded = () {
        print(
            'By adding a listener on onEnded you can: 1) catch stop video sharing on Web');
      };

      _localStream = stream;
      _screenShareRenderer.srcObject = _localStream;
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      //_inCalling = true;
    });
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("walkzero Meet"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //create roomid button...
              ElevatedButton(
                onPressed: () async {
                  //meetCallScreen();
                  signaling.openUserMedia(_localRenderer, _remoteRenderer);
                  roomId = await signaling.createRoom(_remoteRenderer);
                  textEditingController.text = roomId!;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MeetPage(
                              roomId: roomId!,
                              localRenderer: _localRenderer,
                              remoteRenderer: _remoteRenderer)));

                  setState(() {
                    _ishiden = true;
                  });
                },
                child: const Text("Create room"),
              ),
              const SizedBox(width: 8),
              //join roomid button....
              ElevatedButton(
                onPressed: () {
                  if (textEditingController.text.isNotEmpty) {
                    signaling.openUserMedia(_localRenderer, _remoteRenderer);
                    // Add roomId
                    signaling.joinRoom(
                      textEditingController.text.trim(),
                      _remoteRenderer,
                    );
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MeetPage(
                                roomId: textEditingController.text,
                                localRenderer: _localRenderer,
                                remoteRenderer: _remoteRenderer)));
                    meetCallScreen();
                  } else {
                    ReuseWidget()
                        .snackBarMessage(context, "Please enter room Id");
                  }
                  setState(() {
                    _ishiden = true;
                  });
                },
                child: const Text("Join room"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Join the following Room: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 15),
          // _isScreenShare
          //     ? Container(
          //         color: Colors.black26,
          //         width: MediaQuery.of(context).size.width,
          //         height: MediaQuery.of(context).size.height * 0.6,
          //         child: RTCVideoView(_screenShareRenderer),
          //       )
          //     : Expanded(
          //         child: Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: Column(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               Expanded(
          //                   child: Container(
          //                       width:
          //                           MediaQuery.of(context).size.width * 0.85,
          //                       height: 200,
          //                       decoration: BoxDecoration(
          //                           borderRadius: BorderRadius.circular(15)),
          //                       child: _isVideo
          //                           ? RTCVideoView(
          //                               _localRenderer,
          //                               mirror: true,
          //                               objectFit: RTCVideoViewObjectFit
          //                                   .RTCVideoViewObjectFitCover,
          //                             )
          //                           : const SizedBox(
          //                               width: 60,
          //                               height: 60,
          //                               child: CircleAvatar(
          //                                 //radius: 2,
          //                                 child: Text(
          //                                   'AN',
          //                                   style: TextStyle(
          //                                       fontWeight: FontWeight.w500,
          //                                       fontSize: 20),
          //                                 ),
          //                               ),
          //                             ))),
          //               const SizedBox(height: 10),
          //               Expanded(
          //                   child: Container(
          //                       width:
          //                           MediaQuery.of(context).size.width * 0.5,
          //                       height: 150,
          //                       margin: const EdgeInsets.fromLTRB(
          //                           5.0, 5.0, 5.0, 5.0),
          //                       decoration: BoxDecoration(
          //                           borderRadius: BorderRadius.circular(15)),
          //                       child: RTCVideoView(_remoteRenderer))),
          //             ],
          //           ),
          //         ),
          //       ),
          // const SizedBox(height: 8),
          // _ishiden
          //     ? Align(
          //         alignment: Alignment.bottomCenter,
          //         child: Padding(
          //           padding: const EdgeInsets.only(bottom: 20),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               iconButton(() {
          //                 _toggleMic();
          //                 //_localRenderer.getAudioTracks()[0].enabled = !_isMute;
          //               }, _isMute ? Icons.mic : Icons.mic_off,
          //                   _isMute ? Colors.redAccent : Colors.grey),
          //               const SizedBox(width: 15),
          //               iconButton(() {
          //                 _toggleCamera();
          //               }, _isVideo ? Icons.videocam : Icons.videocam_off,
          //                   _isVideo ? Colors.redAccent : Colors.grey),
          //               const SizedBox(width: 15),
          //               iconButton(() {
          //                 setState(() {
          //                   _isScreenShare = !_isScreenShare;
          //                 });
          //                 screenSharing();
          //                 _toggleCamera();
          //                 if (!_isScreenShare) {
          //                   signaling.openUserMedia(
          //                       _localRenderer, _remoteRenderer);
          //                 }
          //               }, Icons.ios_share,
          //                   _isScreenShare ? Colors.redAccent : Colors.grey),
          //               const SizedBox(width: 15),
          //               iconButton(() {
          //                 signaling.hangUp(_localRenderer);

          //                 setState(() {
          //                   _ishiden = false;
          //                 });
          //                 //dispose();

          //                 Navigator.pop(context);
          //               }, Icons.call_end, Colors.redAccent)
          //             ],
          //           ),
          //         ),
          //       )
          //     : Container(),
        ],
      ),
    );
  }

  Widget meetCallScreen() {
    return Column(
      children: [
        Expanded(
          child: Stack(children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: RTCVideoView(
                _remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: SizedBox(
                height: 150,
                width: 120,
                child: RTCVideoView(
                  _localRenderer,
                  mirror: isFrontCameraSelected,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
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
                icon: const Icon(Icons.call_end),
                iconSize: 30,
                onPressed: () => signaling.hangUp(_localRenderer),
              ),
              IconButton(
                icon: const Icon(Icons.cameraswitch),
                onPressed: _switchCamera,
              ),
              IconButton(
                icon: Icon(_isVideo ? Icons.videocam : Icons.videocam_off),
                onPressed: _toggleCamera,
              ),
            ],
          ),
        ),
      ],
    );
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
