import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../Home/home_screen.dart';
import 'signup_profile_step_1.dart';
import 'signup_profile_step.dart';

const _accentColor = Color(0xFF3C86C0);
const _accentDark = Color(0xFF3C86C0);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    FocusScope.of(context).unfocus();
    _goToHome();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenLayout(
      title: '다시 만나서 반가워요',
      subtitle: '핏 메이트와 함께 오늘 하루를 시작해볼까요?',
      bottomAction: _AuthBottomAction(
        label: '계정이 필요하신가요?',
        actionLabel: '회원가입',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SignupProfileStepOne()),
          );
        },
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AuthTextField(
              controller: _emailController,
              label: '이메일 주소',
              hintText: '예: 사용자@fitmate.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            _AuthTextField(
              controller: _passwordController,
              label: '비밀번호',
              hintText: '********',
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: (value) => _validateRequired(value, '비밀번호'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) =>
                              setState(() => _rememberMe = value ?? false),
                          activeColor: _accentColor,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '로그인 상태 유지',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('로그인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthScreenLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget bottomAction;

  const AuthScreenLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.bottomAction,
  });

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Container(
          color: AppColors.background,
          child: Column(
            children: [
              const SizedBox(height: 16),
              const _AuthHero(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 28,
                          offset: Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: _accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        child,
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.center,
                          child: bottomAction,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: padding.bottom > 16 ? padding.bottom : 16),
            ],
          ),
        ),
      ),
    );
  }
}
class _AuthHero extends StatelessWidget {
  const _AuthHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          'Fit Mate',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _accentColor,
          ),
        ),
      ],
    );
  }
}

class _AuthBottomAction extends StatelessWidget {
  final String label;
  final String actionLabel;
  final VoidCallback onTap;

  const _AuthBottomAction({
    required this.label,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionLabel,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _accentDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFF7F9FD),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _accentColor, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return '이메일을 입력해주세요';
  }
  final emailRegex = RegExp(r'^.+@.+\..+$');
  if (!emailRegex.hasMatch(value)) {
    return '올바른 이메일 형식을 입력해주세요';
  }
  return null;
}

String? _validateRequired(String? value, String label) {
  if (value == null || value.isEmpty) {
    return '$label 입력이 필요해요';
  }
  return null;
}

String? _validateMinLength(String? value, String label, {int min = 8}) {
  if (value == null || value.isEmpty) {
    return '$label 입력이 필요해요';
  }
  if (value.length < min) {
    return '$label 최소 $min자 이상 입력해주세요';
  }
  return null;
}
