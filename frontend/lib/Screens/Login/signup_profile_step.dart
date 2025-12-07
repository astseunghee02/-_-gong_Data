import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'signup_profile_shell.dart';

enum Gender { male, female, other }

class SignupProfileStep extends StatefulWidget {
  final String username;
  final String password;
  final String name;
  final String phone;

  const SignupProfileStep({
    super.key,
    required this.username,
    required this.password,
    required this.name,
    required this.phone,
  });

  @override
  State<SignupProfileStep> createState() => _SignupProfileStepState();
}

class _SignupProfileStepState extends State<SignupProfileStep> {
  Gender _selectedGender = Gender.female;
  final TextEditingController _ageController =
      TextEditingController(text: '25');
  final TextEditingController _weightController =
      TextEditingController(text: '60');
  final TextEditingController _heightController =
      TextEditingController(text: '165');

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    final age = int.tryParse(_ageController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;

    if (age <= 0 || weight <= 0 || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 정보를 올바르게 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('서버 주소가 설정되지 않았습니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': widget.username,
          'email': '${widget.username}@work-flow.com',
          'password': widget.password,
        }),
      );

      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final registerData = json.decode(response.body);
        final accessToken = registerData['tokens']['access'];

        debugPrint('회원가입 성공!');

        // 프로필 정보 업데이트
        final profileResponse = await http.post(
          Uri.parse('$baseUrl/api/auth/profile/update/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: json.encode({
            'name': widget.name,
            'phone': widget.phone,
            'age': age,
            'gender': _selectedGender.toString().split('.').last,
            'weight': weight,
            'height': height,
          }),
        );

        debugPrint('프로필 업데이트 상태: ${profileResponse.statusCode}');
        debugPrint('이름: ${widget.name}');
        debugPrint('전화번호: ${widget.phone}');
        debugPrint('성별: $_selectedGender');
        debugPrint('나이: $age');
        debugPrint('몸무게: $weight');
        debugPrint('키: $height');

        // 회원가입 완료 안내
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              '회원가입 완료',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: signupAccentColor,
              ),
            ),
            content: const Text(
              '회원가입이 완료되었습니다!\n로그인 화면으로 이동합니다.',
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                },
                child: const Text(
                  '확인',
                  style: TextStyle(
                    color: signupAccentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입 실패: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();

      debugPrint('회원가입 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('서버 연결 실패: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SignupProfileShell(
      title: '프로필을 완성해주세요',
      subtitle: '나이, 신체 정보 등을 입력하면 맞춤형 추천을 받을 수 있어요.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SignupStepIndicator(current: 2, total: 2),
          const SizedBox(height: 24),
          const Text(
            '성별을 선택해주세요',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GenderCard(
                  label: '남성',
                  icon: Icons.male,
                  isSelected: _selectedGender == Gender.male,
                  onTap: () => setState(() => _selectedGender = Gender.male),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GenderCard(
                  label: '여성',
                  icon: Icons.female,
                  isSelected: _selectedGender == Gender.female,
                  onTap: () => setState(() => _selectedGender = Gender.female),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GenderCard(
                  label: '기타',
                  isSelected: _selectedGender == Gender.other,
                  showLabelBelow: false,
                  onTap: () => setState(() => _selectedGender = Gender.other),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _ProfileInputCard(
            title: '나이를 알려주세요',
            controller: _ageController,
            suffixText: '세',
            hintText: '25',
          ),
          const SizedBox(height: 18),
          _ProfileInputCard(
            title: '몸무게를 알려주세요',
            controller: _weightController,
            suffixText: 'kg',
            hintText: '60',
          ),
          const SizedBox(height: 18),
          _ProfileInputCard(
            title: '키를 알려주세요',
            controller: _heightController,
            suffixText: 'cm',
            hintText: '165',
          ),
        ],
      ),
      bottomSection: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: TextButton.styleFrom(
                foregroundColor: signupAccentColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('뒤로가기'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: signupAccentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('다음'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final bool showLabelBelow;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    this.icon,
    required this.isSelected,
    this.showLabelBelow = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? signupAccentColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? signupAccentColor : const Color(0xFFE2E8F0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: signupAccentColor.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: isSelected ? Colors.white : signupAccentColor,
                size: 32,
              )
            else
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            if (showLabelBelow) ...[
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileInputCard extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String suffixText;
  final String hintText;

  const _ProfileInputCard({
    required this.title,
    required this.controller,
    required this.suffixText,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: InputDecoration(
              hintText: hintText,
              suffixText: suffixText,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: signupAccentColor, width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
