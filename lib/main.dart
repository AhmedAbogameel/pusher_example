import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pusher_client/pusher_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late PusherClient pusher;
  late Channel channel;

  String AUTH_URL = 'https://afaqalsyola.online/api/broadcasting/auth';
  String BEARER_TOKEN = '9|jNL6MpxPXU8uTNiMftgEPK15Lmltiu5Ru2W6TtUh"';

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    pusher = new PusherClient(
        "local",
        PusherOptions(
          // cluster: 'eu'
          wssPort: 6001,
          wsPort: 6001,
          host: 'afaqalsyola.online',
          encrypted: false,
          // auth: PusherAuth(
          //   'https://afaqalsyola.online/api/broadcasting/auth',
          //   headers: {
          //     'Authorization': 'Bearer $BEARER_TOKEN',
          //     'Content-Type': 'application/json',
          //     'Accept': 'application/json'
          //   },
          // ),
        ),
        enableLogging: true,
        autoConnect: false
    );
    await pusher.connect();

    channel = pusher.subscribe("public-channel");

    pusher.onConnectionStateChange((state) {
      log("previousState: ${state!.previousState}, currentState: ${state.currentState}");
    });

    pusher.onConnectionError((error) {
      log("error: ${error!.message}");
    });

    channel.bind('PublicEvent', (event) {
      log("Order Filled Event" + event!.data.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Example Pusher App'),
        ),
        body: Center(
            child: Column(
              children: [
                ElevatedButton(
                  child: Text('Unsubscribe Presence'),
                  onPressed: () {
                    pusher.unsubscribe("presence-presence-channel.2");
                    pusher.disconnect();
                  },
                ),
                ElevatedButton(
                  child: Text('Unbind Status Update'),
                  onPressed: () {
                    channel.unbind('status-update');
                  },
                ),
                ElevatedButton(
                  child: Text('Unbind Order Filled'),
                  onPressed: () {
                    channel.unbind('order-filled');
                  },
                ),
                ElevatedButton(
                  child: Text('Bind Status Update'),
                  onPressed: () {
                    channel.bind('status-update', (PusherEvent? event) {
                      log("Status Update Event" + event!.data.toString());
                    });
                  },
                ),
                ElevatedButton(
                  child: Text('Trigger Client Typing'),
                  onPressed: () {
                    // channel.trigger('client-istyping', {'name': 'Bob'});
                    final id = pusher.getSocketId();
                    print(id);
                  },
                ),
              ],
            )),
      ),
    );
  }
}