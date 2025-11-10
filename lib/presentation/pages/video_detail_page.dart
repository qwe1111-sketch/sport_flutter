import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sport_flutter/domain/entities/video.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';

class VideoDetailPage extends StatefulWidget {
  final Video video;
  final List<Video> recommendedVideos;

  const VideoDetailPage({
    super.key,
    required this.video,
    this.recommendedVideos = const [],
  });

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late VideoPlayerController _controller;
  bool _isFullScreen = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  late int _viewCount;
  late int _likeCount;
  late bool _isLiked;
  bool _viewRecorded = false;

  final String _apiBaseUrl = 'http://192.168.4.140:3000/api';

  @override
  void initState() {
    super.initState();
    _viewCount = widget.video.viewCount;
    _likeCount = widget.video.likeCount;
    _isLiked = false; // This should be fetched from an API in a real app

    _initializePlayer(widget.video.videoUrl);
  }

  @override
  void didUpdateWidget(covariant VideoDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.videoUrl != widget.video.videoUrl) {
      _controller.dispose();
      _initializePlayer(widget.video.videoUrl);
    }
  }

  void _initializePlayer(String url) {
     _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _controller.play();
        _startHideTimer();
      })
      ..addListener(_videoListener);
  }

  void _videoListener() {
    if (!_viewRecorded && _controller.value.position >= _controller.value.duration) {
      _recordView();
      if (mounted) {
        setState(() {
          _viewCount++;
          _viewRecorded = true;
        });
      }
    }
  }

  Future<void> _recordView() async {
    try {
      await http.post(Uri.parse('$_apiBaseUrl/videos/${widget.video.id}/view'));
    } catch (e) {
      print("Failed to record view: $e");
    }
  }

  Future<void> _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      _isLiked ? _likeCount++ : _likeCount--;
    });
    try {
      final response = await http.post(Uri.parse('$_apiBaseUrl/videos/${widget.video.id}/like'));
      if (response.statusCode != 200) setState(() { _isLiked = !_isLiked; _isLiked ? _likeCount++ : _likeCount--; });
    } catch (e) {
      print("Failed to toggle like: $e");
      setState(() { _isLiked = !_isLiked; _isLiked ? _likeCount++ : _likeCount--; });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    _hideControlsTimer?.cancel();
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    }
    super.dispose();
  }
  
  void _startHideTimer(){_hideControlsTimer?.cancel();_hideControlsTimer=Timer(const Duration(seconds:4),(){if(mounted)setState(()=>_showControls=false);});}
  void _toggleFullScreen(){_startHideTimer();setState((){_isFullScreen=!_isFullScreen;if(_isFullScreen){SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft,DeviceOrientation.landscapeRight]);SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);}else{SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays:SystemUiOverlay.values);}});}
  String _formatNumber(int number)=>number>=10000?'${(number/10000).toStringAsFixed(1)}万':number.toString();String _formatDate(DateTime date){final d=DateTime.now().difference(date);if(d.inDays>1)return'${d.inDays}天前';if(d.inHours>1)return'${d.inHours}小时前';return'刚刚';}

  @override
  Widget build(BuildContext context) {
    final videoPlayer = _buildVideoPlayer();
    if (_isFullScreen) return Scaffold(backgroundColor: Colors.black, body: Center(child: videoPlayer));
    return Scaffold(appBar: AppBar(title: Text(widget.video.title)), body: Column(children: [videoPlayer, Expanded(child: _buildMetaAndCommentsSection())]));
  }

  Widget _buildVideoPlayer() => GestureDetector(onTap:(){setState(()=>_showControls=!_showControls);if(_showControls)_startHideTimer();},child:AspectRatio(aspectRatio:_controller.value.isInitialized?_controller.value.aspectRatio:16/9,child:Stack(alignment:Alignment.center,children:[if(_controller.value.isInitialized)VideoPlayer(_controller)else const Center(child:CircularProgressIndicator()),AnimatedOpacity(opacity:_showControls?1.0:0.0,duration:const Duration(milliseconds:300),child:_buildControls(context))])));

  Widget _buildMetaAndCommentsSection() => DefaultTabController(length:2,child:Column(children:[const TabBar(tabs:[Tab(text:'简介'),Tab(text:'评论')]),Expanded(child:TabBarView(children:[_buildIntroPanel(),_buildCommentsPanel()]))]));

  Widget _buildIntroPanel() {
    // The primary fix for the overflow error.
    // By wrapping the content in a NestedScrollView, we allow the inner list
    // to scroll independently within the TabBarView.
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [const CircleAvatar(child: Icon(Icons.person)), const SizedBox(width: 12), Expanded(child: Text(widget.video.authorName, style: Theme.of(context).textTheme.titleMedium)), ElevatedButton(onPressed: () {}, child: const Text('+ 关注'))]),
                  const SizedBox(height: 12),
                  Text(widget.video.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('${_formatNumber(_viewCount)}次观看 - ${_formatDate(widget.video.createdAt)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildActionButton(icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined, label: _formatNumber(_likeCount), onPressed: _toggleLike), _buildActionButton(icon: Icons.thumb_down_outlined, label: '不喜欢'), _buildActionButton(icon: Icons.star_border, label: '收藏'), _buildActionButton(icon: Icons.share_outlined, label: '分享')]),
                  const Divider(height: 32),
                  const Text('接下来播放', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ];
      },
      body: ListView.builder(
          itemCount: widget.recommendedVideos.length,
          itemBuilder: (context, index) {
              final recommendedVideo = widget.recommendedVideos[index];
              if (recommendedVideo.id == widget.video.id) return const SizedBox.shrink();
              return _buildRecommendedItem(context, recommendedVideo);
          },
      ),
    );
  }

  Widget _buildRecommendedItem(BuildContext context,Video video)=>Padding(padding:const EdgeInsets.symmetric(horizontal:16.0,vertical:8.0),child:InkWell(onTap:(){Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(_)=>VideoDetailPage(video:video,recommendedVideos:widget.recommendedVideos)));},child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[SizedBox(width:150,child:AspectRatio(aspectRatio:16/9,child:ClipRRect(borderRadius:BorderRadius.circular(8.0),child:CachedNetworkImage(imageUrl:video.thumbnailUrl,fit:BoxFit.cover,placeholder:(context,url)=>const Center(child:CircularProgressIndicator()),errorWidget:(context,url,error)=>const Icon(Icons.error))))),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(video.title,style:Theme.of(context).textTheme.titleSmall,maxLines:2,overflow:TextOverflow.ellipsis),const SizedBox(height:4),Text(video.authorName,style:Theme.of(context).textTheme.bodySmall?.copyWith(color:Colors.grey))]))])));
  Widget _buildActionButton({required IconData icon,required String label,VoidCallback? onPressed})=>InkWell(onTap:onPressed,child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(icon,size:28),const SizedBox(height:4),Text(label,style:Theme.of(context).textTheme.labelMedium)]));
  Widget _buildCommentsPanel()=>const Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.comment_outlined,size:60,color:Colors.grey),SizedBox(height:16),Text('// TODO: Comments will be here')]));
  Widget _buildControls(BuildContext context)=>Stack(children:[Center(child:IconButton(icon:Icon(_controller.value.isPlaying?Icons.pause_circle_filled:Icons.play_circle_filled),onPressed:(){_startHideTimer();setState(()=>_controller.value.isPlaying?_controller.pause():_controller.play());},color:Colors.white,iconSize:60)),Positioned(bottom:0,left:0,right:0,child:Container(color:Colors.black38,child:Column(mainAxisSize:MainAxisSize.min,children:[VideoProgressIndicator(_controller,allowScrubbing:true),Row(children:[const SizedBox(width:8),PopupMenuButton<double>(onSelected:(speed){_startHideTimer();_controller.setPlaybackSpeed(speed);},itemBuilder:(context)=>[for(final speed in[0.5,1.0,1.5,2.0])PopupMenuItem(value:speed,child:Text('${speed}x'))],child:Padding(padding:const EdgeInsets.all(8.0),child:Text('${_controller.value.playbackSpeed}x',style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold)))),const Spacer(),IconButton(icon:Icon(_isFullScreen?Icons.fullscreen_exit:Icons.fullscreen),onPressed:_toggleFullScreen,color:Colors.white)])])))]);
}
