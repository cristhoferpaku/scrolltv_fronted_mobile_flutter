// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/routes_manager.dart';

class LoginPage extends StatefulWidget {
 const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.backgroundDark,
      body: PlatformUtils.isTV ? _buildTVLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppPadding.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: AppSize.s60),
              
              // Logo
              _buildLogo(120),
              
              const SizedBox(height: AppSize.s40),
              
              // Formulario
              _buildLoginForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTVLayout() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(AppPadding.p24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSize.s20),
                  
                  // Logo más compacto para TV
                  _buildLogo(120),
                  
                  const SizedBox(height: AppSize.s16),
                  
                  // Título para TV
                  Text(
                    'ScrollTV',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: ColorManager.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: AppSize.s8),
                  
                  Text(
                    'Experiencia TV Premium',
                    style: TextStyle(
                      fontSize: 16,
                      color: ColorManager.lightHintColorText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: AppSize.s24),
                  
                  // Formulario
                  _buildLoginForm(),
                  
                  const SizedBox(height: AppSize.s20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            ColorManager.primary,
            ColorManager.primaryDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: size * 0.6,
          height: size * 0.6,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              PlatformUtils.isTV ? Icons.tv : Icons.movie,
              size: size * 0.5,
              color: ColorManager.white,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    final double formSpacing = PlatformUtils.isTV ? AppSize.s16 : AppSize.s24;
    final double buttonSpacing = PlatformUtils.isTV ? AppSize.s24 : AppSize.s40;
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label Cuenta
          Text(
            'Cuenta',
            style: TextStyle(
              color: ColorManager.white,
              fontSize: PlatformUtils.isTV ? 18 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSize.s8),
          
          // Campo Email
          _buildTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            hintText: 'Uisesxs31',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu email';
              }
              return null;
            },
          ),
          
          SizedBox(height: formSpacing),
          
          // Label Contraseña
          Text(
            'Contraseña',
            style: TextStyle(
              color: ColorManager.white,
              fontSize: PlatformUtils.isTV ? 18 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSize.s8),
          
          // Campo Password
          _buildTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            hintText: '••••••••••••',
            isPassword: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              return null;
            },
          ),
          
          SizedBox(height: buttonSpacing),
          
          // Login Button
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    FocusNode? focusNode,
    bool isPassword = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {
    final double fontSize = PlatformUtils.isTV ? 18 : 16;
    final double iconSize = PlatformUtils.isTV ? 24 : 20;
    final double padding = PlatformUtils.isTV ? AppPadding.p20 : AppPadding.p16;
    
    // Configuraciones específicas para TV
    final bool enableSuggestions = !PlatformUtils.isTV;
    final bool autocorrect = !PlatformUtils.isTV;
    
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.darkGray.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        validator: validator,
        enableSuggestions: enableSuggestions,
        autocorrect: autocorrect,
        textInputAction: textInputAction ?? TextInputAction.done,
        onFieldSubmitted: onFieldSubmitted,
        style: TextStyle(
          color: ColorManager.white,
          fontSize: fontSize,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: ColorManager.lightHintColorText.withOpacity(0.7),
            fontSize: fontSize,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: ColorManager.lightHintColorText,
                    size: iconSize,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: ColorManager.primary,
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: ColorManager.error,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: ColorManager.error,
              width: 1,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: padding,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final double buttonHeight = PlatformUtils.isTV ? 64 : 56;
    final double fontSize = PlatformUtils.isTV ? 18 : 16;
    final double loadingSize = PlatformUtils.isTV ? 24 : 20;
    
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primary,
          foregroundColor: ColorManager.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBackgroundColor: ColorManager.primary.withOpacity(0.6),
        ),
        child: _isLoading
            ? SizedBox(
                height: loadingSize,
                width: loadingSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(ColorManager.white),
                ),
              )
            : Text(
                'Ingresar',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }



  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simular proceso de login
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login exitoso!'),
          backgroundColor: ColorManager.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      // Navegar al home después del login exitoso
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.homeRoute,
        (route) => false,
      );
    }
  }
}