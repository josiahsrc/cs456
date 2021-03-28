import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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

class UnusableVideoPlayer extends StatefulWidget {
  @override
  _UnusableVideoPlayerState createState() => _UnusableVideoPlayerState();
}

class _UnusableVideoPlayerState extends State<UnusableVideoPlayer> {
  final _controller = YoutubePlayerController(
    initialVideoId: 'djV11Xbc914',
    flags: YoutubePlayerFlags(
      autoPlay: false,
      mute: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final player = YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.amber,
      progressColors: ProgressBarColors(
        playedColor: Colors.amber,
        handleColor: Colors.amberAccent,
      ),
    );

    final layout = LayoutBuilder(
      builder: _buildLayout,
    );

    return Stack(
      children: [
        player,
        layout,
      ],
    );
  }

  Widget _buildLayout(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    return Container();
  }
}
