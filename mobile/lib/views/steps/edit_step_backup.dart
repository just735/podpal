import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'dart:math' as math;

class EditStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrev;
  const EditStep({super.key, required this.onNext, required this.onPrev});

  @override
  State<EditStep> createState() => _EditStepState();
}

class _EditStepState extends State<EditStep> {
  // 口癖词列表（与 web 端保持一致，添加 '呃'、'诶'）
  final List<String> _fillerWords = ['就是', '然后', '那个', '嗯', '啊', '呃', '诶', '你知道', '对吧', '可以说', '怎么说呢', '就是说'];
  
  List<Map<String, dynamic>> _transcript = [];
  List<Map<String, dynamic>> _voiceTasks = [
    {
      'id': '1',
      'label': 'TTS 插入片段',
      'note': '补充播客开场白，使用声线：智能男声',
      'createdAt': '10:25',
      'status': '已完成',
      'inserted': true,
    },
    {
      'id': '2',
      'label': '声线克隆任务',
      'note': '基于 A 的 10s 样本生成',
      'createdAt': '11:12',
      'status': '处理中',
      'inserted': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeTranscript();
    _filteredTranscript = List.from(_transcript);
    _saveHistory();
  }

  @override
  void dispose() {
    _transcriptScrollController.dispose();
    super.dispose();
  }

  void _initializeTranscript() {
    final rawData = [
      {
        'speaker': 'A',
        'time': '00:00 - 00:10',
        'text': '王老师，好久不见。今天咱们请您来，是想聊聊那个……最近创作者圈子里讨论特别多的"AI 介入创作"的问题。'
      },
      {
        'speaker': 'B',
        'time': '00:10 - 00:15',
        'text': '诶，你好 Claire。其实我一直有在关注你们这个 PodPal 的进展。'
      },
      {
        'speaker': 'A',
        'time': '00:15 - 00:30',
        'text': '真的吗？那咱们直奔主题。现在 AI 剪辑挺火的，但很多人担心……呃，就是说，AI 剪出来的东西太冷冰冰了，没那个……人情味。'
      },
      {
        'speaker': 'B',
        'time': '00:30 - 00:50',
        'text': '嗯，其实这确实是个普遍的……那个，误区。传统的 AI 剪辑逻辑比较机械，它只会盯着波形看，哪里没声音了它就直接剪掉。'
      },
      {
        'speaker': 'B',
        'time': '00:50 - 01:10',
        'text': '但我们要知道，人类聊天时的"停顿"是有灵魂的。有些沉默是因为思考，有些沉默是因为情绪到了。'
      },
      {
        'speaker': 'A',
        'time': '01:10 - 01:25',
        'text': '没错！有时候那个……就是说，沉默反而比说话更有力量。我之前用传统软件剪辑，最怕的就是把嘉宾这种有温度的瞬间给切碎了。'
      },
      {
        'speaker': 'B',
        'time': '01:25 - 01:35',
        'text': '对。所以真正的智能不该只做物理意义上的"减法"，而是要做逻辑上的"筛选"。'
      },
      {
        'speaker': 'B',
        'time': '01:35 - 01:45',
        'text': '好的工具不应该替代人的思考，而应该延长人的感官。'
      },
      {
        'speaker': 'A',
        'time': '01:45 - 02:00',
        'text': '这句话说得太好了，我得记下来。那您觉得，像 PodPal 这种"文稿式剪辑"的操作逻辑，对普通人意味着什么？'
      },
      {
        'speaker': 'B',
        'time': '02:00 - 02:20',
        'text': '意味着……呃，创作权力的下放吧。以前你得学三个月软件才能剪出一档像样的播客，把时间都花在对齐音轨这种机械劳动上。'
      },
      {
        'speaker': 'B',
        'time': '02:20 - 02:35',
        'text': '现在只要你会改作文，你就能当主编。你可以把所有精力都放在打磨你的观点和故事上。'
      },
      {
        'speaker': 'B',
        'time': '02:35 - 02:50',
        'text': '当技术退居幕后，表达的欲望才会真正走向台前。'
      },
      {
        'speaker': 'A',
        'time': '02:50 - 03:05',
        'text': '明白了。就像 PodPal 做的，把复杂留给算法，把直觉留给作者。'
      },
      {
        'speaker': 'A',
        'time': '03:05 - 03:25',
        'text': '其实这种理念非常契合我们产品的初衷。我们希望通过 AI 的辅助，让每一个有思想的人都能无障碍地发声。'
      },
      {
        'speaker': 'B',
        'time': '03:25 - 03:40',
        'text': '总结得非常到位。技术的进步不应该是为了取代人，而是为了让人更有尊严地去创造。'
      },
    ];

    _transcript = rawData.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final tokens = _parseTranscriptToTokens(item['text'] as String);
      
      // AI 自动识别口癖/口吃并高亮标注
      // 注意：只标注不删除，由用户自行决定是否删除
      // - filler: 口癖词（黄色高亮）
      // - stutter: 口吃重复（紫色高亮）
      bool hasAnnotation = false;
      for (var token in tokens) {
        if (token['type'] == 'filler' || token['type'] == 'stutter') {
          hasAnnotation = true;
        }
      }

      return {
        'speaker': item['speaker'],
        'time': item['time'],
        'text': _tokensToText(tokens),
        'isOriginal': true,
        'isTts': false,
        'confirmed': true,
        'tokens': tokens,
        'editTrace': {
          'oldText': item['text'],
          'newText': _tokensToText(tokens),
          'type': hasAnnotation ? 'AI 自动标注 (口癖/口吃)' : 'AI 自动标注',
          'timestamp': DateTime.now().toString(),
        },
      };
    }).toList();
  }

  List<Map<String, dynamic>> _parseTranscriptToTokens(String text) {
    final List<Map<String, dynamic>> tokens = [];
    
    // 正则匹配：中文单词、英文单词、数字、标点符号、空白字符
    final pattern = RegExp(r'([\u4e00-\u9fa5]+|[a-zA-Z0-9]+|[^\w\s\u4e00-\u9fa5]+|[\s]+)');
    
    final matches = pattern.allMatches(text);
    for (final match in matches) {
      final part = match.group(0)!;
      if (RegExp(r'^\s+$').hasMatch(part)) {
        tokens.add({'type': 'space', 'text': part});
      } else if (RegExp(r'^[^\w\s\u4e00-\u9fa5]+$').hasMatch(part)) {
        tokens.add({'type': 'punctuation', 'text': part});
      } else {
        // 检查是否是口癖词
        if (_fillerWords.contains(part)) {
          tokens.add({'type': 'filler', 'text': part});
        } else {
          // 检查是否包含口癖词
          bool hasFiller = false;
          for (final filler in _fillerWords) {
            if (part.contains(filler)) {
              // 对于包含口癖词的文本，拆分处理
              _splitTextWithFiller(part, tokens);
              hasFiller = true;
              break;
            }
          }
          if (!hasFiller) {
            _addTokenToTokens(part, tokens);
          }
        }
      }
    }
    
    return tokens;
  }
  
  // 拆分包含口癖词的文本
  void _splitTextWithFiller(String text, List<Map<String, dynamic>> tokens) {
    // 按口癖词长度降序排列，优先匹配长的口癖词
    final sortedFillerWords = List.from(_fillerWords)..sort((a, b) => b.length.compareTo(a.length));
    
    // 构建包含口癖词的正则表达式
    final fillerRegex = RegExp(r'(' + sortedFillerWords.map((w) => RegExp.escape(w)).join('|') + r')');
    
    // 拆分文本
    int lastIndex = 0;
    for (final match in fillerRegex.allMatches(text)) {
      // 匹配前的文本
      if (match.start > lastIndex) {
        final beforeText = text.substring(lastIndex, match.start);
        if (beforeText.isNotEmpty) {
          _addTokenToTokens(beforeText, tokens);
        }
      }
      // 口癖词
      tokens.add({'type': 'filler', 'text': match.group(0)!});
      lastIndex = match.end;
    }
    
    // 剩余的文本
    if (lastIndex < text.length) {
      final remainingText = text.substring(lastIndex);
      if (remainingText.isNotEmpty) {
        _addTokenToTokens(remainingText, tokens);
      }
    }
  }

  void _addTokenToTokens(String text, List<Map<String, dynamic>> tokens) {
    // 改进的口吃匹配：匹配连续重复的单字，如"我我我"、"这这"
    // 注意：至少3个相同字符才认为是口吃，避免误识别"冷冰冰"等词
    final stutterRegex = RegExp(r'([\u4e00-\u9fa5A-Za-z])\1{2,}');
    
    if (!stutterRegex.hasMatch(text)) {
      // 没有口吃，直接添加为普通文本
      tokens.add({'type': 'text', 'text': text});
      return;
    }
    
    // 拆分出口吃部分
    int lastIndex = 0;
    for (final match in stutterRegex.allMatches(text)) {
      // 匹配前的正常文本
      if (match.start > lastIndex) {
        tokens.add({
          'type': 'text',
          'text': text.substring(lastIndex, match.start),
        });
      }
      // 口吃部分
      tokens.add({
        'type': 'stutter',
        'text': match.group(0)!,
      });
      lastIndex = match.end;
    }
    
    // 剩余的正常文本
    if (lastIndex < text.length) {
      tokens.add({
        'type': 'text',
        'text': text.substring(lastIndex),
      });
    }
  }

  String _tokensToText(List<Map<String, dynamic>> tokens) {
    return tokens.map((t) => t['text']).join();
  }

  List<Map<String, dynamic>> _filteredTranscript = [];
  String _searchQuery = '';
  bool _isSearching = false;
  int _selectedStrategy = 0; // 0: 全剪辑, 1: 口癖, 2: 口吃
  bool _isTranscribing = false;
  Timer? _transcriptionTimer;
  final List<List<Map<String, dynamic>>> _history = [];
  int _historyIndex = -1;
  final ScrollController _transcriptScrollController = ScrollController();
  final Map<int, GlobalKey> _segmentKeys = {};

  GlobalKey _segmentKeyFor(int index) {
    return _segmentKeys.putIfAbsent(index, () => GlobalKey());
  }

  Map<String, dynamic> _cloneItem(Map<String, dynamic> item) {
    final cloned = Map<String, dynamic>.from(item);
    cloned['tokens'] = (item['tokens'] as List).map((t) => Map<String, dynamic>.from(t)).toList();
    if (item['editTrace'] is Map) {
      cloned['editTrace'] = Map<String, dynamic>.from(item['editTrace']);
    }
    return cloned;
  }

  void _saveHistory() {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(_transcript.map(_cloneItem).toList());
    _historyIndex++;
  }

  void _undo() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        _transcript = _history[_historyIndex].map(_cloneItem).toList();
        _onSearch(_searchQuery);
      });
    }
  }

  void _redo() {
    if (_historyIndex < _history.length - 1) {
      setState(() {
        _historyIndex++;
        _transcript = _history[_historyIndex].map(_cloneItem).toList();
        _onSearch(_searchQuery);
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTranscript = List.from(_transcript);
      } else {
        _filteredTranscript = _transcript.where((item) {
          final tokens = (item['tokens'] as List?) ?? [];
          return tokens.any((t) => (t as Map)['text'].toString().contains(query));
        }).toList();
      }
    });
  }

  void _optimizeAI() {
    setState(() {
      for (var item in _transcript) {
        final tokens = (item['tokens'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final oldText = _tokensToText(tokens);
        bool modified = false;
        
        for (var token in tokens) {
          if (token['type'] == 'filler' || token['type'] == 'stutter') {
            token['oldType'] = token['type'];
            token['type'] = 'deleted';
            modified = true;
          }
        }
        
        if (modified) {
          item['text'] = _tokensToText(tokens);
          item['editTrace'] = {
            'oldText': oldText,
            'newText': item['text'],
            'type': 'AI 自动优化 (去除口癖/重复)',
            'timestamp': DateTime.now().toString(),
          };
        }
      }
      _onSearch(_searchQuery);
    });
    _saveHistory();
  }

  void _showKeywords() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('智能关键词'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('根据音频内容提取出的核心关键词：', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['人工智能', '播客创作', 'PodPal', '智能剪辑', '真实表达', '音频分发'].map((k) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.pink[100]!),
                ),
                child: Text(k, style: const TextStyle(fontSize: 12, color: Color(0xFFFF6B9D))),
              )).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('确定')),
        ],
      ),
    );
  }

  void _showShownotes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B9D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.description, color: Color(0xFFFF6B9D), size: 20),
            ),
            const SizedBox(width: 12),
            const Text('智能 Shownotes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('推荐标题：', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 8),
                _buildTitleItem('AI 时代的播客创作：从灵感到分发的全流程解析'),
                _buildTitleItem('如何利用 PodPal 打造你的第一个爆款播客？'),
                const SizedBox(height: 16),
                const Text('内容摘要：', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: const Text(
                    '本期节目我们深入探讨了人工智能在播客创作领域的应用。从早期的语音转写到如今的智能剪辑、内容生成，AI 正在重塑音频内容的生产流程。我们邀请了资深播客制作人，分享他们使用 PodPal 提升效率的实战经验...',
                    style: TextStyle(fontSize: 13, height: 1.5, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('时间轴要点：', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 8),
                _buildTimestampItem('00:00', '节目开场及主题介绍'),
                _buildTimestampItem('02:15', 'AI 语音转写技术的演进历程'),
                _buildTimestampItem('05:30', 'PodPal 核心功能演示：智能去口癖'),
                _buildTimestampItem('12:45', '嘉宾分享：如何利用 AI 缩短 50% 的后期时间'),
                _buildTimestampItem('20:10', '未来展望：播客创作的下一个十年'),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('思维导图：', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                    Container(
                      height: 28,
                      child: TextButton.icon(
                        onPressed: () {
                          // 模拟生成逻辑
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('正在基于时间轴生成思维导图...'), duration: Duration(seconds: 1)),
                          );
                        },
                        icon: const Icon(Icons.account_tree_outlined, size: 14),
                        label: const Text('生成思维导图', style: TextStyle(fontSize: 11)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFFF6B9D),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          backgroundColor: const Color(0xFFFF6B9D).withOpacity(0.05),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMindmapPreview(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('确定', style: TextStyle(color: Color(0xFFFF6B9D), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMindmapPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 根节点
          _buildMindmapNode('AI 播客创作', time: '00:00', isRoot: true),
          
          const SizedBox(height: 20),
          
          // 子节点容器
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildMindmapNode('技术演进', time: '02:15', children: [
                      {'label': '语音转写', 'time': '02:30'},
                      {'label': '情感识别', 'time': '04:10'}
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _buildMindmapNode('实战应用', time: '05:30', children: [
                      {'label': '智能剪辑', 'time': '06:45'},
                      {'label': '后期提效', 'time': '12:15'}
                    ]),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildMindmapNode('行业展望', time: '20:10', children: [
                  {'label': '创作门槛', 'time': '21:00'},
                  {'label': '未来趋势', 'time': '23:45'}
                ]),
              ),
            ],
          ),
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
            color: isRoot ? const Color(0xFFFF6B9D).withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isRoot ? const Color(0xFFFF6B9D).withOpacity(0.3) : Colors.grey.withOpacity(0.2),
            ),
            boxShadow: [
              if (!isRoot) BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isRoot ? 14 : 12,
                  fontWeight: FontWeight.bold,
                  color: isRoot ? const Color(0xFFFF6B9D) : Colors.black87,
                ),
              ),
              if (time != null)
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isRoot ? const Color(0xFFFF6B9D).withOpacity(0.7) : Colors.grey,
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
                  Text(child['label']!, style: const TextStyle(fontSize: 10, color: Colors.black54)),
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
              color: Color(0xFFFF6B9D),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleItem(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark_border, size: 16, color: Color(0xFFFF6B9D)),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  void _toggleTokenDelete(int itemIndex, int tokenIndex) {
    setState(() {
      final item = _transcript[itemIndex];
      if (item['isOriginal'] != true) return;
      final tokens = (item['tokens'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      if (tokenIndex >= tokens.length) return;
      final token = tokens[tokenIndex];
      
      if (token['type'] == 'space') return;
      
      if (token['type'] == 'deleted') {
        // 恢复原始类型
        token['type'] = token['oldType'] ?? 'text';
        token.remove('oldType');
      } else {
        // 标记删除，保存原始类型以便恢复
        token['oldType'] = token['type'];
        token['type'] = 'deleted';
      }
      
      item['text'] = _tokensToText(tokens);
      _onSearch(_searchQuery);
    });
    _saveHistory();
  }

  void _editTokenText(int itemIndex, int tokenIndex) {
    final item = _transcript[itemIndex];
    final tokens = (item['tokens'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (tokenIndex >= tokens.length) return;
    final token = tokens[tokenIndex];
    final TextEditingController controller = TextEditingController(text: token['text']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑文字'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '请输入修改后的文字'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              setState(() {
                final newText = controller.text;
                if (newText != token['text']) {
                  if (item['isOriginal'] == true) {
                    token['oldText'] = token['text'];
                    token['text'] = newText;
                    token['type'] = 'modified';
                  } else {
                    token['text'] = newText;
                  }
                  item['text'] = _tokensToText(tokens);
                }
              });
              _onSearch(_searchQuery);
              _saveHistory();
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _diffText(String oldText, String newText) {
    final List<Map<String, dynamic>> tokens = [];
    
    // 简单的字符级差异对比（实际开发中建议使用 diff_match_patch 库）
    // 这里为了演示实现一个基础版本
    int i = 0, j = 0;
    while (i < oldText.length || j < newText.length) {
      if (i < oldText.length && j < newText.length && oldText[i] == newText[j]) {
        // 相同字符
        tokens.add({'type': 'text', 'text': oldText[i]});
        i++;
        j++;
      } else {
        // 查找下一个匹配点以确定是删除还是新增
        int nextI = i;
        int nextJ = j;
        bool found = false;
        
        // 尝试寻找后续匹配
        for (int lookAhead = 1; lookAhead < 10; lookAhead++) {
          if (i + lookAhead < oldText.length && j < newText.length && oldText[i + lookAhead] == newText[j]) {
            // 说明 i 到 i+lookAhead 之间是被删掉的
            for (int k = 0; k < lookAhead; k++) {
              tokens.add({'type': 'deleted', 'text': oldText[i + k]});
            }
            i += lookAhead;
            found = true;
            break;
          }
          if (j + lookAhead < newText.length && i < oldText.length && newText[j + lookAhead] == oldText[i]) {
            // 说明 j 到 j+lookAhead 之间是新增的
            for (int k = 0; k < lookAhead; k++) {
              tokens.add({'type': 'added', 'text': newText[j + k]});
            }
            j += lookAhead;
            found = true;
            break;
          }
        }
        
        if (!found) {
          // 如果没找到匹配，视为替换（先删后加）
          if (i < oldText.length) {
            tokens.add({'type': 'deleted', 'text': oldText[i]});
            i++;
          }
          if (j < newText.length) {
            tokens.add({'type': 'added', 'text': newText[j]});
            j++;
          }
        }
      }
    }
    return tokens;
  }

  void _editSegmentText(int itemIndex) {
    final item = _transcript[itemIndex];
    final tokens = (item['tokens'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final bool isOriginal = item['isOriginal'] == true;
    final bool isTts = item['isTts'] == true;
    final bool confirmed = item['confirmed'] == true;

    if (isTts && !confirmed) {
      return;
    }

    final oldText = _tokensToText(tokens);
    final TextEditingController controller = TextEditingController(text: oldText);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑文稿'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 6,
          decoration: const InputDecoration(hintText: '请输入修改后的内容'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              final newText = controller.text;
              if (newText != oldText) {
                setState(() {
                  // 手动编辑时，不再使用原有的 token 解析，而是生成带有差异信息的 token 列表
                  if (isOriginal) {
                    item['tokens'] = _diffText(oldText, newText);
                    item['editTrace'] = {
                      'oldText': oldText,
                      'newText': newText,
                      'type': '手动编辑修改',
                      'timestamp': DateTime.now().toString(),
                    };
                  } else {
                    item['tokens'] = _parseTranscriptToTokens(newText);
                    item['editTrace'] = null;
                  }
                  item['text'] = newText;
                  _onSearch(_searchQuery);
                });
                _saveHistory();
              }
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _confirmTtsSegment(int itemIndex) {
    setState(() {
      final item = _transcript[itemIndex];
      item['confirmed'] = true;
      item['editTrace'] = null;
      final tokens = (item['tokens'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final text = _tokensToText(tokens);
      item['text'] = text;
      item['tokens'] = _parseTranscriptToTokens(text);
    });
    _saveHistory();
  }

  void _deleteSegment(int itemIndex) {
    setState(() {
      _transcript.removeAt(itemIndex);
      _onSearch(_searchQuery);
    });
    _saveHistory();
  }

  void _scrollToSegment(int itemIndex) {
    final key = _segmentKeyFor(itemIndex);
    final context = key.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      alignment: 0.1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  final List<Map<String, dynamic>> _tracks = [
    {
      'id': 1,
      'name': '主人声 A',
      'color': const Color(0xFF6366F1),
      'clips': [
        {'name': '大家好，欢迎来到...', 'start': 0.0, 'end': 7.5},
        {'name': '没错，比如 PodPal...', 'start': 16.0, 'end': 24.0},
        {'name': '这种个性化的处理...', 'start': 32.5, 'end': 40.0},
        {'name': '说得太好了。其实...', 'start': 47.5, 'end': 55.0},
        {'name': '这种理念非常契合...', 'start': 62.5, 'end': 70.0},
      ]
    },
    {
      'id': 2,
      'name': '嘉宾声 B',
      'color': const Color(0xFF10B981),
      'clips': [
        {'name': '是的，这确实是一个...', 'start': 7.5, 'end': 16.0},
        {'name': '而且它它它还能够...', 'start': 24.0, 'end': 32.5},
        {'name': '我觉得最核心的优势...', 'start': 40.0, 'end': 47.5},
        {'name': '没错，我们不应该...', 'start': 55.0, 'end': 62.5},
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
              // 顶部波形预览（简化版条形波形）
              SizedBox(
                height: 28,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(80, (i) {
                      final h = 8 + (i % 9) * 2;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: Container(
                          width: 2,
                          height: h.toDouble(),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B9D).withOpacity(0.6 - (i % 5) * 0.08),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
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
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          _isSearching ? '搜索结果' : '文案稿',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(Icons.undo, size: 20, color: _historyIndex > 0 ? Colors.black87 : Colors.grey[300]),
                          onPressed: _historyIndex > 0 ? _undo : null,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.redo, size: 20, color: _historyIndex < _history.length - 1 ? Colors.black87 : Colors.grey[300]),
                          onPressed: _historyIndex < _history.length - 1 ? _redo : null,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (_isSearching)
                          SizedBox(
                            width: 120,
                            height: 32,
                            child: TextField(
                              onChanged: _onSearch,
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: '搜索...',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                prefixIcon: const Icon(Icons.search, size: 14),
                              ),
                            ),
                          ),
                        IconButton(
                          icon: Icon(_isSearching ? Icons.close : Icons.search, size: 20),
                          onPressed: () {
                            setState(() {
                              _isSearching = !_isSearching;
                              if (!_isSearching) {
                                _onSearch('');
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32),
                Expanded(
                  child: ListView.builder(
                    controller: _transcriptScrollController,
                    itemCount: _filteredTranscript.length,
                    itemBuilder: (context, index) {
                      final item = _filteredTranscript[index];
                      // Find original index for editing
                      final originalIndex = _transcript.indexOf(item);
                      return _buildTranscriptItem(
                        originalIndex,
                        (item['speaker'] as String?) ?? '',
                        (item['time'] as String?) ?? '',
                        (item['tokens'] as List?)?.cast<Map<String, dynamic>>() ?? [],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        
        _buildBottomToolbar(),
      ],
    );
  }

  void _optimizeScript() {
    int? selectedIndex;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('文稿医生', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.2,
                  children: [
                    _buildActionBtn(
                      '去口语冗余', 
                      '自动修正错别字、剔除口语化冗余', 
                      () async {
                        setModalState(() => selectedIndex = 0);
                        await Future.delayed(const Duration(milliseconds: 300));
                        if (mounted) Navigator.pop(context);
                        _optimizeAI();
                      },
                      isSelected: selectedIndex == 0,
                    ),
                    _buildActionBtn(
                      '逻辑纠错', 
                      '检测逻辑断层，推荐衔接句', 
                      () async {
                        setModalState(() => selectedIndex = 1);
                        await Future.delayed(const Duration(milliseconds: 300));
                        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
                        _applyOptimization('logic');
                      },
                      isSelected: selectedIndex == 1,
                    ),
                    _buildActionBtn(
                      '一键精华提取', 
                      '提取核心片段生成精华版', 
                      () async {
                        setModalState(() => selectedIndex = 2);
                        await Future.delayed(const Duration(milliseconds: 300));
                        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
                        _applyOptimization('highlights');
                      },
                      isSelected: selectedIndex == 2,
                    ),
                    _buildActionBtn(
                      'BGM智能匹配', 
                      '根据内容推荐背景音乐', 
                      () async {
                        setModalState(() => selectedIndex = 3);
                        await Future.delayed(const Duration(milliseconds: 300));
                        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
                        _applyOptimization('bgm');
                      },
                      isSelected: selectedIndex == 3,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _applyOptimization(String type) {
    setState(() {
      if (type == 'logic') {
        // Mock logic optimization: add a tip or insert a transition segment
        final newItem = {
          'speaker': 'AI',
          'time': '32.00',
          'text': '[建议补充过渡句] 此处语义跳跃明显，建议补充一句过渡说明。',
          'isOriginal': false,
          'isTts': true,
          'confirmed': false,
          'tokens': _parseTranscriptToTokens('[建议补充过渡句] 此处语义跳跃明显，建议补充一句过渡说明。'),
          'editTrace': {
            'oldText': '',
            'newText': '逻辑优化建议',
            'type': 'AI 逻辑纠错',
            'timestamp': DateTime.now().toString(),
          }
        };
        _transcript.insert(5, newItem); // Insert at a specific place
      } else if (type == 'highlights') {
        // Highlight segments with high scores (mock)
      } else if (type == 'bgm') {
        // Suggest BGM (mock)
      }
      _onSearch(_searchQuery);
    });
    _saveHistory();
  }

  void _handleVoiceTool(String type, [String emotion = '平静', String emphasis = '']) {
    if (type == 'clone') {
      _showVoiceCloningDialog(emotion: emotion, emphasis: emphasis);
    } else if (type == 'multi') {
      _showMultiRoleDialog(emotion: emotion, emphasis: emphasis);
    } else if (type == 'tts') {
      _showTTSDialog(emotion: emotion, emphasis: emphasis);
    }
  }

  List<String> _getThemeRelevantSamples() {
    // 优先从当前文稿中提取真实片段作为样例，保证绝对符合主题
    List<String> realSamples = [];
    if (_transcript.isNotEmpty) {
      // 提取前几个片段中较短的句子
      for (var item in _transcript.take(5)) {
        String text = item['text'] ?? '';
        if (text.length > 5 && text.length < 30) {
          realSamples.add(text);
        }
      }
    }

    // 如果文稿内容不足，补充一些通用的主题相关句子
    final List<String> fallbackSamples = [
      "AI 正在重新定义播客创作的边界。",
      "PodPal 让每个创作者都能拥有专业的音频处理能力。",
      "技术的进步不应牺牲内容的真实性与自然度。",
    ];

    return (realSamples + fallbackSamples).take(4).toList();
  }

  void _addVoiceTask(String label, String content, String note) {
    // 校验逻辑：检查生成内容是否与当前文稿相关
    String warning = '';
    bool isConsistent = false;
    
    // 简单校验：如果生成内容包含提示词，则认为是一致的
    // 在实际 AI 流程中，这里会通过 API 返回一致性评分
    for (var item in _transcript) {
      if ((item['text'] as String).contains(content)) {
        isConsistent = true;
        break;
      }
    }
    
    if (!isConsistent && content.length > 5) {
      warning = '注意：生成内容可能与原文稿存在偏差';
    }

    setState(() {
      final id = (DateTime.now().millisecondsSinceEpoch % 10000).toString();
      _voiceTasks.insert(0, {
        'id': id,
        'label': label,
        'prompt': content, // 保存原始提示词
        'note': '正在根据提示词生成...', // 初始状态显示生成中
        'info': note,
        'warning': warning, // 记录一致性警告
        'createdAt': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'status': '处理中',
        'inserted': false,
      });
    });
    
    // 模拟 AI 根据提示词生成完整句子的过程
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          final index = _voiceTasks.indexWhere((t) => t['status'] == '处理中');
          if (index != -1) {
            final task = _voiceTasks[index];
            final prompt = task['prompt'] as String;
            
            // 模拟 AI 结合主题生成：保持用户输入的提示词为核心，增加自然的衔接
            String generatedContent = '';
            if (task['label'] == '声线克隆') {
              generatedContent = '“$prompt” —— 这句话通过我的克隆声线说出来，听起来是不是非常自然？在我们的播客中，这种一致性非常重要。';
            } else if (task['label'] == '多角色生成') {
              generatedContent = '主持人：刚才提到“$prompt”，这引发了我的思考。\n嘉宾：没错，这确实是目前行业关注的焦点。';
            } else {
              generatedContent = '（AI 合成）$prompt'; // TTS 直接使用内容，不做额外修饰，保证纯净
            }
            
            task['status'] = '已完成';
            task['note'] = generatedContent; // 将 note 更新为 AI 生成的完整句子
          }
        });
      }
    });
  }

  void _showVoiceCloningDialog({String emotion = '平静', String emphasis = ''}) {
    final TextEditingController controller = TextEditingController();
    final samples = _getThemeRelevantSamples();
    String selectedEmotion = emotion;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('声线克隆', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('基于您的声音样本，生成自然流畅的克隆语音。', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                onChanged: (v) => setDialogState(() {}),
                decoration: InputDecoration(
                  hintText: '输入想要生成的文字内容...',
                  hintStyle: const TextStyle(fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              const Text('推荐样例 (点击使用):', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: samples.map((s) => InkWell(
                  onTap: () {
                    setDialogState(() {
                      controller.text = s;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F5),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFFF6B9D).withOpacity(0.2)),
                    ),
                    child: Text(
                      s,
                      style: const TextStyle(fontSize: 11, color: Color(0xFFFF6B9D)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            if (emotion != '平静' || emphasis.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F8),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFFFE4ED)),
                ),
                child: Text(
                  '情感: $emotion${emphasis.isNotEmpty ? " | 重读: $emphasis" : ""}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFFF6B9D)),
                ),
              ),
            TextButton(
              onPressed: () {
                final text = samples.isNotEmpty ? samples[0] : "AI 正在重新定义播客创作的边界。";
                Navigator.pop(context);
                final note = '[情感:$emotion]${emphasis.isNotEmpty ? ' [重读:$emphasis]' : ''} 声线：您的克隆声线';
                _addVoiceTask('声线克隆', text, note);
              },
              child: const Text('直接生成示例', style: TextStyle(color: Color(0xFFFF6B9D))),
            ),
            ElevatedButton(
              onPressed: controller.text.trim().isEmpty ? null : () {
                final text = controller.text.trim();
                Navigator.pop(context);
                final note = '[情感:$emotion]${emphasis.isNotEmpty ? ' [重读:$emphasis]' : ''} 声线：您的克隆声线';
                _addVoiceTask('声线克隆', text, note);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D),
                disabledBackgroundColor: Colors.grey[200],
              ),
              child: const Text('生成样例', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showMultiRoleDialog({String emotion = '平静', String emphasis = ''}) {
    final TextEditingController controller = TextEditingController();
    final samples = _getThemeRelevantSamples();
    String selectedEmotion = emotion;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('多角色生成', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AI 自动识别并匹配多个角色的声线进行对话生成。', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                onChanged: (v) => setDialogState(() {}),
                decoration: InputDecoration(
                  hintText: '输入多角色对话内容...',
                  hintStyle: const TextStyle(fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              const Text('推荐对话样例 (点击使用):', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  "主持人：关于 AI，大家怎么看？\n嘉宾：我觉得很有趣。",
                  "A：这个功能太赞了！\nB：是的，我也这么认为。",
                ].map((s) => InkWell(
                  onTap: () {
                    setDialogState(() {
                      controller.text = s;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Text(
                      s.replaceAll('\n', ' '),
                      style: const TextStyle(fontSize: 11, color: Colors.blue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            if (emotion != '平静' || emphasis.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F8),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFFFE4ED)),
                ),
                child: Text(
                  '情感: $emotion${emphasis.isNotEmpty ? " | 重读: $emphasis" : ""}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFFF6B9D)),
                ),
              ),
            TextButton(
              onPressed: () {
                final text = "主持人：关于 AI，大家怎么看？\n嘉宾：我觉得很有趣。";
                Navigator.pop(context);
                final note = '[情感:$emotion]${emphasis.isNotEmpty ? ' [重读:$emphasis]' : ''} 声线：智能匹配多角色';
                _addVoiceTask('多角色生成', text, note);
              },
              child: const Text('直接生成示例对话', style: TextStyle(color: Color(0xFFFF6B9D))),
            ),
            ElevatedButton(
              onPressed: controller.text.trim().isEmpty ? null : () {
                final text = controller.text.trim();
                Navigator.pop(context);
                final note = '[情感:$emotion]${emphasis.isNotEmpty ? ' [重读:$emphasis]' : ''} 声线：智能匹配多角色';
                _addVoiceTask('多角色生成', text, note);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D),
                disabledBackgroundColor: Colors.grey[200],
              ),
              child: const Text('生成样例', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showTTSDialog({String emotion = '平静', String emphasis = ''}) {
    final TextEditingController textController = TextEditingController();
    final samples = _getThemeRelevantSamples();
    String selectedEmotion = emotion;
    final TextEditingController emphasisController = TextEditingController(text: emphasis);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('声演实验室 · 角色配音', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                maxLines: 4,
                onChanged: (v) => setDialogState(() {}),
                decoration: InputDecoration(
                  hintText: '请输入要转语音的文本内容...',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFBCFE8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('情感语气', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFF6B9D))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildEmotionChip('平静', selectedEmotion, (v) => setDialogState(() => selectedEmotion = v)),
                        _buildEmotionChip('兴奋', selectedEmotion, (v) => setDialogState(() => selectedEmotion = v)),
                        _buildEmotionChip('坚定', selectedEmotion, (v) => setDialogState(() => selectedEmotion = v)),
                        _buildEmotionChip('温柔', selectedEmotion, (v) => setDialogState(() => selectedEmotion = v)),
                        _buildEmotionChip('幽默', selectedEmotion, (v) => setDialogState(() => selectedEmotion = v)),
                        _buildEmotionChip('严肃', selectedEmotion, (v) => setDialogState(() => selectedEmotion = v)),
                        _buildEmotionChip('亲切', selectedEmotion, (v) => setDialogState(() => selectedEmotion = v)),
                        _buildEmotionChip('激昂', selectedEmotion, (v) => setDialogState(() => selectedEmotion = v)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('重读标注', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                    const SizedBox(height: 4),
                    const Text('输入需要重读的关键词，用空格分隔', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emphasisController,
                      decoration: InputDecoration(
                        hintText: '例如：重要 关键 核心',
                        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.all(10),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 小型波形预览占位
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('波形预览', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 24,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(50, (i) {
                          final h = 6 + ((i * 7) % 12);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: Container(
                              width: 2,
                              height: h.toDouble(),
                              decoration: BoxDecoration(
                                color: const Color(0xFF60A5FA).withOpacity(0.8 - (i % 4) * 0.1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('推荐样例 (点击使用):', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: samples.map((s) => InkWell(
                  onTap: () {
                    setDialogState(() {
                      textController.text = s;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Text(
                      s,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('选择声线:', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('默认 AI 女声', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final text = samples.isNotEmpty ? samples[0] : "AI 正在重新定义播客创作的边界。";
                Navigator.pop(context);
                final emphasis = emphasisController.text.trim();
                final note = '[情感:$selectedEmotion]'
                    '${emphasis.isNotEmpty ? ' [重读:$emphasis]' : ''} '
                    '（AI 合成）$text';
                _addVoiceTask('音频补录', note, '声线：默认 AI 女声');
              },
              child: const Text('直接生成示例', style: TextStyle(color: Color(0xFFFF6B9D))),
            ),
            ElevatedButton(
              onPressed: textController.text.trim().isEmpty ? null : () {
                final text = textController.text.trim();
                Navigator.pop(context);
                final emphasis = emphasisController.text.trim();
                final note = '[情感:$selectedEmotion]'
                    '${emphasis.isNotEmpty ? ' [重读:$emphasis]' : ''} '
                    '（AI 合成）$text';
                _addVoiceTask('音频补录', note, '声线：默认 AI 女声');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D),
                disabledBackgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('立即生成', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _openTTSPreview(Map<String, dynamic> task) {
    final TextEditingController editController = TextEditingController(text: task['note']);
    bool isEditing = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Text('预览与编辑: ${task['label']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: Icon(isEditing ? Icons.check_circle_outline : Icons.edit_outlined, size: 20, color: const Color(0xFFFF6B9D)),
                onPressed: () {
                  setDialogState(() {
                    if (isEditing) {
                      task['note'] = editController.text;
                    }
                    isEditing = !isEditing;
                  });
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('文本内容', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    isEditing
                        ? TextField(
                            controller: editController,
                            maxLines: 4,
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                          )
                        : Text(task['note'], style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.play_circle_fill, color: Color(0xFFFF6B9D), size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('00:00 / 00:15', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: 0,
                          backgroundColor: Color(0xFFF3F4F6),
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
                          minHeight: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  task['inserted'] = true;
                  // 插入到文字稿
                  _transcript.insert(0, {
                    'speaker': 'AI',
                    'time': '00:00',
                    'text': task['note'],
                    'isOriginal': false,
                    'isTts': true,
                    'confirmed': true,
                    'editTrace': {
                      'type': task['label'],
                      'timestamp': DateTime.now().millisecondsSinceEpoch,
                    },
                    'tokens': _parseTranscriptToTokens(task['note']),
                  });
                  // 强制同步搜索列表，确保界面刷新
                  _onSearch(_searchQuery);
                });
                _saveHistory(); // 确保支持撤销插入
                Navigator.pop(context);
                Navigator.pop(context); // 关闭底栏
                
                // 如果在搜索模式，滚动到顶部查看新插入的内容
                if (_searchQuery.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToSegment(0);
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('确认插入', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _generateVoice() {
    String selectedEmotion = '平静';
    final TextEditingController emphasisController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 固定头部
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B9D),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('声演实验室', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // 可滚动内容
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 三个功能按钮
                      Row(
                        children: [
                          Expanded(child: _buildActionBtn('声线克隆', '根据语音生成配置', () => _handleVoiceTool('clone', selectedEmotion, emphasisController.text), icon: Icons.mic_rounded)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildActionBtn('多角色生成', 'AI 自动匹配声线', () => _handleVoiceTool('multi', selectedEmotion, emphasisController.text), icon: Icons.groups_rounded)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildActionBtn('音频补录', '手动输入文本转语音', () => _handleVoiceTool('tts', selectedEmotion, emphasisController.text), icon: Icons.text_fields_rounded)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // 情感参数选择
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFE4ED)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.emoji_emotions_outlined, size: 16, color: const Color(0xFFFF6B9D)),
                                const SizedBox(width: 6),
                                const Text('情感参数', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF6B9D))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _buildEmotionChip('平静', selectedEmotion, (v) => setModalState(() => selectedEmotion = v)),
                                _buildEmotionChip('兴奋', selectedEmotion, (v) => setModalState(() => selectedEmotion = v)),
                                _buildEmotionChip('坚定', selectedEmotion, (v) => setModalState(() => selectedEmotion = v)),
                                _buildEmotionChip('温柔', selectedEmotion, (v) => setModalState(() => selectedEmotion = v)),
                                _buildEmotionChip('幽默', selectedEmotion, (v) => setModalState(() => selectedEmotion = v)),
                                _buildEmotionChip('严肃', selectedEmotion, (v) => setModalState(() => selectedEmotion = v)),
                                _buildEmotionChip('亲切', selectedEmotion, (v) => setModalState(() => selectedEmotion = v)),
                                _buildEmotionChip('激昂', selectedEmotion, (v) => setModalState(() => selectedEmotion = v)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 重读标注
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.format_bold, size: 16, color: const Color(0xFF0284C7)),
                                const SizedBox(width: 6),
                                const Text('重读标注', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text('输入需要重读的关键词，用空格分隔', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 10),
                            TextField(
                              controller: emphasisController,
                              decoration: InputDecoration(
                                hintText: '例如：重要 关键 核心',
                                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: const Icon(Icons.edit_note, size: 20, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_voiceTasks.isNotEmpty) ...[
                        const Text('最近语音生成任务', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 12),
                        ..._voiceTasks.map((task) => _buildVoiceTaskItem(task)),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceTaskItem(Map<String, dynamic> task) {
    final bool isCompleted = task['status'] == '已完成';
    final bool isInserted = task['inserted'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFE4ED)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task['label'], 
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCompleted ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        task['status'],
                        style: TextStyle(
                          fontSize: 9,
                          color: isCompleted ? const Color(0xFF065F46) : const Color(0xFF92400E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  task['note'], 
                  style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                ),
                if (task['warning'] != null && (task['warning'] as String).isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 10, color: Colors.orange),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          task['warning'], 
                          style: const TextStyle(fontSize: 9, color: Colors.orange, fontWeight: FontWeight.bold), 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis
                        ),
                      ),
                    ],
                  ),
                ],
                if (task['info'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    task['info'], 
                    style: const TextStyle(fontSize: 9, color: Color(0xFF9CA3AF)), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(task['createdAt'], style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
              const SizedBox(width: 8),
              if (isCompleted)
                SizedBox(
                  height: 22,
                  child: OutlinedButton(
                    onPressed: () => _openTTSPreview(task),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isInserted ? const Color(0xFF2563EB) : const Color(0xFF1F2937),
                      side: BorderSide(color: isInserted ? const Color(0xFF3B82F6) : const Color(0xFFFFD1E1)),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      backgroundColor: isInserted ? Colors.blue.withOpacity(0.05) : Colors.white,
                    ),
                    child: Text(isInserted ? '已插入' : '查看', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
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

  void _insertTTS(String title) {
    setState(() {
      const ttsText = '这是由 AI 生成的补充文稿，您可以对其进行编辑或删除。';
      _transcript.insert(1, {
        'speaker': 'AI',
        'startTime': 45.0,
        'endTime': 52.0,
        'text': ttsText,
        'tokens': _parseTranscriptToTokens(ttsText),
        'isOriginal': false,
        'isTts': true,
        'confirmed': false,
      });
    });
    _onSearch(_searchQuery);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSegment(1));
    Navigator.pop(context);
  }

  void _aiSpecialCut() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.indigo,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('AI 专项剪辑', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildStrategyOption(0, 'AI 全剪辑', '一键全剪，处理所有冗余内容', setModalState),
                  _buildStrategyOption(1, 'AI 口癖剪辑', '只处理口癖（如：嗯、呃、这个等）', setModalState),
                  _buildStrategyOption(2, 'AI 口吃剪辑', '只处理口吃（如：重复字词、结巴等）', setModalState),
                  _buildStrategyOption(3, '智能分段', '根据语义自动拆分长段落', setModalState),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _applySpecialCut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B9D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('立即生成剪辑建议'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _applySpecialCut() {
    setState(() {
      String typeLabel = '';
      if (_selectedStrategy == 0) typeLabel = 'AI 全剪辑 (口癖+口吃)';
      else if (_selectedStrategy == 1) typeLabel = 'AI 口癖剪辑';
      else if (_selectedStrategy == 2) typeLabel = 'AI 口吃剪辑';
      else if (_selectedStrategy == 3) typeLabel = '智能分段';

      if (_selectedStrategy == 3) {
        // 模拟智能分段逻辑
        final List<Map<String, dynamic>> newTranscript = [];
        for (var item in _transcript) {
          if (item['isOriginal'] == true && item['text'].length > 50) {
            // 简单模拟拆分
            final text = item['text'] as String;
            final mid = text.length ~/ 2;
            final part1 = text.substring(0, mid);
            final part2 = text.substring(mid);
            
            newTranscript.add({
              ...item,
              'text': part1,
              'tokens': _parseTranscriptToTokens(part1),
              'editTrace': {'type': '智能分段', 'oldText': text, 'newText': part1, 'timestamp': DateTime.now().toString()}
            });
            newTranscript.add({
              ...item,
              'text': part2,
              'tokens': _parseTranscriptToTokens(part2),
              'editTrace': {'type': '智能分段', 'oldText': text, 'newText': part2, 'timestamp': DateTime.now().toString()}
            });
          } else {
            newTranscript.add(item);
          }
        }
        _transcript = newTranscript;
      } else {
        for (var item in _transcript) {
          if (item['isOriginal'] != true) continue;
          
          final tokens = (item['tokens'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          final oldText = _tokensToText(tokens);
          bool modified = false;
          
          for (var token in tokens) {
            if (_selectedStrategy == 0) {
              if (token['type'] == 'filler' || token['type'] == 'stutter') {
                token['type'] = 'deleted';
                modified = true;
              }
            } else if (_selectedStrategy == 1) {
              if (token['type'] == 'filler') {
                token['type'] = 'deleted';
                modified = true;
              }
            } else if (_selectedStrategy == 2) {
              if (token['type'] == 'stutter') {
                token['type'] = 'deleted';
                modified = true;
              }
            }
          }
          
          if (modified) {
            item['text'] = _tokensToText(tokens);
            item['editTrace'] = {
              'oldText': oldText,
              'newText': item['text'],
              'type': typeLabel,
              'timestamp': DateTime.now().toString(),
            };
          }
        }
      }
      _onSearch(_searchQuery);
    });
    _saveHistory();
  }

  Widget _buildStrategyOption(int index, String title, String desc, StateSetter setModalState) {
    bool isSelected = _selectedStrategy == index;
    return InkWell(
      onTap: () {
        setModalState(() {
          _selectedStrategy = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink.withOpacity(0.05) : Colors.white,
          border: Border.all(color: isSelected ? Colors.pink : Colors.pink.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: Colors.pink),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _semanticSearch() {
    final List<Map<String, dynamic>> allSentences = [
      {'content': 'AI 正在重塑音频内容的生产流程，这不仅是效率的提升，更是创意的解放。', 'time': '05:24', 'score': 95},
      {'content': '未来播客的竞争力不再是剪辑技术，而是内容深度与情感共鸣。', 'time': '12:15', 'score': 88},
      {'content': '播客的本质是陪伴，技术的加入是为了让这种陪伴更有温度。', 'time': '08:42', 'score': 92},
      {'content': '好的内容是自带流量的，AI 只是帮我们把这份价值放大了。', 'time': '15:30', 'score': 90},
      {'content': '创作不应该被繁琐的后期所束缚，我们要把时间留给更有价值的思考。', 'time': '21:10', 'score': 85},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final TextEditingController searchController = TextEditingController();
        List<Map<String, dynamic>> filteredSentences = List.from(allSentences);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('金句定位', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Text('字幕样式:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: DropdownButton<String>(
                                value: '简洁白底',
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: '简洁白底', child: Text('简洁白底', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: '卡拉OK高亮', child: Text('卡拉OK高亮', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: '科技霓虹', child: Text('科技霓虹', style: TextStyle(fontSize: 12))),
                                ],
                                onChanged: (v) {},
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            const Text('BGM:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: DropdownButton<String>(
                                value: 'LoFi Chill',
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: 'LoFi Chill', child: Text('LoFi Chill', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'Ambient Soft', child: Text('Ambient Soft', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'Conversation Bed', child: Text('Conversation Bed', style: TextStyle(fontSize: 12))),
                                ],
                                onChanged: (v) {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setModalState(() {
                        if (value.isEmpty) {
                          filteredSentences = List.from(allSentences);
                        } else {
                          filteredSentences = allSentences
                              .where((s) => s['content'].toString().toLowerCase().contains(value.toLowerCase()))
                              .toList();
                        }
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '例如：搜索关于职场焦虑的对话片段',
                      hintStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setModalState(() {
                                searchController.clear();
                                filteredSentences = List.from(allSentences);
                              });
                            },
                          )
                        : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.pink, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    searchController.text.isEmpty ? '推荐金句' : '搜索结果 (${filteredSentences.length})', 
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: filteredSentences.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text('未找到相关内容', style: TextStyle(color: Colors.grey[400])),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredSentences.length,
                          itemBuilder: (context, index) {
                            final item = filteredSentences[index];
                            return Stack(
                              children: [
                                _buildGoldenSentence(item['content'], item['time'], item['score']),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 16, color: Colors.orange),
                                        onPressed: () async {
                                          final ctrl = TextEditingController(text: item['content']);
                                          await showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text('编辑金句'),
                                              content: TextField(controller: ctrl, maxLines: 3),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
                                                TextButton(onPressed: () { Navigator.pop(context); }, child: const Text('保存')),
                                              ],
                                            ),
                                          );
                                          setModalState(() => item['content'] = ctrl.text);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                        onPressed: () => setModalState(() {
                                          filteredSentences.removeAt(index);
                                        }),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGoldenSentence(String content, String time, int score) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.yellow.shade50, Colors.orange.shade50]),
        border: Border.all(color: Colors.yellow.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.yellow.shade200, borderRadius: BorderRadius.circular(4)),
                child: const Text('金句', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('传播潜力: $score%', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  void _voiceAnalysis() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('语音分析', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              _buildToggleItem('说话人分离', true),
              _buildToggleItem('智能情绪提取', false),
              const SizedBox(height: 10),
              const Text('转写语言', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: '自动识别',
                    isExpanded: true,
                    items: ['自动识别', '中文', 'English', '中英混合'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
                    onChanged: (v) {},
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isTranscribing ? null : () {
                    Navigator.pop(context);
                    _startTranscription();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(_isTranscribing ? '正在转写中...' : '开始转写'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 作品预览中心（音频/视频/文案）
  void _openPreviewCenter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        int tab = 0;
        return StatefulBuilder(
          builder: (context, setSheet) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(width: 4, height: 16, decoration: BoxDecoration(color: const Color(0xFFFF6B9D), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 8),
                    const Text('作品预览', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChoiceChip(label: const Text('音频预览'), selected: tab == 0, onSelected: (_) => setSheet(() => tab = 0)),
                    const SizedBox(width: 8),
                    ChoiceChip(label: const Text('视频预览'), selected: tab == 1, onSelected: (_) => setSheet(() => tab = 1)),
                    const SizedBox(width: 8),
                    ChoiceChip(label: const Text('文案预览'), selected: tab == 2, onSelected: (_) => setSheet(() => tab = 2)),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: IndexedStack(
                    index: tab,
                    children: [
                      // 音频
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_circle_fill, size: 64, color: Color(0xFFFF6B9D)),
                            const SizedBox(height: 8),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              height: 40,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final maxWidth = constraints.maxWidth;
                                  final barCount = (maxWidth ~/ 7).clamp(20, 40); // 每个条形占7像素（4宽+3间距）
                                  final barWidth = 3.0;
                                  final barSpacing = 3.0;
                                  
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(barCount, (i) {
                                      // 创建多个起伏波形，使用正弦波叠加
                                      final x = i / barCount * 4 * 3.14159; // 2个完整周期
                                      final wave1 = (math.sin(x) + 1) / 2; // 基础波形
                                      final wave2 = (math.sin(x * 2.5) + 1) / 2 * 0.4; // 叠加高频小波
                                      final wave3 = (math.sin(x * 0.5) + 1) / 2 * 0.3; // 叠加低频大波
                                      final amplitude = (wave1 * 0.6 + wave2 + wave3 * 0.5).clamp(0.0, 1.0);
                                      final h = 8 + amplitude * 28;
                                      
                                      // 渐变颜色
                                      final gradientColors = [
                                        const Color(0xFFFF6B9D),
                                        const Color(0xFFFF8FB3),
                                        const Color(0xFFFFB8D0),
                                      ];
                                      final colorIndex = (amplitude * (gradientColors.length - 1)).floor();
                                      final color = gradientColors[colorIndex.clamp(0, gradientColors.length - 1)];
                                      
                                      return Padding(
                                        padding: EdgeInsets.symmetric(horizontal: barSpacing / 2),
                                        child: Container(
                                          width: barWidth,
                                          height: h.toDouble(),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.7 + amplitude * 0.3),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text('00:00 / 15:00', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      // 视频
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          height: 220,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFFF6B9D)),
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(colors: [Color(0xFFFFF0F5), Color(0xFFF5F3FF)]),
                          ),
                          child: const Center(child: Text('视频预览占位', style: TextStyle(color: Colors.grey))),
                        ),
                      ),
                      // 文案
                      ListView(
                        padding: const EdgeInsets.all(8),
                        children: _transcript.take(8).map((e) => ListTile(
                          dense: true,
                          title: Text((e['text'] as String), maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${e['speaker']} · ${e['time']}', style: const TextStyle(fontSize: 11)),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 金句视频生成（角色头像/虚拟形象、字幕样式、AI BGM 推荐）
  void _showGoldenVideoDialog() {
    String subtitleStyle = '简洁白底';
    String bgm = 'LoFi Chill';
    String avatar = '使用虚拟形象';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 4, height: 16, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  const Text('金句视频', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('角色形象', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButton<String>(
                value: avatar,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: '上传角色照片', child: Text('上传角色照片')),
                  DropdownMenuItem(value: '使用虚拟形象', child: Text('使用虚拟形象')),
                ],
                onChanged: (v) => setSheet(() => avatar = v ?? avatar),
              ),
              const SizedBox(height: 8),
              const Text('字幕样式', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButton<String>(
                value: subtitleStyle,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: '简洁白底', child: Text('简洁白底')),
                  DropdownMenuItem(value: '卡拉OK高亮', child: Text('卡拉OK高亮')),
                  DropdownMenuItem(value: '科技霓虹', child: Text('科技霓虹')),
                ],
                onChanged: (v) => setSheet(() => subtitleStyle = v ?? subtitleStyle),
              ),
              const SizedBox(height: 8),
              const Text('AI 推荐 BGM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButton<String>(
                value: bgm,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'LoFi Chill', child: Text('LoFi Chill')),
                  DropdownMenuItem(value: 'Ambient Soft', child: Text('Ambient Soft')),
                  DropdownMenuItem(value: 'Conversation Bed', child: Text('Conversation Bed')),
                ],
                onChanged: (v) => setSheet(() => bgm = v ?? bgm),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('生成预览视频'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _startTranscription() {
    if (_isTranscribing) return;
    
    setState(() {
      _isTranscribing = true;
    });

    int count = 0;
    final List<String> mockSentences = [
      "大家好，欢迎收听本期播客。",
      "今天我们邀请到了一位特别嘉宾，来聊聊 AI 时代的创作。",
      "其实我觉得，技术的边界正在被不断拓宽。",
      "没错，正如我们之前讨论的那样，效率与创意的平衡至关重要。"
    ];

    _transcriptionTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (count >= mockSentences.length) {
        timer.cancel();
        setState(() {
          _isTranscribing = false;
        });
        return;
      }

      setState(() {
        final text = mockSentences[count];
        final newItem = {
          'speaker': 'C',
          'time': '111.00 - ${111.00 + (count + 1) * 5}.00',
          'text': text,
          'isOriginal': true, // Keep as original so we see history
          'isTts': false,
          'confirmed': true,
          'tokens': _parseTranscriptToTokens(text),
          'editTrace': {
            'oldText': '(新转写内容)',
            'newText': text,
            'type': '语音转写 (Speaker C)',
            'timestamp': DateTime.now().toString(),
          }
        };
        _transcript.add(newItem);
        _onSearch(_searchQuery);
        _saveHistory(); // Save history for each new segment
        
        // Auto scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_transcriptScrollController.hasClients) {
            _transcriptScrollController.animateTo(
              _transcriptScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      });
      count++;
    });
  }

  Widget _buildToggleItem(String title, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          Switch(value: value, onChanged: (v) {}, activeColor: Colors.pink),
        ],
      ),
    );
  }

  void _audioEnhance() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('音质增强', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('智能降噪 (80%)', style: TextStyle(fontSize: 14)),
            Slider(value: 0.8, onChanged: (v) {}, activeColor: Colors.green),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.pink,
                      side: const BorderSide(color: Colors.pink),
                    ),
                    child: const Text('人声增强'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.pink,
                      side: const BorderSide(color: Colors.pink),
                    ),
                    child: const Text('去回声'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(String title, String desc, VoidCallback onTap, {bool isSelected = false, IconData? icon}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF5F8) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B9D) : const Color(0xFFF3F4F6),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: isSelected ? const Color(0xFFFF6B9D) : const Color(0xFF9CA3AF)),
              const SizedBox(height: 8),
            ],
            Text(
              title, 
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFFFF6B9D) : const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc, 
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9, 
                color: isSelected ? const Color(0xFFFF6B9D).withOpacity(0.7) : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
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
          // 6 Tools evenly distributed
          SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 90, child: _buildToolBtn(Icons.description_outlined, '内容润色', _optimizeScript)),
                      SizedBox(width: 90, child: _buildToolBtn(Icons.mic_none_outlined, '声演实验室', _generateVoice)),
                      SizedBox(width: 90, child: _buildToolBtn(Icons.content_cut_outlined, '后期大师', _aiSpecialCut)),
                      SizedBox(width: 90, child: _buildToolBtn(Icons.search, '高光提取', _semanticSearch)),
                      SizedBox(width: 90, child: _buildToolBtn(Icons.analytics_outlined, '文本引擎', _voiceAnalysis)),
                      SizedBox(width: 90, child: _buildToolBtn(Icons.high_quality_outlined, '声效修复', _audioEnhance)),
                      SizedBox(width: 90, child: _buildToolBtn(Icons.movie_creation_outlined, '金句视频', _showGoldenVideoDialog)),
                      SizedBox(width: 90, child: _buildToolBtn(Icons.visibility_outlined, '作品预览', _openPreviewCenter)),
                    ],
                  ),
                ),
        ],
      ),
    );
  }


  Widget _buildTimelineRuler() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 110,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey[300]!, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _zoomLevel = (_zoomLevel - 2).clamp(4.0, 20.0)),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.zoom_out, size: 18, color: Colors.black54),
                  ),
                ),
                const SizedBox(width: 2),
                SizedBox(
                  width: 35,
                  child: Text(
                    '${(_zoomLevel * 10).toInt()}%',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 2),
                GestureDetector(
                  onTap: () => setState(() => _zoomLevel = (_zoomLevel + 2).clamp(4.0, 20.0)),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.zoom_in, size: 18, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  width: 60, // 6 seconds at zoomLevel 10
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 4,
                        bottom: 4,
                        child: Text(
                          '${index * 6}s',
                          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ),
                      // 刻度
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (i) => Container(
                          width: 1,
                          height: i == 0 ? 15 : 8,
                          color: i == 0 ? Colors.grey[400] : Colors.grey[300],
                        )),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackRow(Map<String, dynamic> track) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Container(
            width: 110,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Colors.grey[300]!, width: 1),
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        track['name'],
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.lock_outline, size: 10, color: Colors.grey[300]),
                  ],
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 12,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 3),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 6),
                      // 减少 Slider 的默认内边距
                      padding: EdgeInsets.zero,
                    ),
                    child: Slider(
                      value: 80,
                      onChanged: (v) {},
                      max: 100,
                      activeColor: track['color'],
                      inactiveColor: Colors.grey[200],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1200, // Matching timeline width (111s * zoom)
                child: Stack(
                  children: [
                    ...(track['clips'] as List).map((clip) {
                      double start = clip['start'] * _zoomLevel;
                      double width = (clip['end'] - clip['start']) * _zoomLevel;
                      return Positioned(
                        left: start,
                        top: 4,
                        bottom: 4,
                        child: Container(
                          width: width,
                          decoration: BoxDecoration(
                            color: (track['color'] as Color).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: (track['color'] as Color).withOpacity(0.5)),
                          ),
                          child: Center(
                            child: Text(
                              clip['name'],
                              style: TextStyle(fontSize: 8, color: track['color'], overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptItem(int itemIndex, String speaker, String time, List<Map<String, dynamic>> tokens) {
    final item = _transcript[itemIndex];
    final bool isOriginal = item['isOriginal'] == true;
    final bool isTts = item['isTts'] == true;
    final bool confirmed = item['confirmed'] == true;
    final Map<String, dynamic>? editTrace = item['editTrace'] is Map ? Map<String, dynamic>.from(item['editTrace']) : null;
    final bool allowTokenEdit = !(isTts && !confirmed);

    return KeyedSubtree(
      key: _segmentKeyFor(itemIndex),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isOriginal ? Colors.white : Colors.pink.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOriginal ? Colors.grey[100]! : Colors.pink.withOpacity(0.1),
            width: isOriginal ? 1 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRect(
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: isOriginal ? Colors.blue.withOpacity(0.1) : Colors.pink.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isOriginal)
                                  const Icon(Icons.auto_awesome, size: 10, color: Colors.pink),
                                if (!isOriginal) const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    isOriginal ? 'Speaker $speaker' : 'AI 生成',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isOriginal ? Colors.blue : Colors.pink,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (editTrace != null && editTrace['type'] != null)
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              margin: const EdgeInsets.only(right: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber[50],
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: Colors.amber[200]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome, size: 7, color: Colors.amber[700]),
                                  const SizedBox(width: 1),
                                  Flexible(
                                    child: Text(
                                      editTrace['type'],
                                      style: TextStyle(fontSize: 7, color: Colors.amber[800], fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (isTts && !confirmed)
                          TextButton(
                            onPressed: () => _confirmTtsSegment(itemIndex),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 9),
                                const SizedBox(width: 1),
                                const Text('确认', style: TextStyle(fontSize: 8)),
                              ],
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(horizontal: 1),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        if (!isOriginal)
                          IconButton(
                            onPressed: () => _deleteSegment(itemIndex),
                            icon: const Icon(Icons.delete_outline, size: 12, color: Colors.red),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                          ),
                        TextButton(
                          onPressed: isTts && !confirmed ? null : () => _editSegmentText(itemIndex),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.edit_outlined, size: 10),
                              const SizedBox(width: 1),
                              const Text('编辑', style: TextStyle(fontSize: 8)),
                            ],
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                children: [
                  ...List.generate(tokens.length, (tokenIndex) {
                    final token = tokens[tokenIndex];
                    final type = token['type'];
                    final text = token['text'];

                    if (type == 'space') {
                      return TextSpan(text: text);
                    }

                    Color textColor = Colors.black87;
                    Color bgColor = Colors.transparent;
                    TextDecoration decoration = TextDecoration.none;

                    if (type == 'filler') {
                      textColor = Colors.orange[700]!;
                      bgColor = Colors.orange[50]!;
                    } else if (type == 'stutter') {
                      textColor = Colors.purple[700]!;
                      bgColor = Colors.purple[50]!;
                    } else if (type == 'deleted') {
                      textColor = Colors.grey[400]!;
                      decoration = TextDecoration.lineThrough;
                    } else if (type == 'added') {
                      textColor = Colors.blue[700]!;
                      bgColor = Colors.blue[50]!;
                    } else if (type == 'modified') {
                      textColor = Colors.blue[700]!;
                      bgColor = Colors.blue[50]!;
                    }

                    // 如果是新增的文本（来自手动编辑差异对比）
                    if (type == 'added') {
                      return TextSpan(
                        text: text,
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                          backgroundColor: bgColor,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }

                    // 修改过的单词（长按修改）
                    if (type == 'modified') {
                      return TextSpan(
                        children: [
                          TextSpan(
                            text: token['oldText'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(Icons.arrow_right, size: 16, color: Colors.blue[300]),
                          ),
                          TextSpan(
                            text: text,
                            recognizer: allowTokenEdit ? (LongPressGestureRecognizer()..onLongPress = () => _editTokenText(itemIndex, tokenIndex)) : null,
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                              backgroundColor: bgColor != Colors.transparent ? bgColor : null,
                              decoration: decoration,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }

                    // 普通单词、语气词、重复词
                    return TextSpan(
                      text: text,
                      recognizer: allowTokenEdit ? (TapGestureRecognizer()..onTap = () => _toggleTokenDelete(itemIndex, tokenIndex)) : null,
                      onEnter: (event) {
                        // 可以添加悬浮效果
                      },
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        backgroundColor: bgColor != Colors.transparent ? bgColor : null,
                        decoration: decoration,
                        fontWeight: (type == 'filler' || type == 'stutter') ? FontWeight.w500 : FontWeight.normal,
                      ),
                    );
                  }),
                ],
              ),
            ),
            if (tokens.any((t) => t['type'] == 'deleted'))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text('点击划线文字可恢复删除', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionChip(String emotion, String selectedEmotion, Function(String) onSelect) {
    final bool isSelected = selectedEmotion == emotion;
    return GestureDetector(
      onTap: () => onSelect(emotion),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B9D) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          emotion,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
