import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';

class OptionPanel extends StatefulWidget {
  final String title;
  final String? currentValue;
  final List<Map<String, String>> options;
  final Function(String) onValueChanged;
  final bool isVisible;
  final VoidCallback onClose;

  const OptionPanel({
    Key? key,
    required this.title,
    this.currentValue,
    required this.options,
    required this.onValueChanged,
    required this.isVisible,
    required this.onClose,
  }) : super(key: key);

  @override
  State<OptionPanel> createState() => OptionPanelState();
}

class OptionPanelState extends State<OptionPanel> {
  int selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final bool isTV = PlatformUtils.isTV;

  @override
  void initState() {
    super.initState();
    _findCurrentIndex();
  }

  @override
  void didUpdateWidget(OptionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentValue != widget.currentValue) {
      _findCurrentIndex();
    }
  }

  void _findCurrentIndex() {
    final index = widget.options.indexWhere(
      (option) => option['value'] == widget.currentValue,
    );
    if (index != -1) {
      selectedIndex = index;
    }
  }

  void _scrollToSelected() {
    if (_scrollController.hasClients) {
      final itemHeight = isTV ? 100.0 : 80.0;
      final viewportHeight = _scrollController.position.viewportDimension;
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      
      final targetOffset = (selectedIndex * itemHeight) - (viewportHeight / 2) + (itemHeight / 2);
      final clampedOffset = targetOffset.clamp(0.0, maxScrollExtent);
      
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _changeValue(int index) {
    setState(() {
      selectedIndex = index;
    });
    
    final selectedOption = widget.options[index];
    widget.onValueChanged(selectedOption['value'] ?? '');
    
    // Mostrar confirmación del cambio
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.title} cambiado a: ${selectedOption['label']}'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF2DD4BF),
      ),
    );
  }

  bool handleKeyEvent(KeyEvent event) {
    if (!widget.isVisible) return false;
    
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          if (selectedIndex > 0) {
            setState(() {
              selectedIndex--;
            });
            print('OptionPanel: selectedIndex changed to $selectedIndex');
            _scrollToSelected();
            // Feedback háptico ligero para TV
            if (isTV) {
              // TODO: Agregar feedback háptico si está disponible
            }
          }
          return true;
        case LogicalKeyboardKey.arrowDown:
          if (selectedIndex < widget.options.length - 1) {
            setState(() {
              selectedIndex++;
            });
            print('OptionPanel: selectedIndex changed to $selectedIndex');
            _scrollToSelected();
            // Feedback háptico ligero para TV
            if (isTV) {
              // TODO: Agregar feedback háptico si está disponible
            }
          }
          return true;
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.select:
          _changeValue(selectedIndex);
          widget.onClose();
          return true;
        case LogicalKeyboardKey.arrowLeft:
        case LogicalKeyboardKey.escape:
          widget.onClose();
          return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final panelWidth = isTV ? 450.0 : 300.0;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      right: widget.isVisible ? 0 : -panelWidth,
      top: 0,
      bottom: 0,
      width: panelWidth,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.95),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isTV ? 32 : 20),
              decoration: isTV ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF2DD4BF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ) : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (isTV)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2DD4BF),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2DD4BF).withOpacity(0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTV ? 32 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, 
                      color: Colors.white,
                      size: isTV ? 32 : 24),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
            
            // Options List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: isTV ? 24 : 16),
                itemCount: widget.options.length,
                itemBuilder: (context, index) {
                  final isSelected = index == selectedIndex;
                  final option = widget.options[index];
                  
                  // Debug print para verificar el focus
                  if (isSelected) {
                    print('Item $index is selected (selectedIndex: $selectedIndex)');
                  }
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.only(bottom: isTV ? 12 : 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFF2DD4BF).withOpacity(0.9)
                          : Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(isTV ? 16 : 12),
                      border: isSelected 
                          ? Border.all(
                              color: Colors.white, 
                              width: isTV ? 4 : 3
                            )
                          : Border.all(
                              color: Colors.white.withOpacity(0.2), 
                              width: 1
                            ),
                      boxShadow: isSelected 
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.6),
                                blurRadius: isTV ? 15 : 8,
                                spreadRadius: isTV ? 4 : 2,
                              ),
                              BoxShadow(
                                color: const Color(0xFF2DD4BF).withOpacity(0.8),
                                blurRadius: isTV ? 25 : 12,
                                spreadRadius: isTV ? 2 : 1,
                              ),
                            ]
                          : null,
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTV ? 24 : 16,
                        vertical: isTV ? 18 : 12,
                      ),
                      title: Text(
                        option['label']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: isTV ? 22 : 18,
                          shadows: isSelected ? [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ] : null,
                        ),
                      ),
                      trailing: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isTV ? 32 : 24,
                        height: isTV ? 32 : 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected 
                                ? Colors.white 
                                : Colors.white.withOpacity(0.6),
                            width: isTV ? 4 : 3,
                          ),
                          color: isSelected ? Colors.white : Colors.transparent,
                          boxShadow: isSelected && isTV 
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2DD4BF).withOpacity(0.5),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                             ? Icon(
                                 Icons.check,
                                 color: const Color(0xFF2DD4BF),
                                 size: isTV ? 20 : 16,
                                 weight: 800,
                               )
                             : null,
                      ),
                      onTap: () {
                        _changeValue(index);
                        widget.onClose();
                      },
                    ),
                  );
                },
              ),
            ),
            

          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}