import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/view/cloud_firestore/cloud_chat_page.dart';
import 'package:demo/view/login/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CloudHomePage extends StatefulWidget {
  const CloudHomePage({super.key});

  @override
  State<CloudHomePage> createState() => _CloudHomePageState();
}

class _CloudHomePageState extends State<CloudHomePage> {

  var cUser = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    addUser();
  }

  void addUser() {
    users.doc(cUser?.uid).set({
      'userId': cUser?.uid,
      'userEmail': cUser?.email,
      'userName': cUser?.displayName,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        centerTitle: true,
        actions: [
          ElevatedButton(
            onPressed: () async {
              FirebaseAuth auth = FirebaseAuth.instance;
              await auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
            child: Text("Logout"),
          ),
        ],
      ),
      body: FutureBuilder(
        future: users.where('userId', isNotEqualTo: cUser?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data;
            if (data != null) {
              return ListView.builder(
                itemCount: data.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CloudChatPage(
                            name: data.docs[index]["userName"],
                            email: data.docs[index]["userEmail"],
                            senderId: cUser!.uid,
                            receiverId: data.docs[index]['userId'],
                          ),
                        ),
                      );
                    },
                    title: Text(data.docs[index]['userName']),
                    subtitle: Text(data.docs[index]['userEmail']),
                  );
                },
              );
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
