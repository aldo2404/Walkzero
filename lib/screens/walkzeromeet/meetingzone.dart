//import 'dart:math';

import 'package:flutter/material.dart';
//import 'package:walkzero/config/jitisi_meetconfig.dart';
import 'package:walkzero/constwidget/reusebutton.dart';
//import 'package:walkzero/screens/videocallscreen.dart';

class MeetingZoneScreen extends StatefulWidget {
  const MeetingZoneScreen({super.key});

  @override
  State<MeetingZoneScreen> createState() => _MeetingZoneScreenState();
}

class _MeetingZoneScreenState extends State<MeetingZoneScreen> {
  //final JitsiMeetMethods _jitsiMeetMethods = JitsiMeetMethods();

  createNewMeeting() async {
    // String roomName = (Random().nextInt(1000000) + 1000000).toString();
    // _jitsiMeetMethods.createMeeting(
    //     roomName: roomName, isAudioMuted: true, isVideoMuted: true);
  }

  joinMeeting(BuildContext context) {
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (_) => const VideoCallScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ReuseButtonField().meetingButton('New meeting', () {}),

              const SizedBox(width: 10),
              ReuseButtonField().meetingButton('Join meeting', () {}),
              // ElevatedButton(onPressed: () {}, child: const Text('Join meeting')),
            ],
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              HomeMeetingButton(
                onPressed: createNewMeeting,
                text: 'New Meeting',
                color: const Color.fromARGB(255, 255, 112, 74),
                icon: Icons.videocam,
              ),
              HomeMeetingButton(
                onPressed: () {
                  // Navigator.of(context).pushNamed(VideoCallScreen.id);
                },
                text: 'Join Meeting',
                icon: Icons.add_box_rounded,
              ),
              HomeMeetingButton(
                onPressed: () {},
                text: 'Schedule',
                icon: Icons.calendar_today,
              ),
              HomeMeetingButton(
                onPressed: () {},
                text: 'Share Screen',
                icon: Icons.arrow_upward_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
