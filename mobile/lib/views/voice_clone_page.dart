import 'package:flutter/material.dart';
import 'dart:async';

class VoiceClonePage extends StatefulWidget {
  const VoiceClonePage({super.key});

  @override
  State<VoiceClonePage> createState() => _VoiceClonePageState();
}

class _VoiceClonePageState extends State<VoiceClonePage> {
  bool _isTraining = false;
  double _trainingProgress = 0;
  String _statusText = '未开始';
  
  final List<Map<String, String>> _history = [
    {'id': '1', 'name': '我的默认音色', 'date': '2024-01-20', 'status': '已完成'},
    {'id': '2', 'name': '专业播报音色', 'date': '2024-01-15', 'status': '已完成'},
  ];

  void _startTraining() {
    if (_isTraining) return;

    setState(() {
      _isTraining = true;
      _trainingProgress = 0;
      _statusText = '准备中...';
    });

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _trainingProgress += 0.05;
        if (_trainingProgress < 0.3) {
          _statusText = '上传音频中...';
        } else if (_trainingProgress < 0.7) {
          _statusText = '模型训练中...';
        } else if (_trainingProgress < 1.0) {
          _statusText = '音色生成中...';
        } else {
          _trainingProgress = 1.0;
          _statusText = '训练完成';
          _isTraining = false;
          _history.insert(0, {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'name': '新训练音色_${DateTime.now().month}${DateTime.now().day}',
            'date': '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
            'status': '已完成',
          });
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '训练个人音色模型',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '通过少量录音克隆你的专属音色，用于 AI 语音合成',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            
            // 步骤 1
            _buildStepCard(
              step: '1',
              title: '第一步：训练音色模型',
              subtitle: '录制或上传 1-3 分钟的高质量音频',
              icon: Icons.mic,
              color: const Color(0xFFFF6B9D),
              isActive: true,
              isTraining: _isTraining,
              progress: _trainingProgress,
              statusText: _statusText,
              buttonText: _isTraining ? '正在训练中...' : '开始录音训练',
              onPressed: _isTraining ? null : _startTraining,
            ),
            
            const SizedBox(height: 20),
            
            // 步骤 2
            _buildStepCard(
              step: '2',
              title: '第二步：添加克隆内容',
              subtitle: '训练完成后添加文本即可克隆读出',
              icon: Icons.edit_note,
              color: Colors.grey,
              isActive: _trainingProgress >= 1.0,
              isTraining: false,
              progress: 0,
              statusText: '',
              buttonText: _trainingProgress >= 1.0 ? '立即克隆' : '等待训练完成',
              onPressed: _trainingProgress >= 1.0 ? () {} : null,
            ),

            const SizedBox(height: 32),
            const Text(
              '历史训练记录',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _history[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B9D),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name']!,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              item['date']!,
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item['status']!,
                          style: TextStyle(color: Colors.green[700], fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // 指南
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.amber[800], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '训练指南',
                        style: TextStyle(
                          color: Colors.amber[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildGuideline('请在安静的环境下录音，避免背景噪音。'),
                  _buildGuideline('建议录制 3 分钟以上，音色还原度更高。'),
                  _buildGuideline('模型训练通常需要 5-10 分钟，完成后我们将通过邮件通知您。'),
                  _buildGuideline('严禁克隆他人音色，仅限个人使用。'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String step,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isActive,
    required bool isTraining,
    required double progress,
    required String statusText,
    required String buttonText,
    required VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFFFF6B9D).withOpacity(0.3) : Colors.grey[200]!,
          width: 2,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFFF6B9D).withOpacity(0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    step,
                    style: TextStyle(
                      color: isActive ? const Color(0xFFFF6B9D) : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.black : Colors.grey,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: isActive ? color : Colors.grey[300]),
            ],
          ),
          if (isTraining || progress > 0) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  statusText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF6B9D)),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF6B9D)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[100],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
                minHeight: 12,
              ),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive ? const Color(0xFFFF6B9D) : Colors.grey[300],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideline(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.amber[700])),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.amber[900]!.withOpacity(0.8), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
