import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../services/pedometer_service.dart';
import '../../widgets/app_bottom_nav_items.dart';
import '../../widgets/community_sections.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final PedometerService _pedometerService = PedometerService();
  StreamSubscription<int>? _stepsSubscription;

  int _steps = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPedometer();
  }

  Future<void> _initPedometer() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final started = await _pedometerService.startTracking();
    if (!started) {
      setState(() {
        _isLoading = false;
        _error = '만보기 권한을 허용해주세요.';
      });
      return;
    }

    _stepsSubscription = _pedometerService.stepsStream.listen((value) {
      setState(() {
        _steps = value;
      });
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _stepsSubscription?.cancel();
    _pedometerService.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calories = (_steps * 0.04).toStringAsFixed(1); // 대략 칼로리 추정
    final distanceKm = (_steps * 0.00075).toStringAsFixed(2); // 평균 보폭 0.75m 가정

    return Scaffold(
      backgroundColor: AppColors.background,
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
                  '운동 리포트',
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
                  children: [
                    const _DateSelector(),
                    const SizedBox(height: 16),
                    const _MapPreviewCard(),
                    const SizedBox(height: 16),
                    _StepCountSection(
                      steps: _steps,
                      isLoading: _isLoading,
                      error: _error,
                      onRefresh: _initPedometer,
                    ),
                    const SizedBox(height: 16),
                    _SummaryStatsRow(
                      calories: calories,
                      distance: distanceKm,
                    ),
                    const SizedBox(height: 24),
                    const _ExerciseLevelSection(),
                    const SizedBox(height: 80 / 3),
                    const _StatusFitnessComparisonSection(),
                    const SizedBox(height: 24),
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
    final picked = await showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _CustomDatePickerDialog(
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2035),
      ),
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

class _CustomDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _CustomDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_CustomDatePickerDialog> createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<_CustomDatePickerDialog> {
  static const Color accentColor = Color(0xFF3C86C0);
  late DateTime _tempSelectedDate = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '날짜 선택',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Theme(
                data: theme.copyWith(
                  colorScheme: theme.colorScheme.copyWith(
                    primary: accentColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
                  textTheme: theme.textTheme.apply(
                    bodyColor: Colors.black87,
                    displayColor: Colors.black87,
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: _tempSelectedDate,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onDateChanged: (date) {
                    setState(() {
                      _tempSelectedDate = date;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black54,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_tempSelectedDate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
  final int steps;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;

  const _StepCountSection({
    required this.steps,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (isLoading) {
      content = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (error != null) {
      content = Column(
        children: [
          const Icon(Icons.info_outline, color: Colors.redAccent, size: 28),
          const SizedBox(height: 6),
          Text(
            error!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: onRefresh,
            child: const Text('다시 시도'),
          ),
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$steps',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            '걸음 수',
            style: TextStyle(
              fontSize: 17,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Center(child: content);
  }
}

class _SummaryStatsRow extends StatelessWidget {
  final String calories;
  final String distance;

  const _SummaryStatsRow({
    required this.calories,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SummaryItem(label: '소모 칼로리', value: '$calories kcal'),
        const SizedBox(width: 16),
        const _SummaryItem(label: '운동 시간', value: '알 수 없음'),
        const SizedBox(width: 16),
        _SummaryItem(label: '이동 거리', value: '${distance}km'),
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
            fontSize: 13,
            color: Colors.black45,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
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
      ),
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
        border: Border.all(color: const Color(0xFFE0E0E0)),
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

class _StatusFitnessComparisonSection extends StatelessWidget {
  const _StatusFitnessComparisonSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const FitnessComparisonBlock(
        data: defaultFitnessComparison,
      ),
    );
  }
}
