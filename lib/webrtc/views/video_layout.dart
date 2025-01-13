import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoLayout extends StatelessWidget {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;

  VideoLayout({required this.localRenderer, required this.remoteRenderer});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          // Remote video stream fills the entire screen
          Positioned.fill(
            child: RTCVideoView(
              remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
          // Local video stream is in the top-left corner
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: RTCVideoView(
                localRenderer,
                mirror: true,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
