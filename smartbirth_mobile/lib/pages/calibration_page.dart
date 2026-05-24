import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../main.dart';

class CalibrationPage extends ConsumerStatefulWidget {
  const CalibrationPage({super.key});

  @override
  ConsumerState<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends ConsumerState<CalibrationPage> {
  bool _isCalibrated = false;
  bool _isCalibrating = false;
  double _calibrationProgress = 0.0;
  String _statusText = "กรุณาเล็งกล้องไปที่พื้นราบ...";
  Timer? _timer;

  void _startCalibration() {
    if (_isCalibrating || _isCalibrated) return;
    
    setState(() {
      _isCalibrating = true;
      _statusText = "กำลังสแกนหาพื้นผิวราบ...";
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _calibrationProgress += 0.05;
        if (_calibrationProgress >= 1.0) {
          _timer?.cancel();
          _isCalibrating = false;
          _isCalibrated = true;
          _statusText = "ปรับเทียบพิกัดราบสำเร็จ! แนะนำการวางมือทำคลอดพร้อมแล้ว";
          ref.read(smartBirthStateProvider.notifier).addRewards(150, 60);
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
      appBar: AppBar(
        title: const Text('ด่านที่ 3: ปรับเทียบพิกัดกล้อง AR', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: kBgSecondary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NeobrutalistButton(
                  onTap: () => context.go('/dashboard'),
                  child: const Text('🏠 กลับหน้าหลัก'),
                ),
                NeobrutalistButton(
                  backgroundColor: _isCalibrated ? kSuccessGreen : Colors.grey.shade400,
                  onTap: _isCalibrated
                      ? () {
                          ref.read(smartBirthStateProvider.notifier).completeStage('stage3');
                          context.go('/dashboard');
                        }
                      : () {},
                  child: const Text('ส่งงานด่าน 3', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Camera Simulation Box
            NeobrutalistCard(
              padding: 0,
              child: Container(
                height: 320,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Mock Scan Reticle Target
                    if (!_isCalibrated && !_isCalibrating)
                      GestureDetector(
                        onTap: _startCalibration,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: kPrimaryPink, width: 4),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Text('🎯', style: TextStyle(fontSize: 32)),
                        ),
                      ),

                    // Loading overlay calibration
                    if (_isCalibrating)
                      Container(
                        color: Colors.black.withOpacity(0.4),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'กำลังคำนวณตำแหน่ง 3D Grid...',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(value: _calibrationProgress, color: kPrimaryPink),
                            const SizedBox(height: 8),
                            Text(
                              '${(_calibrationProgress * 100).toInt()}%',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                    // Calibrated placement
                    if (_isCalibrated) ...[
                      // Simulated neon pelvis lines
                      CustomPaint(
                        size: const Size(double.infinity, double.infinity),
                        painter: ARGuidePainter(),
                      ),
                      const Positioned(
                        bottom: 12,
                        child: Text(
                          '🟢 วางตำแหน่งกระดูกเชิงกรานจำลองแล้ว',
                          style: TextStyle(fontWeight: FontWeight.w900, color: kChocolateBrown, fontSize: 13),
                        ),
                      ),
                    ],

                    // Top Banner message toast
                    Positioned(
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kBgSecondary,
                          border: Border.all(color: kChocolateBrown, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusText,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: kChocolateBrown),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Instructions text card
            NeobrutalistCard(
              backgroundColor: kBgTertiary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('🖐️ ทฤษฎีประคองบ่าเด็ก Ritgen Maneuver', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  SizedBox(height: 8),
                  Text(
                    '1. มือข้างถนัด (ด้านล่าง): สวมผ้าสะอาดรองดันบริเวณขอบแผลฝีเย็บเพื่อยึดและกระจายแรงต้านตึง\n2. มืออีกข้าง (ด้านบน): วางแตะต้านท้ายทอยทารกคอยควบคุมมุมในการเงยหัวเด็ก ป้องกันการสะบัดหน้าเงยรวดเร็วอันทำให้ฝีเย็บของมารดาฉีกขาดลึก',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kTextSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple painter to sketch pelvis/guides lines
class ARGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kAccentBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw central ellipse pelvis boundary ring
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: 140, height: 90),
      paint,
    );

    // Draw fetal head sketch
    final paintHead = Paint()
      ..color = kPrimaryPink
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: 70, height: 75),
      paintHead,
    );

    // Draw suture lines
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2 - 37.5),
      Offset(size.width / 2, size.height / 2 + 37.5),
      paintHead,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
