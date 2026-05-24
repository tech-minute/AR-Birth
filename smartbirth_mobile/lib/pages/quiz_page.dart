import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../main.dart';

class LeaderboardItem {
  final String name;
  final int score;

  LeaderboardItem({required this.name, required this.score});
}

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({super.key});

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  final List<String> _correctOrder = [
    '1. Engagement (ศีรษะเข้าสู่เชิงกราน)',
    '2. Descent (ศีรษะเคลื่อนต่ำลง)',
    '3. Flexion (ศีรษะก้ม)',
    '4. Internal Rotation (ศีรษะหมุนภายใน)',
    '5. Extension (ศีรษะเงย)',
    '6. Restitution & Ext Rotation (หมุนกลับและหมุนภายนอก)',
    '7. Expulsion (คลอดไหล่และลำตัว)'
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

    // Trigger score update in state
    ref.read(smartBirthStateProvider.notifier).updateQuizScore(score);

    if (correctCount == 7) {
      ref.read(smartBirthStateProvider.notifier).addRewards(200, 80);
      _showSuccessDialog();
    } else {
      _showRetryDialog(correctCount, score);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final colors = Theme.of(context).extension<SmartBirthColors>() ?? warmColors;
        return AlertDialog(
          backgroundColor: colors.bgSecondary,
          title: Text('🎉 สุดยอด 100%!', style: TextStyle(fontWeight: FontWeight.w900, color: colors.chocolateBrown)),
          content: Text(
            'คุณจัดเรียงลำดับขั้นตอนได้อย่างถูกต้องครบถ้วนสมบูรณ์แบบ ได้รับเหรียญทองและ XP สูงสุด',
            style: TextStyle(color: colors.chocolateBrown, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(smartBirthStateProvider.notifier).completeStage('stage5');
                Navigator.pop(context);
                context.go('/dashboard');
              },
              child: Text('กลับสู่แดชบอร์ด', style: TextStyle(color: colors.primaryPink, fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  void _showRetryDialog(int correctCount, int score) {
    showDialog(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).extension<SmartBirthColors>() ?? warmColors;
        return AlertDialog(
          backgroundColor: colors.bgSecondary,
          title: Text('❌ ลองใหม่อีกครั้ง', style: TextStyle(fontWeight: FontWeight.w900, color: colors.chocolateBrown)),
          content: Text(
            'คุณตอบถูกทั้งหมด $correctCount จาก 7 ขั้นตอน (คะแนน $score%)\nต้องการรีเซ็ตคำตอบแล้วลองจัดเรียงใหม่อีกครั้งเพื่อทำคะแนนเต็มหรือไม่?',
            style: TextStyle(color: colors.chocolateBrown, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/dashboard');
              },
              child: Text('กลับเมนู', style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetQuiz();
              },
              child: Text('ลองอีกครั้ง', style: TextStyle(color: colors.primaryPink, fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  IconData _getStepIcon(String step) {
    if (step.contains('Engagement')) return Icons.vertical_align_bottom;
    if (step.contains('Descent')) return Icons.arrow_downward;
    if (step.contains('Flexion')) return Icons.keyboard_return;
    if (step.contains('Internal Rotation')) return Icons.sync;
    if (step.contains('Extension')) return Icons.north_east;
    if (step.contains('Restitution')) return Icons.rotate_left;
    if (step.contains('Expulsion')) return Icons.child_care;
    return Icons.drag_handle;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smartBirthStateProvider);
    final colors = Theme.of(context).extension<SmartBirthColors>() ?? warmColors;

    final headerTextSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ด่านที่ 5: แบบทดสอบเรียงลำดับขั้นตอนกลไกการคลอด 🧠',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: colors.chocolateBrown,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'จัดเรียงลำดับขั้นตอนกลไกการเคลื่อนตัวของทารก 7 ขั้นตอนให้ถูกต้องตามกาลเวลาเพื่อพิสูจน์ความรู้เชิงปฏิวัติ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: colors.textSecondary,
          ),
        ),
      ],
    );

    // Dynamic leaderboard sorted in real-time
    final List<LeaderboardItem> leaderboardData = [
      LeaderboardItem(name: 'พญ. วริศรา เรืองเดช (MD) 🩺', score: 100),
      LeaderboardItem(name: 'พว. มนัสวี สมบูรณ์ (RN) 🧤', score: 100),
      LeaderboardItem(name: 'พว. ณภัทร ชูเกียรติ (RN) 🧤', score: 100),
      LeaderboardItem(name: 'คุณ (ผู้ทดสอบ) 👤', score: state.quizHighScore),
      LeaderboardItem(name: 'นพ. วรุตม์ เจริญสุข (MD) 🩺', score: 85),
    ];
    leaderboardData.sort((a, b) => b.score.compareTo(a.score));

    final leaderboardPanel = NeobrutalistCard(
      backgroundColor: colors.bgSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: colors.primaryPink, size: 20),
              const SizedBox(width: 8),
              Text(
                'ตารางอันดับบอร์ดจำลอง',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: colors.chocolateBrown),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...leaderboardData.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isUser = item.name.contains('คุณ (ผู้ทดสอบ)');
            final rank = idx + 1;

            return Container(
              margin: const EdgeInsets.only(bottom: 6.0),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isUser ? colors.bgTertiary : colors.bgSecondary,
                border: Border.all(color: colors.chocolateBrown, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: rank <= 3 ? colors.primaryPink : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '#$rank',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            color: rank <= 3 ? Colors.white : colors.chocolateBrown,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: isUser ? FontWeight.w900 : FontWeight.bold,
                          fontSize: 12,
                          color: colors.chocolateBrown,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${item.score}%',
                    style: TextStyle(
                      fontFamily: 'Courier New',
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: colors.chocolateBrown,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 12),
          Text(
            '*จัดเรียงลำดับได้ถูกต้องครบ 100% เพื่อไต่อันดับสู่จุดสูงสุดของโรงเรียนสูตินรีแพทย์ พร้อมปลดล็อกรับตราดิจิทัล Pre-VR Ready!',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );

    // Draggable Workspace
    final quizWorkspace = Column(
      children: [
        // Drop Slots 1-7
        NeobrutalistCard(
          backgroundColor: colors.bgSecondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'จัดเรียงลำดับขั้นตอน (บนลงล่าง ลำดับที่ 1-7)',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: colors.chocolateBrown),
              ),
              const SizedBox(height: 12),
              ...List.generate(7, (index) {
                final item = _placedSlots[index];
                final isCorrect = _evaluatedSlots[index];

                Color slotBg = colors.bgPrimary;
                if (_hasSubmitted) {
                  slotBg = (isCorrect == true) ? colors.successGreen.withOpacity(0.15) : colors.primaryPink.withOpacity(0.15);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  height: 48,
                  decoration: BoxDecoration(
                    color: slotBg,
                    border: Border.all(color: colors.chocolateBrown, width: 2.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: colors.chocolateBrown, width: 2.5)),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(fontWeight: FontWeight.w900, color: colors.chocolateBrown),
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
                                      children: [
                                        Icon(
                                          _getStepIcon(item),
                                          size: 16,
                                          color: colors.primaryPink,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12,
                                              color: colors.chocolateBrown,
                                            ),
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
                                            child: const Icon(Icons.cancel, color: Colors.red, size: 18),
                                          ),
                                      ],
                                    )
                                  : Text(
                                      'ลากตัวเลือกวางที่นี่...',
                                      style: TextStyle(
                                        color: colors.textSecondary.withOpacity(0.4),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
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
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Shuffled Options Pool Card
        NeobrutalistCard(
          backgroundColor: colors.bgSecondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ตัวเลือกขั้นตอนกลไกคลอด',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: colors.chocolateBrown),
              ),
              const SizedBox(height: 10),
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
                          color: colors.bgSecondary,
                          border: Border.all(color: colors.chocolateBrown, width: 2.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            color: colors.chocolateBrown,
                          ),
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: Chip(
                        backgroundColor: colors.bgPrimary,
                        label: Text(
                          option,
                          style: TextStyle(fontSize: 11, color: colors.textSecondary),
                        ),
                      ),
                    ),
                    child: ActionChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStepIcon(option),
                            size: 14,
                            color: colors.primaryPink,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            option,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              color: colors.chocolateBrown,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: colors.bgTertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: colors.chocolateBrown, width: 2.5),
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
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('ด่านที่ 5: จัดเรียงลำดับกลไกคลอด', style: TextStyle(fontWeight: FontWeight.w900)),
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
                NeobrutalistButton(
                  backgroundColor: _hasSubmitted ? Colors.grey.shade400 : colors.primaryPink,
                  onTap: _hasSubmitted ? () {} : _submitAnswers,
                  child: const Text(
                    'ส่งคำตอบ',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
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
                  quizWorkspace,
                  const SizedBox(height: 24),
                  leaderboardPanel,
                ],
              ),
              tablet: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 12, child: quizWorkspace),
                  const SizedBox(width: 20),
                  Expanded(flex: 9, child: leaderboardPanel),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 13, child: quizWorkspace),
                  const SizedBox(width: 24),
                  Expanded(flex: 9, child: leaderboardPanel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
