import 'package:flutter/material.dart';

const Color signupAccentColor = Color(0xFF3C86C0);

class SignupProfileShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget bottomSection;

  const SignupProfileShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.bottomSection,
  });

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 16),
              const SignupProfileHero(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
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
                            color: signupAccentColor,
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
                        const SizedBox(height: 28),
                        child,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: bottomSection,
              ),
              SizedBox(height: padding.bottom > 16 ? padding.bottom : 16),
            ],
          ),
        ),
      ),
    );
  }

}

class SignupProfileHero extends StatelessWidget {
  const SignupProfileHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          'Fit Mate',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: signupAccentColor,
          ),
        ),
      ],
    );
  }
}

class SignupStepIndicator extends StatelessWidget {
  final int current;
  final int total;

  const SignupStepIndicator({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : current / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$current / $total 단계',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFFE7EEF5),
            valueColor: const AlwaysStoppedAnimation<Color>(signupAccentColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
