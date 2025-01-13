import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mithc_koko_chat_app/webrtc/views/room_id.dart';
import '../services/signalling.dart';
import 'room_controls.dart';
import 'video_layout.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  TextEditingController textEditingController = TextEditingController(text: '');
  String? roomId;

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = (stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    };
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter WebRTC - Video Call"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          RoomControls(
            onOpenCamera: () => signaling.openUserMedia(_localRenderer, _remoteRenderer),
            onCreateRoom: () async {
              roomId = await signaling.createRoom(_remoteRenderer);
              textEditingController.text = roomId!;
              setState(() {});
            },
            onJoinRoom: () => signaling.joinRoom(textEditingController.text.trim(), _remoteRenderer),
            onHangUp: () => signaling.hangUp(_localRenderer),
          ),
          VideoLayout(localRenderer: _localRenderer, remoteRenderer: _remoteRenderer),
          RoomIdInput(controller: textEditingController),
        ],
      ),
    );
  }
}
