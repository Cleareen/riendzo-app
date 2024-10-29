import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // Import video_player package

class VideoPlayerWidget extends StatefulWidget {
  final File videoFile;

  VideoPlayerWidget({Key? key, required this.videoFile}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Initialize the video player controller with the video file
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {}); // Ensure the first frame is shown after the video is initialized
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Column(
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio, // Maintain the video's aspect ratio
          child: VideoPlayer(_controller),
        ),
        VideoProgressIndicator(
          _controller,
          allowScrubbing: true,
          colors: VideoProgressColors(playedColor: Colors.blue),
        ),
        IconButton(
          icon: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            setState(() {
              // Toggle play/pause functionality
              _controller.value.isPlaying ? _controller.pause() : _controller.play();
            });
          },
        ),
      ],
    )
        : Center(child: CircularProgressIndicator()); // Show loading spinner while video is initializing
  }
}
