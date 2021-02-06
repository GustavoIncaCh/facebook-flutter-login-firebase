import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

class LoginWithFacebook extends StatefulWidget {
  @override
  _LoginWithFacebookState createState() => _LoginWithFacebookState();
}

class _LoginWithFacebookState extends State<LoginWithFacebook> {
  bool isSignIn = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  User _user;
  FacebookLogin facebookLogin = FacebookLogin();
  Map userData;
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('data');
  CollectionReference pacientes =
      FirebaseFirestore.instance.collection('Pacientes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("facebook login"),
      ),
      body: isSignIn
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.network(
                    userData["picture"]["data"]["url"],
                    height: 50.0,
                    width: 50.0,
                  ),
                  Text(
                    _user.displayName,
                    style: TextStyle(fontSize: 30),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  OutlineButton(
                    onPressed: () {
                      gooleSignout();
                    },
                    child: Text(
                      "Logout",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ],
              ),
            )
          : Center(
              child: OutlineButton(
                onPressed: () async {
                  await handleLogin();
                },
                child: Text(
                  "Login with facebook",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
    );
  }

  Future<void> handleLogin() async {
    final FacebookLoginResult result =
        await facebookLogin.logInWithReadPermissions(['email']);
    switch (result.status) {
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        break;
      case FacebookLoginStatus.loggedIn:
        try {
          await loginWithfacebook(result);
        } catch (e) {
          print(e);
        }
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');
        final profile = JSON.jsonDecode(graphResponse.body);
        Map<String, dynamic> dataPacientes = {
          "id": userData["id"],
          "name": userData["name"],
          "email": userData["email"]
        };
        pacientes.add(dataPacientes);
        collectionReference.add(userData);
        print(profile);
        userData = profile;
        //AddUser();
        //collectionReference.add(userData);
        break;
    }
  }

  Future loginWithfacebook(FacebookLoginResult result) async {
    final FacebookAccessToken accessToken = result.accessToken;
    AuthCredential credential =
        FacebookAuthProvider.credential(accessToken.token);
    var a = await _auth.signInWithCredential(credential);
    setState(() {
      isSignIn = true;
      _user = a.user;
    });
  }

  Future<void> gooleSignout() async {
    await _auth.signOut().then((onValue) {
      setState(() {
        facebookLogin.logOut();
        isSignIn = false;
      });
    });
  }
}
