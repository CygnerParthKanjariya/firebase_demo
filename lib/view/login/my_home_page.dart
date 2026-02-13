import 'package:demo/view/otp_page.dart';
import 'package:demo/view/success_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final FirebaseAuth auth = FirebaseAuth.instance;
      if (auth.currentUser?.uid != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SuccessPage()),
          (route) => false,
        );
      }
    });
    super.initState();
  }

  TextEditingController phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Page")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            spacing: 15,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  hintText: "Enter your Mobile Number",
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.verifyPhoneNumber(
                    verificationCompleted: (PhoneAuthCredential credential) {},
                    verificationFailed: (FirebaseAuthException ex) {},
                    codeSent: (String verificationID, int? reEnterToken) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  OtpPage(verificationId: verificationID),
                        ),
                      );
                    },
                    codeAutoRetrievalTimeout: (String verificationID) {},
                    phoneNumber: phoneController.text.toString(),
                  );
                },
                child: Text("Verify Your Number"),
              ),

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
                      MaterialPageRoute(builder: (context) => SuccessPage()),(route) => false,
                    );
                  }
                },
                child: Text("Login With Google"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
