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
  List<Map<String, String>> _generatedVideos = [];

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
            ...(_shownotesResult!['titles'] as List<String>).map((t) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(t, style: const TextStyle(fontSize: 13))),
                  const Icon(Icons.copy, size: 14, color: Color(0xFF818CF8)),
                ],
              ),
            )),
            const SizedBox(height: 12),
            const Text('摘要', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _shownotesResult!['summary'],
                style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF374151)),
              ),
            ),
          ],
        ],
      ),
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
          if (_generatedVideos.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            const Text('已生成视频预览', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            ..._generatedVideos.map((v) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(6),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1478737270239-2f02b77fc618?w=200&q=80'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(v['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        Text('时长: ${v['duration']} | 风格: ${v['style']}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download_rounded, size: 20, color: Color(0xFFF472B6)),
                    onPressed: () {},
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  void _generateVideoExample() async {
    setState(() => _isGeneratingVideo = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isGeneratingVideo = false;
      _generatedVideos.add({
        'name': '金句片段_${_generatedVideos.length + 1}',
        'duration': '00:45',
        'style': _videoTemplate,
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
