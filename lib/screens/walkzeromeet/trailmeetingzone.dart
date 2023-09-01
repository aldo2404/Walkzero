//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:walkzero/constwidget/reusewidget.dart';
import 'package:walkzero/screens/walkzeromeet/meetpage.dart';
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
  TextEditingController joinRoomIdController = TextEditingController(text: '');

  final selectedAll = EmployeeNameList(name: 'Select All');
  // bool _multiSelected = false;
  bool isContainerVisible = false;
  bool isJoinRoomVisiable = false;

  final emloyeeNameList = [
    EmployeeNameList(name: 'Kishore'),
    EmployeeNameList(name: 'Nixon'),
    EmployeeNameList(name: 'Gokul')
  ];

  void _toggleContainerVisibility() {
    setState(() {
      isContainerVisible = !isContainerVisible;
    });
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  roomId = await signaling.createRoom(_remoteRenderer);
                  //_toggleContainerVisibility();
                  showModalSheet();
                },
                child: const Text("Create room"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isJoinRoomVisiable = !isJoinRoomVisiable;
                  });
                  // Add roomId
                },
                child: const Text("Join room"),
              ),
              // const SizedBox(width: 8),
              // ElevatedButton(
              //   onPressed: () {
              //     signaling.hangUp(_localRenderer);
              //   },
              //   child: const Text("Hangup"),
              // )
            ],
          ),
          if (isContainerVisible)
            Center(heightFactor: 1.5, child: createRooms()),
          const SizedBox(height: 8),
          if (isJoinRoomVisiable) Center(heightFactor: 5, child: joinRooms()),
        ],
      ),
    );
  }

  Widget joinRooms() {
    return Container(
      width: 300,
      height: 120,
      decoration: BoxDecoration(
          border: Border.all(), borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  "Enter Room Id: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Flexible(
                  child: TextFormField(
                    controller: joinRoomIdController,
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
                onPressed: () {
                  if (joinRoomIdController.text.isNotEmpty) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MeetPage(
                              localRenderer: _localRenderer,
                              remoteRenderer: _remoteRenderer,
                                  roomId: joinRoomIdController.text,
                                  
                                )));
                    signaling.joinRoom(
                        joinRoomIdController.text.trim(), _remoteRenderer);
                    setState(() {
                      isJoinRoomVisiable = !isJoinRoomVisiable;
                    });
                  } else {
                    ReuseWidget()
                        .snackBarMessage(context, "Please enter room Id");
                  }
                },
                child: const Text('ok')),
          )
        ],
      ),
    );
  }

  Widget createRooms() {
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
                      isAllSelected(selectedAll);
                    },
                    leading: Checkbox(
                      shape: const CircleBorder(),
                      value: selectedAll.value,
                      onChanged: (value) {
                        isAllSelected(selectedAll);
                      },
                    ),
                    title: Text(selectedAll.name),
                  ),
                  const Divider(),
                  ...emloyeeNameList
                      .map(
                        (item) => ListTile(
                          onTap: () => isSingleSelected(item),
                          leading: Checkbox(
                            shape: const CircleBorder(),
                            value: item.value,
                            onChanged: (value) {
                              isSingleSelected(item);
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
                        //roomId = await signaling.createRoom(_remoteRenderer);
                        //textEditingController.text = roomId!;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => MeetPage(
                                   localRenderer: _localRenderer,
                              remoteRenderer: _remoteRenderer,
                                      roomId: roomId!,
                                      // joinRoom: false,
                                    )));
                        setState(() {
                          isContainerVisible = !isContainerVisible;
                        });
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

  showModalSheet() {
    showModalBottomSheet<void>(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 220,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.link),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Get a meeting link to share'),
                  ],
                ),
                onTap: () async {},
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.video_call),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Start an instant meeting'),
                  ],
                ),
                onTap: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MeetPage(
                             localRenderer: _localRenderer,
                              remoteRenderer: _remoteRenderer,
                                roomId: roomId!,
                                // joinRoom: false,
                              )));
                  //Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.calendar_month),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Schedule in Google Calender'),
                  ],
                ),
                onTap: () async {},
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.close),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Close'),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  isAllSelected(EmployeeNameList valueItem) {
    setState(() {
      emloyeeNameList.forEach((element) {
        element.value = !valueItem.value;
      });
      valueItem.value = !valueItem.value;
    });
  }

  isSingleSelected(EmployeeNameList valueItem) {
    setState(() {
      valueItem.value = !valueItem.value;

      if (!valueItem.value) {
        selectedAll.value = false;
      } else {
        final allSingleSelected =
            emloyeeNameList.every((element) => element.value);
        selectedAll.value = allSingleSelected;
      }
    });
  }
}

class EmployeeNameList {
  String name;
  bool value;

  EmployeeNameList({required this.name, this.value = false});
}
