import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:podcasts_app/components/cards/light_episode_card.dart';
import 'package:podcasts_app/components/cards/podcast_card.dart';
import 'package:podcasts_app/models/podcasts/podcast.dart';
import 'package:podcasts_app/models/podcasts/podcast_episode.dart';
import 'package:podcasts_app/models/search_result.dart';
import 'package:podcasts_app/providers/network_data_provider.dart';
import 'package:podcasts_app/screens/home_tabs/podcast_pages/podcast_viewer.dart';
import 'package:podcasts_app/util/utils.dart';
import '../value_listanable_builder_2.dart';
import '../value_listanable_builder_3.dart';

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
  final ValueNotifier<bool> _showRelatedTab = ValueNotifier(false);
  final ValueNotifier<bool> _loading = ValueNotifier(false);
  final ValueNotifier<PlayerSpeed> _speed = ValueNotifier(PlayerSpeed.ONE);
  final ValueNotifier<Duration> _duration = ValueNotifier(Duration(milliseconds: 1));
  final ValueNotifier<Duration> _currentPosition = ValueNotifier(Duration(milliseconds: 0));
  final ValueNotifier<bool> _showFullDescription = ValueNotifier(false);

  late final ValueNotifier<List<PodcastEpisode>?> _playNext;
  late final ValueNotifier<PodcastEpisode> _selectedEpisode;
  AudioPlayer? _player;

  @override
  void initState() {
    _selectedEpisode = ValueNotifier(widget.podcastEpisode);
    _playNext = ValueNotifier(widget.playNext);
    _player = AudioPlayer();
    fetchEpisodeData();
    super.initState();
  }

  Future<void> fetchEpisodeData() async {
    _loading.value = true;
    final NetworkDataProvider data = NetworkDataProvider();
    await Future.wait([
      _createPlayer(),
      data.fetchEpisodeRecommendations(_selectedEpisode.value),
    ]);
    if (_selectedEpisode.value.related.isEmpty) await data.fetchPodcastRecommendations(_selectedEpisode.value.podcast);
    _loading.value = false;
  }

  Future<void> _createPlayer() async {
    _duration.value = (await _player!.setAudioSource(
      AudioSource.uri(
        Uri.parse(_selectedEpisode.value.audioUrl),
        tag: MediaItem(
          id: "podcasting_together",
          album: _selectedEpisode.value.podcast.title,
          title: _selectedEpisode.value.title,
          artUri: Uri.parse(_selectedEpisode.value.thumbnailUrl),
        ),
      ),
    ))!;
    _player!.positionStream.listen((time) {
      _currentPosition.value = time;
    });
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
                        Container(
                          height: hasPlayNext ? size.height * 0.25 : null,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: episode.thumbnailUrl,
                              placeholder: (context, url) => Container(
                                color: Colors.white,
                                child: Center(
                                  child: SizedProgressCircular(),
                                ),
                              ),
                              errorWidget: (context, url, error) => SizedBox(),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          episode.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32 - episode.title.length / 12,
                            color: Colors.black,
                            height: 1.1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ValueListenableBuilder<bool>(
                            valueListenable: _showFullDescription,
                            builder: (_, showFull, __) {
                              final int maxLength = 130;
                              final bool hasOverflow = episode.description.length > maxLength;
                              final String description =
                                  showFull ? episode.description : episode.description.substring(0, maxLength);
                              return InkWell(
                                onTap: () => _showFullDescription.value = !showFull,
                                child: RichText(
                                  maxLines: showFull ? null : 3,
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      text: hasOverflow && !showFull ? "$description..." : description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w300,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: hasOverflow
                                              ? showFull
                                                  ? " Show less"
                                                  : " Show more"
                                              : "",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ]),
                                ),
                              );
                            }),
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
                child: ValueListenableBuilder2<List<PodcastEpisode>?, bool>(
                  _playNext,
                  _showRelatedTab,
                  builder: (_, _playNext, showRelatedTab, __) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hasPlayNext)
                        InkWell(
                          onTap: () {
                            _showRelatedTab.value = false;
                          },
                          child: Text(
                            "Playing next",
                            style: TextStyle(
                              color: showRelatedTab ? Colors.white38 : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      InkWell(
                        onTap: () {
                          _showRelatedTab.value = true;
                        },
                        child: Text(
                          "Recommended",
                          style: TextStyle(
                            color: showRelatedTab || !hasPlayNext ? Colors.white : Colors.white38,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _loading,
              builder: (_, loading, __) => loading
                  ? Container(
                      padding: const EdgeInsets.all(10),
                      child: SizedProgressCircular(color: Colors.white,),
                    )
                  : Transform(
                      transform: Matrix4.translationValues(
                        0,
                        -20,
                        0,
                      ),
                      child: ValueListenableBuilder3<List<PodcastEpisode>?, PodcastEpisode, bool>(
                        _playNext,
                        _selectedEpisode,
                        _showRelatedTab,
                        builder: (_, playNext, selected, showRelatedTab, __) {
                          final Set<SearchResult> results = {};
                          final displayRelated = showRelatedTab || !hasPlayNext;

                          displayRelated
                              ? selected.related.isEmpty
                                  ? results.addAll(selected.podcast.related)
                                  : results.addAll(selected.related)
                              : results.addAll(playNext ?? []);

                          return Container(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: results.length,
                              itemBuilder: (_, index) {
                                final result = results.elementAt(index);
                                final isPodcast = result is Podcast;
                                return InkWell(
                                  onTap: () {
                                    if (isPodcast) {
                                      showCupertinoModalBottomSheet(
                                        barrierColor: Colors.black,
                                        topRadius: Radius.circular(20),
                                        context: context,
                                        builder: (_) => PodcastViewerPage(result as Podcast),
                                      );
                                    } else {
                                      _selectedEpisode.value = result as PodcastEpisode;
                                      fetchEpisodeData();

                                      if (showRelatedTab) {
                                        _playNext.value = null;
                                      } else {
                                        playNext != null && playNext.last != result
                                            ? _playNext.value!.removeRange(0, index + 1)
                                            : _playNext.value = null;
                                        _scrollController.animateTo(
                                          0,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.decelerate,
                                        );
                                      }
                                    }
                                  },
                                  child: isPodcast
                                      ? PodcastCard(result as Podcast, isDark: true)
                                      : LightEpisodeCard(result as PodcastEpisode),
                                );
                              },
                            ),
                          );
                        },
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

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  Future<void> _disposePlayer() async {
    if (_player != null) {
      if (_player!.playing) {
        await _player!.stop();
      }
      await _player?.dispose();
    }
  }

  bool get hasPlayNext => _playNext.value != null && _playNext.value!.isNotEmpty;
}

class AudioStream {
  final double position;
  final PlayerState state;

  AudioStream(this.position, this.state);
}
