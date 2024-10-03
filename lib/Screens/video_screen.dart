import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:watchpool/Components/colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:watchpool/Models/channel_model.dart';
import 'package:watchpool/Models/video_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:watchpool/Services/api_services.dart';

class VideoScreen extends StatefulWidget {
  final String? id;
  final Channel? channel;
  const VideoScreen({super.key, this.id, this.channel});

  @override
  VideoScreenState createState() => VideoScreenState();
}

class VideoScreenState extends State<VideoScreen> {
  YoutubePlayerController? _controller;
  Timer? _timer;
  bool _isPreviewShown = false;
  bool _isLoading = false;
  List<Video> _randomizedVideos = [];

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.id!,
      flags: const YoutubePlayerFlags(
        forceHD: true,
        controlsVisibleAtStart: true,
        enableCaption: false,
        mute: false,
        autoPlay: true,
      ),
    );

    _randomizedVideos = List.from(widget.channel!.videos!)..shuffle();
    _randomizedVideos.removeWhere((video) => video.id == widget.id);

    // Start the timer to check video position
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkPosition();
    });
  }

  void playNextVideo() {
    if (_randomizedVideos.isNotEmpty) {
      setState(() {
        Video nextVideo = _randomizedVideos.removeAt(0);
        _controller?.load(nextVideo.id);
        _controller?.play();
      });
    }
  }

  _loadMoreVideos() async {
    _isLoading = true;
    List<Video> moreVideos = await APIService.instance
        .fetchVideosFromPlaylist(playlistId: widget.channel!.uploadPlaylistId);
    List<Video> allVideos = widget.channel!.videos!..addAll(moreVideos);
    setState(() {
      widget.channel!.videos = allVideos;
    });
    _isLoading = false;
  }

  void _checkPosition() {
    if (_controller != null && _controller!.value.isPlaying) {
      final int totalSeconds = _controller!.metadata.duration.inSeconds;
      final int currentSeconds = _controller!.value.position.inSeconds;

      if (totalSeconds - currentSeconds <= 30 && !_isPreviewShown) {
        setState(() {
          _isPreviewShown = true;
        });
        _buildNextVideoPreview();
      }
    }
  }

  Widget _buildNextVideoPreview() {
    if (_randomizedVideos.isEmpty) return const SizedBox.shrink();

    final random = Random();
    final int randomIndex = random.nextInt(_randomizedVideos.length);
    Video nextVideo = _randomizedVideos[randomIndex];

    return Positioned(
      top: 28,
      left: 6,
      child: GestureDetector(
        onTap: () {
          _controller?.load(nextVideo.id);
          _controller?.play();
          setState(() {
            _randomizedVideos.removeAt(randomIndex);
            _isPreviewShown = false;
          });
        },
        child: Container(
          width: 140,
          height: 80,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(nextVideo.thumbnailUrl),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 1),
            blurRadius: 6.0,
          ),
        ],
        color: Colors.white,
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 15.0,
            backgroundImage: NetworkImage(widget.channel!.profilePictureUrl),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.channel!.title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.channel!.subscriberCount} subscribers',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  String _formatViewCount(String viewCount) {
    int count = int.parse(viewCount);
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  Widget _buildVideo(Video video) {
    if (video.id == widget.id) {
      return Container(); // Skip the current video
    }
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VideoScreen(id: video.id, channel: widget.channel),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                video.thumbnailUrl,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(video.channelProfilePictureUrl),
                  radius: 25,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      FittedBox(
                        child: Row(
                          children: [
                            Text(
                              video.channelTitle,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Text(' • '),
                            Text(
                              '${_formatViewCount(video.viewCount)} views',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Text(' • '),
                            Text(
                              timeago.format(video.publishedAt),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
            child: Stack(
          children: [
            Column(
              children: [
                YoutubePlayer(
                  onEnded: (metaData) {
                    playNextVideo();
                  },
                  topActions: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: secondaryColor,
                        size: 22,
                      ),
                    )
                  ],
                  progressColors: ProgressBarColors(
                    backgroundColor: primaryColor,
                    handleColor: primaryColor,
                    bufferedColor: primaryColor,
                    playedColor: primaryColor,
                  ),
                  controller: _controller!,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.channel!.videos!
                            .firstWhere((v) => v.id == widget.id)
                            .title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      FittedBox(
                        child: Row(
                          children: [
                            Text(
                              '${_formatViewCount(widget.channel!.videos!.firstWhere((v) => v.id == widget.id).viewCount)} views',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const Text(' • '),
                            Text(
                              timeago.format(widget.channel!.videos!
                                  .firstWhere((v) => v.id == widget.id)
                                  .publishedAt),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      FittedBox(
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                  widget.channel!.profilePictureUrl),
                              radius: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.channel!.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatViewCount(widget.channel!.subscriberCount)} subscribers',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.53,
                  child: widget.channel != null
                      ? NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollDetails) {
                            if (!_isLoading &&
                                _randomizedVideos.length !=
                                    int.parse(widget.channel!.videoCount) &&
                                scrollDetails.metrics.pixels ==
                                    scrollDetails.metrics.maxScrollExtent) {
                              _loadMoreVideos();
                            }
                            return false;
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 15),
                            itemCount: _randomizedVideos.length,
                            itemBuilder: (BuildContext context, int index) {
                              Video video = _randomizedVideos[index];
                              return _buildVideo(video);
                            },
                          ),
                        )
                      : Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        ),
                ),
              ],
            ),
            if (_isPreviewShown) _buildNextVideoPreview(),
          ],
        )),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
