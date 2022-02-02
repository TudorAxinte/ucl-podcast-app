import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcasts_app/components/cards/light_episode_card.dart';
import 'package:podcasts_app/models/podcast.dart';
import 'package:podcasts_app/util/utils.dart';
import '../value_listanable_builder_2.dart';

enum PlayerSpeed {
  ONE,
  ONE_FIVE,
  TWO,
}

class PodcastPlayer extends StatefulWidget {
  final PodcastEpisode podcastEpisode;
  final List<PodcastEpisode>? playNext;

  const PodcastPlayer(this.podcastEpisode, {this.playNext});

  @override
  PodcastPlayerState createState() => PodcastPlayerState();
}

class PodcastPlayerState extends State<PodcastPlayer> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _loading = ValueNotifier(false);
  final ValueNotifier<PlayerSpeed> _speed = ValueNotifier(PlayerSpeed.ONE);
  final ValueNotifier<Duration> _duration = ValueNotifier(Duration(milliseconds: 1));
  final ValueNotifier<Duration> _currentPosition = ValueNotifier(Duration(milliseconds: 0));

  late final ValueNotifier<PodcastEpisode> _selectedEpisode;
  AudioPlayer? _player;

  @override
  void initState() {
    _selectedEpisode = ValueNotifier(widget.podcastEpisode);
    _player = AudioPlayer();
    _createPlayer();
    super.initState();
  }

  void _createPlayer() async {
    _loading.value = true;
    _duration.value = (await _player!.setUrl(_selectedEpisode.value.audioUrl))!;
    _player!.positionStream.listen((time) {
      _currentPosition.value = time;
    });
    _loading.value = false;
  }

  void play() async {
    await _player!.play();
  }

  void pause() async {
    await _player!.pause();
  }

  void seek(int value) async {
    await _player!.seek(Duration(milliseconds: value));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          InkResponse(
            child: Icon(
              Icons.clear,
              size: 20,
              color: Colors.black,
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          SizedBox(width: 20),
        ],
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            ValueListenableBuilder<PodcastEpisode>(
                valueListenable: _selectedEpisode,
                builder: (context, episode, child) {
                  return Container(
                    height: hasPlayNext ? null : size.height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: hasPlayNext ? size.height * 0.08 : size.height * 0.13,
                      horizontal: 30,
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: episode.podcast.thumbnailUrl,
                            placeholder: (context, url) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.white,
                              child: Center(child: SizedProgressCircular()),
                            ),
                            errorWidget: (context, url, error) => SizedBox(),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          episode.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          episode.description,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: 30),
                        ValueListenableBuilder2<Duration, bool>(
                          _currentPosition,
                          _loading,
                          builder: (context, time, loading, child) {
                            final value = time;
                            if (value.inMilliseconds >= _duration.value.inMilliseconds) {
                              pause();
                            }
                            return Visibility(
                              visible: !loading,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 35,
                                      child: Slider(
                                        value: value.inMilliseconds > _duration.value.inMilliseconds
                                            ? 0.0
                                            : value.inMilliseconds.toDouble(),
                                        onChanged: (time) => seek(time.toInt()),
                                        min: 0.0,
                                        max: _duration.value.inMilliseconds.toDouble(),
                                        activeColor: Theme.of(context).primaryColor,
                                        inactiveColor: Colors.grey[300],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 22),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(bottom: 10),
                                            child: Text(
                                              _currentPositionString(value),
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(bottom: 10),
                                            child: Text(
                                              "-${_playbackPositionString(value)}",
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ValueListenableBuilder<bool>(
                                valueListenable: _loading,
                                builder: (context, loading, child) {
                                  return InkResponse(
                                    child: Icon(
                                      Icons.replay_30,
                                      color: loading ? Colors.grey[800] : Colors.black87,
                                      size: 60,
                                    ),
                                    onTap: loading
                                        ? null
                                        : () {
                                            final current = _currentPosition.value.inMilliseconds;
                                            final calculation = _currentPosition.value.inMilliseconds - 30000;
                                            current > calculation
                                                ? calculation <= 0
                                                    ? seek(0)
                                                    : seek(current - 30000)
                                                : seek(0);
                                          },
                                  );
                                },
                              ),
                              SizedBox(width: 20),
                              ValueListenableBuilder<bool>(
                                valueListenable: _loading,
                                builder: (context, loading, child) {
                                  return StreamBuilder<PlayerState>(
                                    stream: _player!.playerStateStream,
                                    builder: (context, snapshot) {
                                      final playing = snapshot.hasData && snapshot.data!.playing;
                                      return InkResponse(
                                        child: ClipOval(
                                          child: Container(
                                            height: 50,
                                            width: 50,
                                            color: Colors.black,
                                            child: loading
                                                ? Padding(
                                                    padding: const EdgeInsets.all(15),
                                                    child: SizedProgressCircular(
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : Icon(
                                                    playing ? Icons.pause : Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 40,
                                                  ),
                                          ),
                                        ),
                                        onTap: loading
                                            ? null
                                            : () async {
                                                playing ? pause() : play();
                                              },
                                      );
                                    },
                                  );
                                },
                              ),
                              SizedBox(width: 20),
                              ValueListenableBuilder2<PlayerSpeed, bool>(
                                _speed,
                                _loading,
                                builder: (context, speed, loading, child) {
                                  return InkResponse(
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Theme.of(context).primaryColor,
                                      child: _speedText(speed),
                                    ),
                                    onTap: loading
                                        ? null
                                        : () {
                                            _speedToggle(speed);
                                          },
                                  );
                                },
                              ),
                              SizedBox(width: 20),
                              ValueListenableBuilder<bool>(
                                valueListenable: _loading,
                                builder: (context, loading, child) {
                                  return InkResponse(
                                    child: Icon(
                                      Icons.forward_30,
                                      color: loading ? Colors.grey[800] : Colors.black87,
                                      size: 60,
                                    ),
                                    onTap: loading
                                        ? null
                                        : () {
                                            final current = _currentPosition.value.inMilliseconds;
                                            current < _duration.value.inMilliseconds - 30000
                                                ? seek(current + 30000)
                                                : seek(_duration.value.inMilliseconds);
                                          },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            if (hasPlayNext)
              Transform(
                transform: Matrix4.translationValues(
                  0,
                  -20,
                  0,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Playing next",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (hasPlayNext)
              Transform(
                transform: Matrix4.translationValues(
                  0,
                  -20,
                  0,
                ),
                child: Container(
                  child: ValueListenableBuilder<PodcastEpisode>(
                    valueListenable: _selectedEpisode,
                    builder: (context, episode, child) => ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: widget.playNext!.length,
                      itemBuilder: (_, index) {
                        final episode = widget.playNext![index];
                        return InkWell(
                          onTap: () {
                            _createPlayer();
                            _selectedEpisode.value = episode;
                            widget.playNext!.removeRange(0, index + 1);
                            _scrollController.animateTo(
                              0,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.decelerate,
                            );
                          },
                          child: LightEpisodeCard(episode),
                        );
                      },
                    ),
                  ),
                ),
              ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  String _currentPositionString(Duration currentPosition) {
    return currentPosition.toString().split('.').first;
  }

  String _playbackPositionString(Duration currentPosition) {
    var remainingTime = Duration(seconds: _duration.value.inSeconds - currentPosition.inSeconds);
    return remainingTime.toString().split('.').first;
  }

  Widget _speedText(PlayerSpeed speed) {
    switch (speed) {
      case PlayerSpeed.ONE:
        return Text("1x");
      case PlayerSpeed.ONE_FIVE:
        return Text("1.5x");
      case PlayerSpeed.TWO:
        return Text("2x");
    }
  }

  void _speedToggle(PlayerSpeed speed) async {
    switch (speed) {
      case PlayerSpeed.ONE:
        await _player!.setSpeed(1.5);
        _speed.value = PlayerSpeed.ONE_FIVE;
        break;
      case PlayerSpeed.ONE_FIVE:
        await _player!.setSpeed(2.0);
        _speed.value = PlayerSpeed.TWO;
        break;
      case PlayerSpeed.TWO:
        await _player!.setSpeed(1.0);
        _speed.value = PlayerSpeed.ONE;
        break;
    }
  }

  bool get hasPlayNext => widget.playNext != null && widget.playNext!.isNotEmpty;
}

class AudioStream {
  final double position;
  final PlayerState state;

  AudioStream(this.position, this.state);
}
