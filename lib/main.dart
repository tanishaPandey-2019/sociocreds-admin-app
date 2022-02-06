import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:http/http.dart' as http;

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.black),
  );
  runApp(MyApp());
}

Future<bool> pay(int amount, String userID) async {
  final url = "https://sociocredz.herokuapp.com/api/v1/shop/points/send";
  try {
    print("started");
    var response = await http.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      },
      body: jsonEncode({
        "userId": userID,
        "shopId": "3bac264b-962f-4913-843b-bfc2455e9004",
        "amount": amount,
      }),
    );
    print("finished");
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Something went wrong");
    }
  } catch (e) {
    throw Exception("Something went wrong");
  }
}

class MyDialog extends StatefulWidget {
  final String userID;

  MyDialog(this.userID);

  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      content: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "How many SocioCredz to transfer?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: 100,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
              ),
            ),
            SizedBox(height: 32),
            (!_isLoading)
                ? MaterialButton(
                    height: 50,
                    minWidth: double.maxFinite,
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        final res = await pay(
                          int.parse(_controller.value.text),
                          widget.userID,
                        );
                        setState(() {
                          _isLoading = false;
                        });
                        if (res) {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                              ),
                              content: Container(
                                margin: EdgeInsets.all(24),
                                child: Text(
                                  "Hooray! Its all done!",
                                ),
                              ),
                            ),
                          );
                        }
                      } catch (e) {}
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                    color: Color(0xFF000000),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Let's Go!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: double.maxFinite,
              child: Image.asset(
                "assets/images/landing.gif",
                fit: BoxFit.cover,
              ),
            ),
            Opacity(
              opacity: 0.3,
              child: Container(
                color: Colors.black,
              ),
            ),
            Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Container(
                      child: SvgPicture.asset("assets/images/logo.svg"),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.maxFinite,
                    margin: EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hey there!,\nReward your loyal clients.",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 56),
                        MaterialButton(
                          height: 55,
                          minWidth: double.maxFinite,
                          onPressed: () async {
                            var status = await Permission.camera.status;
                            if (status.isGranted) {
                              String userID = await scanner.scan();
                              if (userID != null) {
                                showDialog(
                                  context: context,
                                  builder: (context) => MyDialog(userID),
                                );
                              }
                            } else {
                              var res = await Permission.camera.request();
                              if (res.isGranted) {
                                String userID = await scanner.scan();
                                if (userID != null) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => MyDialog(userID),
                                  );
                                }
                              }
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35),
                          ),
                          color: Color(0xFFFC257E),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                "Tap to Pay",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      title: 'SocioCredz Admin',
      theme: ThemeData(fontFamily: 'Poppins'),
      debugShowCheckedModeBanner: false,
      home: MainApp(),
    );
  }
}
