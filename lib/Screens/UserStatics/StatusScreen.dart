import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/app_bottom_nav_items.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomBottomNavBar(
          items: buildAppBottomNavItems(
            context,
            AppNavDestination.user,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '나의 상태',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _CharacterStatusCard(),
                    SizedBox(height: 16),
                    _DateSelector(),
                    SizedBox(height: 16),
                    _MapPreviewCard(),
                    SizedBox(height: 16),
                    _StepCountSection(),
                    SizedBox(height: 16),
                    _SummaryStatsRow(),
                    SizedBox(height: 24),
                    _ExerciseLevelSection(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterStatusCard extends StatelessWidget {
  const _CharacterStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  '탱구리님의 상태',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _InfoColumn(label: '키', value: '178 cm'),
                    SizedBox(width: 12),
                    _InfoColumn(label: '몸무게', value: '70 kg'),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    _InfoColumn(label: '체지방', value: '65%'),
                    SizedBox(width: 12),
                    _InfoColumn(label: '레벨', value: 'Lv.3'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/pori.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;

  const _InfoColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black45,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DateSelector extends StatefulWidget {
  const _DateSelector();

  @override
  State<_DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<_DateSelector> {
  static const Color primaryBlue = Color(0xFF3C86C0);
  DateTime _selectedDate = DateTime.now();

  void _changeDay(int delta) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: delta));
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatSelectedDate() {
    const weekdayNames = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final weekdayLabel = weekdayNames[_selectedDate.weekday - 1];
    return '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일 $weekdayLabel';
  }

  Widget _arrowButton({required bool isPrevious}) {
    return GestureDetector(
      onTap: () => _changeDay(isPrevious ? -1 : 1),
      child: Transform.rotate(
        angle: isPrevious ? math.pi : 0,
        child: SvgPicture.asset(
          'assets/images/next.svg',
          width: 14,
          height: 14,
          colorFilter: const ColorFilter.mode(primaryBlue, BlendMode.srcIn),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _arrowButton(isPrevious: true),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  _formatSelectedDate(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 16),
              _arrowButton(isPrevious: false),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _pickDate,
          child: SvgPicture.asset(
            'assets/images/calender.svg',
            width: 16.8,
            height: 16.8,
            colorFilter: const ColorFilter.mode(primaryBlue, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      alignment: Alignment.center,
      child: const Text(
        '사용자 이동 경로 표시 예정',
        style: TextStyle(
          fontSize: 14,
          color: Colors.black54,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _StepCountSection extends StatelessWidget {
  const _StepCountSection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text(
            '4880',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            '걸음 수',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SummaryStatsRow extends StatelessWidget {
  const _SummaryStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _SummaryItem(label: '소모 칼로리', value: '480kcal'),
        SizedBox(width: 16),
        _SummaryItem(label: '운동 시간', value: '24:06'),
        SizedBox(width: 16),
        _SummaryItem(label: '이동 거리', value: '4.84km'),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black45,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ExerciseLevelSection extends StatelessWidget {
  const _ExerciseLevelSection();

  @override
  Widget build(BuildContext context) {
    const Color blue = Color(0xFF3C86C0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '오늘의 운동 정도',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: CircularProgressIndicator(
                      value: 0.78,
                      strokeWidth: 10,
                      backgroundColor: const Color(0xFFE5E9F2),
                      valueColor: const AlwaysStoppedAnimation<Color>(blue),
                    ),
                  ),
                  const Text(
                    '78점',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: const [
                  _ExerciseCard(
                    title: '동일 연령대 평균 대비 운동량',
                    value: '+12%',
                  ),
                  SizedBox(height: 8),
                  _ExerciseCard(
                    title: '오늘 활동 난이도',
                    value: '중간',
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final String title;
  final String value;

  const _ExerciseCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    const Color blue = Color(0xFF3C86C0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: blue,
            ),
          ),
        ],
      ),
    );
  }
}
