import 'package:flutter/material.dart';

import 'signup_profile_shell.dart';

enum Gender { male, female, other }

class SignupProfileStep extends StatefulWidget {
  const SignupProfileStep({super.key});

  @override
  State<SignupProfileStep> createState() => _SignupProfileStepState();
}

class _SignupProfileStepState extends State<SignupProfileStep> {
  Gender _selectedGender = Gender.female;
  double _age = 25;
  double _weight = 60;
  double _height = 165;

  void _handleNext() {
    debugPrint('선택한 성별: $_selectedGender');
    debugPrint('나이: ${_age.round()}');
    debugPrint('몸무게: ${_weight.round()}');
    debugPrint('키: ${_height.round()}');
    // TODO: 다음 단계로 이동하거나 서버 연동 로직을 연결하세요.
  }

  @override
  Widget build(BuildContext context) {
    return SignupProfileShell(
      title: '프로필을 완성해 주세요',
      subtitle: '나이, 신체 정보를 입력하면 맞춤형 플랜을 준비해 드릴게요.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SignupStepIndicator(current: 2, total: 2),
          const SizedBox(height: 24),
          const Text(
            '성별을 선택해 주세요',
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
          _ProfileSliderCard(
            title: '나이를 알려주세요',
            valueLabel: '${_age.round()} 세',
            value: _age,
            min: 10,
            max: 100,
            onChanged: (value) => setState(() => _age = value),
          ),
          const SizedBox(height: 18),
          _ProfileSliderCard(
            title: '몸무게를 알려주세요',
            valueLabel: '${_weight.round()} kg',
            value: _weight,
            min: 30,
            max: 200,
            onChanged: (value) => setState(() => _weight = value),
          ),
          const SizedBox(height: 18),
          _ProfileSliderCard(
            title: '키를 알려주세요',
            valueLabel: '${_height.round()} cm',
            value: _height,
            min: 120,
            max: 220,
            onChanged: (value) => setState(() => _height = value),
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
              child: const Text('돌아가기'),
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
              child: const Text('완료'),
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

class _ProfileSliderCard extends StatelessWidget {
  final String title;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _ProfileSliderCard({
    required this.title,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
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
          const SizedBox(height: 8),
          Text(
            valueLabel,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: signupAccentColor,
              inactiveTrackColor: const Color(0xFFE3ECF7),
              thumbColor: Colors.white,
              overlayColor: signupAccentColor.withOpacity(0.15),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                min.toInt().toString(),
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
              Text(
                max.toInt().toString(),
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
