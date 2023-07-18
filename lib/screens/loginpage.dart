import 'package:flutter/material.dart';
import 'package:walkzero/constwidget/reusebutton.dart';
import 'package:walkzero/constwidget/textfield.dart';
import 'package:walkzero/screens/constants.dart';
import 'package:walkzero/screens/homescreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool visibility = true;
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(

              // gradient: LinearGradient(
              //     colors: [Colors.orange.shade900, Colors.blue.shade900],
              //     begin: Alignment.topLeft,
              //     end: Alignment.bottomRight),
              ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
            child: Stack(
              children: [
                const Text(
                  "SignUp",
                  style: TextStyle(fontSize: titleSize),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ReuseTextField(
                      controller: emailController,
                      hintText: "Enter mail ID",
                      obscureText: false,
                      suffixIcon: const Icon(Icons.mail),
                      validator: (value) {
                        if (value!.isEmpty ||
                            !RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                                .hasMatch(value)) {
                          return 'Enter correct email id';
                        }
                        return null;
                      },
                    ),
                    ReuseTextField(
                      controller: passwordController,
                      hintText: 'Enter Password',
                      obscureText: visibility,
                      suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              visibility = !visibility;
                            });
                          },
                          child: visibility
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                checkColor: Colors.white,
                                activeColor: checkBoxColor,
                                side: const BorderSide(
                                    width: 2, color: Color(0XFFE64A19)),
                                value: _isChecked,
                                onChanged: (value) {
                                  setState(() {
                                    _isChecked = !_isChecked;
                                  });
                                },
                              ),
                              const Text(
                                "Remember me",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          ReuseButtonField()
                              .textButton(() => null, 'Forget Password?')
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ReuseButtonField().elavatedButton(context, () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()));
                    })
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
