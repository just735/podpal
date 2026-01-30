import 'package:flutter/material.dart';

class PublishStep extends StatefulWidget {
  final VoidCallback onPrev;
  const PublishStep({super.key, required this.onPrev});

  @override
  State<PublishStep> createState() => _PublishStepState();
}

class _PublishStepState extends State<PublishStep> {
  String _selectedFormat = 'audio'; // audio, video_9_16, video_16_9

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: [
                _buildPlatformItem('小宇宙', Icons.rocket_launch, true, const Color(0xFFFBBF24)),
                _buildPlatformItem('Apple 播客', Icons.podcasts, true, const Color(0xFFFB923C)),
                _buildPlatformItem('微信听书', Icons.wechat, false, const Color(0xFF16A34A)),
                _buildPlatformItem('抖音', Icons.music_note, false, Colors.black),
                _buildPlatformItem('QQ 音乐', Icons.queue_music, false, const Color(0xFF2563EB)),
                _buildPlatformItem('小红书', Icons.camera_alt, false, const Color(0xFFDC2626)),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('正在发布中，请稍候...')),
                );
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

  Widget _buildPlatformItem(String name, IconData icon, bool isLinked, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLinked ? themeColor.withOpacity(0.3) : Colors.grey[200]!),
        boxShadow: isLinked ? [
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
                  color: isLinked ? themeColor.withOpacity(0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isLinked ? themeColor : Colors.grey[400],
                ),
              ),
              if (isLinked)
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
              color: isLinked ? Colors.black87 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            isLinked ? '已绑定' : '未绑定',
            style: TextStyle(
              fontSize: 9,
              color: isLinked ? themeColor : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
