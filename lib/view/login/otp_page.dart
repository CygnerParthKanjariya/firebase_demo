import 'dart:math';

import 'package:demo/view/success_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OtpPage extends StatefulWidget {
  String verificationId;

  OtpPage({super.key, required this.verificationId});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OTP Page")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                controller: otpController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  hintText: "Enter OTP",
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try{
                    PhoneAuthCredential credential = await PhoneAuthProvider.credential(
                      verificationId: widget.verificationId,
                      smsCode: otpController.text.toString(),
                    );
                    FirebaseAuth.instance.signInWithCredential(credential).then((value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SuccessPage())
                      );
                    });
                  }
                      catch(ex){
                    log(ex as num);
                      }
                },
                child: Text("Verify OTP"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
