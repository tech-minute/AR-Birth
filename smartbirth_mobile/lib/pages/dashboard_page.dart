import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../main.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  String _mascotBubble = "สวัสดีหมอฝึกหัด! 🚀 เลือกด่านกลไกการทำคลอดเพื่อเริ่มสะสมเหรียญทองกันเลยครับ!";
  final Random _random = Random();

  final List<String> _dialogues = [
    "สวัสดีหมอฝึกหัด! 🚀 เลือกด่านกลไกการทำคลอดเพื่อเริ่มสะสมเหรียญทองกันเลยครับ!",
    "ยินดีต้อนรับสู่วิถีนักเรียนแพทย์! ทำภารกิจให้ครบเพื่อผ่านเกณฑ์การฝึกแบบ Pre-VR นะครับ ⭐",
    "ทุกด่านเปิดใช้งานตลอดเวลา คุณสามารถเลือกข้ามด่านไปเรียนส่วนที่สนใจก่อนได้เลยครับ!",
    "พยายามเข้าครับ! สะสมเหรียญและ XP เพื่อปลดล็อกใบประกาศเกียรติคุณในด่านสุดท้าย 🎓"
  ];

  void _cycleMascotDialogue() {
    setState(() {
      String next = _dialogues[_random.nextInt(_dialogues.length)];
      while (next == _mascotBubble) {
        next = _dialogues[_random.nextInt(_dialogues.length)];
      }
      _mascotBubble = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smartBirthStateProvider);
    final colors = Theme.of(context).extension<SmartBirthColors>() ?? warmColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SmartBirth Quest',
          style: TextStyle(fontWeight: FontWeight.w900, color: colors.chocolateBrown),
        ),
        backgroundColor: colors.bgSecondary,
        elevation: 0,
        actions: [
          // Theme Toggle Button
          IconButton(
            icon: Icon(
              state.theme == 'warm' ? Icons.palette_outlined : Icons.palette,
              color: colors.chocolateBrown,
            ),
            tooltip: 'สลับธีมสี',
            onPressed: () {
              ref.read(smartBirthStateProvider.notifier).toggleTheme();
            },
          ),
          const SizedBox(width: 4),
          // Coins Badge Widget
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3C4),
              border: Border.all(color: colors.chocolateBrown, width: 2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                const Text('🪙 ', style: TextStyle(fontSize: 16)),
                Text(
                  '${state.coins}',
                  style: const TextStyle(
                    fontFamily: 'Courier New',
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF8A6200),
                  ),
                ),
              ],
            ),
          ),
          // XP Badge Widget
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE6CC),
              border: Border.all(color: colors.chocolateBrown, width: 2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                const Text('⭐ ', style: TextStyle(fontSize: 16)),
                Text(
                  '${state.xp} XP',
                  style: const TextStyle(
                    fontFamily: 'Courier New',
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFC25E00),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Scrollable Grid content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🏆 เรียนรู้และประเมินผลสะสมทักษะ',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: colors.chocolateBrown,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Dynamic layout allocation based on Mobile, Tablet, and Desktop breakpoints
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: ResponsiveLayout.isDesktop(context)
                      ? 3
                      : (ResponsiveLayout.isTablet(context) ? 2 : 1),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: ResponsiveLayout.isTablet(context) ? 1.1 : 1.25,
                  children: [
                    _buildStepCard(
                      title: 'เครื่องมือและกายวิภาค',
                      subtitle: 'ภารกิจที่ 1 • เลเวล 1',
                      description: 'ทบทวนการ์ดรายละเอียดเครื่องมือและเช็คลิสต์เตรียมของ',
                      imageUrl: 'https://img.icons8.com/color/256/rubber-gloves.png',
                      isCompleted: state.completedStages['stage1'] ?? false,
                      onTap: () => context.push('/stage1'),
                    ),
                    _buildStepCard(
                      title: 'กลไกการคลอด 3 มิติ',
                      subtitle: 'ภารกิจที่ 2 • เลเวล 2',
                      description: 'เลื่อนแถบจำลองศีรษะทารกผ่านอุ้งเชิงกราน 360 องศา',
                      imageUrl: 'https://img.icons8.com/color/256/pregnant.png',
                      isCompleted: state.completedStages['stage2'] ?? false,
                      onTap: () => context.push('/stage2'),
                    ),
                    _buildStepCard(
                      title: 'ปรับเทียบพิกัด AR Lab',
                      subtitle: 'ภารกิจที่ 3 • เลเวล 3',
                      description: 'ทบทวนการวางมือสนับสนุน perineal (Ritgen)',
                      imageUrl: 'https://img.icons8.com/color/256/camera.png',
                      isCompleted: state.completedStages['stage3'] ?? false,
                      onTap: () => context.push('/stage3'),
                    ),
                    _buildStepCard(
                      title: 'ประเมินสัมผัสกางนิ้ว',
                      subtitle: 'ภารกิจที่ 4 • เลเวล 4',
                      description: 'ฝึกนิ้วชี้และนิ้วกลางตรวจระดับเปิดมดลูก 1-10 ซม.',
                      imageUrl: 'https://img.icons8.com/color/256/hand.png',
                      isCompleted: state.completedStages['stage4'] ?? false,
                      onTap: () => context.push('/stage4'),
                    ),
                    _buildStepCard(
                      title: 'เกมเรียงลำดับขั้นตอน',
                      subtitle: 'ภารกิจที่ 5 • เลเวล 5',
                      description: 'จัดลำดับกลไกทำคลอด 7 ลำดับให้ถูกต้องตามเวลา',
                      imageUrl: 'https://img.icons8.com/color/256/brain.png',
                      isCompleted: state.completedStages['stage5'] ?? false,
                      onTap: () => context.push('/stage5'),
                    ),
                    _buildStepCard(
                      title: 'เกียรติบัตร Pre-VR Ready',
                      subtitle: 'เป้าหมายปลายทาง • เลเวล 6',
                      description: 'ออกใบรับรองความความพร้อมสำหรับใช้สอบจำลองแล็บ VR',
                      imageUrl: 'https://img.icons8.com/color/256/graduation-cap.png',
                      isCompleted: false, // Badge is summary page
                      onTap: () => context.push('/stage6'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 120), // Spacing for floating mascot
              ],
            ),
          ),
          
          // Floating Mascot Assistant Widget
          Positioned(
            bottom: 24,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Speech Bubble
                Container(
                  constraints: const BoxConstraints(maxWidth: 240),
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 24, right: 8),
                  decoration: BoxDecoration(
                    color: colors.bgSecondary,
                    border: Border.all(color: colors.chocolateBrown, width: 2.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _mascotBubble,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.chocolateBrown,
                    ),
                  ),
                ),
                // Stork Avatar
                GestureDetector(
                  onTap: _cycleMascotDialogue,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F3),
                      border: Border.all(color: colors.chocolateBrown, width: 3),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('🦢', style: TextStyle(fontSize: 40)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String title,
    required String subtitle,
    required String description,
    required String imageUrl,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).extension<SmartBirthColors>() ?? warmColors;

    return GestureDetector(
      onTap: onTap,
      child: NeobrutalistCard(
        backgroundColor: isCompleted ? const Color(0xFFF2FBF7) : colors.bgSecondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: colors.primaryPink),
                ),
                // Vector badge icon
                Image.network(imageUrl, width: 32, height: 32),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: colors.chocolateBrown),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                description,
                style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Star ratings indicators
                Row(
                  children: List.generate(3, (index) => Text(
                    '⭐',
                    style: TextStyle(
                      fontSize: 14,
                      color: isCompleted ? Colors.amber : Colors.grey.shade300,
                    ),
                  )),
                ),
                Text(
                  isCompleted ? '✅ สำเร็จแล้ว' : '🎯 เริ่มด่าน',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isCompleted ? colors.successGreen : colors.chocolateBrown,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
