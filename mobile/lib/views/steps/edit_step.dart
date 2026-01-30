import 'package:flutter/material.dart';

class EditStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrev;
  const EditStep({super.key, required this.onNext, required this.onPrev});

  @override
  State<EditStep> createState() => _EditStepState();
}

class _EditStepState extends State<EditStep> {
  final List<Map<String, dynamic>> _transcript = [
    {
      'speaker': 'A',
      'time': '00:00 - 07.50',
      'text': '大家好，欢迎来到今天的播客节目。那个，今天我们要聊的话题是关于人工智能在创作领域的应用。'
    },
    {
      'speaker': 'B',
      'time': '07.50 - 16.00',
      'text': '是的，这确实是一个很有趣的话题。我觉得AI在音频剪辑方面已经有了很大的突破。嗯，比如自动去除口癖。'
    },
    {
      'speaker': 'A',
      'time': '16.00 - 24.00',
      'text': '没错，比如我们现在使用的这个PodPal平台，就能够智能识别语音内容，自动生成剪辑建议。其实，它还能识别口吃。'
    },
    {
      'speaker': 'B',
      'time': '24.00 - 32.50',
      'text': '而且它它它还能够根据不同的播客类型，比如知识分享类或者情感陪伴类，采用不同的剪辑策略。你知道，这很有用。'
    },
    {
      'speaker': 'A',
      'time': '32.50 - 40.00',
      'text': '这种个性化的处理方式确实很智能。怎么说呢，那么你觉得AI剪辑的优势主要体现在哪些方面呢？'
    },
    {
      'speaker': 'B',
      'time': '40.00 - 47.50',
      'text': '我觉得最核心的优势在于，AI能够帮助创作者从繁琐的机械劳动中解放出来。这就是播客创作的未来，让技术服务于创意。'
    },
    {
      'speaker': 'A',
      'time': '47.50 - 55.00',
      'text': '说得太好了。其实，创作的本质在于真实性的表达，这才是真正能打动听众的关键所在。'
    },
    {
      'speaker': 'B',
      'time': '55.00 - 62.50',
      'text': '没错，我们不应该为了追求完美而牺牲了内容的自然流动。技术的进步应当是无感的，让听众更专注于内容本身。'
    },
    {
      'speaker': 'A',
      'time': '62.50 - 70.00',
      'text': '这种理念非常契合我们产品的初衷。怎么说呢，技术只是工具，创意才是播客的灵魂所在。'
    },
    {
      'speaker': 'A',
      'time': '70.00 - 82.00',
      'text': '继续刚才的话题，我们来结合一个实际的剪辑案例，那个，看看如何提升听感。'
    },
    {
      'speaker': 'B',
      'time': '82.00 - 97.00',
      'text': '首先，去除口癖会让信息更凝练，比如把“就是说、然后呢、那个那个”等词清理掉。'
    },
    {
      'speaker': 'A',
      'time': '97.00 - 111.00',
      'text': '其次，补充过渡句可以减少语义跳跃，让让让听众更容易跟上思路。'
    },
  ];

  final List<Map<String, dynamic>> _tracks = [
    {
      'id': 1,
      'name': '主人声 A',
      'color': const Color(0xFF6366F1),
      'clips': [
        {'name': '大家好...', 'start': 0.0, 'end': 7.5},
        {'name': '没错，比如...', 'start': 16.0, 'end': 24.0},
        {'name': '这种个性化...', 'start': 32.5, 'end': 40.0},
        {'name': '说得太好了...', 'start': 47.5, 'end': 55.0},
        {'name': '这种理念...', 'start': 62.5, 'end': 70.0},
      ]
    },
    {
      'id': 2,
      'name': '嘉宾声 B',
      'color': const Color(0xFF10B981),
      'clips': [
        {'name': '是的，确实...', 'start': 7.5, 'end': 16.0},
        {'name': '而且它还能够...', 'start': 24.0, 'end': 32.5},
        {'name': '我觉得核心...', 'start': 40.0, 'end': 47.5},
        {'name': '没错，不应...', 'start': 55.0, 'end': 62.5},
      ]
    },
    {
      'id': 3,
      'name': '背景音乐',
      'color': const Color(0xFFF59E0B),
      'clips': [
        {'name': 'BGM - Jazz', 'start': 0.0, 'end': 111.0},
      ]
    },
    {
      'id': 4,
      'name': '片头/片尾',
      'color': const Color(0xFFEC4899),
      'clips': [
        {'name': 'Intro', 'start': 0.0, 'end': 5.0},
      ]
    },
  ];

  double _zoomLevel = 10.0; // pixels per second

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 轨道编辑区域 (新设计)
        Container(
          height: 200,
          color: Colors.grey[50],
          child: Column(
            children: [
              _buildTimelineRuler(),
              Expanded(
                child: ListView.builder(
                  itemCount: _tracks.length,
                  itemBuilder: (context, index) => _buildTrackRow(_tracks[index]),
                ),
              ),
            ]
          ),
        ),

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
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    const Text(
                      '文案稿',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_transcript.length} 条转写片段',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Expanded(
                  child: ListView.builder(
                    itemCount: _transcript.length,
                    itemBuilder: (context, index) {
                      final item = _transcript[index];
                      return _buildTranscriptItem(item['speaker'], item['time'], item['text']);
                    },
                  ),
                ),
              ],
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
                color: Colors.black.withValues(alpha: 0.05),
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
                  _buildToolBtn(Icons.auto_fix_high, 'AI优化'),
                  _buildToolBtn(Icons.key, '关键词'),
                  _buildToolBtn(Icons.article_outlined, 'Shownotes'),
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
                        onPressed: widget.onPrev,
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
                        onPressed: widget.onNext,
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

  Widget _buildTimelineRuler() {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Container(
            width: 60, // 6 seconds per block at zoomLevel 10
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              '${index * 6}s',
              style: TextStyle(fontSize: 10, color: Colors.grey[400]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrackRow(Map<String, dynamic> track) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Center(
              child: Text(
                track['name'],
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Stack(
                children: [
                  Container(
                    width: 1200, // Total duration placeholder
                    height: 40,
                  ),
                  ...(track['clips'] as List).map((clip) {
                    return Positioned(
                      left: clip['start'] * _zoomLevel,
                      width: (clip['end'] - clip['start']) * _zoomLevel,
                      top: 4,
                      bottom: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: (track['color'] as Color).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: track['color'] as Color),
                        ),
                        child: Center(
                          child: Text(
                            clip['name'],
                            style: TextStyle(fontSize: 8, color: track['color']),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptItem(String speaker, String time, String text) {
    final bool isSpeakerA = speaker == 'A';
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
                  color: isSpeakerA ? Colors.blue[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '说话人 $speaker',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSpeakerA ? Colors.blue[700] : Colors.green[700],
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
