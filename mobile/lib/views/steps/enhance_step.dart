import 'package:flutter/material.dart';

class EnhanceStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrev;
  const EnhanceStep({super.key, required this.onNext, required this.onPrev});

  @override
  State<EnhanceStep> createState() => _EnhanceStepState();
}

class _EnhanceStepState extends State<EnhanceStep> {
  String _podcastType = 'knowledge';
  final List<String> _platforms = ['公众号', '小红书', '微博', '短视频'];
  final Map<String, bool> _platformSelection = {
    '公众号': true,
    '小红书': true,
    '微博': false,
    '短视频': false,
  };
  
  String _videoAspectRatio = '9:16';
  String _videoTemplate = '简约风';
  bool _includeHighlights = true;

  // 生成状态与数据
  bool _isGeneratingShownotes = false;
  Map<String, dynamic>? _shownotesResult;

  bool _isGeneratingVideo = false;
  List<Map<String, dynamic>> _generatedVideoTasks = []; // 改为更详细的结构

  bool _isGeneratingSocial = false;
  Map<String, String> _socialResults = {};
  String _currentSocialPlatform = '公众号';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FAFB),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  
                  // 1. Shownotes 生成
                  _buildSectionTitle(
                    '智能 Shownotes', 
                    '一键生成标题、摘要、时间轴要点', 
                    Icons.description_outlined,
                    const Color(0xFF818CF8),
                  ),
                  const SizedBox(height: 12),
                  _buildShownotesSection(),
                  
                  const SizedBox(height: 32),
                  
                  // 2. 视频播客生成
                  _buildSectionTitle(
                    '视频播客生成', 
                    '包含金句选择与 AI 视频合成', 
                    Icons.videocam_outlined,
                    const Color(0xFFF472B6),
                  ),
                  const SizedBox(height: 12),
                  _buildVideoSection(),
                  
                  const SizedBox(height: 32),
                  
                  // 3. 多平台文案生成
                  _buildSectionTitle(
                    '多平台文案', 
                    '适配不同社交平台的推广素材', 
                    Icons.campaign_outlined,
                    const Color(0xFFFB923C),
                  ),
                  const SizedBox(height: 12),
                  _buildSocialSection(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '内容增值工作台',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 4),
            Text(
              '利用 AI 为您的播客创造更多价值',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShownotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('播客类型', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildDropdown<String>(
            value: _podcastType,
            items: [
              {'value': 'knowledge', 'label': '知识分享类 (干货提取)'},
              {'value': 'companion', 'label': '情感陪伴类 (氛围描述)'},
              {'value': 'interview', 'label': '访谈对话类 (观点碰撞)'},
            ],
            onChanged: (val) => setState(() => _podcastType = val!),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            label: _isGeneratingShownotes ? '正在生成...' : (_shownotesResult == null ? '生成 Shownotes' : '重新生成'),
            icon: _isGeneratingShownotes ? Icons.hourglass_empty : Icons.auto_awesome,
            color: const Color(0xFF818CF8),
            onPressed: _isGeneratingShownotes ? null : _generateShownotesExample,
          ),
          if (_shownotesResult != null) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            const Text('推荐标题', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            if (_shownotesResult!['titles'] != null)
              ...(_shownotesResult!['titles'] as List).map((t) => _buildTitleItem(t.toString())),
            const SizedBox(height: 16),
            const Text('摘要', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                _shownotesResult!['summary']?.toString() ?? '',
                style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF374151)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('时间轴要点', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            if (_shownotesResult!['timestamps'] != null)
              ...(_shownotesResult!['timestamps'] as List).map((item) {
                final map = item as Map;
                return _buildTimestampItem(map['time']?.toString() ?? '', map['desc']?.toString() ?? '');
              }),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('思维导图预览', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('正在基于时间轴生成思维导图...'), duration: Duration(seconds: 1)),
                    );
                  },
                  icon: const Icon(Icons.account_tree_outlined, size: 14),
                  label: const Text('重新生成导图', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF818CF8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: const Color(0xFF818CF8).withOpacity(0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMindmapPreview(_shownotesResult!['timestamps'] as List?),
          ],
        ],
      ),
    );
  }

  Widget _buildTitleItem(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark_border, size: 16, color: Color(0xFF818CF8)),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13))),
          const Icon(Icons.copy, size: 14, color: Color(0xFF818CF8)),
        ],
      ),
    );
  }

  Widget _buildTimestampItem(String time, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF818CF8),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMindmapPreview(List? timestamps) {
    // 如果没有数据，使用默认展示
    final List nodes = timestamps ?? [
      {'time': '00:00', 'desc': '开场'},
      {'time': '05:00', 'desc': '核心内容'},
      {'time': '10:00', 'desc': '总结'}
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF818CF8).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF818CF8).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMindmapNode('播客核心架构', time: 'TOPIC', isRoot: true),
          const SizedBox(height: 24),
          // 渲染思维导图节点
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: nodes.take(4).map((n) {
              final map = n as Map;
              return _buildMindmapNode(
                map['desc']?.toString() ?? '',
                time: map['time']?.toString(),
              );
            }).toList(),
          ),
          if (nodes.length > 4) ...[
            const SizedBox(height: 16),
            const Text('更多节点已在思维导图中生成...', style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
          ]
        ],
      ),
    );
  }

  Widget _buildMindmapNode(String label, {String? time, bool isRoot = false, List<Map<String, String>>? children}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: isRoot ? 16 : 12, vertical: isRoot ? 10 : 8),
          decoration: BoxDecoration(
            color: isRoot ? const Color(0xFF818CF8).withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isRoot ? const Color(0xFF818CF8).withOpacity(0.3) : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isRoot ? 14 : 12,
                  fontWeight: FontWeight.bold,
                  color: isRoot ? const Color(0xFF818CF8) : const Color(0xFF374151),
                ),
              ),
              if (time != null)
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isRoot ? const Color(0xFF818CF8).withOpacity(0.7) : Colors.grey,
                  ),
                ),
            ],
          ),
        ),
        if (children != null && children.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: children.map((child) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Text(child['label']!, style: const TextStyle(fontSize: 10, color: Color(0xFF4B5563))),
                  if (child['time'] != null)
                    Text(child['time']!, style: const TextStyle(fontSize: 8, color: Colors.grey)),
                ],
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }

  void _generateShownotesExample() async {
    setState(() => _isGeneratingShownotes = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isGeneratingShownotes = false;
      _shownotesResult = {
        'titles': [
          '为什么你的播客没人听？揭秘内容创作的底层逻辑',
          '从0到1：新手播客如何打造爆款内容',
          '播客创作避坑指南：我走过的那些弯路',
        ],
        'summary': '在本期节目中，我们深入探讨了播客创作的核心痛点。从选题策划到后期剪辑，分享了多个实用的技巧和工具。无论你是刚入门的新手，还是遇到瓶颈的资深创作者，都能从中获得启发。',
        'timestamps': [
          {'time': '00:00', 'desc': '节目开场及主题介绍'},
          {'time': '02:15', 'desc': 'AI 语音转写技术的演进历程'},
          {'time': '05:30', 'desc': 'PodPal 核心功能演示：智能去口癖'},
          {'time': '12:45', 'desc': '嘉宾分享：如何利用 AI 缩短 50% 的后期时间'},
          {'time': '20:10', 'desc': '未来展望：播客创作的下一个十年'},
        ],
      };
    });
  }

  Widget _buildVideoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('视频比例', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    _buildDropdown<String>(
                      value: _videoAspectRatio,
                      items: [
                        {'value': '9:16', 'label': '9:16 (短视频)'},
                        {'value': '16:9', 'label': '16:9 (横屏)'},
                        {'value': '1:1', 'label': '1:1 (方屏)'},
                      ],
                      onChanged: (val) => setState(() => _videoAspectRatio = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('视觉风格', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    _buildDropdown<String>(
                      value: _videoTemplate,
                      items: [
                        {'value': '简约风', 'label': '简约风'},
                        {'value': '动态文字', 'label': '动态文字'},
                        {'value': '播客演播室', 'label': '演播室'},
                      ],
                      onChanged: (val) => setState(() => _videoTemplate = val!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildToggleItem('自动提取金句片段', _includeHighlights, (val) => setState(() => _includeHighlights = val)),
          const SizedBox(height: 16),
          _buildActionButton(
            label: _isGeneratingVideo ? '正在合成视频...' : '开始生成视频',
            icon: _isGeneratingVideo ? Icons.hourglass_empty : Icons.movie_creation_outlined,
            color: const Color(0xFFF472B6),
            onPressed: _isGeneratingVideo ? null : _generateVideoExample,
          ),
          if (_generatedVideoTasks.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            const Text('已生成视频预览', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            ..._generatedVideoTasks.map((task) => _buildVideoTaskItem(
              task['name']?.toString() ?? '', 
              task['content']?.toString() ?? '', 
              task['desc']?.toString() ?? '', 
              (task['segments'] as List?)?.map((e) => e.toString()).toList() ?? [],
              viralPotential: task['viralPotential'] as int?,
              logicScore: task['logicScore'] as int?,
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoTaskItem(String title, String content, String desc, List<String> segments, {int? viralPotential, int? logicScore}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF472B6).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF472B6).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF472B6), Color(0xFFC084FC)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.movie_outlined, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(desc, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 20, color: Color(0xFFF472B6)),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.yellow.shade50, Colors.orange.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.yellow.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      segments.isNotEmpty ? segments.first : '00:00', 
                      style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500, fontFamily: 'monospace')
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('金句', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 13, 
                    color: Colors.black87, 
                    height: 1.5, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMetric('传播潜力', viralPotential ?? 90),
                    const SizedBox(width: 12),
                    _buildMetric('逻辑完整度', logicScore ?? 85),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.segment, size: 12, color: Colors.grey),
                    const SizedBox(width: 6),
                    const Text('对应片段:', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: segments.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.withOpacity(0.05)),
                    ),
                    child: Text(
                      s, 
                      style: const TextStyle(
                        fontSize: 10, 
                        color: Colors.black54, 
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500
                      )
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('编辑脚本', style: TextStyle(fontSize: 11)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF472B6).withOpacity(0.1),
                    foregroundColor: const Color(0xFFF472B6),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('预览视频', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, int value) {
    return Row(
      children: [
        Text('$label: ', style: TextStyle(fontSize: 9, color: Colors.grey[600])),
        Text('$value%', style: TextStyle(fontSize: 9, color: Colors.orange.shade700, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _generateVideoExample() async {
    setState(() => _isGeneratingVideo = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isGeneratingVideo = false;
      _generatedVideoTasks.add({
        'name': '金句片段_${_generatedVideoTasks.length + 1}',
        'content': _generatedVideoTasks.isEmpty 
          ? 'AI 正在重塑音频内容的生产流程，这不仅是效率的提升，更是创意的解放。'
          : '未来播客的竞争力不再是剪辑技术，而是内容深度与情感共鸣。',
        'desc': '时长: 00:45 | 风格: $_videoTemplate',
        'segments': _generatedVideoTasks.isEmpty ? ['00:05 - 00:50'] : ['02:15 - 02:47'],
        'viralPotential': _generatedVideoTasks.isEmpty ? 92 : 85,
        'logicScore': _generatedVideoTasks.isEmpty ? 88 : 94,
      });
    });
  }

  Widget _buildSocialSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('目标平台', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _platforms.map((p) => _buildChip(p)).toList(),
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            label: _isGeneratingSocial ? 'AI 正在创作...' : '生成全平台文案',
            icon: _isGeneratingSocial ? Icons.hourglass_empty : Icons.bolt,
            color: const Color(0xFFFB923C),
            onPressed: _isGeneratingSocial ? null : _generateSocialExample,
          ),
          if (_socialResults.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('文案预览', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const Spacer(),
                DropdownButton<String>(
                  value: _currentSocialPlatform,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                  style: const TextStyle(fontSize: 12, color: Color(0xFFFB923C), fontWeight: FontWeight.bold),
                  items: _socialResults.keys.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (val) => setState(() => _currentSocialPlatform = val!),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _socialResults[_currentSocialPlatform] ?? '',
                    style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF374151)),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.copy, size: 14),
                      label: const Text('复制文案', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFFFB923C)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _generateSocialExample() async {
    setState(() => _isGeneratingSocial = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isGeneratingSocial = false;
      _socialResults = {
        '公众号': '【本期必听】为什么你的播客没人听？揭秘内容创作的底层逻辑。\n\n在本期节目中，我们邀请到了资深播客制作人，深入探讨了从选题到分发的全流程技巧。无论你是新手还是老手，这篇干货分享都不容错过！\n\n👇 点击下方卡片收听完整节目',
        '小红书': '播客新手必看！3个技巧让你的内容更有吸引力 ✨\n\n最近很多小伙伴问我怎么做播客，今天就把压箱底的干货分享给大家：\n1️⃣ 选题要有共鸣\n2️⃣ 剪辑要快节奏\n3️⃣ 标题要抓人眼球\n\n详细内容都在我的最新一期播客里啦，大家快去听！\n\n#播客推荐 #内容创作 #自媒体干货 #Podpal',
        '微博': '做播客真的不难，难的是坚持。今天和大家聊聊播客创作中的那些坑，希望能帮到正在努力的你。🔗 网页链接 #播客# #内容创业#',
        '短视频': '播客创作避坑指南：我走过的那些弯路！从0到1教你打造爆款播客内容。#播客 #干货分享 #自媒体',
      };
      _currentSocialPlatform = '公众号';
    });
  }

  Widget _buildChip(String label) {
    bool isSelected = _platformSelection[label] ?? false;
    return GestureDetector(
      onTap: () => setState(() => _platformSelection[label] = !isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFB923C).withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFB923C) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? const Color(0xFFFB923C) : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563))),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFF472B6),
          activeTrackColor: const Color(0xFFF472B6).withOpacity(0.2),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE5E7EB)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.toString(),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
          items: items.map((e) => DropdownMenuItem(
            value: e['value'], 
            child: Text(e['label'] ?? '')
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _showResultDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFFF6B9D), size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Color(0xFF4B5563))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('好的', style: TextStyle(color: Color(0xFFFF6B9D), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
