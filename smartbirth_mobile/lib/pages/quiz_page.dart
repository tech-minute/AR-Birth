import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../main.dart';

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({super.key});

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  final List<String> _correctOrder = [
    '1. Engagement (เข้าสู่อุ้งเชิงกราน)',
    '2. Descent (เคลื่อนต่ำลง)',
    '3. Flexion (ศีรษะก้ม)',
    '4. Internal Rotation (หมุนภายใน)',
    '5. Extension (เงยศีรษะ)',
    '6. Restitution & Ext Rotation (สะบัดและหมุนนอก)',
    '7. Expulsion (ทำคลอดไหล่และตัวเด็ก)'
  ];

  late List<String> _shuffledPool;
  late List<String?> _placedSlots;
  bool _hasSubmitted = false;
  Map<int, bool> _evaluatedSlots = {};

  @override
  void initState() {
    super.initState();
    _resetQuiz();
  }

  void _resetQuiz() {
    setState(() {
      _shuffledPool = [..._correctOrder]..shuffle();
      _placedSlots = List.generate(7, (_) => null);
      _hasSubmitted = false;
      _evaluatedSlots.clear();
    });
  }

  void _submitAnswers() {
    if (_placedSlots.any((s) => s == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเติมคำตอบในช่องว่างให้ครบทั้ง 7 ช่องก่อนกดยืนยันครับ')),
      );
      return;
    }

    int correctCount = 0;
    setState(() {
      _hasSubmitted = true;
      for (int i = 0; i < 7; i++) {
        final correct = _placedSlots[i] == _correctOrder[i];
        _evaluatedSlots[i] = correct;
        if (correct) correctCount++;
      }
    });

    final score = ((correctCount / 7.0) * 100).round();

    if (correctCount == 7) {
      ref.read(smartBirthStateProvider.notifier).addRewards(200, 80);
      ref.read(smartBirthStateProvider.notifier).updateQuizScore(100);
      _showSuccessDialog();
    } else {
      _showRetryDialog(correctCount, score);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 สุดยอด 100%!', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('คุณจัดเรียงลำดับขั้นตอนได้อย่างถูกต้องครบถ้วนสมบูรณ์แบบ ได้รับเหรียญทองและ XP สูงสุด'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(smartBirthStateProvider.notifier).completeStage('stage5');
              Navigator.pop(context);
              context.go('/dashboard');
            },
            child: const Text('กลับสู่แดชบอร์ด'),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog(int correctCount, int score) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ ลองใหม่อีกครั้ง', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('คุณตอบถูกทั้งหมด $correctCount จาก 7 ขั้นตอน (คะแนน $score%)\nต้องการรีเซ็ตคำตอบแล้วลองจัดเรียงใหม่อีกครั้งเพื่อทำคะแนนเต็มหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/dashboard');
            },
            child: const Text('กลับเมนู'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetQuiz();
            },
            child: const Text('ลองอีกครั้ง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ด่านที่ 5: จัดเรียงลำดับกลไกคลอด', style: TextStyle(fontWeight: FontWeight.w900)),
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
                  backgroundColor: _hasSubmitted ? Colors.grey.shade400 : kPrimaryPink,
                  onTap: _hasSubmitted ? () {} : _submitAnswers,
                  child: const Text('ส่งคำตอบ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main sequencing layout
            Column(
              children: [
                // Drop targets list (Slots 1-7)
                NeobrutalistCard(
                  backgroundColor: kBgSecondary,
                  child: Column(
                    children: List.generate(7, (index) {
                      final item = _placedSlots[index];
                      final isCorrect = _evaluatedSlots[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        height: 48,
                        decoration: BoxDecoration(
                          color: _hasSubmitted
                              ? (isCorrect == true ? kSuccessGreen.withOpacity(0.15) : kPrimaryPink.withOpacity(0.15))
                              : kBgTertiary,
                          border: Border.all(color: kChocolateBrown, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                border: Border(right: BorderSide(color: kChocolateBrown, width: 2)),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                            
                            Expanded(
                              child: DragTarget<String>(
                                builder: (context, candidateData, rejectedData) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    alignment: Alignment.centerLeft,
                                    child: item != null
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item,
                                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (!_hasSubmitted)
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _placedSlots[index] = null;
                                                      _shuffledPool.add(item);
                                                    });
                                                  },
                                                  child: const Icon(Icons.close, color: Colors.red, size: 16),
                                                ),
                                            ],
                                          )
                                        : Text(
                                            'ลากตัวเลือกวางที่นี่...',
                                            style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                  );
                                },
                                onAccept: (data) {
                                  setState(() {
                                    _placedSlots[index] = data;
                                    _shuffledPool.remove(data);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),

                // Source Options Cards Pool
                NeobrutalistCard(
                  backgroundColor: kBgSecondary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ตัวเลือกขั้นตอนกลไกคลอด', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _shuffledPool.map((option) {
                          return Draggable<String>(
                            data: option,
                            feedback: Material(
                              color: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: kBgSecondary,
                                  border: Border.all(color: kChocolateBrown, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  option,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: Chip(
                                label: Text(option),
                                backgroundColor: Colors.grey.shade100,
                              ),
                            ),
                            child: DragTarget<String>(
                              builder: (context, _, __) {
                                return ActionChip(
                                  label: Text(option, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: kChocolateBrown)),
                                  backgroundColor: kBgTertiary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(color: kChocolateBrown, width: 2),
                                  ),
                                  onPressed: () {
                                    // Click to place helper
                                    final emptyIndex = _placedSlots.indexOf(null);
                                    if (emptyIndex != -1) {
                                      setState(() {
                                        _placedSlots[emptyIndex] = option;
                                        _shuffledPool.remove(option);
                                      });
                                    }
                                  },
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ],
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
