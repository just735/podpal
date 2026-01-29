import 'package:flutter/material.dart';

class EditStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrev;
  const EditStep({super.key, required this.onNext, required this.onPrev});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 文案稿区域
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '文案稿',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 32),
                  _buildTranscriptItem('A', '00:00 - 00:12', '大家好，欢迎来到本期播客。今天我们要聊聊 AI 如何改变创作。'),
                  _buildTranscriptItem('B', '00:12 - 00:25', '没错，比如我们现在使用的这个 PodPal 平台，它能够智能识别语音内容。'),
                  _buildTranscriptItem('A', '00:25 - 00:38', '其实，它不仅能识别内容，还能识别你的语气和情感。'),
                  _buildTranscriptItem('B', '00:38 - 00:50', '这太神奇了，那我们接下来看看具体是怎么操作的。'),
                ],
              ),
            ),
          ),
        ),
        
        // 功能条
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildToolBtn(Icons.people_alt_outlined, '说话人'),
                  _buildToolBtn(Icons.emoji_emotions_outlined, '情绪'),
                  _buildToolBtn(Icons.translate, '语言'),
                  _buildToolBtn(Icons.search, '搜索'),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onPrev,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('上一步'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B9D),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('生成内容'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptItem(String speaker, String time, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: speaker == 'A' ? Colors.blue[50] : Colors.purple[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '说话人 $speaker',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: speaker == 'A' ? Colors.blue : Colors.purple,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildToolBtn(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Icon(icon, color: Colors.grey[700], size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
