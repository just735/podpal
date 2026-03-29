import 'package:flutter/material.dart';

class PublishStep extends StatefulWidget {
  final VoidCallback onPrev;
  final VoidCallback onPublishSuccess;
  const PublishStep({super.key, required this.onPrev, required this.onPublishSuccess});

  @override
  State<PublishStep> createState() => _PublishStepState();
}

class _PublishStepState extends State<PublishStep> {
  String _selectedFormat = 'audio'; // audio, video_9_16, video_16_9
  int _previewTab = 0; // 0: 音频, 1: 视频, 2: 文案
  bool _isPlaying = false;
  double _playbackProgress = 0.0;
  
  final List<Map<String, dynamic>> _platforms = [
    {'name': '小宇宙', 'icon': Icons.rocket_launch, 'color': const Color(0xFFFBBF24), 'selected': false},
    {'name': 'Apple 播客', 'icon': Icons.podcasts, 'color': const Color(0xFFFB923C), 'selected': false},
    {'name': '微信听书', 'icon': Icons.wechat, 'color': const Color(0xFF16A34A), 'selected': false},
    {'name': '抖音', 'icon': Icons.music_note, 'color': Colors.black, 'selected': false},
    {'name': 'QQ 音乐', 'icon': Icons.queue_music, 'color': const Color(0xFF2563EB), 'selected': false},
    {'name': '小红书', 'icon': Icons.camera_alt, 'color': const Color(0xFFDC2626), 'selected': false},
  ];









  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '导出设置',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFormatOption('audio', '纯音频', Icons.audiotrack),
              const SizedBox(width: 12),
              _buildFormatOption('video_9_16', '竖屏视频', Icons.stay_current_portrait),
              const SizedBox(width: 12),
              _buildFormatOption('video_16_9', '横屏视频', Icons.stay_current_landscape),
            ],
          ),
          const SizedBox(height: 24),
          
          // 预览区域
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '内容预览',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    const Spacer(),
                    // 预览标签切换
                    Row(
                      children: [
                        _buildPreviewTab(0, '音频', Icons.audiotrack),
                        const SizedBox(width: 8),
                        _buildPreviewTab(1, '视频', Icons.videocam),
                        const SizedBox(width: 8),
                        _buildPreviewTab(2, '文案', Icons.description),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 预览内容
                IndexedStack(
                  index: _previewTab,
                  children: [
                    _buildAudioPreview(),
                    _buildVideoPreview(),
                    _buildTextPreview(),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          const Text(
            '选择平台上传',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '一键同步到主流播客平台',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 16),
          
          // 平台列表
          SizedBox(
            height: 280,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _platforms.length,
              itemBuilder: (context, index) {
                final platform = _platforms[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _platforms[index]['selected'] = !_platforms[index]['selected'];
                    });
                  },
                  child: _buildPlatformItem(
                    platform['name'],
                    platform['icon'],
                    platform['selected'],
                    platform['color'],
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final selectedPlatforms = _platforms.where((p) => p['selected'] == true).toList();
                
                if (selectedPlatforms.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请至少选择一个发布平台')),
                  );
                  return;
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('正在发布中，请稍候...')),
                );
                
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                '发布成功！',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '您的播客已成功发布到 ${selectedPlatforms.length} 个平台',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    widget.onPublishSuccess();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6B9D),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    '返回首页',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('确认发布', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text('仅导出到本地相册/文件夹', style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatOption(String format, String label, IconData icon) {
    bool isSelected = _selectedFormat == format;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFormat = format),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF6B9D).withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, color: isSelected ? const Color(0xFFFF6B9D) : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformItem(String name, IconData icon, bool isSelected, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? themeColor.withOpacity(0.3) : Colors.grey[200]!),
        boxShadow: isSelected ? [
          BoxShadow(
            color: themeColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? themeColor.withOpacity(0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? themeColor : Colors.grey[400],
                ),
              ),
              if (isSelected)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, size: 14, color: Colors.green),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 12,
              color: isSelected ? Colors.black87 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            isSelected ? '已选择' : '未选择',
            style: TextStyle(
              fontSize: 9,
              color: isSelected ? themeColor : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewTab(int index, String label, IconData icon) {
    final isSelected = _previewTab == index;
    return GestureDetector(
      onTap: () => setState(() => _previewTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/fengmian.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        '音频预览',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击播放预览音频',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  '00:00',
                  style: const TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'monospace'),
                ),
              ),
              const Text('/', style: TextStyle(fontSize: 14, color: Colors.grey)),
              Expanded(
                child: Text(
                  '15:30',
                  style: const TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'monospace'),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: _playbackProgress,
            onChanged: (value) => setState(() => _playbackProgress = value),
            activeColor: const Color(0xFFFF6B9D),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10),
                onPressed: () {},
                iconSize: 24,
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => setState(() => _isPlaying = !_isPlaying),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B9D),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.forward_10),
                onPressed: () {},
                iconSize: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_selectedFormat == 'audio') {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey.shade100,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.music_note, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  '纯音频模式',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '当前选择为纯音频导出，无视频预览',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: _selectedFormat == 'video_9_16' ? 9/16 : 16/9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/vp.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        '视频预览',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击播放预览视频',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildVideoInfo('分辨率', _selectedFormat == 'video_9_16' ? '1080x1920' : '1920x1080'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVideoInfo('帧率', '30fps'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildVideoInfo('格式', 'MP4'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVideoInfo('大小', '约 45MB'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoInfo(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
          ),
        ],
      ),
    );
  }

  // 平台列表
  final List<Map<String, dynamic>> _textPlatforms = [
    {'name': '通用', 'icon': Icons.public, 'color': const Color(0xFF6B7280), 'selected': true},
    {'name': '小宇宙', 'icon': Icons.rocket_launch, 'color': const Color(0xFFFBBF24), 'selected': false},
    {'name': '抖音', 'icon': Icons.music_note, 'color': const Color(0xFF000000), 'selected': false},
    {'name': '小红书', 'icon': Icons.camera_alt, 'color': const Color(0xFFDC2626), 'selected': false},
  ];
  
  // 获取当前选中的平台索引
  int get _selectedPlatformIndex {
    return _textPlatforms.indexWhere((platform) => platform['selected'] == true);
  }
  
  // 根据平台生成不同格式的文案
  String getPlatformTitle(int platformIndex) {
    switch (platformIndex) {
      case 1: // 小宇宙
        return '【AI赋能】播客创作的新纪元 | 让创作更简单';
      case 2: // 抖音
        return 'AI赋能播客创作！看完这个视频，你的创作效率提升50% #播客创作 #AI工具';
      case 3: // 小红书
        return '🔥播客创作新纪元：AI赋能让你告别繁琐后期';
      default: // 通用
        return 'AI赋能：播客创作的新纪元';
    }
  }
  
  String getPlatformSummary(int platformIndex) {
    switch (platformIndex) {
      case 1: // 小宇宙
        return '在本期节目中，我们深入探讨了播客创作的核心痛点，分享了如何利用AI技术提升创作效率。从选题策划到后期剪辑，多个实用技巧等你来学！\n\n🎧 适合人群：播客新手、资深创作者\n🎯 核心亮点：AI智能去口癖、语音转写、自动剪辑\n\n#播客创作 #AI工具 #内容创作';
      case 2: // 抖音
        return '想知道如何用AI让播客创作更简单？本期视频告诉你！\n\n从选题到剪辑，AI全程助力，让你节省50%的后期时间！\n\n💡 关键技巧：智能去口癖、语音转写、自动剪辑\n⏰ 时长：15分钟\n\n#播客创作 #AI工具 #内容创作 #效率提升';
      case 3: // 小红书
        return '【播客创作必备工具】AI赋能让你告别繁琐后期\n\n作为一名播客创作者，你是否也被这些问题困扰？\n• 后期剪辑耗时太长\n• 口癖太多影响收听体验\n• 选题策划缺乏灵感\n\n本期分享AI工具如何解决这些痛点，让你的创作效率提升50%！\n\n#播客创作 #AI工具 #内容创作 #效率提升';
      default: // 通用
        return '在本期节目中，我们深入探讨了播客创作的核心痛点。从选题策划到后期剪辑，分享了多个实用的技巧和工具。无论你是刚入门的新手，还是遇到瓶颈的资深创作者，都能从中获得启发。';
    }
  }
  
  Widget _buildTextPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 平台选择标签页
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_textPlatforms.length, (index) {
                  final platform = _textPlatforms[index];
                  final isSelected = platform['selected'] == true;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        // 先取消所有平台的选择状态
                        for (var p in _textPlatforms) {
                          p['selected'] = false;
                        }
                        // 然后选择当前平台
                        _textPlatforms[index]['selected'] = true;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? platform['color'] as Color : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: (platform['color'] as Color).withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ] : null,
                      ),
                      child: Row(
                        children: [
                          Icon(platform['icon'] as IconData, size: 16, color: isSelected ? Colors.white : Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            platform['name'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.grey,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '推荐标题',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Text(
                    getPlatformTitle(_selectedPlatformIndex),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '内容摘要',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Text(
                    getPlatformSummary(_selectedPlatformIndex),
                    style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF374151)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '时间轴要点',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 8),
                _buildTimestampItem('00:00', '节目开场及主题介绍'),
                _buildTimestampItem('02:15', 'AI 语音转写技术的演进历程'),
                _buildTimestampItem('05:30', 'PodPal 核心功能演示：智能去口癖'),
                _buildTimestampItem('12:45', '嘉宾分享：如何利用 AI 缩短 50% 的后期时间'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('编辑', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6B9D),
                    side: const BorderSide(color: Color(0xFFFF6B9D)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // 复制文案到剪贴板
                    final text = '${getPlatformTitle(_selectedPlatformIndex)}\n\n${getPlatformSummary(_selectedPlatformIndex)}\n\n时间轴要点：\n00:00 节目开场及主题介绍\n02:15 AI 语音转写技术的演进历程\n05:30 PodPal 核心功能演示：智能去口癖\n12:45 嘉宾分享：如何利用 AI 缩短 50% 的后期时间';
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('文案已复制到剪贴板')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('复制', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampItem(String time, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B9D),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
            ),
          ),
        ],
      ),
    );
  }
}
