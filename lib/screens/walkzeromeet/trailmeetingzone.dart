//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:walkzero/screens/walkzeromeet/web_rtc.dart';

class MeetingHomePage extends StatefulWidget {
  const MeetingHomePage({Key? key}) : super(key: key);

  @override
  MeetingHomePageState createState() => MeetingHomePageState();
}

class MeetingHomePageState extends State<MeetingHomePage> {
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');

  final selectedAll = EmployeeNameList(name: 'Select All');
  // bool _multiSelected = false;
  bool isContainerVisible = false;

  final emloyeeNameList = [
    EmployeeNameList(name: 'Kishore'),
    EmployeeNameList(name: 'Nixon'),
    EmployeeNameList(name: 'Gokul')
  ];

  @override
  void initState() {
    _localRenderer.initialize();
    // _remoteRenderer.initialize();

    signaling.openUserMedia(_localRenderer, _remoteRenderer);

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
  }

  void _toggleContainerVisibility() {
    setState(() {
      isContainerVisible = !isContainerVisible;
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Walkzero Meet"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ElevatedButton(
                //   onPressed: () {
                //     //signaling.openUserMedia(_localRenderer, _remoteRenderer);
                //   },
                //   child: const Text("Open camera & microphone"),
                // ),
                // const SizedBox(
                //   width: 8,
                // ),
                ElevatedButton(
                  onPressed: () async {
                    // const AlertDialog(
                    //   title: Text('trail'),
                    // );
                    _toggleContainerVisibility();

                    // roomId = await signaling.createRoom(_remoteRenderer);
                    // textEditingController.text = roomId!;
                    // setState(() {});
                  },
                  child: const Text("Create room"),
                ),

                const SizedBox(
                  width: 8,
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add roomId
                    signaling.joinRoom(
                      textEditingController.text.trim(),
                      _remoteRenderer,
                    );
                  },
                  child: const Text("Join room"),
                ),
                const SizedBox(
                  width: 8,
                ),
                ElevatedButton(
                  onPressed: () {
                    signaling.hangUp(_localRenderer);
                  },
                  child: const Text("Hangup"),
                )
              ],
            ),
          ),
          if (isContainerVisible) Center(child: createRoom()),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                  Expanded(child: RTCVideoView(_remoteRenderer)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Join the following Room: "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8)
        ],
      ),
    );
  }

  Widget createRoom() {
    return Center(
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.orange.shade300,
          border: Border.all(),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    onTap: () {
                      final newValue = !selectedAll.value;
                      setState(() {
                        emloyeeNameList.forEach((element) {
                          element.value = newValue;
                        });
                        selectedAll.value = !selectedAll.value;
                      });
                    },
                    leading: Checkbox(
                      shape: const CircleBorder(),
                      value: selectedAll.value,
                      onChanged: (value) {
                        setState(() {
                          selectedAll.value = !selectedAll.value;
                        });
                      },
                    ),
                    title: const Text('Selected All'),
                  ),
                  const Divider(),
                  ...emloyeeNameList
                      .map(
                        (item) => ListTile(
                          onTap: () => setState(() {
                            item.value = !item.value;
                          }),
                          leading: Checkbox(
                            shape: const CircleBorder(),
                            value: item.value,
                            onChanged: (value) {
                              setState(() {
                                item.value = !item.value;
                              });
                            },
                          ),
                          title: Text(item.name),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        _toggleContainerVisibility();
                      },
                      child: const Text('cancel')),
                  ElevatedButton.icon(
                      onPressed: () async {
                        roomId = await signaling.createRoom(_remoteRenderer);
                        textEditingController.text = roomId!;
                        setState(() {});
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Send Id')),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class EmployeeNameList {
  String name;
  bool value;

  EmployeeNameList({required this.name, this.value = false});
}
