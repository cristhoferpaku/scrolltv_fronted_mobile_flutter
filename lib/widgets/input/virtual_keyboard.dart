import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/colors.dart';

class VirtualKeyboard extends StatefulWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback onSpace;
  final VoidCallback onEnter;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool isPasswordField;
  final FocusNode? focusNode;

  const VirtualKeyboard({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onSpace,
    required this.onEnter,
    this.onPrevious,
    this.onNext,
    this.isPasswordField = false,
    this.focusNode,
  });

  @override
  State<VirtualKeyboard> createState() => _VirtualKeyboardState();
}

class _VirtualKeyboardState extends State<VirtualKeyboard> {
  int _focusedRow = 0;
  int _focusedCol = 0;
  bool _isShiftPressed = false;
  bool _isSymbolMode = false;
  late FocusNode _keyboardFocus;
  bool _ignoreNavigation = false;
  
  // Solo uno de estos puede ser true a la vez
  bool _isActionButtonFocused = false;
  int _focusedActionButton = 0;
  bool _isEmailSuggestionFocused = false;
  int _focusedEmailSuggestion = 0;
  bool _isNavigationButtonFocused = false;
  int _focusedNavigationButton = 0;

  @override
  void initState() {
    super.initState();
    _keyboardFocus = widget.focusNode ?? FocusNode();
    // Asegurar que solo el teclado principal tenga focus inicialmente
    _resetNavigationState();
    if (widget.focusNode == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _keyboardFocus.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(VirtualKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambió el campo (usuario/contraseña), resetear el estado de navegación
    if (oldWidget.isPasswordField != widget.isPasswordField) {
      _resetNavigationState();
      // Asegurar que el foco se mantenga en el teclado
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          _keyboardFocus.requestFocus();
        }
      });
    }
  }

  void _resetNavigationState() {
    _setFocusState(keyboard: true);
    setState(() {
      _focusedActionButton = 0;
      _focusedEmailSuggestion = 0;
      _focusedNavigationButton = 0;
      _focusedRow = 0;
      _focusedCol = 0;
    });
  }

  void _setFocusState({
    bool keyboard = false,
    bool emailSuggestion = false,
    bool actionButton = false,
    bool navigationButton = false,
  }) {
    setState(() {
      // Resetear todos los estados de focus
      _isActionButtonFocused = false;
      _isEmailSuggestionFocused = false;
      _isNavigationButtonFocused = false;
      
      // Activar solo el estado solicitado
      if (actionButton) {
        _isActionButtonFocused = true;
      } else if (emailSuggestion) {
        _isEmailSuggestionFocused = true;
      } else if (navigationButton) {
        _isNavigationButtonFocused = true;
      }
      // Si keyboard = true o ninguno está activo, el teclado principal tendrá focus por defecto
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _keyboardFocus.dispose();
    }
    super.dispose();
  }

  final List<List<String>> _keyboardLayout = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', '-'],
    ['⇧', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '-'],
  ];

  final List<String> _emailSuggestions = [
    '@hotmail.com',
    '@gmail.com',
    '@outlook.com'
  ];

  final List<String> _actionButtons = ['!#\$','@', '.', '⎵','⌫'];

  KeyEventResult _handleRemoteKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // Ignorar eventos de navegación si acabamos de procesar una tecla
      if (_ignoreNavigation &&
          (event.logicalKey == LogicalKeyboardKey.arrowUp ||
              event.logicalKey == LogicalKeyboardKey.arrowDown ||
              event.logicalKey == LogicalKeyboardKey.arrowLeft ||
              event.logicalKey == LogicalKeyboardKey.arrowRight)) {
        return KeyEventResult.handled; // Consumir el evento
      }

      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          if (_isNavigationButtonFocused) {
            // Volver a los botones de acción desde los botones de navegación
            _setFocusState(actionButton: true);
            setState(() {
              _focusedActionButton = _actionButtons.length - 1;
            });
          } else if (_isActionButtonFocused) {
            // Volver a las sugerencias de email desde los botones de acción
            _setFocusState(emailSuggestion: true);
            setState(() {
              _focusedEmailSuggestion = _emailSuggestions.length - 1;
            });
          } else if (_isEmailSuggestionFocused) {
            // Volver al teclado desde las sugerencias de email
            _setFocusState(keyboard: true);
            setState(() {
              _focusedRow = _keyboardLayout.length - 1;
            });
          } else if (_focusedRow > 0) {
            setState(() {
              _focusedRow--;
            });
          }
          return KeyEventResult.handled; // Consumir el evento
        case LogicalKeyboardKey.arrowDown:
          if (!_isEmailSuggestionFocused && !_isActionButtonFocused && !_isNavigationButtonFocused &&
              _focusedRow < _keyboardLayout.length - 1) {
            setState(() {
              _focusedRow++;
            });
          } else if (!_isEmailSuggestionFocused && !_isActionButtonFocused && !_isNavigationButtonFocused &&
              _focusedRow == _keyboardLayout.length - 1) {
            // Mover a las sugerencias de email desde el teclado
            _setFocusState(emailSuggestion: true);
            setState(() {
              _focusedEmailSuggestion = 0;
            });
          } else if (_isEmailSuggestionFocused) {
            // Mover a los botones de acción desde las sugerencias de email
            _setFocusState(actionButton: true);
            setState(() {
              _focusedActionButton = 0;
            });
          } else if (_isActionButtonFocused) {
            // Mover a los botones de navegación desde los botones de acción
            _setFocusState(navigationButton: true);
            setState(() {
              _focusedNavigationButton = 0;
            });
          }
          return KeyEventResult.handled; // Consumir el evento
        case LogicalKeyboardKey.arrowLeft:
          setState(() {
            if (_isNavigationButtonFocused) {
              // Navegación entre botones de navegación
              if (_focusedNavigationButton > 0) {
                _focusedNavigationButton--;
              } else {
                // Ir al último botón de navegación
                _focusedNavigationButton = 2;
              }
            } else if (_isActionButtonFocused) {
              // Navegación entre botones de acción
              if (_focusedActionButton > 0) {
                _focusedActionButton--;
              } else {
                // Ir al último botón de acción
                _focusedActionButton = _actionButtons.length - 1;
              }
            } else if (_isEmailSuggestionFocused) {
              // Navegación entre sugerencias de email
              if (_focusedEmailSuggestion > 0) {
                _focusedEmailSuggestion--;
              } else {
                // Ir a la última sugerencia de email
                _focusedEmailSuggestion = _emailSuggestions.length - 1;
              }
            } else {
              // Navegación en el teclado
              if (_focusedCol > 0) {
                _focusedCol--;
              } else {
                // Ir al final de la fila
                _focusedCol = _keyboardLayout[_focusedRow].length - 1;
              }
            }
          });
          return KeyEventResult.handled; // Consumir el evento
        case LogicalKeyboardKey.arrowRight:
          setState(() {
            if (_isNavigationButtonFocused) {
              // Navegación entre botones de navegación
              if (_focusedNavigationButton < 2) {
                _focusedNavigationButton++;
              } else {
                _focusedNavigationButton = 0;
              }
            } else if (_isActionButtonFocused) {
              // Navegación entre botones de acción
              if (_focusedActionButton < _actionButtons.length - 1) {
                _focusedActionButton++;
              } else {
                _focusedActionButton = 0;
              }
            } else if (_isEmailSuggestionFocused) {
              // Navegación entre sugerencias de email
              if (_focusedEmailSuggestion < _emailSuggestions.length - 1) {
                _focusedEmailSuggestion++;
              } else {
                _focusedEmailSuggestion = 0;
              }
            } else {
              if (_focusedCol < _keyboardLayout[_focusedRow].length - 1) {
                _focusedCol++;
              } else {
                _focusedCol = 0;
              }
            }
          });
          return KeyEventResult.handled; // Consumir el evento
        case LogicalKeyboardKey.select:
        case LogicalKeyboardKey.enter:
          if (_isNavigationButtonFocused) {
            _handleActionButtonPress();
          } else if (_isActionButtonFocused) {
            String actionKey = _actionButtons[_focusedActionButton];
            _handleActionKeyPress(actionKey);
          } else if (_isEmailSuggestionFocused) {
            String suggestion = _emailSuggestions[_focusedEmailSuggestion];
            widget.onKeyPressed(suggestion);
            // Volver al teclado después de seleccionar
            _setFocusState(keyboard: true);
            setState(() {
              _focusedRow = 0;
              _focusedCol = 0;
            });
          } else {
            String key = _keyboardLayout[_focusedRow][_focusedCol];
            _handleKeyPress(key);
          }
          return KeyEventResult.handled; // Consumir el evento
        default:
          return KeyEventResult.ignored; // No consumir eventos no manejados
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        focusNode: _keyboardFocus,
        autofocus: true,
        onKey: (node, event) {
          if (event is RawKeyEvent) {
            return _handleRemoteKey(event);
          }
          return KeyEventResult.ignored;
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isPasswordField ? Colors.orange : Colors.blue,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Field indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: widget.isPasswordField
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.isPasswordField ? 'Contraseña' : 'Usuario',
                  style: TextStyle(
                    color: widget.isPasswordField ? Colors.orange : Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Keyboard rows
              Container(
                color: Color.fromRGBO(38, 38, 38, 1),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Keyboard Grid
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 500, // Ancho máximo del teclado
                      ),
                      child: Column(
                        children: _keyboardLayout.asMap().entries.map((entry) {
                          int rowIndex = entry.key;
                          List<String> row = entry.value;
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: row.asMap().entries.map((keyEntry) {
                                int colIndex = keyEntry.key;
                                String key = keyEntry.value;
                                bool isFocused = !_isEmailSuggestionFocused &&
                                    !_isActionButtonFocused &&
                                    !_isNavigationButtonFocused &&
                                    _focusedRow == rowIndex &&
                                    _focusedCol == colIndex;

                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    child: _buildKey(
                                      key: key,
                                      isFocused: isFocused,
                                      onPressed: () => _handleKeyPress(key),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    // Email suggestions grid
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 500, // Mismo ancho que el teclado
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _emailSuggestions.asMap().entries.map((entry) {
                          int index = entry.key;
                          String suggestion = entry.value;
                          bool isFocused = _isEmailSuggestionFocused &&
                              _focusedEmailSuggestion == index;
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              child: _buildSuggestionButton(suggestion, isFocused),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    // Action buttons grid (⇧, ⌫, ⎵, ↵)
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 500, // Ancho máximo para botones de acción
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _actionButtons.asMap().entries.map((entry) {
                          int index = entry.key;
                          String button = entry.value;
                          bool isFocused = _isActionButtonFocused &&
                              _focusedActionButton == index;

                          return Expanded(
                            flex: (button == '⎵' || button == '⌫') ? 3 : 1, // Space y backspace más anchos
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              child: _buildActionKey(
                                key: button,
                                isFocused: isFocused,
                                onPressed: () => _handleActionKeyPress(button),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
               
                    
                    const SizedBox(height: 12),
                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _buildActionButtons(),
                    ),
                ]),
              ),
              // Keyboard rows

              // Navigation buttons
           
            ],
          ),
        ));
  }

  Widget _buildKey({
    required String key,
    required bool isFocused,
    required VoidCallback onPressed,
  }) {
    String displayKey = key;
    if (key == '⇧') {
      displayKey = key;
    } else if (_isShiftPressed && key.length == 1 && key != '-') {
      displayKey = key.toUpperCase();
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isFocused ? Colors.white : Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
 
        ),
        child: Center(
          child: Text(
            displayKey,
            style: TextStyle(
              color: isFocused ? Colors.black : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({
    required String key,
    required bool isFocused,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isFocused ? Colors.white : Color.fromRGBO(68, 68, 68, 1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isFocused ? Colors.white : Colors.transparent,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Center(
            child: Text(
              key,
              style: TextStyle(
                color: isFocused ? Colors.black : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionButton(String suggestion, bool isFocused) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isFocused ? Colors.white : Color.fromRGBO(68, 68, 68, 1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isFocused ? Colors.white : Colors.transparent,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onKeyPressed(suggestion);
            _keyboardFocus.requestFocus();
          },
          borderRadius: BorderRadius.circular(4),
          child: Center(
            child: Text(
              suggestion,
              style: TextStyle(
                color: isFocused ? Colors.black : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons() {
    List<Widget> buttons = [];
    int buttonIndex = 0;

    if (widget.isPasswordField) {
      // En campo contraseña: mostrar Anterior e Ingresar
      if (widget.onPrevious != null) {
        buttons.add(_buildActionButton('Anterior', widget.onPrevious!,
            isFocused:
                _isNavigationButtonFocused && _focusedNavigationButton == buttonIndex));
        buttonIndex++;
      }
      buttons.add(_buildActionButton('Ingresar', widget.onEnter,
          isPrimary: true,
          isFocused:
              _isNavigationButtonFocused && _focusedNavigationButton == buttonIndex));
    } else {
      // En campo usuario: solo mostrar Siguiente
      if (widget.onNext != null) {
        buttons.add(_buildActionButton('Siguiente', widget.onNext!,
            isPrimary: true,
            isFocused:
                _isNavigationButtonFocused && _focusedNavigationButton == buttonIndex));
      }
    }

    return buttons;
  }

  Widget _buildActionButton(String text, VoidCallback onPressed,
      {bool isPrimary = false, bool isFocused = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isFocused
              ? Colors.white
              : (isPrimary ? ColorManager.primaryContainer : Colors.grey[700]),
          borderRadius: BorderRadius.circular(8),
          border: isFocused ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isFocused
                ? Colors.black
                : (isPrimary ? ColorManager.onPrimaryContainer : Colors.white),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _handleActionKeyPress(String key) {
    switch (key) {
      case '!#\$':
        // Cambiar a modo de símbolos/números
        setState(() {
          _isSymbolMode = !_isSymbolMode;
        });
        break;
      case '@':
        widget.onKeyPressed('@');
        break;
      case '.':
        widget.onKeyPressed('.');
        break;
      case '⇧':
        setState(() {
          _isShiftPressed = !_isShiftPressed;
        });
        break;
      case '⌫':
        widget.onBackspace();
        break;
      case '⎵':
        widget.onSpace();
        break;
      // case '↵':
      //   widget.onEnter();
      //   break;
    }

    // Ignorar navegación automática temporalmente
    _ignoreNavigation = true;
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _ignoreNavigation = false;
      }
    });

    // Mantener el foco en el teclado virtual
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _keyboardFocus.requestFocus();
      }
    });
  }

  void _handleActionButtonPress() {
    if (widget.isPasswordField) {
      // En campo contraseña: 0 = Anterior, 1 = Ingresar
      if (_focusedNavigationButton == 0 && widget.onPrevious != null) {
        widget.onPrevious!();
        // Resetear el estado de navegación y mantener el foco
        _resetNavigationState();
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            _keyboardFocus.requestFocus();
          }
        });
      } else if (_focusedNavigationButton == 1) {
        widget.onEnter();
      }
    } else {
      // En campo usuario: 0 = Siguiente
      if (_focusedNavigationButton == 0 && widget.onNext != null) {
        widget.onNext!();
        // Resetear el estado de navegación y mantener el foco
        _resetNavigationState();
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            _keyboardFocus.requestFocus();
          }
        });
      }
    }
  }

  void _handleKeyPress(String key) {
    if (key == '⇧') {
      setState(() {
        _isShiftPressed = !_isShiftPressed;
      });
    } else if (key == '-') {
      widget.onBackspace();

      // Ignorar navegación automática temporalmente
      _ignoreNavigation = true;
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _ignoreNavigation = false;
        }
      });
    } else {
      String actualKey =
          _isShiftPressed && key.length == 1 ? key.toUpperCase() : key;
      widget.onKeyPressed(actualKey);
      if (_isShiftPressed) {
        setState(() {
          _isShiftPressed = false;
        });
      }

      // Ignorar navegación automática temporalmente después de entrada de tecla
      _ignoreNavigation = true;
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _ignoreNavigation = false;
        }
      });

      // Mantener el foco en el teclado virtual
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _keyboardFocus.requestFocus();
        }
      });
    }
  }
}
