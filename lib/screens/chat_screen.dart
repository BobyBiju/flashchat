


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore=FirebaseFirestore.instance;
User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const id='chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
final messageTextController=TextEditingController();
  final _auth=FirebaseAuth.instance;


  String messageText;


  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async{
    try{
      final user = await _auth.currentUser;
      if(user!=null){
        loggedInUser=user;
        print(loggedInUser.email);
      }
    }
    catch(e){
      print(e);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {

                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
           MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      //Implement send functionality.
                      _fireStore.collection('messages').add({'text':messageText,'sender':loggedInUser.email});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MessagesStream extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
        stream: _fireStore.collection('messages').snapshots(),
        builder: (context,snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          final messages =snapshot.data.docs.reversed;

          List<MessageBubble> messageBubbles=[];
          for(var message in messages){
            final messageText=message.data() as Map<String,dynamic>;
            final messageSender=message.data() as Map<String,dynamic>;

            final currentUser=loggedInUser.email;


            final messageBubble=MessageBubble(sender: messageSender["sender"],text:messageText["text"],
              isMe: currentUser==messageSender["sender"]?true:false,
            );
            messageBubbles.add(messageBubble);


          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
              children: messageBubbles,
            ),
          );
        }

    );
  }
}

class MessageBubble extends StatelessWidget {

  MessageBubble({this.sender,this.text,this.isMe});

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          Text('$sender',
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.black54,
          ),),
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.only(topLeft: isMe?Radius.circular(30.0):Radius.circular(0.0),bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0),topRight: isMe?Radius.circular(0.0):Radius.circular(30.0)),
            color: isMe?Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 20.0),
              child: Text('$text',
                style: TextStyle(
                    fontSize: 15.0,
                  color: isMe?Colors.white:Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// '${messageText["text"]} from ${messageSender["sender"]}'
