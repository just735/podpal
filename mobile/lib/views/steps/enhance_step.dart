import 'package:flutter/material.dart';

class EnhanceStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrev;
  const EnhanceStep({super.key, required this.onNext, required this.onPrev});

  @override
  State<EnhanceStep> createState() => _EnhanceStepState();
}

class _EnhanceStepState extends State<EnhanceStep> {
  final List<String> _selectedTools = [];

  void _toggleTool(String tool) {
    setState(() {
      if (_selectedTools.contains(tool)) {
        _selectedTools.remove(tool);
      } else {
        _selectedTools.add(tool);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 功能栏
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI 增强功能',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildToolChip('去口语冗余', Icons.cleaning_services),
                  _buildToolChip('逻辑纠错', Icons.fact_check),
                  _buildToolChip('高光提取', Icons.auto_awesome),
                  _buildToolChip('BGM 匹配', Icons.music_note),
                  _buildToolChip('声线克隆', Icons.record_voice_over),
                ],
              ),
            ],
          ),
        ),

        // 生成内容区域
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: _selectedTools.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_fix_high, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          '选择上方功能开始增强',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      const Text(
                        '生成预览',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedTools.contains('去口语冗余'))
                        _buildPreviewItem('去口语冗余', '已自动识别并删除 12 处“那个”、“然后”等口癖。'),
                      if (_selectedTools.contains('高光提取'))
                        _buildPreviewItem('高光提取', '已为您提取 3 段精华片段，总计 45 秒。'),
                      if (_selectedTools.contains('BGM 匹配'))
                        _buildPreviewItem('BGM 匹配', '根据情感分析，推荐背景音乐：LoFi Chill Beats。'),
                    ],
                  ),
          ),
        ),

        // 底部按钮
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onPrev,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('返回剪辑'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('进入发布'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolChip(String label, IconData icon) {
    bool isSelected = _selectedTools.contains(label);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _toggleTool(label),
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey),
      selectedColor: const Color(0xFFFF6B9D),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[300]!),
      ),
    );
  }

  Widget _buildPreviewItem(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF6B9D).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6B9D)),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
