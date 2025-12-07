import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_bottom_nav_items.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

const Color _actionColor = Color(0xFF3C86C0);

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    final profileData = await AuthService.getUserProfile();
    if (profileData != null && mounted) {
      final profile = profileData['profile'];
      setState(() {
        _nameController.text = profile?['name'] ?? profileData['username'] ?? '';
        _weightController.text = profile?['weight']?.toString() ?? '';
        _heightController.text = profile?['height']?.toString() ?? '';
        _ageController.text = profile?['age']?.toString() ?? '';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _toggleEdit() async {
    if (_isEditing) {
      // 저장 로직
      FocusScope.of(context).unfocus();

      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final profileData = <String, dynamic>{};

      if (_nameController.text.isNotEmpty) {
        profileData['name'] = _nameController.text;
      }
      if (_weightController.text.isNotEmpty) {
        profileData['weight'] = double.tryParse(_weightController.text);
      }
      if (_heightController.text.isNotEmpty) {
        profileData['height'] = double.tryParse(_heightController.text);
      }
      if (_ageController.text.isNotEmpty) {
        profileData['age'] = int.tryParse(_ageController.text);
      }

      final success = await AuthService.updateUserProfile(profileData);

      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();

      if (success) {
        await _loadUserProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('사용자 정보가 저장되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('저장에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    setState(() => _isEditing = !_isEditing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomBottomNavBar(
          items: buildAppBottomNavItems(
            context,
            AppNavDestination.setting,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '설정',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _ProfileFieldCard(
                              label: '이름',
                              controller: _nameController,
                              enabled: _isEditing,
                            ),
                            const SizedBox(height: 14),
                            _ProfileFieldCard(
                              label: '몸무게 (kg)',
                              controller: _weightController,
                              enabled: _isEditing,
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                            ),
                            const SizedBox(height: 14),
                            _ProfileFieldCard(
                              label: '키 (cm)',
                              controller: _heightController,
                              enabled: _isEditing,
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                            ),
                            const SizedBox(height: 14),
                            _ProfileFieldCard(
                              label: '나이 (세)',
                              controller: _ageController,
                              enabled: _isEditing,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _toggleEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isEditing ? Colors.green : _actionColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(_isEditing ? '완료' : '수정'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '수정 후 완료 버튼을 눌러 저장해주세요.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ProfileFieldCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;

  const _ProfileFieldCard({
    required this.label,
    required this.controller,
    required this.enabled,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 16, 13, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: !enabled,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? const Color(0xFFF7F9FD) : Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: enabled ? const Color(0xFFE2E8F0) : Colors.transparent,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: enabled ? const Color(0xFFE2E8F0) : Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: enabled ? _actionColor : Colors.transparent,
                  width: enabled ? 1.2 : 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
