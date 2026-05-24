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
  String _statusText = "กำลังสแกนหาพื้นราบ...";
  Timer? _timer;

  void _startCalibration() {
    if (_isCalibrating || _isCalibrated) return;

    setState(() {
      _isCalibrating = true;
      _statusText = "กำลังสแกนระนาบและล็อกพิกัด...";
      _calibrationProgress = 0.0;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      setState(() {
        _calibrationProgress += 0.05;
        if (_calibrationProgress >= 1.0) {
          _timer?.cancel();
          _isCalibrating = false;
          _isCalibrated = true;
          _statusText = "ปรับเทียบพิกัดสำเร็จ ด่านประคองการวางมือทำคลอดพร้อมเรียนรู้!";
          ref.read(smartBirthStateProvider.notifier).addRewards(150, 40);
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
    final state = ref.watch(smartBirthStateProvider);
    final colors = Theme.of(context).extension<SmartBirthColors>() ?? warmColors;

    final headerTextSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ด่านที่ 3: ปรับเทียบพื้นที่จำลองห้องแล็บ AR 📷',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: colors.chocolateBrown,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'กรุณาสแกนพื้นที่ราบรอบตัวคุณ และทำการปรับเทียบตำแหน่งทางพิกัดเพื่อแสดงท่าประคองและวางมือทำคลอดเสมือนจริง',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: colors.textSecondary,
          ),
        ),
      ],
    );

    final arViewportPanel = NeobrutalistCard(
      padding: 0,
      child: Container(
        height: 380,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.bgTertiary, colors.bgPrimary],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer status toast overlay
            Positioned(
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.bgSecondary,
                  border: Border.all(color: colors.chocolateBrown, width: 2.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isCalibrated ? Icons.check_circle : Icons.sensors_rounded,
                      size: 16,
                      color: _isCalibrated ? colors.successGreen : colors.primaryPink,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _statusText,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: colors.chocolateBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Target scan reticle icon
            if (!_isCalibrated && !_isCalibrating)
              GestureDetector(
                onTap: _startCalibration,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: colors.bgSecondary.withOpacity(0.9),
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.primaryPink, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: colors.chocolateBrown,
                        offset: const Offset(3, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '🎯',
                    style: TextStyle(fontSize: 34, color: colors.primaryPink),
                  ),
                ),
              ),

            // Scanning progress overlay
            if (_isCalibrating)
              Container(
                color: colors.chocolateBrown.withOpacity(0.15),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'กำลังปรับเทียบพิกัดราบ...',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: colors.chocolateBrown,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: 200,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors.bgSecondary,
                        border: Border.all(color: colors.chocolateBrown, width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _calibrationProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.primaryPink,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_calibrationProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Courier New',
                        color: colors.chocolateBrown,
                      ),
                    ),
                  ],
                ),
              ),

            // Pelvis model guide overlay
            if (_isCalibrated)
              Positioned.fill(
                child: CustomPaint(
                  painter: ARGuidePainter(colors: colors),
                ),
              ),
          ],
        ),
      ),
    );

    final instructionsPanel = Column(
      children: [
        NeobrutalistCard(
          backgroundColor: colors.bgTertiary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎯 ขั้นตอนการปรับเทียบ',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: colors.chocolateBrown,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1. ถือสมาร์ทโฟนหรือกล้อง เล็งไปยังพื้นผิวที่เรียบและสว่าง (เช่น โต๊ะหรือเตียงฝึกหุ่นจำลอง)\n'
                '2. แตะปุ่มเป้าวงกลมตรงกลาง เพื่อจำลองล็อกพิกัดภูมิศาสตร์และวางโมเดลเชิงกราน\n'
                '3. เมื่อระบบเชื่อมต่อเรียบร้อยแล้ว ให้ศึกษาวิธีการทำคลอดและการประคองครรภ์ตามภาพไกด์ไลน์นำทาง',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: colors.chocolateBrown,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        NeobrutalistCard(
          backgroundColor: colors.bgSecondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🖐️ แนวทางและกลยุทธ์การวางมือทำคลอด',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: colors.chocolateBrown,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'การต้านและประคองท้ายทอยทารก (Occiput):',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: colors.primaryPink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'ใช้มือข้างที่ไม่ถนัดกดต้านบริเวณท้ายทอยของทารกเบาๆ เพื่อควบคุมให้ศีรษะทารกเงยคลอดอย่างช้าๆ ป้องกันการเงยศีรษะกระทันหันซึ่งจะทำให้ฝีเย็บฉีกขาด',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'การประคองฝีเย็บ (Perineal Support):',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: colors.successGreen,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'ใช้มือข้างที่ถนัดถือผ้าสะอาดประคองดันบริเวณฝีเย็บ โดยใช้นิ้วชี้และนิ้วโป้งโอบฝีเย็บเข้าหากันเพื่อช่วยผ่อนคลายและลดความตึงขณะศีรษะทารกเคลื่อนผ่านพ้น',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('ด่านที่ 3: ปรับเทียบพื้นที่จำลอง AR', style: TextStyle(fontWeight: FontWeight.w900)),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: colors.chocolateBrown,
                    ),
                  ),
                ),
                NeobrutalistButton(
                  backgroundColor: _isCalibrated ? colors.successGreen : Colors.grey.shade400,
                  onTap: _isCalibrated
                      ? () {
                          ref.read(smartBirthStateProvider.notifier).completeStage('stage3');
                          context.go('/dashboard');
                        }
                      : () {},
                  child: Text(
                    'ส่งงานสำเร็จด่าน 3',
                    style: TextStyle(
                      color: _isCalibrated ? Colors.white : colors.chocolateBrown.withOpacity(0.5),
                      fontWeight: FontWeight.w900,
                    ),
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
                  arViewportPanel,
                  const SizedBox(height: 24),
                  instructionsPanel,
                ],
              ),
              tablet: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 11, child: arViewportPanel),
                  const SizedBox(width: 20),
                  Expanded(flex: 10, child: instructionsPanel),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 12, child: arViewportPanel),
                  const SizedBox(width: 24),
                  Expanded(flex: 10, child: instructionsPanel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ARGuidePainter extends CustomPainter {
  final SmartBirthColors colors;

  ARGuidePainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    
    // Scale coordinate system to match 400x400 viewBox of SVG
    final scaleX = size.width / 400.0;
    final scaleY = size.height / 400.0;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    
    // Centering the canvas
    canvas.translate((size.width - 400 * scale) / 2, (size.height - 400 * scale) / 2);
    canvas.scale(scale, scale);

    // 1. Draw glowing pelvis inlet ellipse
    final paintPelvis = Paint()
      ..color = colors.accentBlue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(200, 200), width: 220, height: 160),
      paintPelvis,
    );

    // 2. Ischial spines (pink dots)
    final paintSpine = Paint()
      ..color = colors.primaryPink
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(105, 200), 8, paintSpine);
    canvas.drawCircle(const Offset(295, 200), 8, paintSpine);

    _drawText(canvas, 'Ischial Spine (ระดับ 0)', const Offset(105, 182), colors.chocolateBrown, fontSize: 10, bold: true);
    _drawText(canvas, 'Ischial Spine (ระดับ 0)', const Offset(295, 182), colors.chocolateBrown, fontSize: 10, bold: true);

    // 3. Fetal head ellipse
    final paintFetalBg = Paint()
      ..color = colors.primaryPink.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final paintFetalBorder = Paint()
      ..color = colors.primaryPink
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(200, 200), width: 120, height: 150),
      paintFetalBg,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(200, 200), width: 120, height: 150),
      paintFetalBorder,
    );

    // 4. Suture lines
    canvas.drawLine(const Offset(200, 125), const Offset(200, 250), paintFetalBorder);

    // 5. Dominant Hand guide vector curve (bottom)
    final paintHandBottom = Paint()
      ..color = colors.successGreen
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final pathBottom = Path()
      ..moveTo(160, 360)
      ..quadraticBezierTo(200, 290, 240, 360);
    _drawDashedPath(canvas, pathBottom, paintHandBottom);

    _drawText(canvas, 'มือที่ถนัดประคองฝีเย็บ (Ritgen Maneuver)', const Offset(200, 305), colors.successGreen, fontSize: 11, bold: true);

    // 6. Non-dominant Hand guide vector curve (top)
    final paintHandTop = Paint()
      ..color = colors.primaryPink
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pathTop = Path()
      ..moveTo(160, 120)
      ..quadraticBezierTo(200, 170, 240, 120);
    _drawDashedPath(canvas, pathTop, paintHandTop);

    _drawText(canvas, 'มืออีกข้างควบคุมการเงยของศีรษะทารก', const Offset(200, 95), colors.primaryPink, fontSize: 11, bold: true);

    canvas.restore();
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color, {double fontSize = 10, bool bold = false}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamily: 'Nunito',
          fontWeight: bold ? FontWeight.w900 : FontWeight.bold,
          backgroundColor: Colors.white.withOpacity(0.65),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(offset.dx - textPainter.width / 2, offset.dy - textPainter.height / 2));
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    // Simple helper to draw dashes along a path
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final length = draw ? 6.0 : 4.0;
        if (draw) {
          canvas.drawPath(
            metric.extractPath(distance, (distance + length).clamp(0.0, metric.length)),
            paint,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant ARGuidePainter oldDelegate) => oldDelegate.colors != colors;
}
