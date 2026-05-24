import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../main.dart';

class ToolItem {
  final String id;
  final String name;
  final String short;
  final String description;
  final String icon;

  ToolItem({
    required this.id,
    required this.name,
    required this.short,
    required this.description,
    required this.icon,
  });
}

class AnatomyPage extends ConsumerStatefulWidget {
  const AnatomyPage({super.key});

  @override
  ConsumerState<AnatomyPage> createState() => _AnatomyPageState();
}

class _AnatomyPageState extends ConsumerState<AnatomyPage> {
  int _activeCardIndex = 0;
  bool _isFlipped = false;
  final Set<int> _viewedCards = {0};

  final List<ToolItem> _tools = [
    ToolItem(
      id: 'gloves',
      name: 'ถุงมือปราศจากเชื้อ 🧤',
      short: 'สำหรับเทคนิคทำคลอดปลอดเชื้อ',
      description: 'มีความจำเป็นสูงสุดในการรักษาความสะอาดและการควบคุมเชื้อระหว่างทำคลอด ต้องสวมใส่เพื่อป้องกันสิ่งปนเปื้อนเข้าช่องคลอดมารดาและปกป้องตนเองจากการสัมผัสเลือด',
      icon: '🧤',
    ),
    ToolItem(
      id: 'scissors',
      name: 'กรรไกรตัดฝีเย็บ ✂️',
      short: 'กรรไกรโค้งตัดขยายช่องทางคลอด',
      description: 'ออกแบบพิเศษมีใบมีดทำมุมเอียงและปลายกลมทู่เพื่อป้องกันอันตรายต่อศีรษะทารก ใช้สำหรับการตัดขยายฝีเย็บช่วยชีวิตเมื่อทารกพร่องออกซิเจน',
      icon: '✂️',
    ),
    ToolItem(
      id: 'clamp',
      name: 'ตัวหนีบสายสะดือ 🔗',
      short: 'ตัวล็อกพลาสติกหนีบเส้นเลือด',
      description: 'หนีบล็อกแน่นทำจากพลาสติกเกรดการแพทย์ ใช้หนีบล็อกสายสะดือห่างจากหน้าท้องทารกประมาณ 2-3 ซม. ก่อนทำการตัดเพื่อหยุดเลือด',
      icon: '🔗',
    ),
    ToolItem(
      id: 'bulb',
      name: 'ลูกยางแดงดูดเสมหะ 🔴',
      short: 'เคลียร์ทางเดินหายใจเด็กแรกเกิด',
      description: 'ใช้สำหรับดูดน้ำคร่ำหรือเมือกในปากและจมูกทารกทันทีที่ศีรษะคลอดพ้น หลักสูตรเตือน: ต้องดูดในช่องปากก่อนดูดในรูจมูกเสมอเพื่อป้องกันทารกสะดุ้งสำลัก',
      icon: '🔴',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smartBirthStateProvider);
    final colors = Theme.of(context).extension<SmartBirthColors>() ?? warmColors;
    final activeTool = _tools[_activeCardIndex];

    final allChecked = _tools.every((t) => state.checklist[t.id] ?? false);
    final allViewed = _viewedCards.length == _tools.length;
    final canComplete = allChecked && allViewed;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ด่านที่ 1: เครื่องมือ & กายวิภาค',
          style: TextStyle(fontWeight: FontWeight.w900, color: colors.chocolateBrown),
        ),
        backgroundColor: colors.bgSecondary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header status actions row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NeobrutalistButton(
                  backgroundColor: colors.bgTertiary,
                  onTap: () => context.go('/dashboard'),
                  child: Text(
                    '🏠 กลับเมนูหลัก',
                    style: TextStyle(fontWeight: FontWeight.w800, color: colors.chocolateBrown),
                  ),
                ),
                NeobrutalistButton(
                  backgroundColor: canComplete ? colors.successGreen : Colors.grey.shade400,
                  onTap: canComplete
                      ? () {
                          ref.read(smartBirthStateProvider.notifier).completeStage('stage1');
                          ref.read(smartBirthStateProvider.notifier).addRewards(100, 50);
                          context.go('/dashboard');
                        }
                      : () {},
                  child: const Text(
                    'ส่งงานด่าน 1',
                    style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Dynamic Responsive Layout: Row on Tablet/Desktop, Column on Mobile
            ResponsiveLayout.isMobile(context)
                ? Column(
                    children: [
                      _buildChecklistCard(state, colors),
                      const SizedBox(height: 24),
                      _buildFlashcardSection(activeTool, colors),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildChecklistCard(state, colors),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: _buildFlashcardSection(activeTool, colors),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistCard(SmartBirthState state, SmartBirthColors colors) {
    return NeobrutalistCard(
      backgroundColor: colors.bgSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📝 เช็คลิสต์เตรียมเครื่องมือทำคลอด',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: colors.chocolateBrown),
          ),
          const SizedBox(height: 12),
          ..._tools.map((tool) {
            final isChecked = state.checklist[tool.id] ?? false;
            return CheckboxListTile(
              title: Text(
                tool.name,
                style: TextStyle(fontWeight: FontWeight.w900, color: colors.chocolateBrown),
              ),
              subtitle: Text(
                tool.short,
                style: TextStyle(fontWeight: FontWeight.w600, color: colors.textSecondary),
              ),
              value: isChecked,
              activeColor: colors.successGreen,
              onChanged: (val) {
                ref.read(smartBirthStateProvider.notifier).toggleChecklist(tool.id);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFlashcardSection(ToolItem activeTool, SmartBirthColors colors) {
    return Column(
      children: [
        // Interactive Flashcard
        GestureDetector(
          onTap: () => setState(() => _isFlipped = !_isFlipped),
          child: NeobrutalistCard(
            backgroundColor: _isFlipped ? colors.bgTertiary : colors.bgSecondary,
            child: Container(
              height: 240,
              width: double.infinity,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isFlipped) ...[
                    Text(activeTool.icon, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      activeTool.name,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: colors.chocolateBrown),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '👉 แตะแผ่นเพื่ออ่านคำแนะนำการใช้งานทางคลินิก',
                      style: TextStyle(fontSize: 11, color: colors.textSecondary, fontWeight: FontWeight.bold),
                    ),
                  ] else ...[
                    Text(
                      '🩺 แนวปฏิบัติทางคลินิก',
                      style: TextStyle(fontWeight: FontWeight.w900, color: colors.primaryPink, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        activeTool.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.chocolateBrown),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '👈 แตะแผ่นเพื่อพลิกกลับด้านหน้า',
                      style: TextStyle(fontSize: 11, color: colors.textSecondary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Flashcard Navigation Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: colors.chocolateBrown),
              onPressed: _activeCardIndex > 0
                  ? () => setState(() {
                        _activeCardIndex--;
                        _isFlipped = false;
                        _viewedCards.add(_activeCardIndex);
                      })
                  : null,
            ),
            Text(
              'การ์ดใบที่ ${_activeCardIndex + 1} / ${_tools.length}',
              style: TextStyle(fontWeight: FontWeight.w800, color: colors.chocolateBrown),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios, color: colors.chocolateBrown),
              onPressed: _activeCardIndex < _tools.length - 1
                  ? () => setState(() {
                        _activeCardIndex++;
                        _isFlipped = false;
                        _viewedCards.add(_activeCardIndex);
                      })
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
