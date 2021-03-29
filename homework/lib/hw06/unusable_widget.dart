import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class UnusableVideoPlayer extends StatefulWidget {
  @override
  _UnusableVideoPlayerState createState() => _UnusableVideoPlayerState();
}

class _UnusableVideoPlayerState extends State<UnusableVideoPlayer> {
  bool _playable = false;
  bool _loading = false;

  final _controller = YoutubePlayerController(
    initialVideoId: 'djV11Xbc914',
    flags: YoutubePlayerFlags(
      autoPlay: false,
      mute: true,
    ),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _setYoutube() async {
    setState(() {
      _playable = true;
      _controller.play();
    });

    await Future.delayed(Duration(seconds: 4));

    setState(() {
      _playable = false;
      _controller.pause();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'The video needs to buffer. Please wait five seconds '
          'before playing again.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final player = YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.amber,
      progressColors: ProgressBarColors(
        playedColor: Colors.amber,
        handleColor: Colors.amberAccent,
      ),
    );

    final blackout = Positioned.fill(
      child: Container(
        color: Colors.black,
      ),
    );

    final fakePlaybutton = Positioned.fill(
      child: Center(
        child: IconButton(
          iconSize: 64,
          icon: Icon(Icons.play_arrow),
          color: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    final fakeLoading = Positioned.fill(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );

    final videoFrame = Stack(
      fit: StackFit.loose,
      children: [
        player,
        if (!_playable) blackout,
        if (!_playable && !_loading) fakePlaybutton,
        if (!_playable && _loading) fakeLoading,
      ],
    );

    final caption = RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'A music video which displays a cool song. The song itself '
                'is written by aha. This band is pretty popular. If you would '
                'like to play the video, then please click this ',
            style: theme.textTheme.subtitle1.copyWith(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(
            text: 'link ',
            style: theme.textTheme.subtitle1,
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                setState(() => _loading = true);
                await Future.delayed(Duration(seconds: 3));
                setState(() => _loading = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'The video is done loading. You can now '
                      'play the video.',
                    ),
                    action: SnackBarAction(
                      label: 'Okay',
                      onPressed: () => _setYoutube(),
                    ),
                  ),
                );
              },
          ),
          TextSpan(
            text: 'which will try to play the video.',
            style: theme.textTheme.subtitle1,
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        videoFrame,
        SizedBox(height: 16),
        caption,
      ],
    );
  }
}
