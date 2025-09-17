import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/ui/providers/bloc/tv_player_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';

class ChannelView extends StatefulWidget {
  const ChannelView({
    super.key,
    required this.selectedChannelIndex,
  });

  final ChannelModel? selectedChannelIndex;

  @override
  State<ChannelView> createState() => _ChannelViewState();
}

class _ChannelViewState extends State<ChannelView> {
  final TvPlayerBloc tvPlayerBloc = instance<TvPlayerBloc>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedChannelIndex == null) {
      return Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey,
        ),
      );
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[900]!,
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ChannelPlayerPage(channelUrl: widget.selectedChannelIndex?.url ?? '', channelName: widget.selectedChannelIndex?.name ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}

class ChannelPlayerPage extends StatefulWidget {
  final String channelUrl;
  final String channelName;

  const ChannelPlayerPage({
    super.key,
    required this.channelUrl,
    required this.channelName,
  });

  @override
  State<ChannelPlayerPage> createState() => _ChannelPlayerPageState();
}

class _ChannelPlayerPageState extends State<ChannelPlayerPage> {
  late VlcPlayerController _vlcController;

  @override
  void initState() {
    super.initState();
    _vlcController = VlcPlayerController.network(
      widget.channelUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void didUpdateWidget(covariant ChannelPlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.channelUrl != widget.channelUrl) {
      _vlcController.stop();
      _vlcController.setMediaFromNetwork(widget.channelUrl, autoPlay: true);
    }
  }

  @override
  void dispose() {
    _vlcController.stop();
    _vlcController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: "videoPlayer",
          child: VideoPlayerView(
            controller: _vlcController,
            aspectRatio: 16 / 9,
          ),
        ),
      ),
    );
  }
}

class VideoPlayerView extends StatefulWidget {
  final VlcPlayerController controller;
  final double aspectRatio;

  const VideoPlayerView({super.key, required this.controller, required this.aspectRatio});

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool isLandscape = false;
  bool showControls = false;
  Timer? _hideTimer;
  bool isLoading = true; // 👈 nuevo estado

  bool isError = false;
  bool isTv = PlatformUtils.isTV;

  changeOrientation() {
    if (isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
  }

  void _toggleControls() {
    setState(() {
      showControls = !showControls;
    });

    // Reiniciar el temporizador
    _hideTimer?.cancel();
    if (showControls) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        setState(() => showControls = false);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Escucha cambios en el reproductor
    widget.controller.addListener(() {
      final value = widget.controller.value;

      setState(() {
        if (value.playingState == PlayingState.buffering || value.playingState == PlayingState.initializing || value.playingState == PlayingState.initialized) {
          isLoading = true; // está cargando
          isError = false;
        } else if (value.playingState == PlayingState.playing) {
          isLoading = false; // ya está reproduciendo
          isError = false;
        } else if (value.playingState == PlayingState.error) {
          isLoading = false; // podrías manejar error aparte
          isError = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.stop(); // detener el video al destruir
    widget.controller.removeListener(() {});
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
  //     widget.controller.pause(); // pausa cuando la app va al background
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return WillPopScope(
      onWillPop: () async {
        if (isTv) {
          return true;
        }
        if (isLandscape) {
          Future.delayed(const Duration(seconds: 0), () {
            changeOrientation();
          });
          return false;
        } else {
          return true;
        }
      },
      child: ExcludeFocusTraversal(
          child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Column(
              children: [
                if (isTv)
                  Expanded(
                    child: VlcPlayer(
                      controller: widget.controller,
                      aspectRatio: widget.aspectRatio,
                      placeholder: const Center(child: CircularProgressIndicator()),
                    ),
                  )
                else
                  Expanded(
                    child: InkWell(
                      autofocus: false,
                      canRequestFocus: false,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                      onTap: isTv ? null : _toggleControls,
                      child: Stack(
                        children: [
                          // Video
                          AnimatedContainer(
                            height: double.infinity,
                            width: double.infinity,
                            duration: const Duration(milliseconds: 300),
                            child: VlcPlayer(
                              controller: widget.controller,
                              aspectRatio: 16 / 9,
                              placeholder: const Center(child: CircularProgressIndicator()),
                            ),
                          ),

                          // Controles con fade in/out
                          isTv
                              ? SizedBox()
                              : AnimatedOpacity(
                                  opacity: showControls ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: IgnorePointer(
                                    ignoring: !showControls, // para no interceptar taps cuando está oculto
                                    child: Stack(
                                      children: [
                                        // Fondo semi-transparente como YT
                                        Container(
                                          color: Colors.black26,
                                        ),
                                        Positioned(
                                          bottom: isLandscape ? 20 : 10,
                                          right: isLandscape ? 20 : 10,
                                          child: IconButton(
                                            icon: Icon(
                                              isLandscape ? Icons.fullscreen_exit : Icons.fullscreen,
                                            ),
                                            color: Colors.white,
                                            onPressed: () {
                                              setState(() {
                                                changeOrientation();
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Positioned.fill(
              child: isLoading
                  ? Container(
                      color: Colors.black.withOpacity(0.5), // fondo negro con opacidad
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : const SizedBox(),
            ),
            isError
                ? Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5), // fondo negro con opacidad
                      child: Center(
                        child: Text('El canal no se encuentra\n disponible en estos momentos', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      )),
    );
  }
}
