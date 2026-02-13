import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'my_home_page.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final FirebaseAuth auth = FirebaseAuth.instance;
                await auth.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                  (route) => false,
                );
              },

              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
