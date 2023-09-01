import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:walkzero/constwidget/glass_box.dart';
import 'package:walkzero/constwidget/reusebutton.dart';
import 'package:walkzero/constwidget/reusewidget.dart';
import 'package:walkzero/constwidget/textfield.dart';
import 'package:walkzero/screens/constants.dart';
import 'package:walkzero/screens/homescreen.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  String? _initialLink;
  final confirmPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  bool newPassVisibility = false;
  bool confirmPassVisibility = false;
  bool errorText = false;

  String x_account_id = "58e2793f-9e43-438f-ae0d-0c31a3b479f5";

  Dio dio = Dio();
  String userId = "70f2265e-de31-4e5a-89a9-5b23717fbc32";
  String userToken = "bdb80736-7a53-470a-9d34-ca295e8b79e6";

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  Future<void> _initDeepLinkListener() async {
    try {
      // Get the initial link when the app is first opened via a deep link
      String? link = await getInitialLink();
      print('link: $link');

      setState(() {
        _initialLink = link;
      });
      _handleDeepLink(link);

      // You can also set up a stream to listen for future deep links
      getUriLinksStream().listen((Uri? uri) {
        _handleDeepLink(uri?.toString());
      });
    } on PlatformException {
      // Handle exception, if any
    }
  }

  void _handleDeepLink(String? link) {
    if (link != null) {
      // Parse the URL and extract the token
      Uri uri = Uri.parse(link);
      String? token = uri.queryParameters['token'];

      if (token != null) {
        // Use the extracted token for password reset
        print('Reset password token: $token');
        // You can now navigate to the password reset screen with the token
        // For example:
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => PasswordResetScreen(token: token)),
        // );
      }
    }
  }

  void setPasswordPost() async {
    dio.options.headers = {'x-account-id': x_account_id};

    String setPassword = r'''
 mutation setPassword ($input: SetPasswordInput!) {
  setPassword(input: $input) {
    token,
    profile {
     first_name,
      last_name,
      fullname,
      email,
      photo,
      type,
      superuser
    }
    org {
      id,
      name,
      logo
    }
  }
}
  ''';

    Map<String, dynamic> variables = {
      'input': {
        'password': newPasswordController.text,
        'confirm_password': confirmPasswordController.text,
        'uid': userId,
        'token': "052b9461-b25a-4fa0-b755-72058db6be12"
      }
    };
    try {
      final response = await dio.post(endPointLink,
          data: {'query': setPassword, 'variables': variables});

      if (response.statusCode == 200) {
        print(response.data['password']);
        if (response.data['data'] != null &&
            response.data['password'] == response.data['confirm_password']) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => HomeScreen()));
        } else {
          ReuseWidget().snackBarMessage(
              context, response.data['errors'][0]['error'][0].toString());

          // ReuseWidget().snackBarMessage(context,
          //     response.data['errors'][0]['confirm_password'][0].toString());
          print(response.data['errors'][0]['error'][0].toString());
        }

        print('success');
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print('error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Colors.grey,
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.3),
              Colors.grey,
            ])),
            child: Center(
              child: GlassBoxWidget(
                width: 300.0,
                height: 300.0,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ListTile(
                        title: Text('Set New Password'),
                        subtitle: Text('change only never Change'),
                      ),
                      ReuseTextField(
                        controller: newPasswordController,
                        hintText: "New password",
                        obscureText: newPassVisibility,
                        suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                newPassVisibility = !newPassVisibility;
                              });
                            },
                            child: newPassVisibility
                                ? Icon(Icons.visibility_off,
                                    color: Colors.green.shade500)
                                : Icon(
                                    Icons.visibility,
                                    color: Colors.green.shade500,
                                  )),
                      ),
                      const SizedBox(height: 10),
                      ReuseTextField(
                        controller: confirmPasswordController,
                        hintText: "Confirm password",
                        obscureText: confirmPassVisibility,
                        helperText: '',
                        suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                confirmPassVisibility = !confirmPassVisibility;
                              });
                            },
                            child: confirmPassVisibility
                                ? Icon(Icons.visibility_off,
                                    color: Colors.green.shade500)
                                : Icon(Icons.visibility,
                                    color: Colors.green.shade500)),
                        validator: ((value) {
                          if (value != newPasswordController.text) {
                            return "Password not match";
                          }
                          return null;
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                        child: ReuseButtonField()
                            .elavatedButton(context, 'Set New Password', () {
                          if (confirmPasswordController.text.isNotEmpty) {
                            setPasswordPost();
                            if (newPasswordController.text ==
                                confirmPasswordController.text) {
                            } else {
                              ReuseWidget().snackBarMessage(
                                  context, 'Password does not match');
                            }
                          } else {
                            ReuseWidget()
                                .snackBarMessage(context, 'Enter Password ');
                          }
                        }),
                      )
                    ],
                  ),
                ),
              ),
            )

            // Stack(
            //   children: [

            //     Center(
            //       child: Container(
            //         width: MediaQuery.of(context).size.width * 0.9,
            //         height: 300,
            //         decoration: BoxDecoration(
            //             border: Border.all(color: Colors.black26),
            //             borderRadius: BorderRadius.circular(20),
            //             boxShadow: [
            //               // const BoxShadow(
            //               //   color: Colors.black12,
            //               // ),
            //               BoxShadow(
            //                   color: Colors.black12,
            //                   spreadRadius: 0.0,
            //                   blurRadius: 0.0,
            //                   offset: Offset(5, 2)),
            //             ]),
            //         child: Stack(
            //           children: [
            //             // BackdropFilter(
            //             //   filter: ImageFilter.blur(
            //             //     sigmaX: 4.0,
            //             //     sigmaY: 4.0,
            //             //   ),
            //             //   child: Container(),
            //             // ),
            //             Center(
            //               child: Column(
            //                 mainAxisAlignment: MainAxisAlignment.center,
            //                 children: [
            //                   const ListTile(
            //                     title: Text('Set New Password'),
            //                     subtitle: Text('change only never Change'),
            //                   ),
            //                   ReuseTextField(
            //                     controller: newPasswordController,
            //                     hintText: "New password",
            //                     obscureText: newPassVisibility,
            //                     suffixIcon: InkWell(
            //                         onTap: () {
            //                           setState(() {
            //                             newPassVisibility = !newPassVisibility;
            //                           });
            //                         },
            //                         child: newPassVisibility
            //                             ? const Icon(Icons.visibility_off)
            //                             : const Icon(Icons.visibility)),
            //                   ),
            //                   const SizedBox(height: 10),
            //                   ReuseTextField(
            //                     controller: confirmPasswordController,
            //                     hintText: "Confirm password",
            //                     obscureText: confirmPassVisibility,
            //                     helperText: '',
            //                     suffixIcon: InkWell(
            //                         onTap: () {
            //                           setState(() {
            //                             confirmPassVisibility =
            //                                 !confirmPassVisibility;
            //                           });
            //                         },
            //                         child: confirmPassVisibility
            //                             ? const Icon(Icons.visibility_off)
            //                             : const Icon(Icons.visibility)),
            //                     validator: ((value) {
            //                       if (value != newPasswordController.text) {
            //                         return "Password not match";
            //                       }
            //                       return null;
            //                     }),
            //                   ),
            //                   Padding(
            //                     padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
            //                     child: ReuseButtonField()
            //                         .elavatedButton(context, 'Reset Password', () {
            //                       if (confirmPasswordController.text.isNotEmpty) {
            //                         setPasswordPost();
            //                         if (newPasswordController.text ==
            //                             confirmPasswordController.text) {
            //                         } else {
            //                           ReuseWidget().snackBarMessage(
            //                               context, 'Password does not match');
            //                         }
            //                       } else {
            //                         ReuseWidget().snackBarMessage(
            //                             context, 'Enter Password ');
            //                       }
            //                     }),
            //                   )
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            ),
      ),
    );
  }

  void callGraphqlAPI(input) async {
    String graphqlEndpoint = "https://api.walkzero.com/graphql";
    String token1 = 'hi';
    String token = token1;
    Dio dio = Dio();
    dio.options.headers = {
      'Authorization': 'Bearer ${token}',
      'Content-Type': 'application/json',
    };

    String query = '''
query {
 checkDomain(input:'${input}') {
 url,
 accountId
}
}
''';
    String email = newPasswordController.text;
    Map<String, dynamic> variables = {
      'input': {'new password': email}
    };

    try {
      Response response = await dio.post(graphqlEndpoint,
          data: {'query': query, 'variables': variables});

      if (response.statusCode == 200) {
        print("Response data: ${response.data}");
      } else {
        print("Error: ${response.statusCode} - ${response.data}");
      }
    } catch (e) {
      print("error:${e.toString()}");
    }
  }
}
