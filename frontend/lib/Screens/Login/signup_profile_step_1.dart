import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'signup_profile_shell.dart';
import 'signup_profile_step.dart';

class SignupProfileStepOne extends StatefulWidget {
  const SignupProfileStepOne({super.key});

  @override
  State<SignupProfileStepOne> createState() => _SignupProfileStepOneState();
}

class _SignupProfileStepOneState extends State<SignupProfileStepOne> {
  final _formKey = GlobalKey<FormState>();
  final _confirmFieldKey = GlobalKey<FormFieldState<String>>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _idController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _goToNext() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    FocusScope.of(context).unfocus();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignupProfileStep(
          username: _idController.text,
          password: _passwordController.text,
          name: _nameController.text,
          phone: _phoneController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignupProfileShell(
      title: 'Work flow 회원가입',
      subtitle: '기본 정보를 입력하고 다음 단계로 이동하세요.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SignupStepIndicator(current: 1, total: 2),
            const SizedBox(height: 24),
            _SignupTextField(
              controller: _idController,
              label: '아이디',
              hintText: '아이디를 입력해 주세요',
              textInputAction: TextInputAction.next,
              validator: _validateId,
            ),
            const SizedBox(height: 16),
            _SignupTextField(
              controller: _passwordController,
              label: '비밀번호',
              hintText: '영문, 숫자 조합 8자 이상',
              obscureText: true,
              validator: (value) => _validateMinLength(value, label: '비밀번호'),
            ),
            const SizedBox(height: 16),
            _SignupTextField(
              controller: _confirmController,
              fieldKey: _confirmFieldKey,
              label: '비밀번호 확인',
              hintText: '비밀번호를 다시 입력해 주세요',
              obscureText: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호 확인을 입력해 주세요';
                }
                if (value != _passwordController.text) {
                  return '비밀번호가 일치하지 않습니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _SignupTextField(
              controller: _nameController,
              label: '이름',
              hintText: '홍길동',
              textInputAction: TextInputAction.next,
              validator: (value) => _validateRequired(value, label: '이름'),
            ),
            const SizedBox(height: 16),
            _SignupTextField(
              controller: _phoneController,
              label: '전화번호',
              hintText: '01012345678',
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '전화번호를 입력해 주세요';
                }
                if (value.length < 9) {
                  return '올바른 전화번호를 입력해 주세요';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      bottomSection: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _goToNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: signupAccentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text('다음 단계'),
        ),
      ),
    );
  }

  void _onPasswordChanged() {
    _confirmFieldKey.currentState?.validate();
  }

  String? _validateId(String? value) {
    if (value == null || value.isEmpty) {
      return '아이디를 입력해 주세요';
    }
    if (value.contains(' ')) {
      return '아이디에는 공백을 사용할 수 없습니다';
    }
    if (value.length < 4) {
      return '아이디는 최소 4자 이상이어야 합니다';
    }
    return null;
  }

  String? _validateMinLength(String? value, {required String label, int min = 8}) {
    if (value == null || value.isEmpty) {
      return '$label를 입력해 주세요';
    }
    if (value.length < min) {
      return '$label는 최소 $min자 이상이어야 합니다';
    }
    return null;
  }

  String? _validateRequired(String? value, {required String label}) {
    if (value == null || value.isEmpty) {
      return '$label를 입력해 주세요';
    }
    return null;
  }
}

class _SignupTextField extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormFieldState<String>>? fieldKey;
  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final AutovalidateMode? autovalidateMode;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;

  const _SignupTextField({
    required this.controller,
    this.fieldKey,
    required this.label,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.autovalidateMode,
    this.inputFormatters,
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
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          validator: validator,
          autovalidateMode: autovalidateMode,
          inputFormatters: inputFormatters,
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
              borderSide: const BorderSide(color: signupAccentColor, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
