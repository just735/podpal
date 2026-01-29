import 'package:flutter/material.dart';

class PublishStep extends StatelessWidget {
  final VoidCallback onPrev;
  const PublishStep({super.key, required this.onPrev});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            '选择平台上传',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '一键同步到主流播客平台',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          
          // 平台列表
          _buildPlatformItem('小宇宙', 'https://placeholder.com/xyz', true),
          _buildPlatformItem('Apple Podcasts', 'https://placeholder.com/apple', true),
          _buildPlatformItem('Spotify', 'https://placeholder.com/spotify', false),
          _buildPlatformItem('喜马拉雅', 'https://placeholder.com/xmly', false),
          
          const Spacer(),
          
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onPrev,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('返回增强'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('正在发布中，请稍候...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('确认发布'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text('仅导出到本地相册/文件夹', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformItem(String name, String iconUrl, bool isLinked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.podcasts, color: Color(0xFFFF6B9D)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  isLinked ? '已绑定账号' : '未绑定',
                  style: TextStyle(
                    fontSize: 12,
                    color: isLinked ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: isLinked,
            onChanged: (val) {},
            activeColor: const Color(0xFFFF6B9D),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }
}
