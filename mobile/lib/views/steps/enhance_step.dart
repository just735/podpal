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

  // 生成状态与数据 - 拆分Shownotes和思维导图
  bool _isGeneratingShownotes = false;
  Map<String, dynamic>? _shownotesResult;

  bool _isGeneratingMindmap = false;
  Map<String, dynamic>? _mindmapResult; // 思维导图独立数据

  bool _isGeneratingVideo = false;
  List<Map<String, dynamic>> _generatedVideoTasks = [];

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
                  
                  // 1. Shownotes 生成（仅标题、摘要、时间轴）
                  _buildSectionTitle(
                    '智能 Shownotes', 
                    '一键生成标题、摘要、时间轴要点（对外展示）', 
                    Icons.description_outlined,
                    const Color(0xFF818CF8),
                  ),
                  const SizedBox(height: 12),
                  _buildShownotesSection(),
                  
                  const SizedBox(height: 32),
                  
                  // 2. 思维导图生成（独立模块，层级化内容架构）
                  _buildSectionTitle(
                    '内容思维导图', 
                    '生成结构化的核心内容框架（创作梳理）', 
                    Icons.account_tree_outlined,
                    const Color(0xFF60A5FA),
                  ),
                  const SizedBox(height: 12),
                  _buildMindmapSection(),
                  
                  const SizedBox(height: 32),
                  
                  // 3. 视频播客生成
                  _buildSectionTitle(
                    '视频播客生成', 
                    '包含金句选择与 AI 视频合成', 
                    Icons.videocam_outlined,
                    const Color(0xFFF472B6),
                  ),
                  const SizedBox(height: 12),
                  _buildVideoSection(),
                  
                  const SizedBox(height: 32),
                  
                  // 4. 多平台文案生成
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
          
          const SizedBox(height: 20),
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

  // ========== 1. Shownotes 模块（仅标题、摘要、时间轴） ==========
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
          
          // Shownotes 结果展示（仅标题、摘要、时间轴）
          if (_shownotesResult != null) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            
            // 推荐标题
            const Text('推荐标题', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            if (_shownotesResult!['titles'] != null)
              ...(_shownotesResult!['titles'] as List).asMap().entries.map((e) => _buildTitleItem(e.value.toString(), e.key)),
            
            const SizedBox(height: 16),
            
            // 摘要
            const Text('摘要', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _shownotesResult!['summary']?.toString() ?? '',
                      style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF374151)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 14, color: Color(0xFF818CF8)),
                    onPressed: () => _editSummary(_shownotesResult!['summary']?.toString() ?? ''),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 时间轴要点
            const Text('时间轴要点', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            if (_shownotesResult!['timestamps'] != null)
              ...(_shownotesResult!['timestamps'] as List).asMap().entries.map((e) {
                final map = e.value as Map;
                return _buildTimestampItem(map['time']?.toString() ?? '', map['desc']?.toString() ?? '', e.key);
              }),
          ],
        ],
      ),
    );
  }

  // ========== 2. 思维导图模块（独立、层级化内容） ==========
  Widget _buildMindmapSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('思维导图配置', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildDropdown<String>(
            value: _podcastType,
            items: [
              {'value': 'knowledge', 'label': '知识分享类 (按知识点分层)'},
              {'value': 'companion', 'label': '情感陪伴类 (按情绪脉络分层)'},
              {'value': 'interview', 'label': '访谈对话类 (按观点逻辑分层)'},
            ],
            onChanged: (val) => setState(() => _podcastType = val!),
            enabled: false, // 与Shownotes共用播客类型，禁用修改
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            label: _isGeneratingMindmap ? '正在生成...' : (_mindmapResult == null ? '生成思维导图' : '重新生成'),
            icon: _isGeneratingMindmap ? Icons.hourglass_empty : Icons.account_tree_outlined,
            color: const Color(0xFF60A5FA),
            onPressed: _isGeneratingMindmap ? null : _generateMindmapExample,
          ),
          
          // 思维导图结果展示（层级化架构）
          if (_mindmapResult != null) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            
            const Text('核心内容架构', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            
            // 渲染层级化思维导图
            _buildHierarchicalMindmap(_mindmapResult!['nodes'] as List),
            
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('思维导图已导出为PDF格式'), duration: Duration(seconds: 2)),
                  );
                },
                icon: const Icon(Icons.download_outlined, size: 14),
                label: const Text('导出思维导图', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF60A5FA),
                  backgroundColor: const Color(0xFF60A5FA).withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 层级化思维导图渲染（区分根节点、一级节点、二级节点）
  Widget _buildHierarchicalMindmap(List nodes) {
    // 根节点（仅1个）
    final rootNode = nodes.firstWhere((n) => (n as Map)['level'] == 0);
    // 一级节点
    final level1Nodes = nodes.where((n) => (n as Map)['level'] == 1).toList();
    // 二级节点
    final level2Nodes = nodes.where((n) => (n as Map)['level'] == 2).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF60A5FA).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 根节点
          _buildMindmapNode(
            (rootNode as Map)['label']?.toString() ?? '',
            isRoot: true,
            time: (rootNode)['time']?.toString(),
          ),
          const SizedBox(height: 24),
          
          // 一级节点 + 二级节点
          ...level1Nodes.map((level1) {
            final level1Map = level1 as Map;
            // 找到当前一级节点下的二级节点
            final childNodes = level2Nodes.where((n) => (n as Map)['parent'] == level1Map['id']).toList();
            
            return Column(
              children: [
                _buildMindmapNode(
                  level1Map['label']?.toString() ?? '',
                  isRoot: false,
                  level: 1,
                  time: level1Map['time']?.toString(),
                ),
                if (childNodes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.start,
                      children: childNodes.map((level2) {
                        final level2Map = level2 as Map;
                        return _buildMindmapNode(
                          level2Map['label']?.toString() ?? '',
                          isRoot: false,
                          level: 2,
                          time: level2Map['time']?.toString(),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            );
          }),
        ],
      ),
    );
  }

  // 思维导图节点样式（区分层级）
  Widget _buildMindmapNode(String label, {bool isRoot = false, int level = 0, String? time}) {
    Color nodeColor = const Color(0xFF60A5FA);
    double paddingH = isRoot ? 20 : (level == 1 ? 16 : 12);
    double paddingV = isRoot ? 12 : (level == 1 ? 10 : 8);
    double fontSize = isRoot ? 15 : (level == 1 ? 13 : 11);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
      decoration: BoxDecoration(
        color: isRoot 
            ? nodeColor.withOpacity(0.1) 
            : (level == 1 ? Colors.grey[50] : Colors.white),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isRoot 
              ? nodeColor.withOpacity(0.3) 
              : (level == 1 ? nodeColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: isRoot 
                  ? nodeColor 
                  : (level == 1 ? const Color(0xFF374151) : const Color(0xFF4B5563)),
            ),
          ),
          if (time != null)
            Text(
              time,
              style: TextStyle(
                fontSize: fontSize - 2,
                color: isRoot 
                    ? nodeColor.withOpacity(0.7) 
                    : Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  // ========== 3. 视频播客模块 ==========
  String _videoAvatarType = 'virtual'; // 'virtual' 或 'upload'
  String _videoSubtitleStyle = '简洁白底';
  String _videoBGM = '';
  final List<String> _subtitleStyles = ['简洁白底', '卡拉OK高亮', '科技霓虹', '文艺清新'];
  final Map<String, String> _emotionBGMMap = {
    '平静': 'LoFi Chill',
    '兴奋': 'Upbeat Pop',
    '坚定': 'Epic Orchestral',
    '温柔': 'Acoustic Guitar',
    '幽默': 'Quirky Fun',
    '严肃': 'Minimal Piano',
    '亲切': 'Warm Jazz',
    '激昂': 'Motivational Rock',
  };

  Widget _buildVideoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 角色形象选择
          const Text('角色形象', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildAvatarOption(
                  '使用虚拟形象',
                  Icons.smart_toy_outlined,
                  _videoAvatarType == 'virtual',
                  () => setState(() => _videoAvatarType = 'virtual'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAvatarOption(
                  '上传角色照片',
                  Icons.add_photo_alternate_outlined,
                  _videoAvatarType == 'upload',
                  () => setState(() => _videoAvatarType = 'upload'),
                ),
              ),
            ],
          ),
          if (_videoAvatarType == 'upload') ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 32, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text('点击上传角色照片', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text('支持 JPG、PNG 格式', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // 视频比例和字幕样式
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
                    const Text('字幕样式', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    _buildDropdown<String>(
                      value: _videoSubtitleStyle,
                      items: _subtitleStyles.map((s) => {'value': s, 'label': s}).toList(),
                      onChanged: (val) => setState(() => _videoSubtitleStyle = val!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // AI 推荐 BGM
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF2F8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFBCFE8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.music_note, size: 16, color: Color(0xFFF472B6)),
                    const SizedBox(width: 6),
                    const Text('AI 智能 BGM 推荐', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFF472B6))),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF472B6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('自动匹配', style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('系统将根据金句情感自动推荐背景音乐', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _emotionBGMMap.entries.map((e) => _buildBGMChip(e.key, e.value)).toList(),
                ),
              ],
            ),
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
              emotion: task['emotion']?.toString(),
              bgm: task['bgm']?.toString(),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarOption(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDF2F8) : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFFF472B6) : Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: isSelected ? const Color(0xFFF472B6) : Colors.grey[600]),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 11, color: isSelected ? const Color(0xFFF472B6) : Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildBGMChip(String emotion, String bgm) {
    final isSelected = _videoBGM == bgm;
    return GestureDetector(
      onTap: () => setState(() => _videoBGM = bgm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF472B6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFFF472B6) : Colors.grey.shade300),
        ),
        child: Text(
          '$emotion · $bgm',
          style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.grey[700]),
        ),
      ),
    );
  }

  // ========== 4. 多平台文案模块 ==========
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _editSocialContent(_currentSocialPlatform),
                        icon: const Icon(Icons.edit, size: 14),
                        label: const Text('编辑', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFFB923C)),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.copy, size: 14),
                        label: const Text('复制', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFFB923C)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ========== 工具方法 ==========
  Widget _buildTitleItem(String title, int index) {
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
          IconButton(
            icon: const Icon(Icons.edit, size: 14, color: Color(0xFF818CF8)),
            onPressed: () => _editTitle(title, index),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.copy, size: 14, color: Color(0xFF818CF8)),
        ],
      ),
    );
  }

  void _editTitle(String currentTitle, int index) async {
    final controller = TextEditingController(text: currentTitle);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑标题'),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: '请输入新标题',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF818CF8)),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (newTitle != null && newTitle.isNotEmpty) {
      setState(() {
        _shownotesResult!['titles'][index] = newTitle;
      });
    }
  }

  void _editSummary(String currentSummary) async {
    final controller = TextEditingController(text: currentSummary);
    final newSummary = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑摘要'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: '请输入新摘要',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF818CF8)),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (newSummary != null && newSummary.isNotEmpty) {
      setState(() {
        _shownotesResult!['summary'] = newSummary;
      });
    }
  }

  void _editTimestamp(String currentTime, String currentDesc, int index) async {
    final timeController = TextEditingController(text: currentTime);
    final descController = TextEditingController(text: currentDesc);
    
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑时间轴要点'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: '时间',
                hintText: '如：00:00',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '内容',
                hintText: '请输入时间轴内容',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'time': timeController.text,
              'desc': descController.text,
            }),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF818CF8)),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    
    if (result != null && result['time'] != null && result['desc'] != null) {
      setState(() {
        _shownotesResult!['timestamps'][index] = {
          'time': result['time']!,
          'desc': result['desc']!,
        };
      });
    }
  }

  Widget _buildTimestampItem(String time, String desc, int index) {
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
          IconButton(
            icon: const Icon(Icons.edit, size: 14, color: Color(0xFF818CF8)),
            onPressed: () => _editTimestamp(time, desc, index),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTaskItem(String title, String content, String desc, List<String> segments, {int? viralPotential, int? logicScore, String? emotion, String? bgm}) {
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
                if (emotion != null || bgm != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2F8),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFBCFE8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (emotion != null) ...[
                          Icon(Icons.emoji_emotions_outlined, size: 12, color: const Color(0xFFF472B6)),
                          const SizedBox(width: 4),
                          Text('情感: $emotion', style: const TextStyle(fontSize: 10, color: Color(0xFFF472B6))),
                        ],
                        if (emotion != null && bgm != null) ...[
                          const SizedBox(width: 12),
                          Container(width: 1, height: 10, color: const Color(0xFFFBCFE8)),
                          const SizedBox(width: 12),
                        ],
                        if (bgm != null) ...[
                          Icon(Icons.music_note, size: 12, color: const Color(0xFFF472B6)),
                          const SizedBox(width: 4),
                          Text('BGM: $bgm', style: const TextStyle(fontSize: 10, color: Color(0xFFF472B6))),
                        ],
                      ],
                    ),
                  ),
                ],
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
    bool enabled = true,
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
          style: TextStyle(
            fontSize: 14, 
            color: enabled ? const Color(0xFF1F2937) : Colors.grey[500]
          ),
          items: items.map((e) => DropdownMenuItem(
            value: e['value'], 
            child: Text(e['label'] ?? '')
          )).toList(),
          onChanged: enabled ? onChanged : null,
          disabledHint: Text(items.firstWhere((e) => e['value'] == value.toString())['label'] ?? '', 
            style: TextStyle(color: Colors.grey[500])),
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

  // ========== 生成示例数据 ==========
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

  void _generateMindmapExample() async {
    setState(() => _isGeneratingMindmap = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isGeneratingMindmap = false;
      _mindmapResult = {
        'nodes': [
          // 根节点
          {'id': 'root', 'level': 0, 'label': '播客创作核心方法论', 'time': '全片'},
          // 一级节点
          {'id': '1', 'level': 1, 'label': '前期准备', 'time': '00:00-05:00', 'parent': 'root'},
          {'id': '2', 'level': 1, 'label': '中期制作', 'time': '05:00-15:00', 'parent': 'root'},
          {'id': '3', 'level': 1, 'label': '后期优化', 'time': '15:00-20:00', 'parent': 'root'},
          // 二级节点（前期准备）
          {'id': '1-1', 'level': 2, 'label': '选题策划', 'time': '00:00-02:00', 'parent': '1'},
          {'id': '1-2', 'level': 2, 'label': '嘉宾沟通', 'time': '02:00-03:30', 'parent': '1'},
          {'id': '1-3', 'level': 2, 'label': '设备调试', 'time': '03:30-05:00', 'parent': '1'},
          // 二级节点（中期制作）
          {'id': '2-1', 'level': 2, 'label': '录音技巧', 'time': '05:00-08:00', 'parent': '2'},
          {'id': '2-2', 'level': 2, 'label': 'AI转写', 'time': '08:00-10:00', 'parent': '2'},
          {'id': '2-3', 'level': 2, 'label': '初剪成型', 'time': '10:00-15:00', 'parent': '2'},
          // 二级节点（后期优化）
          {'id': '3-1', 'level': 2, 'label': '去口癖处理', 'time': '15:00-17:00', 'parent': '3'},
          {'id': '3-2', 'level': 2, 'label': '音效添加', 'time': '17:00-18:30', 'parent': '3'},
          {'id': '3-3', 'level': 2, 'label': '导出发布', 'time': '18:30-20:00', 'parent': '3'},
        ]
      };
    });
  }

  // 根据内容智能生成标题
  String _generateSmartTitle(String content) {
    if (content.contains('AI') || content.contains('人工智能')) {
      return 'AI赋能：播客创作的新纪元';
    } else if (content.contains('竞争力') || content.contains('技术')) {
      return '深度思考：播客的核心竞争力是什么';
    } else if (content.contains('情感') || content.contains('共鸣')) {
      return '情感共鸣：让听众爱上你的声音';
    } else if (content.contains('效率') || content.contains('解放')) {
      return '效率革命：AI如何解放创作者';
    } else {
      return '金句时刻：值得回味的精彩观点';
    }
  }

  // 根据内容分析情感
  String _analyzeEmotion(String content) {
    if (content.contains('解放') || content.contains('提升')) {
      return '兴奋';
    } else if (content.contains('竞争力') || content.contains('深度')) {
      return '坚定';
    } else if (content.contains('情感') || content.contains('共鸣')) {
      return '温柔';
    } else {
      return '平静';
    }
  }

  void _generateVideoExample() async {
    setState(() => _isGeneratingVideo = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isGeneratingVideo = false;
      
      final content = _generatedVideoTasks.isEmpty 
        ? 'AI 正在重塑音频内容的生产流程，这不仅是效率的提升，更是创意的解放。'
        : '未来播客的竞争力不再是剪辑技术，而是内容深度与情感共鸣。';
      
      // 智能分析情感并推荐BGM
      final emotion = _analyzeEmotion(content);
      final bgm = _emotionBGMMap[emotion] ?? 'LoFi Chill';
      
      // 使用智能标题而非编号
      final smartTitle = _generateSmartTitle(content);
      
      _generatedVideoTasks.add({
        'name': smartTitle,
        'content': content,
        'desc': '时长: 00:45 | 字幕: $_videoSubtitleStyle | 形象: ${_videoAvatarType == 'virtual' ? '虚拟形象' : '自定义角色'}',
        'segments': _generatedVideoTasks.isEmpty ? ['00:05 - 00:50'] : ['02:15 - 02:47'],
        'viralPotential': _generatedVideoTasks.isEmpty ? 92 : 85,
        'logicScore': _generatedVideoTasks.isEmpty ? 88 : 94,
        'emotion': emotion,
        'bgm': _videoBGM.isNotEmpty ? _videoBGM : bgm,
      });
    });
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

  void _editSocialContent(String platform) async {
    final controller = TextEditingController(text: _socialResults[platform] ?? '');
    final newContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('编辑 $platform 文案'),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: '请输入文案内容',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFB923C)),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (newContent != null) {
      setState(() {
        _socialResults[platform] = newContent;
      });
    }
  }
}