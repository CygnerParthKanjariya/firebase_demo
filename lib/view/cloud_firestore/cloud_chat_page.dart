import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CloudChatPage extends StatefulWidget {
  final String name;
  final String email;
  final String senderId;
  final String receiverId;

  const CloudChatPage({
    super.key,
    required this.name,
    required this.email,
    required this.senderId,
    required this.receiverId,
  });

  @override
  State<CloudChatPage> createState() => _CloudChatPageState();
}

class _CloudChatPageState extends State<CloudChatPage> {
  String chatRoomId = "";
  CollectionReference chatCollection = FirebaseFirestore.instance.collection(
    'chat',
  );

  TextEditingController messageController = TextEditingController();

  final FocusNode _focusNode = FocusNode();
  bool isEditing = false;
  String? editMessageId;

  @override
  void initState() {
    super.initState();
    getChatId();
  }

  void chat() {
    chatCollection.doc(chatRoomId).collection("messages").add({
      "message": messageController.text,
      "senderId": widget.senderId,
      "time": DateTime.now(),
    });
  }

  Future<void> getChatId() async {
    final String id1 = '${widget.senderId}_${widget.receiverId}';
    final String id2 = '${widget.receiverId}_${widget.senderId}';

    final doc1 = await chatCollection.doc(id1).get();

    if (doc1.exists) {
      chatRoomId = id1;
    } else {
      final doc2 = await chatCollection.doc(id2).get();

      if (doc2.exists) {
        chatRoomId = id2;
      } else {
        await chatCollection.doc(id1).set({"chatId": id1});
        chatRoomId = id1;
      }
    }

    setState(() {});
  }

  Future<void> deleteMessage(String messageId) async {
    await chatCollection
        .doc(chatRoomId)
        .collection("messages")
        .doc(messageId)
        .delete();
  }

  Future<void> deleteAllChat() async {
    await chatCollection.doc(chatRoomId).collection("messages").get().then((
      snapshot,
    ) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  void showKeyboard() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void editMessage(String messageId) {
    chatCollection.doc(chatRoomId).collection("messages").doc(messageId).set({
      "message": messageController.text,
      "senderId": widget.senderId,
      "time": DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.email),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              deleteAllChat();
            },
            icon: Icon(Icons.delete),
            tooltip: "Delete Chat",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: chatRoomId.isNotEmpty
                  ? StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: chatCollection
                          .doc(chatRoomId)
                          .collection("messages")
                          .orderBy("time", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var data = snapshot.data;
                          return ListView.builder(
                            reverse: true,
                            itemCount: data?.docs.length,
                            itemBuilder: (context, index) {
                              var key = data!.docs[index].id;
                              final timestamp = data.docs[index].data()["time"];

                              String time = '';

                              if (timestamp != null) {
                                DateTime date = timestamp.toDate();
                                time = DateFormat('hh:mm a').format(date);
                              }

                              return Row(
                                mainAxisAlignment:
                                    data.docs[index].data()['senderId'] ==
                                        widget.senderId
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            .7,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            data.docs[index]
                                                    .data()['senderId'] ==
                                                widget.senderId
                                            ? Colors.blueGrey
                                            : Colors.black12,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  data.docs[index]
                                                      .data()["message"]
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                Text(
                                                  time,
                                                  style: TextStyle(fontSize: 8),
                                                ),
                                              ],
                                            ),
                                            data.docs[index]
                                                        .data()["senderId"] ==
                                                    widget.senderId
                                                ? PopupMenuButton(
                                                    itemBuilder: (context) {
                                                      return [
                                                        PopupMenuItem(
                                                          value: 0,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Icon(
                                                                Icons.delete,
                                                              ),
                                                              Text("Delete"),
                                                            ],
                                                          ),
                                                        ),
                                                        PopupMenuItem(
                                                          value: 1,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Icon(Icons.edit),

                                                              Text("Edit"),
                                                            ],
                                                          ),
                                                        ),
                                                      ];
                                                    },
                                                    onSelected: (value) {
                                                      if (value == 0) {
                                                        deleteMessage(key);
                                                      } else {
                                                        isEditing = true;
                                                        messageController
                                                            .text = data
                                                            .docs[index]
                                                            .data()["message"];
                                                        showKeyboard();
                                                        editMessageId = key;
                                                      }
                                                    },
                                                  )
                                                : SizedBox.shrink(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        return Center(child: CircularProgressIndicator());
                      },
                    )
                  : Center(child: CircularProgressIndicator()),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    controller: messageController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[300],
                      hintText: "Type message here",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (messageController.text.trim().isNotEmpty) {
                      if (isEditing && editMessageId != null) {
                        editMessage(editMessageId!);
                        isEditing = false;
                        editMessageId = null;
                      } else {
                        chat();
                      }

                      messageController.clear();
                    }
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
