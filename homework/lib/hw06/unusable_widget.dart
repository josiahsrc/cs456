import 'package:flutter/material.dart';

class PausePlayButton extends StatefulWidget {
  final VoidCallback onPressed;

  const PausePlayButton({
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  _PausePlayButtonState createState() => _PausePlayButtonState();
}

class _PausePlayButtonState extends State<PausePlayButton>
    with SingleTickerProviderStateMixin {
  bool playing = false;
  AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        progress: controller,
        icon: AnimatedIcons.pause_play,
      ),
      onPressed: () {
        setState(() {
          playing = !playing;
          playing ? controller.forward() : controller.reverse();
        });
        widget?.onPressed?.call();
      },
    );
  }
}

/// Ideas:
/// - A play button that repels away from your finger like a magnet.
/// You have to use two  fingers. One to move it, the other to press
/// it.
/// - When you press on the play button, a radial menu appears with
/// 10 items. Each one is not related to the play button.
/// - Put the play button below the video. Or way apart from the
/// video.
/// - You need to repel the play button into the view so you can use
/// it. There's only one play button. You have to move it in between
/// video frames to use it for each video frame.
class UnusablePlayButton extends StatefulWidget {
  @override
  _UnusablePlayButtonState createState() => _UnusablePlayButtonState();
}

class _UnusablePlayButtonState extends State<UnusablePlayButton> {
  @override
  Widget build(BuildContext context) {
    final button = PausePlayButton();

    return button;

    // return Stack(
    //   children: [],
    // );
  }
}
