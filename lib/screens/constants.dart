import 'dart:ui';

import 'package:flutter/material.dart';

Color buttonColor = const Color.fromARGB(255, 98, 162, 130);
Color checkBoxColor = const Color(0xFFE64A19);
Color compexDrawerCanvasColor = const Color(0xffe3e9f7);
const Color complexDrawerBlack = Color(0xff11111d);
const Color complexDrawerBlueGrey = Color(0xff1d1b31);
const Color iconColor = Color(0xFFE64A19);
const Color textColor = Color.fromARGB(250, 1, 25, 64);

bool modeSelected = false;

double buttonText = 16;
const double titleSize = 24;
const double subtitleSize = 12;
const double textSize = 12;

//URL's....

String endPointLink = "https://api.walkzero.com/graphql";

String loginToken = '58e2793f-9e43-438f-ae0d-0c31a3b479f5';

const String avatar2 =
    "https://cdn.pixabay.com/photo/2016/03/29/03/14/portrait-1287421_960_720.jpg";

Map<String, String> servermap = {
  'janus_ws': 'wss://janus.conf.meetecho.com/ws',
  'janus_rest': 'https://janus.conf.meetecho.com/janus',
  'servercheap': 'ws://proficientio.top/websocket',
  'onemandev_master_ws': 'wss://master-janus.onemandev.tech/websocket',
  'onemandev_master_rest': 'https://master-janus.onemandev.tech/rest',
  'onemandev_unified_rest': 'https://unified-janus.onemandev.tech/rest',
  'onemandev_unified_ws': 'wss://unified-janus.onemandev.tech/websocket'
};
