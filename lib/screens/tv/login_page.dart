import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/colors.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/constants/schemas/validator_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/providers/login/login_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/auth/ui/providers/login/login_listener.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/assets_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/input/virtual_keyboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController tcUsername = TextEditingController();
  final TextEditingController tcPassword = TextEditingController();
  final loginBloc = instance<LoginBloc>();
  final formKey = GlobalKey<FormState>();
  bool _isPasswordField = false;
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _keyboardFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    // Agregar listeners para detectar cambios de foco
    _usernameFocus.addListener(() {
      if (_usernameFocus.hasFocus && _isPasswordField) {
        setState(() {
          _isPasswordField = false;
        });
      }
    });

    _passwordFocus.addListener(() {
      if (_passwordFocus.hasFocus && !_isPasswordField) {
        setState(() {
          _isPasswordField = true;
        });
      }
    });

    _keyboardFocus.addListener(() {});
  }

  @override
  void dispose() {
    // Remover listeners antes de dispose
    _usernameFocus.removeListener(() {});
    _passwordFocus.removeListener(() {});
    _keyboardFocus.removeListener(() {});

    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _keyboardFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: ImageAssets.backgroundTv,
      linearGradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.black.withValues(alpha: 0.85),
          Colors.black.withValues(alpha: 0.80),
          Colors.black.withValues(alpha: 0.5),
        ],
        stops: [0.0, 0.5, 1.0],
      ),
      body: BlocConsumer<LoginBloc, LoginState>(
        bloc: loginBloc,
        listener: (context, state) {
          loginListener(context, state);
        },
        builder: (context, state) {
          return SafeArea(
            child: Form(
              key: formKey,
              child: Row(
                children: [
                  // Left side - Virtual keyboard
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: VirtualKeyboard(
                        focusNode: _keyboardFocus,
                        isPasswordField: _isPasswordField,
                        onKeyPressed: _handleKeyPress,
                        onBackspace: _handleBackspace,
                        onSpace: _handleSpace,
                        onEnter: _handleLogin,
                        onPrevious:
                            _isPasswordField ? _goToPreviousField : null,
                        onNext: !_isPasswordField ? _goToNextField : null,
                      ),
                    ),
                  ),
                  // Right side - Login form
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cuenta',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: tcUsername,
                            focusNode: _usernameFocus,
                            isPassword: false,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Contraseña',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: tcPassword,
                            focusNode: _passwordFocus,
                            isPassword: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isPassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: focusNode.hasFocus
              ? ColorManager.primaryContainer
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword,
        readOnly: true,
        enableInteractiveSelection: false,
        validator: (value) => isPassword
            ? ValidatorManager.validatePassword(value ?? '')
            : ValidatorManager.validateUsername(value ?? ''),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          errorStyle: TextStyle(color: Colors.red),
        ),
        onTap: () {
          setState(() {
            _isPasswordField = isPassword;
          });
          focusNode.requestFocus();
          // Request focus to virtual keyboard
          Future.delayed(const Duration(milliseconds: 100), () {
            _keyboardFocus.requestFocus();
          });
        },
      ),
    );
  }

  void _handleKeyPress(String key) {
    final currentController = _isPasswordField ? tcPassword : tcUsername;

    setState(() {
      final newText = currentController.text + key;
      currentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    });

    // Mantener el foco en el virtual keyboard
    Future.delayed(const Duration(milliseconds: 50), () {
      _keyboardFocus.requestFocus();
    });
  }

  void _handleBackspace() {
    final currentController = _isPasswordField ? tcPassword : tcUsername;

    if (currentController.text.isNotEmpty) {
      setState(() {
        final newText = currentController.text
            .substring(0, currentController.text.length - 1);
        currentController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      });
    }

    // Mantener el foco en el virtual keyboard
    Future.delayed(const Duration(milliseconds: 50), () {
      _keyboardFocus.requestFocus();
    });
  }

  void _handleSpace() {
    final currentController = _isPasswordField ? tcPassword : tcUsername;
    setState(() {
      final newText = '${currentController.text} ';
      currentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    });

    // Mantener el foco en el virtual keyboard
    Future.delayed(const Duration(milliseconds: 50), () {
      _keyboardFocus.requestFocus();
    });
  }

  void _handleLogin() {
    if (formKey.currentState?.validate() ?? false) {
      loginBloc.add(
        LoginEvent.login(tcUsername.text, tcPassword.text),
      );
    }
  }

  void _goToNextField() {
    setState(() {
      _isPasswordField = true;
    });
    _passwordFocus.requestFocus();
    Future.delayed(const Duration(milliseconds: 100), () {
      _keyboardFocus.requestFocus();
    });
  }

  void _goToPreviousField() {
    setState(() {
      _isPasswordField = false;
    });
    _usernameFocus.requestFocus();
    Future.delayed(const Duration(milliseconds: 100), () {
      _keyboardFocus.requestFocus();
    });
  }
}
