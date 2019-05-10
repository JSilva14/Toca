import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:toca/ui/widgets/google_sign_in_button.dart';
import 'package:toca/state_widget.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loadingData = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/Bagend.JPG'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 0, 90, 70),
          title: Text(
            'A TOCA',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.only(
            top: 0,
            left: 30,
            right: 30,
          ),
          child: Container(
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: ButtonTheme(
                        minWidth: 150,
                        child: loadingData
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : GoogleSignInButton(onPressed: () {
                                StateWidget.of(context).signInWithGoogle();
                                setState(() {
                                  loadingData = true;
                                });
                              }),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
