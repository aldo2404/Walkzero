import 'package:flutter/material.dart';
import 'package:walkzero/screens/constants.dart';

class ReuseButtonField {
  elavatedButton(BuildContext context, Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(buttonColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)))),
          onPressed: onPressed,
          child: Text(
            'Login',
            style: TextStyle(fontSize: buttonText),
          ),
        ),
      ),
    );
  }

  meetingButton(String buttonName, Function() onPressed) {
    return ElevatedButton(
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)))),
        onPressed: onPressed,
        child: Text(buttonName));
  }

  textButton(Function() onPressed, String buttonText) {
    return TextButton(onPressed: onPressed, child: Text(buttonText));
  }
}

///video call button field.....

class HomeMeetingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? color;
  final String text;
  const HomeMeetingButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.text,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color ?? const Color.fromARGB(255, 0, 125, 234),
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.06),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            width: 55,
            height: 55,
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}

class MeetingOption extends StatelessWidget {
  final String text;
  final bool isMute;
  final Function(bool) onChange;
  const MeetingOption({
    Key? key,
    required this.text,
    required this.isMute,
    required this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Color.fromRGBO(46, 46, 46, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Switch.adaptive(
            value: isMute,
            onChanged: onChange,
          ),
        ],
      ),
    );
  }
}
