import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../main.dart';

class DilationPage extends ConsumerStatefulWidget {
  const DilationPage({super.key});

  @override
  ConsumerState<DilationPage> createState() => _DilationPageState();
}

class _DilationPageState extends ConsumerState<DilationPage> {
  final List<int> _targets = [3, 5, 8, 10];
  int _currentTargetIndex = 0;
  
  // Touch point variables
  Offset? _p1;
  Offset? _p2;
  double _measuredCm = 0.0;
  
  bool _isMatched = false;
  DateTime? _matchStartTime;
  double _holdingPercentage = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_p1 == null || _p2 == null) {
        setState(() {
          _isMatched = false;
          _matchStartTime = null;
          _holdingPercentage = 0.0;
        });
        return;
      }

      final target = _targets[_currentTargetIndex];
      final error = (_measuredCm - target).abs();
      
      if (error <= 0.35) {
        // Matched target
        if (!_isMatched) {
          _isMatched = true;
          _matchStartTime = DateTime.now();
        } else {
          final elapsedMs = DateTime.now().difference(_matchStartTime!).inMilliseconds;
          setState(() {
            _holdingPercentage = (elapsedMs / 1200.0).clamp(0.0, 1.0);
          });
          
          if (elapsedMs >= 1200) {
            _onTargetCompleted();
          }
        }
      } else {
        setState(() {
          _isMatched = false;
          _matchStartTime = null;
          _holdingPercentage = 0.0;
        });
      }
    });
  }

  void _onTargetCompleted() {
    ref.read(smartBirthStateProvider.notifier).addRewards(40, 15);
    
    setState(() {
      _p1 = null;
      _p2 = null;
      _isMatched = false;
      _matchStartTime = null;
      _holdingPercentage = 0.0;
      
      if (_currentTargetIndex < _targets.length - 1) {
        _currentTargetIndex++;
      } else {
        // Completed all targets!
        _timer?.cancel();
        _showSuccessDialog();
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('🌟 เควสสำเร็จ!', style: TextStyle(fontWeight: FontWeight.w900)),
          content: const Text('คุณประเมินระดับการกางนิ้วสัมผัสปากมดลูกได้ครบถ้วน ถูกต้องตามระยะและเกณฑ์มาตรฐาน'),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(smartBirthStateProvider.notifier).completeStage('stage4');
                ref.read(smartBirthStateProvider.notifier).updateDilationScore(100);
                Navigator.pop(context);
                context.go('/dashboard');
              },
              child: const Text('ตกลงกลับบอร์ดเกม'),
            ),
          ],
        );
      },
    );
  }

  void _calculateDistance() {
    if (_p1 == null || _p2 == null) {
      setState(() => _measuredCm = 0.0);
      return;
    }
    
    // Compute pixel distance and divide by typical device density scale
    final dx = _p2!.dx - _p1!.dx;
    final dy = _p2!.dy - _p1!.dy;
    final distPx = sqrt(dx * dx + dy * dy);
    
    setState(() {
      _measuredCm = (distPx / 38.0).clamp(0.0, 12.0); // assume 38px/cm cap 12cm
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetCm = _targets[_currentTargetIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ด่านที่ 4: เควสประเมินกางนิ้วสัมผัส', style: TextStyle(fontWeight: FontWeight.w900)),
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
                Text(
                  'เป้าหมาย: $targetCm ซม.',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: kPrimaryPink, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dilation Multitouch Panel Area
            NeobrutalistCard(
              padding: 0,
              child: Container(
                height: 340,
                width: double.infinity,
                color: kBgPrimary,
                child: Listener(
                  onPointerDown: (event) {
                    if (_p1 == null) {
                      setState(() => _p1 = event.localPosition);
                    } else if (_p2 == null) {
                      setState(() {
                        _p2 = event.localPosition;
                        _calculateDistance();
                      });
                    }
                  },
                  onPointerMove: (event) {
                    // Update whichever finger moves nearest
                    if (_p1 != null && _p2 != null) {
                      final dist1 = (event.localPosition - _p1!).distance;
                      final dist2 = (event.localPosition - _p2!).distance;
                      if (dist1 < dist2) {
                        setState(() {
                          _p1 = event.localPosition;
                          _calculateDistance();
                        });
                      } else {
                        setState(() {
                          _p2 = event.localPosition;
                          _calculateDistance();
                        });
                      }
                    }
                  },
                  onPointerUp: (event) {
                    setState(() {
                      _p1 = null;
                      _p2 = null;
                      _measuredCm = 0.0;
                    });
                  },
                  child: Stack(
                    children: [
                      // Cervix simulation canvas drawing
                      CustomPaint(
                        size: const Size(double.infinity, double.infinity),
                        painter: CervixCanvasPainter(
                          measuredCm: _measuredCm,
                          targetCm: targetCm,
                          p1: _p1,
                          p2: _p2,
                          isMatched: _isMatched,
                        ),
                      ),

                      // Dilation readouts widget
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kBgSecondary,
                            border: Border.all(color: kChocolateBrown, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ปากมดลูกเปิด', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              Text(
                                '${_measuredCm.toStringAsFixed(1)} ซม.',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Courier New'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Dilation Target progress widget
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kBgSecondary,
                            border: Border.all(color: kChocolateBrown, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('ล็อกค้างไว้: ${(_holdingPercentage * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Container(
                                width: 80,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: _holdingPercentage,
                                  child: Container(color: kSuccessGreen),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Progress badges bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _targets.asMap().entries.map((entry) {
                final idx = entry.key;
                final val = entry.value;
                final isDone = idx < _currentTargetIndex;
                final isActive = idx == _currentTargetIndex;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDone ? kSuccessGreen : (isActive ? kPrimaryPink : kBgSecondary),
                    border: Border.all(color: kChocolateBrown, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$val ซม.',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: (isDone || isActive) ? Colors.white : kTextSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class CervixCanvasPainter extends CustomPainter {
  final double measuredCm;
  final int targetCm;
  final Offset? p1;
  final Offset? p2;
  final bool isMatched;

  CervixCanvasPainter({
    required this.measuredCm,
    required this.targetCm,
    required this.p1,
    required this.p2,
    required this.isMatched,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const pixelsPerCm = 38.0;

    // Draw cervix tissues (outer area)
    final tissuePaint = Paint()
      ..color = const Color(0xFFEF9595).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final radiusPx = (measuredCm * pixelsPerCm) / 2;
    canvas.drawCircle(Offset(centerX, centerY), radiusPx + 20, tissuePaint);

    // Outer skin bounds border
    final tissueBorder = Paint()
      ..color = kChocolateBrown
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(centerX, centerY), radiusPx + 20, tissueBorder);

    // Inner open space orifice
    final orificePaint = Paint()
      ..color = kBgPrimary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), max(0, radiusPx), orificePaint);
    canvas.drawCircle(Offset(centerX, centerY), max(0, radiusPx), tissueBorder);

    // Target reference circle
    final targetPaint = Paint()
      ..color = isMatched ? kSuccessGreen.withOpacity(0.4) : kPrimaryPink.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(centerX, centerY), (targetCm * pixelsPerCm) / 2, targetPaint);

    // Draw finger pointers and connecting line ruler
    if (p1 != null && p2 != null) {
      final linePaint = Paint()
        ..color = isMatched ? kSuccessGreen : kPrimaryPink
        ..strokeWidth = 4;
      canvas.drawLine(p1!, p2!, linePaint);

      final fingerPaint = Paint()
        ..color = kPrimaryPink
        ..style = PaintingStyle.fill;
      final fingerBorder = Paint()
        ..color = kChocolateBrown
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      // Finger 1
      canvas.drawCircle(p1!, 18, fingerPaint);
      canvas.drawCircle(p1!, 18, fingerBorder);

      // Finger 2
      canvas.drawCircle(p2!, 18, fingerPaint);
      canvas.drawCircle(p2!, 18, fingerBorder);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
