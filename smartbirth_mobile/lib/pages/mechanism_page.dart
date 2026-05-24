import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme.dart';
import '../main.dart';

class FetalMovementStep {
  final String title;
  final String desc;
  final List<String> notes;

  const FetalMovementStep({
    required this.title,
    required this.desc,
    required this.notes,
  });
}

class MechanismPage extends ConsumerStatefulWidget {
  const MechanismPage({super.key});

  @override
  ConsumerState<MechanismPage> createState() => _MechanismPageState();
}

class _MechanismPageState extends ConsumerState<MechanismPage> {
  late final WebViewController _controller;
  double _sliderValue = 0.0;
  bool _isLoaded = false;

  final List<FetalMovementStep> _stages = const [
    FetalMovementStep(
      title: 'การเตรียมตัวเข้าสู่เชิงกราน (Pre-Engagement) 🤰',
      desc: 'ศีรษะของทารกลอยอยู่เหนือขอบทางเข้าของอุ้งเชิงกราน (Pelvic Inlet) โดยปกติแล้วศีรษะทารกจะหันไปทางด้านข้างของช่องเชิงกรานมารดา (Occiput Transverse)',
      notes: [
        'ความสูงของศีรษะทารก (Sagittal suture) ยังอยู่สูงเหนือกึ่งกลางโพรงเชิงกราน',
        'แนวรอยต่อกะโหลกศีรษะ (Sagittal suture) อยู่ในแนวขวางหรือแนวเฉียง'
      ],
    ),
    FetalMovementStep(
      title: '1. ศีรษะเข้าสู่เชิงกราน (Engagement) 🎯',
      desc: 'เส้นผ่านศูนย์กลางกว้างสุดของศีรษะทารก (Biparietal diameter) เคลื่อนผ่านขอบทางเข้าของอุ้งเชิงกรานเข้ามาในโพรงเชิงกราน ศีรษะมักจะยังคงหันในแนวขวาง',
      notes: [
        'ระดับศีรษะทารกเคลื่อนลงมาถึงตำแหน่งของปุ่ม ischial spines (เรียกว่า Station 0)',
        'การมี Engagement เป็นการส่งสัญญาณที่ดีว่าขนาดศีรษะทารกและทางเข้าเชิงกรานมารดามีสัดส่วนที่เข้ากันได้'
      ],
    ),
    FetalMovementStep(
      title: '2. ศีรษะเคลื่อนต่ำลง (Descent) ⬇️',
      desc: 'ศีรษะและตัวทารกเคลื่อนต่ำลงไปตามช่องคลอดเรื่อยๆ ภายใต้แรงบีบตัวของกล้ามเนื้อมดลูกและการออกแรงเบ่งอย่างสม่ำเสมอของมารดา',
      notes: [
        'เกิดขึ้นอย่างต่อเนื่องตั้งแต่ระยะปากมดลูกเปิดจนกระทั่งทารกคลอดเสร็จสิ้น',
        'ประเมินระดับความต่ำเป็นหน่วย Station ที่เป็นค่าบวก (+1 ถึง +5)'
      ],
    ),
    FetalMovementStep(
      title: '3. ศีรษะก้ม (Flexion) 🔀',
      desc: 'ในขณะที่ศีรษะเคลื่อนต่ำลงไป จะพบกับแรงต้านจากผนังช่องคลอดและพื้นเชิงกราน ทำให้ศีรษะก้มลงโดยอัตโนมัติจนคางชิดหน้าอกทารก',
      notes: [
        'การก้มช่วยปรับเอาเส้นผ่านศูนย์กลางศีรษะส่วนที่แคบที่สุด (Suboccipitobregmatic, ~9.5 ซม.) เพื่อนำทางผ่านช่องคลอด',
        'เป็นขั้นตอนสำคัญในการลดการใช้เนื้อที่ทางผ่านเพื่อให้คลอดง่ายขึ้น'
      ],
    ),
    FetalMovementStep(
      title: '4. ศีรษะหมุนภายใน (Internal Rotation) 🔄',
      desc: 'ศีรษะของทารกจะหมุนปรับตำแหน่งภายในช่องคลอดประมาณ 90 องศา จากแนวขวางมาอยู่ในแนวหน้าหลัง (Occiput Anterior) เพื่อหันส่วนท้ายทอยมาขัดอยู่ใต้กระดูกหัวหน่าวมารดา',
      notes: [
        'ปรับแนวศีรษะทารกให้สอดรับกับความกว้างแนวหน้าหลังของช่องทางออกเชิงกราน',
        'รอยต่อกะโหลกศีรษะทารก (Sagittal suture) เปลี่ยนจากแนวนอนขวางเป็นแนวตั้งหน้าหลัง'
      ],
    ),
    FetalMovementStep(
      title: '5. ศีรษะเงย (Extension) ↗️',
      desc: 'เมื่อศีรษะท้ายทอยขัดแน่นใต้กระดูกหัวหน่าวมารดา (Symphysis pubis) เป็นจุดหมุน ศีรษะทารกจะก้มต่อไปไม่ได้ จึงเริ่มเงยขึ้นตามมุมโค้งทางออกของช่องคลอด หน้าผาก หน้า และคางจะค่อยๆ ไหลผ่านพ้นฝีเย็บออกมา',
      notes: [
        'ศีรษะของทารกโผล่พ้นช่องคลอดออกมาภายนอกอย่างสมบูรณ์',
        'ผู้ทำคลอดต้องประคองศีรษะและควบคุมแรงเบ่งในขั้นตอนนี้ให้ค่อยเป็นค่อยไปเพื่อรักษาและป้องกันแผลฝีเย็บฉีกขาด'
      ],
    ),
    FetalMovementStep(
      title: '6. ศีรษะสะบัดกลับและหมุนภายนอก (Restitution & External Rotation) ↩️',
      desc: 'เมื่อศีรษะคลอดพ้นมาแล้ว ศีรษะจะหมุนกลับไปแนวขวางธรรมชาติ (Restitution) เพื่อคลายการบิดตัวของลำคอ จากนั้นจะหมุนภายนอกเพิ่มอีกเพื่อช่วยประคองให้ไหล่ทารกที่อยู่ด้านในหมุนตัวเข้าสู่แนวหน้าหลังเตรียมคลอดไหล่',
      notes: [
        'Restitution: ศีรษะทารกสะบัดกลับไปตั้งฉากกับแนวบ่าของเด็กเอง',
        'External Rotation: เป็นปฏิกิริยาต่อเนื่องจากการหมุนแนวไหล่ของทารกภายในเชิงกรานเข้าหาแนวดิ่งหน้าหลัง'
      ],
    ),
    FetalMovementStep(
      title: '7. การคลอดไหล่และลำตัว (Expulsion) 👶🎉',
      desc: 'ทำคลอดไหล่บนโดยโน้มศีรษะทารกลงด้านล่างเบาๆ เพื่อให้ไหล่บนลอดพ้นกระดูกหัวหน่าวมารดา จากนั้นดึงยกศีรษะทารกขึ้นด้านบนเพื่อทำคลอดไหล่ล่างตามลำดับ เมื่อคลอดไหล่ทั้งสองข้างได้แล้ว ลำตัวและขาจะคลอดตามออกมาอย่างรวดเร็ว',
      notes: [
        'เป็นจุดสิ้นสุดของกระบวนการคลอดทารก',
        'แพทย์หรือพยาบาลทำคลอดจะประคองตัวทารกขึ้นขนานไปตามสรีระความโค้งทางช่องคลอดมารดา'
      ],
    ),
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
                            _stages[activeStageIndex].title,
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: colors.chocolateBrown),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _stages[activeStageIndex].desc,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          Text(
                            '💡 บันทึกความรู้ทางคลินิก:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: colors.chocolateBrown),
                          ),
                          const SizedBox(height: 8),
                          ..._stages[activeStageIndex].notes.map((note) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: colors.chocolateBrown)),
                                Expanded(
                                  child: Text(
                                    note,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
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
