import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme.dart';
import '../main.dart';

class MechanismPage extends ConsumerStatefulWidget {
  const MechanismPage({super.key});

  @override
  ConsumerState<MechanismPage> createState() => _MechanismPageState();
}

class _MechanismPageState extends ConsumerState<MechanismPage> {
  late final WebViewController _controller;
  double _sliderValue = 0.0;
  bool _isLoaded = false;

  final List<String> _stages = [
    "0. Pre-Engagement (ศีรษะเหนือบ่ากระดูก)",
    "1. Engagement (เข้าสู่อุ้งเชิงกราน)",
    "2. Descent (เคลื่อนต่ำลงเรื่อยๆ)",
    "3. Flexion (ก้มศีรษะคางชิดหน้าอก)",
    "4. Internal Rotation (หมุนหัวในแนวหน้าหลัง)",
    "5. Extension (เงยศีรษะลอดพ้นช่อง)",
    "6. External Rotation (หมุนตัวคลายบ่า)",
    "7. Expulsion (ทำคลอดไหล่และตัวเด็ก)"
  ];

  @override
  void initState() {
    super.initState();
    
    // Configure WebView to run Three.js pelvic simulator
    // Points to the hosted or local server rendering Three.js models
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoaded = true;
            });
          },
        ),
      )
      // Loads a simulated WebView containing the Three.js canvas Pelvic structure
      ..loadRequest(Uri.parse('https://smartbirth-pre-vr.web.app/three_sim.html'));
  }

  void _onSliderChanged(double val) {
    setState(() {
      _sliderValue = val;
    });
    
    if (_isLoaded) {
      // Pass the translation/rotation cardinal state to JS
      _controller.runJavaScript('if (typeof handleSliderInput === "function") { handleSliderInput($val); }');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<SmartBirthColors>() ?? warmColors;
    final activeStageIndex = _sliderValue.round().clamp(0, _stages.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ด่านที่ 2: กลไกลอดช่องเชิงกราน 3 มิติ',
          style: TextStyle(fontWeight: FontWeight.w900, color: colors.chocolateBrown),
        ),
        backgroundColor: colors.bgSecondary,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Dynamic layout breakpoint using ResponsiveLayout standard width (600px/700px)
          final isTabletOrDesktop = constraints.maxWidth > 700;
          
          final contentList = [
            // Left view: Three.js Canvas loader
            Expanded(
              flex: 2,
              child: NeobrutalistCard(
                padding: 4,
                backgroundColor: colors.bgSecondary,
                child: Stack(
                  children: [
                    // Embedded WebView
                    WebViewWidget(controller: _controller),
                    
                    if (!_isLoaded)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: colors.primaryPink),
                            const SizedBox(height: 12),
                            Text(
                              'กำลังเชื่อมต่อระบบจำลอง 3 มิติ...',
                              style: TextStyle(fontWeight: FontWeight.w800, color: colors.chocolateBrown),
                            ),
                          ],
                        ),
                      ),
                      
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.chocolateBrown.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.touch_app, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'สัมผัสหน้าจอเพื่อหมุนมุมมอง 360 องศา',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            if (!isTabletOrDesktop) const SizedBox(height: 16),
            
            // Right/Bottom view: Slider triggers and annotation notes
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    NeobrutalistCard(
                      backgroundColor: colors.bgSecondary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'กลไกในระยะที่:',
                            style: TextStyle(fontSize: 10, color: colors.primaryPink, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            _stages[activeStageIndex],
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: colors.chocolateBrown),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'ศึกษาระดับการเบียดหัวเด็กและศีรษะก้มขัดใต้หัวหน่าว เพื่อเข้าใจมุมของเด็กขณะลอดช่องคลอดของกระดูกอุ้งเชิงกราน',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Labor Slider
                    NeobrutalistCard(
                      backgroundColor: colors.bgTertiary,
                      child: Column(
                        children: [
                          Text(
                            'แถบเลื่อนตามกลไก cardinal movements 7 ขั้น',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: colors.chocolateBrown),
                          ),
                          Slider(
                            value: _sliderValue,
                            min: 0,
                            max: 7,
                            divisions: 70,
                            activeColor: colors.primaryPink,
                            inactiveColor: colors.bgPrimary,
                            onChanged: _onSliderChanged,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('เริ่ม', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colors.textSecondary)),
                              Text('สิ้นสุดเควส', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        NeobrutalistButton(
                          backgroundColor: colors.bgTertiary,
                          onTap: () => context.go('/dashboard'),
                          child: Text(
                            '🏠 กลับหน้าหลัก',
                            style: TextStyle(fontWeight: FontWeight.w800, color: colors.chocolateBrown),
                          ),
                        ),
                        NeobrutalistButton(
                          backgroundColor: _sliderValue >= 6.8 ? colors.successGreen : Colors.grey.shade400,
                          onTap: _sliderValue >= 6.8
                              ? () {
                                  ref.read(smartBirthStateProvider.notifier).completeStage('stage2');
                                  ref.read(smartBirthStateProvider.notifier).addRewards(100, 50);
                                  context.go('/dashboard');
                                }
                              : () {},
                          child: const Text(
                            'ส่งงานสำเร็จด่าน 2',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ];

          return isTabletOrDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: contentList,
                )
              : Column(
                  children: contentList,
                );
        },
      ),
    );
  }
}
