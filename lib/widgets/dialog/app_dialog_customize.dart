import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/colors.dart';

enum AppDialogCustomizeType {
  error,
  warning,
  success,
}

class AppDialogCustomize extends StatefulWidget {
  final AppDialogCustomizeType type;
  final String? title;
  final String message;
  final void Function()? onPressed;
  final String labelActionButton;
  final IconData iconActionButton;
  final String labelCancelButton;
  final IconData iconCancelButton;
  final void Function()? onCancelPressed;
  final bool showCancelButton;
  final bool canPop;

  const AppDialogCustomize({
    super.key,
    this.type = AppDialogCustomizeType.error,
    required this.message,
    this.title,
    this.onPressed,
    this.labelActionButton = "Reintentar",
    this.iconActionButton = Icons.refresh_rounded,
    this.labelCancelButton = "Cancelar",
    this.iconCancelButton = Icons.arrow_back_rounded,
    this.onCancelPressed,
    this.showCancelButton = true,
    this.canPop = false,
    //required this.bloc,
  });

  @override
  State<AppDialogCustomize> createState() => _AppDialogCustomizeState();
}

class _AppDialogCustomizeState extends State<AppDialogCustomize> {
  getTypeColorContainer() {
    switch (widget.type) {
      case AppDialogCustomizeType.error:
        return Colors.red.withValues(alpha: 0.1);
      case AppDialogCustomizeType.warning:
        return Colors.orange.withValues(alpha: 0.1);
      case AppDialogCustomizeType.success:
        return Colors.green.withValues(alpha: 0.1);
    }
  }

  getTypeColor() {
    switch (widget.type) {
      case AppDialogCustomizeType.error:
        return Colors.red;
      case AppDialogCustomizeType.warning:
        return Colors.orange;
      case AppDialogCustomizeType.success:
        return Colors.green;
    }
  }

  getTypeIcon() {
    switch (widget.type) {
      case AppDialogCustomizeType.error:
        return Icons.error_outline_rounded;
      case AppDialogCustomizeType.warning:
        return Icons.warning_amber_rounded;
      case AppDialogCustomizeType.success:
        return Icons.check_circle_rounded;
    }
  }

  getTypetitle() {
    switch (widget.type) {
      case AppDialogCustomizeType.error:
        return "Error";
      case AppDialogCustomizeType.warning:
        return "Advertencia";
      case AppDialogCustomizeType.success:
        return "¡Todo salió bien!";
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.canPop,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black87,
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 400),
                padding: EdgeInsets.all(20),
                child: Card(
                  shadowColor: Colors.transparent,
                  elevation: 8,
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: getTypeColorContainer(),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            getTypeIcon(),
                            color: getTypeColor(),
                            size: 48,
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          widget.title ?? getTypetitle(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          widget.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  autofocus: true,

                                  onPressed: widget.onPressed,
                                  // onPressed: () {
                                  // Reintentar cargar el video
                                  // final args = ModalRoute.of(context)!.settings.arguments as VideoPageArguments;
                                  // bloc.add(VideoPlayerEvent.loadedVideo(
                                  //   videoUrl: args.videoUrl,
                                  //   episodeNum: args.episodeNumber ?? 0,
                                  // ));
                                  // },
                                  icon: Icon(widget.iconActionButton, size: 20),
                                  label: Text(
                                    widget.labelActionButton,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorManager.primaryContainer,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shadowColor: ColorManager.primaryContainer.withValues(alpha: 0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (widget.showCancelButton) SizedBox(width: 16),
                            if (widget.showCancelButton)
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      if (widget.onCancelPressed != null) {
                                        widget.onCancelPressed!();
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    },
                                    icon: Icon(widget.iconCancelButton, size: 20),
                                    label: Text(
                                      widget.labelCancelButton,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.grey[300],
                                      side: BorderSide(
                                        color: Colors.grey[600]!,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
