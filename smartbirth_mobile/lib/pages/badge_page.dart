import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../main.dart';

class BadgePage extends ConsumerStatefulWidget {
  const BadgePage({super.key});

  @override
  ConsumerState<BadgePage> createState() => _BadgePageState();
}

class _BadgePageState extends ConsumerState<BadgePage> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(smartBirthStateProvider);
    _nameController = TextEditingController(text: state.studentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smartBirthStateProvider);
    
    // Check if 5 stages are complete
    final stages = ['stage1', 'stage2', 'stage3', 'stage4', 'stage5'];
    final completedCount = stages.where((s) => state.completedStages[s] == true).length;
    final isReady = completedCount == stages.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ใบรับรองความความพร้อม Pre-VR Ready', style: TextStyle(fontWeight: FontWeight.w900)),
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
                  backgroundColor: isReady ? kPrimaryPink : Colors.grey.shade400,
                  onTap: isReady
                      ? () {
                          // Print pdf certificate action
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('กำลังเปิดกล่องพิมพ์ประกาศนียบัตร...')),
                          );
                        }
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('กรุณาผ่านการฝึกฝนให้ครบ 5 ด่านก่อนพิมพ์ใบประกาศฯ (สำเร็จแล้ว $completedCount/5)')),
                          );
                        },
                  child: const Text('พิมพ์ใบรับรอง 🖨️', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Badge Showcase Icon
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimaryPink, Colors.amber],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: kChocolateBrown, width: 4),
                  boxShadow: const [
                    BoxShadow(color: kChocolateBrown, offset: Offset(4, 4)),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text('🎓', style: TextStyle(fontSize: 64)),
              ),
            ),
            const SizedBox(height: 24),

            // Name Input
            NeobrutalistCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('กรอกชื่อ-นามสกุลผู้เข้ารับการฝึกอบรม', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'ชื่อ - นามสกุลของคุณ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kChocolateBrown, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kChocolateBrown, width: 2),
                      ),
                    ),
                    onChanged: (val) {
                      ref.read(smartBirthStateProvider.notifier).updateName(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Certificate Summary Box
            NeobrutalistCard(
              backgroundColor: kBgTertiary,
              child: Column(
                children: [
                  const Text(
                    'ใบประกาศความพร้อมปฏิบัติการเสมือนจริง',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const Divider(color: kChocolateBrown, thickness: 2, height: 24),
                  const Text('ขอรับรองว่าผู้ผ่านหลักสูตรวิทยากลไกจำลอง', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    state.studentName.isNotEmpty ? state.studentName : '[ กรุณากรอกชื่อของคุณด้านบน ]',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: kPrimaryPink),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ได้เรียนรู้และสะสมผลงานสำเร็จระดับ ${state.xp} XP ⭐ และ ${state.coins} เหรียญทอง 🪙 ผ่านทฤษฎีเครื่องมือ 3D pelvic simulation และทักษะสัมผัสกางนิ้วตามมาตรฐานวิชาชีพพยาบาล',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.5),
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
