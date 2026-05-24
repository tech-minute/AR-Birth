import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../main.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  int _progress = 0;
  String _loadingText = "กำลังโหลดเครื่องมือจำลอง...";
  Timer? _timer;

  final List<String> _loadingSteps = [
    "กำลังเชื่อมต่อระบบประสาทสัมผัส...",
    "กำลังจำลองโมเดลอุ้งเชิงกราน 3 มิติ...",
    "กำลังจำลองระดับพิกัดแล็บ AR...",
    "กำลังจัดเตรียมชุดเช็คลิสต์เครื่องมือ...",
    "ระบบจำลองพร้อมสำหรับการทดสอบแล้ว!"
  ];

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        _progress += 2;
        final stepIdx = (_progress / 20).floor().clamp(0, _loadingSteps.length - 1);
        _loadingText = "${_loadingSteps[stepIdx]} $_progress%";
        
        if (_progress >= 100) {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kBgPrimary, Color(0xFFFFEEF2), kBgTertiary],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: NeobrutalistCard(
              backgroundColor: kBgSecondary,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main pregnancy Twemoji icon
                  Image.network(
                    'https://img.icons8.com/color/256/pregnant.png',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SmartBirth Quest',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
                      color: kChocolateBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'โปรแกรมเตรียมความพร้อมสูติศาสตร์ (Pre-VR)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: kTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  if (_progress < 100) ...[
                    // Progress Bar
                    Container(
                      width: 250,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: kChocolateBrown, width: 2.5),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _progress / 100.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: kPrimaryPink,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _loadingText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: kTextSecondary,
                      ),
                    ),
                  ] else ...[
                    // Play Button
                    NeobrutalistButton(
                      backgroundColor: kPrimaryPink,
                      onTap: () {
                        ref.read(smartBirthStateProvider.notifier).addRewards(30, 10);
                        context.go('/dashboard');
                      },
                      child: const Text(
                        '🚀 เริ่มทำเควสฝึกฝน',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
