import 'package:flutter/material.dart';

class RoomControls extends StatelessWidget {
  final VoidCallback onOpenCamera;
  final Future<void> Function() onCreateRoom;
  final VoidCallback onJoinRoom;
  final VoidCallback onHangUp;

  RoomControls({
    required this.onOpenCamera,
    required this.onCreateRoom,
    required this.onJoinRoom,
    required this.onHangUp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: onOpenCamera,
            child: Text("Open Camera & Microphone"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: onCreateRoom,
            child: Text("Create Room"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: onJoinRoom,
            child: Text("Join Room"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: onHangUp,
            child: Text("Hang Up"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
