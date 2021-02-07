
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum THUMB_TYPE{
  local,
  network
}
class AliplayerWidget extends StatefulWidget{

  String videoUrl;

  String thumbUrl;

  THUMB_TYPE thumbType;

  bool isMute;

  bool isAutoPlay;

  bool isCanStop;

  AliplayerController controller;

  AliplayerWidget(this.videoUrl,{this.thumbUrl, this.thumbType = THUMB_TYPE.network,this.isMute = false,
  this.isAutoPlay = true, this.isCanStop = false, this.controller});

  @override
  State<StatefulWidget> createState() => AliplayerState();

}

class AliplayerState extends State<AliplayerWidget>{

  AliplayerController _controller;

  @override
  void initState(){
    super.initState();
    if(widget.controller==null)
      _controller = AliplayerController();
    else
      _controller = widget.controller;
    _controller.init(this,widget.videoUrl,widget.isMute,widget.isAutoPlay);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
            children: [
              _controller.textureId == null? Container():Texture(key: _controller.globalKey,textureId: _controller.textureId),
              Visibility(
                  visible: _controller.isThumbShow,
                  child: RepaintBoundary(
                    child: getThumbWidget(),
                  )
              ),
              Visibility(
                  visible: !_controller.isPlaying,
                  child: Center(
                    child: Icon(Icons.play_circle_outline_outlined,color: Colors.white,size: 36),
                  )
              )
            ]
        ),
      ),
      onTap: (){
        if(mounted&&widget.isCanStop){
          if(_controller.isPlaying)
            _controller.pause();
          else
            _controller.start();
        }
      },
    );
  }

  Widget getThumbWidget(){
    if(widget.thumbType == THUMB_TYPE.network)
      return CachedNetworkImage(
          width: double.infinity,
          height: double.infinity,
          imageUrl: widget.thumbUrl,
          fit: BoxFit.fill
      );
    else
      return Image.asset(
          widget.thumbUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.fill
      );
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }
}

class AliplayerController{

  MethodChannel _methodChannel;

  EventChannel _eventChannel;

  StreamSubscription _streamSubscription;

  State _state;

  bool isPlaying = true;

  bool isThumbShow = true;

  int textureId;

  final GlobalKey globalKey = GlobalKey();

  void init(State state,String url,bool isMute,bool isAutoPlay){
    this._state = state;
    _methodChannel = MethodChannel("video_player_method");
    _eventChannel = EventChannel("video_player_stream");
    _streamSubscription = _eventChannel.receiveBroadcastStream().listen((event) {
      if(event!=null && event is String && event.toString().isNotEmpty && event.toString()=="render"){
        // ignore: invalid_use_of_protected_member
        this._state.setState(() {
          isThumbShow = false;
        });
      }
    });
    _setVideoSettings(url, isMute, isAutoPlay);
  }

  void pause(){
    assert(_methodChannel!=null);
    assert(_eventChannel!=null);
    _methodChannel?.invokeMethod("pause");
    this._state.setState(() {
      isPlaying = !isPlaying;
    });
  }

  void start(){
    assert(_methodChannel!=null);
    assert(_eventChannel!=null);
    _methodChannel?.invokeMethod("start");
    this._state.setState(() {
      isPlaying = !isPlaying;
    });
  }

  void dispose(){
    _methodChannel?.invokeMethod("release");
    _streamSubscription?.cancel();
    _methodChannel = null;
    _streamSubscription = null;
  }

  void _setVideoSettings(String url,bool isMute,bool isAutoPlay) async{
    var result = await _methodChannel.invokeMethod("init", {"url": url,"mute": isMute, "autoplay": isAutoPlay});
    if (result != null && result as int != -1000){
      // ignore: invalid_use_of_protected_member
      this._state.setState(() {
        textureId = result as int;
      });
    }
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      _methodChannel?.invokeMethod("start", {"width": globalKey.currentContext.size.width,"height": globalKey.currentContext.size.height});
      timer.cancel();
    });
  }
}