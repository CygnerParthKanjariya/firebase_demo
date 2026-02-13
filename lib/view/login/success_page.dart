import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'my_home_page.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  final DatabaseReference dbref = FirebaseDatabase.instance.ref();
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  Future<void> addUser() async {
    await dbref.child('users').push().set({
      "name": nameController.text,
      "age": ageController.text,
      "city": cityController.text,
    });
  }

  Future<void> updateUser(String id) async {
    await dbref.child('users').child(id).update({
      "name": nameController.text,
      "age": ageController.text,
      "city": cityController.text,
    });
  }

  Future<void> userDelete(String id) async {
    await dbref.child('users').child(id).remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
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
      body: FutureBuilder(
        future: dbref.child('users').get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var dataSnapshot = snapshot.data;
            if (dataSnapshot!.value != null) {
              // Convert snapshot to a Map
              Map<dynamic, dynamic> dataMap =
                  dataSnapshot.value as Map<dynamic, dynamic>;
              // Convert Map to a list of entries for ListView
              var dataList = dataMap.entries.toList();

              return ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(dataList[index].value['name'] ?? 'No Name'),
                    subtitle: Text(dataList[index].value['city'] ?? 'No City'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            nameController.text = dataList[index].value['name'];
                            ageController.text = dataList[index].value['age'];
                            cityController.text = dataList[index].value['city'];
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    spacing: 15,
                                    children: [
                                      TextField(
                                        controller: nameController,
                                        decoration: InputDecoration(
                                          hintText: "Enter Your Name",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextField(
                                        keyboardType: TextInputType.number,
                                        controller: ageController,
                                        decoration: InputDecoration(
                                          hintText: "Enter Your Age",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextField(
                                        controller: cityController,
                                        decoration: InputDecoration(
                                          hintText: "Enter Your City",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (nameController.text.isNotEmpty &&
                                              ageController.text.isNotEmpty &&
                                              cityController.text.isNotEmpty) {
                                            updateUser(dataList[index].key);
                                            // addUser();
                                            Navigator.pop(context);
                                            setState(() {});
                                          }
                                        },
                                        child: Text("Update"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            userDelete(dataList[index].key);
                            setState(() {});
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text('No Data Found'));
            }
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          nameController.clear();
          ageController.clear();
          cityController.clear();
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  spacing: 15,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Enter Your Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: ageController,
                      decoration: InputDecoration(
                        hintText: "Enter Your Age",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    TextField(
                      controller: cityController,
                      decoration: InputDecoration(
                        hintText: "Enter Your City",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            ageController.text.isNotEmpty &&
                            cityController.text.isNotEmpty) {
                          addUser();
                          Navigator.pop(context);
                          setState(() {});
                        }
                      },
                      child: Text("Save"),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
