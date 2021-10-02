import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pusher_client/pusher_client.dart';
// import 'package:pusher_websocket_flutter/pusher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey key = GlobalKey();
  late Channel channel;
  late PusherClient pusher;
  StreamController _streamController = StreamController();
  bool connected = false;

  void connect() async {
    setState(() => connected = true);
    await pusher.connect();
    channel = pusher.subscribe("channel");
    channel.bind("event", (PusherEvent? event) {
      _streamController.sink.add(event!.data!);
      ScaffoldMessenger.of(key.currentContext!).showSnackBar(SnackBar(content: Text(event.data!)));
    });
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  void disconnect() {
    setState(() => connected = false);
    pusher.disconnect();
  }

  // void sendMessage() => channel.trigger('event', 'data');

  void init() {
    pusher = PusherClient(
        // TODO: AppKey from Pusher
        '',
        // TODO: Cluster from Pusher
        PusherOptions(cluster: 'eu'),
        autoConnect: false);
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: key,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) return Text(snapshot.data.toString());
                  return SizedBox();
                },
              ),
              connected
                  ? ElevatedButton(
                      onPressed: disconnect,
                      child: Text('Disconnect!'),
                    )
                  : ElevatedButton(
                      onPressed: connect,
                      child: Text('Connect!'),
                    ),
              // ElevatedButton(onPressed: sendMessage, child: Text('Send!')),
            ],
          ),
        ),
      ),
    );
  }
}

// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     Pusher.init('a34d16a300ef31e103b8', PusherOptions(cluster: 'eu'));
//     Pusher.connect(
//       onConnectionStateChange: (v) {
//         print(v.currentState);
//       },
//     );
//
//     Pusher.subscribe('channel').then((value) {
//       value.bind('event', (v) {
//         print(v.data);
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Text('Home'),
//     );
//   }
// }
//
