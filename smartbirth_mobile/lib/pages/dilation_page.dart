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
        final colors = Theme.of(context).extension<SmartBirthColors>() ?? warmColors;
        return AlertDialog(
          backgroundColor: colors.bgSecondary,
          title: Text(
            '🌟 เควสสำเร็จ!',
            style: TextStyle(fontWeight: FontWeight.w900, color: colors.chocolateBrown),
          ),
          content: Text(
            'คุณประเมินระดับการกางนิ้วสัมผัสปากมดลูกได้ครบถ้วน ถูกต้องตามระยะและเกณฑ์มาตรฐาน',
            style: TextStyle(color: colors.chocolateBrown, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(smartBirthStateProvider.notifier).completeStage('stage4');
                ref.read(smartBirthStateProvider.notifier).updateDilationScore(100);
                Navigator.pop(context);
                context.go('/dashboard');
              },
              child: Text(
                'ตกลงกลับบอร์ดเกม',
                style: TextStyle(color: colors.primaryPink, fontWeight: FontWeight.w900),
              ),
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
    final state = ref.watch(smartBirthStateProvider);
    final colors = Theme.of(context).extension<SmartBirthColors>() ?? warmColors;
    final targetCm = _targets[_currentTargetIndex];

    final headerTextSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ด่านที่ 4: แบบทดสอบกางนิ้วสัมผัสปากมดลูกจำลอง 🖐️',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: colors.chocolateBrown,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'วางนิ้วชี้และนิ้วกลางลงบนหน้าจอแล้วกางออก (ลากจุดสัมผัสสีส้มสองจุด) เพื่อจำลองและประเมินปากมดลูกเป้าหมาย',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: colors.textSecondary,
          ),
        ),
      ],
    );

    // Concurrency / Multitouch Canvas Panel
    final touchCanvasPanel = NeobrutalistCard(
      padding: 0,
      child: Container(
        height: 360,
        color: colors.bgPrimary,
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
              CustomPaint(
                size: const Size(double.infinity, double.infinity),
                painter: CervixCanvasPainter(
                  measuredCm: _measuredCm,
                  targetCm: targetCm,
                  p1: _p1,
                  p2: _p2,
                  isMatched: _isMatched,
                  colors: colors,
                ),
              ),

              // Left Dilation Readout
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.bgSecondary,
                    border: Border.all(color: colors.chocolateBrown, width: 2.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ขนาดเปิดที่กางได้',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _measuredCm.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              color: colors.chocolateBrown,
                              fontFamily: 'Courier New',
                            ),
                          ),
                          Text(
                            ' ซม.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: colors.chocolateBrown,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Right Lock Target State
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.bgSecondary,
                    border: Border.all(color: colors.chocolateBrown, width: 2.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'กางนิ้วค้างไว้: ${(_holdingPercentage * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 90,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors.bgTertiary,
                          border: Border.all(color: colors.chocolateBrown, width: 1.5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: _holdingPercentage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: colors.successGreen,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
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
    );

    // Right Sidebar / Instructions
    final sidebarPanel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Target progress badges
        NeobrutalistCard(
          backgroundColor: colors.bgSecondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🏆 ความก้าวหน้าเป้าหมาย',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: colors.chocolateBrown),
              ),
              const SizedBox(height: 4),
              Text(
                'ฝึกกางนิ้วมือให้ตรงกับระยะเป้าหมายทั้ง 4 ขนาด:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.textSecondary),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _targets.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final val = entry.value;
                  final isDone = idx < _currentTargetIndex;
                  final isActive = idx == _currentTargetIndex;

                  Color itemBg = colors.bgSecondary;
                  Color itemText = colors.textSecondary;

                  if (isDone) {
                    itemBg = colors.successGreen;
                    itemText = Colors.white;
                  } else if (isActive) {
                    itemBg = colors.primaryPink;
                    itemText = Colors.white;
                  }

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: itemBg,
                        border: Border.all(color: colors.chocolateBrown, width: 2.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$val ซม.',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: itemText,
                          fontFamily: 'Courier New',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Visual eye reference list
        NeobrutalistCard(
          backgroundColor: colors.bgTertiary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🔍 เกณฑ์เปรียบเทียบระยะเปิดด้วยสายตา',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: colors.chocolateBrown),
              ),
              const SizedBox(height: 2),
              Text(
                'จำลองความรู้สึกและขนาดเปรียบเทียบเทียบ:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.textSecondary),
              ),
              const SizedBox(height: 12),
              _buildRefRow('⚫', '1 ซม. (เม็ดซีเรียลกลมเล็ก)', colors),
              const SizedBox(height: 8),
              _buildRefRow('🪙', '3 ซม. (ขนาดเหรียญ 10 บาท)', colors),
              const SizedBox(height: 8),
              _buildRefRow('🍋', '5 ซม. (มะนาวฝานซีก)', colors),
              const SizedBox(height: 8),
              _buildRefRow('🥫', '8 ซม. (ขอบปากกระป๋องน้ำ)', colors),
              const SizedBox(height: 8),
              _buildRefRow('🥯', '10 ซม. (ขนมปังเบเกิล / เปิดหมด)', colors),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('ด่านที่ 4: เควสประเมินกางนิ้วสัมผัส', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: colors.bgSecondary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NeobrutalistButton(
                  onTap: () => context.go('/dashboard'),
                  child: Text(
                    '🏠 กลับหน้าหลัก',
                    style: TextStyle(fontWeight: FontWeight.w900, color: colors.chocolateBrown),
                  ),
                ),
                Text(
                  'เป้าหมาย: $targetCm ซม.',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: colors.primaryPink,
                    fontSize: 18,
                    fontFamily: 'Courier New',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            headerTextSection,
            const SizedBox(height: 24),

            ResponsiveLayout(
              mobile: Column(
                children: [
                  touchCanvasPanel,
                  const SizedBox(height: 24),
                  sidebarPanel,
                ],
              ),
              tablet: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 11, child: touchCanvasPanel),
                  const SizedBox(width: 20),
                  Expanded(flex: 10, child: sidebarPanel),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 12, child: touchCanvasPanel),
                  const SizedBox(width: 24),
                  Expanded(flex: 10, child: sidebarPanel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefRow(String icon, String label, SmartBirthColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        border: Border.all(color: colors.chocolateBrown, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: colors.chocolateBrown,
              ),
            ),
          ),
        ],
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
  final SmartBirthColors colors;

  CervixCanvasPainter({
    required this.measuredCm,
    required this.targetCm,
    required this.p1,
    required this.p2,
    required this.isMatched,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const pixelsPerCm = 38.0;

    // Draw cervix tissues (outer area)
    final tissuePaint = Paint()
      ..color = const Color(0xFFEF9595).withOpacity(0.35)
      ..style = PaintingStyle.fill;
    
    final radiusPx = (measuredCm * pixelsPerCm) / 2;
    canvas.drawCircle(Offset(centerX, centerY), radiusPx + 20, tissuePaint);

    // Outer skin bounds border
    final tissueBorder = Paint()
      ..color = colors.chocolateBrown
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(centerX, centerY), radiusPx + 20, tissueBorder);

    // Inner open space orifice
    final orificePaint = Paint()
      ..color = colors.bgPrimary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), max(0, radiusPx), orificePaint);
    canvas.drawCircle(Offset(centerX, centerY), max(0, radiusPx), tissueBorder);

    // Target reference circle
    final targetPaint = Paint()
      ..color = isMatched ? colors.successGreen.withOpacity(0.5) : colors.primaryPink.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(centerX, centerY), (targetCm * pixelsPerCm) / 2, targetPaint);

    // Coins reference helper at 3cm
    if (targetCm == 3) {
      final coinPaint = Paint()
        ..color = Colors.amber.withOpacity(0.08)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(centerX, centerY), (3 * pixelsPerCm) / 2, coinPaint);

      final coinBorder = Paint()
        ..color = Colors.amber.withOpacity(0.4)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      _drawDashedCircle(canvas, Offset(centerX, centerY), (3 * pixelsPerCm) / 2, coinBorder);
    }

    // Draw finger pointers and connecting line ruler
    if (p1 != null && p2 != null) {
      final linePaint = Paint()
        ..color = isMatched ? colors.successGreen : colors.primaryPink
        ..strokeWidth = 4;
      canvas.drawLine(p1!, p2!, linePaint);

      final fingerPaint = Paint()
        ..color = colors.primaryPink
        ..style = PaintingStyle.fill;
      final fingerBorder = Paint()
        ..color = colors.chocolateBrown
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      // Finger 1
      canvas.drawCircle(p1!, 18, fingerPaint);
      canvas.drawCircle(p1!, 18, fingerBorder);

      // Finger 2
      canvas.drawCircle(p2!, 18, fingerPaint);
      canvas.drawCircle(p2!, 18, fingerBorder);

      // Mid-point measurement overlay text box
      final midX = (p1!.dx + p2!.dx) / 2;
      final midY = (p1!.dy + p2!.dy) / 2;

      final textBgPaint = Paint()
        ..color = colors.bgSecondary
        ..style = PaintingStyle.fill;
      final textBorderPaint = Paint()
        ..color = colors.chocolateBrown
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      final rect = Rect.fromCenter(center: Offset(midX, midY), width: 72, height: 28);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), textBgPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), textBorderPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${measuredCm.toStringAsFixed(1)} ซม.',
          style: TextStyle(
            color: colors.chocolateBrown,
            fontSize: 11,
            fontFamily: 'Courier New',
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(midX - textPainter.width / 2, midY - textPainter.height / 2));
    }
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const double dashWidth = 5.0;
    const double dashSpace = 4.0;
    double startAngle = 0.0;
    final double perimeter = 2 * pi * radius;
    final int dashCount = (perimeter / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final double angle = startAngle + (i * (dashWidth + dashSpace) / radius);
      final double sweep = dashWidth / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CervixCanvasPainter oldDelegate) =>
      oldDelegate.measuredCm != measuredCm ||
      oldDelegate.targetCm != targetCm ||
      oldDelegate.p1 != p1 ||
      oldDelegate.p2 != p2 ||
      oldDelegate.isMatched != isMatched ||
      oldDelegate.colors != colors;
}
