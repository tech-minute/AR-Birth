import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../main.dart';
import '../utils/print_stub.dart' if (dart.library.js) '../utils/print_web.dart';

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
    final colors = Theme.of(context).extension<SmartBirthColors>() ?? warmColors;

    // Check if 5 stages are complete
    final stages = ['stage1', 'stage2', 'stage3', 'stage4', 'stage5'];
    final completedCount = stages.where((s) => state.completedStages[s] == true).length;
    final isReady = completedCount == stages.length;

    // Thai Date formatter
    final today = DateTime.now();
    final List<String> months = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    final dateText = '${today.day} ${months[today.month - 1]} ${today.year + 543}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('ใบรับรองความพร้อม Pre-VR Ready', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: colors.bgSecondary,
        elevation: 0,
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
                  child: Text(
                    '🏠 กลับหน้าหลัก',
                    style: TextStyle(fontWeight: FontWeight.w900, color: colors.chocolateBrown),
                  ),
                ),
                NeobrutalistButton(
                  backgroundColor: isReady ? colors.primaryPink : Colors.grey.shade400,
                  onTap: isReady
                      ? () {
                          if (state.studentName.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('กรุณากรอกชื่อ-นามสกุลของคุณในช่องป้อนข้อมูลด้านบนก่อนทำการพิมพ์เกียรติบัตรครับ')),
                            );
                            return;
                          }
                          // Print certificate
                          printDocument();
                        }
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('กรุณาผ่านการฝึกฝนให้ครบ 5 ด่านก่อนพิมพ์ใบประกาศฯ (สำเร็จแล้ว $completedCount/5)')),
                          );
                        },
                  child: Text(
                    'พิมพ์ใบรับรอง 🖨️',
                    style: TextStyle(
                      color: isReady ? Colors.white : colors.chocolateBrown.withOpacity(0.5),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pulsing golden badge card
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primaryPink, Colors.amber],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.chocolateBrown, width: 4),
                  boxShadow: [
                    BoxShadow(color: colors.chocolateBrown, offset: const Offset(4, 4)),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text('🎓', style: TextStyle(fontSize: 60)),
              ),
            ),
            const SizedBox(height: 24),

            // Name input card
            NeobrutalistCard(
              backgroundColor: colors.bgSecondary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'กรอกชื่อ-นามสกุลของคุณเพื่อลงนามเกียรติบัตร',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: colors.chocolateBrown),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: colors.chocolateBrown),
                    decoration: InputDecoration(
                      hintText: 'ชื่อ - นามสกุลของคุณ',
                      hintStyle: TextStyle(color: colors.textSecondary.withOpacity(0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.chocolateBrown, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.chocolateBrown, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.primaryPink, width: 2.5),
                      ),
                    ),
                    onChanged: (val) {
                      ref.read(smartBirthStateProvider.notifier).updateName(val);
                    },
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      '*พิมพ์ชื่อของคุณเพื่ออัปเดตใบรับรองด้านล่างแบบเรียลไทม์',
                      style: TextStyle(fontSize: 10, color: colors.textSecondary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Printable Certificate Paper Card
            NeobrutalistCard(
              backgroundColor: colors.bgTertiary,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                decoration: BoxDecoration(
                  color: colors.bgSecondary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.chocolateBrown, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      'ใบประกาศเกียรติคุณความพร้อมจำลองเสมือนจริง',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SmartBirth Clinical Simulator',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: colors.chocolateBrown,
                        fontFamily: 'Courier New',
                      ),
                    ),
                    const Divider(color: Colors.grey, thickness: 1, height: 24),
                    Text(
                      'เอกสารรับรองฉบับนี้ออกไว้ให้เพื่อแสดงว่า',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.studentName.isNotEmpty ? state.studentName : '[ กรุณากรอกชื่อผู้รับใบรับรอง ]',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: colors.primaryPink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'ได้ผ่านหลักสูตรและแบบประเมินความพร้อมแบบ Pre-VR โดยทำภารกิจสำเร็จสะสมคะแนน ${state.xp} XP ⭐ และรับรางวัล ${state.coins} เหรียญทอง 🪙 ครอบคลุมการจำแนกเครื่องมือทำคลอด กายวิภาคศาสตร์ การศึกษาสรีระกลไกการคลอด 3 มิติ ปรับเทียบพื้นที่กล้อง และประเมินประสาทสัมผัสการกางนิ้วตามเกณฑ์สากล',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colors.chocolateBrown,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const Divider(color: Colors.grey, thickness: 1, height: 32),
                    
                    // Signature and Stamp footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Left Sign
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(width: 80, height: 1, color: colors.chocolateBrown),
                              const SizedBox(height: 4),
                              Text(
                                'ดร. เอฟลิน แวนส์, MD 🩺',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: colors.chocolateBrown),
                              ),
                              Text(
                                'ผู้อำนวยการศูนย์จำลองสูติศาสตร์การแพทย์',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 7, color: colors.textSecondary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),

                        // Center Stamp
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: colors.primaryPink, width: 2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'VR READY\nผ่านการรับรอง',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.primaryPink,
                              fontWeight: FontWeight.w900,
                              fontSize: 8,
                            ),
                          ),
                        ),

                        // Right Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(width: 80, height: 1, color: colors.chocolateBrown),
                              const SizedBox(height: 4),
                              Text(
                                dateText,
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: colors.chocolateBrown),
                              ),
                              Text(
                                'วันที่ออกหนังสือรับรอง',
                                style: TextStyle(fontSize: 7, color: colors.textSecondary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
