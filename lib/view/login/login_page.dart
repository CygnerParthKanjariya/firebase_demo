import 'package:demo/view/cloud_firestore/cloud_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final FirebaseAuth auth = FirebaseAuth.instance;
      if (auth.currentUser?.uid != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => CloudHomePage()),
          (route) => false,
        );
      }
      FirebaseRemoteConfig.instance.onConfigUpdated.listen((event) async {
        await FirebaseRemoteConfig.instance.fetchAndActivate();
        setState(() {});
      });
    });
    super.initState();
  }

  // TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FirebaseRemoteConfig.instance.getString("msg")),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            spacing: 15,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TextField(
              //   controller: phoneController,
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(24),
              //     ),
              //     hintText: "Enter your Mobile Number",
              //   ),
              // ),
              // ElevatedButton(
              //   onPressed: () async {
              //     await FirebaseAuth.instance.verifyPhoneNumber(
              //       verificationCompleted: (PhoneAuthCredential credential) {},
              //       verificationFailed: (FirebaseAuthException ex) {},
              //       codeSent: (String verificationID, int? reEnterToken) {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) =>
              //                 OtpPage(verificationId: verificationID),
              //           ),
              //         );
              //       },
              //       codeAutoRetrievalTimeout: (String verificationID) {},
              //       phoneNumber: phoneController.text.toString(),
              //     );
              //   },
              //   child: Text("Verify Your Number"),
              // ),
              ElevatedButton(
                onPressed: () async {
                  final FirebaseAuth auth = FirebaseAuth.instance;

                  final GoogleSignIn signIn = GoogleSignIn.instance;
                  await signIn.initialize();
                  GoogleSignInAccount googleUser = await signIn.authenticate();
                  final GoogleSignInAuthentication googleAuth =
                      googleUser.authentication;
                  final credential = GoogleAuthProvider.credential(
                    idToken: googleAuth.idToken,
                  );

                  await FirebaseAuth.instance.signInWithCredential(credential);
                  if (auth.currentUser?.uid != null) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => CloudHomePage()),
                      (route) => false,
                    );
                  }
                },
                child: Text(FirebaseRemoteConfig.instance.getString("btnText")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
