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
  List<Map<String, dynamic>> _aiSummaries = [];
  int _insertPosition = 0; // 0: 上方, 1: 下方, 2: 内部
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

  // 声演实验室相关
  Map<String, dynamic>? _lockedTTSSegment;
  String _editSupplementText = '';
  List<Map<String, dynamic>> _clonedVoiceSentences = [];
  List<Map<String, dynamic>> _insertedVoiceRecords = [];
  bool _isCloningVoice = false;
  int _generateProgress = 0;

  // 金句高光相关
  List<Map<String, dynamic>> _goldenSentences = [];
  bool _hasExtractedGolden = false;

  @override
  void initState() {
    super.initState();
    _initializeTranscript();
    _filteredTranscript = List.from(_transcript);
    _saveHistory();
    // 初始化金句状态
    _hasExtractedGolden = false;
    _goldenSentences = [];
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
        'isGolden': false,
        'editTrace': {
          'oldText': item['text'],
          'newText': _tokensToText(tokens),
          'type': hasAnnotation ? 'AI 自动标注 (口癖/口吃)' : 'AI 自动标注',
          'timestamp': DateTime.now().toString(),
        },
      };
    }).toList();
    
    _generateAISummaries();
  }

  void _generateAISummaries() {
    _aiSummaries = [];
    
    if (_transcript.isEmpty) return;
    
    int segmentCount = _transcript.length;
    int segmentsPerSection = (segmentCount / 3).ceil();
    
    for (int i = 0; i < segmentCount; i += segmentsPerSection) {
      int endIndex = math.min(i + segmentsPerSection, segmentCount);
      List<Map<String, dynamic>> section = _transcript.sublist(i, endIndex);
      
      String summary = _generateSummaryForSection(section, i ~/ segmentsPerSection);
      
      _aiSummaries.add({
        'startIndex': i,
        'endIndex': endIndex - 1,
        'summary': summary,
        'sectionNumber': _aiSummaries.length + 1,
      });
    }
  }

  String _generateSummaryForSection(List<Map<String, dynamic>> section, int sectionIndex) {
    final List<String> texts = section.map((item) => item['text'] as String).toList();
    final String fullText = texts.join(' ');
    
    switch (sectionIndex) {
      case 0:
        return '开场引入：讨论AI介入创作的热门话题，提出AI剪辑缺乏人情味的担忧';
      case 1:
        return '深入探讨：阐述人类聊天中"停顿"的意义，强调智能应做逻辑筛选而非物理减法';
      case 2:
        return '总结升华：PodPal的文稿式剪辑让创作更民主化，技术退居幕后，表达走向台前';
      default:
        return '本段讨论了播客创作与AI技术结合的相关话题';
    }
  }

  List<Map<String, dynamic>> _parseTranscriptToTokens(String text) {
    final List<Map<String, dynamic>> tokens = [];
    
    final pattern = RegExp(r'([\u4e00-\u9fa5]+|[a-zA-Z0-9]+|[^\w\s\u4e00-\u9fa5]+|[\s]+)');
    
    final matches = pattern.allMatches(text);
    for (final match in matches) {
      final part = match.group(0)!;
      if (RegExp(r'^\s+$').hasMatch(part)) {
        tokens.add({'type': 'space', 'text': part});
      } else if (RegExp(r'^[^\w\s\u4e00-\u9fa5]+$').hasMatch(part)) {
        tokens.add({'type': 'punctuation', 'text': part});
      } else {
        if (_fillerWords.contains(part)) {
          tokens.add({'type': 'filler', 'text': part});
        } else {
          bool hasFiller = false;
          for (final filler in _fillerWords) {
            if (part.contains(filler)) {
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
  
  void _splitTextWithFiller(String text, List<Map<String, dynamic>> tokens) {
    final sortedFillerWords = List.from(_fillerWords)..sort((a, b) => b.length.compareTo(a.length));
    final fillerRegex = RegExp(r'(' + sortedFillerWords.map((w) => RegExp.escape(w)).join('|') + r')');
    
    int lastIndex = 0;
    for (final match in fillerRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        final beforeText = text.substring(lastIndex, match.start);
        if (beforeText.isNotEmpty) {
          _addTokenToTokens(beforeText, tokens);
        }
      }
      tokens.add({'type': 'filler', 'text': match.group(0)!});
      lastIndex = match.end;
    }
    
    if (lastIndex < text.length) {
      final remainingText = text.substring(lastIndex);
      if (remainingText.isNotEmpty) {
        _addTokenToTokens(remainingText, tokens);
      }
    }
  }

  void _addTokenToTokens(String text, List<Map<String, dynamic>> tokens) {
    final stutterRegex = RegExp(r'([\u4e00-\u9fa5A-Za-z])\1{2,}');
    
    if (!stutterRegex.hasMatch(text)) {
      tokens.add({'type': 'text', 'text': text});
      return;
    }
    
    int lastIndex = 0;
    for (final match in stutterRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        tokens.add({
          'type': 'text',
          'text': text.substring(lastIndex, match.start),
        });
      }
      tokens.add({
        'type': 'stutter',
        'text': match.group(0)!,
      });
      lastIndex = match.end;
    }
    
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
  int _selectedStrategy = 0;
  
  // AI 专项剪辑方法
  void _applySpecialCut() {
    // 模拟 AI 专项剪辑处理
    setState(() {
      // 根据选择的策略进行处理
      switch (_selectedStrategy) {
        case 0: // AI 全剪辑
          // 处理所有冗余内容
          _transcript = _transcript.map((seg) {
            // 模拟处理，实际应用中应该调用 AI 服务
            return seg;
          }).toList();
          break;
        case 1: // AI 口癖剪辑
          // 只处理口癖
          _transcript = _transcript.map((seg) {
            // 模拟处理，实际应用中应该调用 AI 服务
            return seg;
          }).toList();
          break;
        case 2: // AI 口吃剪辑
          // 只处理口吃
          _transcript = _transcript.map((seg) {
            // 模拟处理，实际应用中应该调用 AI 服务
            return seg;
          }).toList();
          break;
        case 3: // 智能分段
          // 根据语义自动拆分长段落
          _transcript = _transcript.map((seg) {
            // 模拟处理，实际应用中应该调用 AI 服务
            return seg;
          }).toList();
          break;
      }
    });
  }
  
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
    _generateAISummaries();
  }

  void _undo() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        _transcript = _history[_historyIndex].map(_cloneItem).toList();
        _syncGoldenFromTranscript();
        _onSearch(_searchQuery);
      });
    }
  }

  void _redo() {
    if (_historyIndex < _history.length - 1) {
      setState(() {
        _historyIndex++;
        _transcript = _history[_historyIndex].map(_cloneItem).toList();
        _syncGoldenFromTranscript();
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
                child: Text(k, style: TextStyle(fontSize: 12, color: Color(0xFFFF6B9D))),
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
          _buildMindmapNode('AI 播客创作', time: '00:00', isRoot: true),
          
          const SizedBox(height: 20),
          
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
        token['type'] = token['oldType'] ?? 'text';
        token.remove('oldType');
      } else {
        token['oldType'] = token['type'];
        token['type'] = 'deleted';
      }
      
      item['text'] = _tokensToText(tokens);
      _syncGoldenFromTranscript();
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
                  _syncGoldenFromTranscript();
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
    int i = 0, j = 0;
    while (i < oldText.length || j < newText.length) {
      if (i < oldText.length && j < newText.length && oldText[i] == newText[j]) {
        tokens.add({'type': 'text', 'text': oldText[i]});
        i++;
        j++;
      } else {
        int nextI = i;
        int nextJ = j;
        bool found = false;
        
        for (int lookAhead = 1; lookAhead < 10; lookAhead++) {
          if (i + lookAhead < oldText.length && j < newText.length && oldText[i + lookAhead] == newText[j]) {
            for (int k = 0; k < lookAhead; k++) {
              tokens.add({'type': 'deleted', 'text': oldText[i + k]});
            }
            i += lookAhead;
            found = true;
            break;
          }
          if (j + lookAhead < newText.length && i < oldText.length && newText[j + lookAhead] == oldText[i]) {
            for (int k = 0; k < lookAhead; k++) {
              tokens.add({'type': 'added', 'text': newText[j + k]});
            }
            j += lookAhead;
            found = true;
            break;
          }
        }
        
        if (!found) {
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
                  _syncGoldenFromTranscript();
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
      _syncGoldenFromTranscript();
    });
    _saveHistory();
  }

  void _deleteSegment(int itemIndex) {
    setState(() {
      final item = _transcript[itemIndex];
      if(item['isGolden'] == true){
        _goldenSentences.removeWhere((e) => e['index'] == itemIndex);
      }
      _transcript.removeAt(itemIndex);
      _syncGoldenFromTranscript();
      _onSearch(_searchQuery);
    });
    _saveHistory();
  }

  // 声演实验室
  void loadSegmentToVoiceLab(Map<String, dynamic> segment, int index) {
    setState(() {
      _lockedTTSSegment = {
        'index': index,
        'text': '',
        'isNew': true
      };
      _editSupplementText = '';
    });
    _showVoiceLabDialog();
  }

  String _getSpeakerName() {
    if (_lockedTTSSegment == null) {
      return 'Speaker';
    }
    final index = _lockedTTSSegment!['index'];
    if (index == null) {
      return 'Speaker';
    }
    if (index < 0 || index >= _transcript.length || _transcript[index] == null) {
      return 'Speaker';
    }
    return _transcript[index]['speaker'] ?? 'Speaker';
  }

  void _showVoiceLabDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题栏
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.pink.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('声演实验室', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _lockedTTSSegment = null;
                          _editSupplementText = '';
                          _clonedVoiceSentences = [];
                        });
                      },
                      icon: const Icon(Icons.close, size: 24, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // 输入框
                TextField(
                  onChanged: (value) {
                    setDialogState(() {
                      _editSupplementText = value;
                    });
                  },
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: '请输入补录内容...',
                    hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.pink.withOpacity(0.7), width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 24),
                
                // 插入位置选择
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('插入位置', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<int>(
                              title: const Text('上方', style: TextStyle(fontSize: 14)),
                              value: 0,
                              groupValue: _insertPosition,
                              onChanged: (value) {
                                setDialogState(() {
                                  _insertPosition = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<int>(
                              title: const Text('下方', style: TextStyle(fontSize: 14)),
                              value: 1,
                              groupValue: _insertPosition,
                              onChanged: (value) {
                                setDialogState(() {
                                  _insertPosition = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<int>(
                              title: const Text('内部', style: TextStyle(fontSize: 14)),
                              value: 2,
                              groupValue: _insertPosition,
                              onChanged: (value) {
                                setDialogState(() {
                                  _insertPosition = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 确认按钮
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _editSupplementText.trim().isEmpty ? null : () async {
                          setDialogState(() {
                            _isCloningVoice = true;
                            _generateProgress = 0;
                          });
                          
                          await confirmEditAndGenerate(setDialogState);
                          
                          setDialogState(() {
                            _isCloningVoice = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.withOpacity(0.7),
                          disabledBackgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text('确认', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
                
                // 进度指示器
                if (_isCloningVoice) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.pink.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('生成中...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.pink.withOpacity(0.7))),
                            Text('${_generateProgress}%', style: TextStyle(fontSize: 14, color: Colors.pink.withOpacity(0.7))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: _generateProgress / 100,
                          backgroundColor: Colors.grey[200],
                          color: Colors.pink.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // 克隆结果
                if (_clonedVoiceSentences.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    height: 1,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('克隆结果', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                      Text('共 ${_clonedVoiceSentences.length} 条', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._clonedVoiceSentences.map((sentence) => Container(
                    padding: const EdgeInsets.all(18),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.pink.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sentence['text'], style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('${_getSpeakerName()} | ${sentence['duration']}s', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => previewClonedVoice(sentence),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.blue.withOpacity(0.7)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text('预览', style: TextStyle(fontSize: 14, color: Colors.blue.withOpacity(0.7))),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  confirmInsertClonedVoice(sentence);
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink.withOpacity(0.7),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('确认插入', style: TextStyle(fontSize: 14, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )).toList(),
                ],

                // 插入记录
                if (_insertedVoiceRecords.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    height: 1,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('插入记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                      Text('共 ${_insertedVoiceRecords.length} 条', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: _insertedVoiceRecords.map((record) {
                      return Container(
                        padding: const EdgeInsets.all(18),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(record['text'], style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text('${record['voiceName']} | ${record['createdAt']}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    editInsertedVoice(record);
                                  },
                                  child: const Text('编辑', style: TextStyle(fontSize: 14, color: Colors.blue)),
                                ),
                                const SizedBox(width: 20),
                                TextButton(
                                  onPressed: () {
                                    deleteInsertedVoice(record['id']);
                                    setDialogState(() {});
                                  },
                                  child: const Text('删除', style: TextStyle(fontSize: 14, color: Colors.red)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> confirmEditAndGenerate(Function(void Function())? updateDialog) async {
    if (_lockedTTSSegment == null || _editSupplementText.trim().isEmpty) return;

    setState(() {
      _lockedTTSSegment!['text'] = _editSupplementText;
    });
    await cloneVoice(updateDialog);
  }

  Future<void> cloneVoice(Function(void Function())? updateDialog) async {
    if (_lockedTTSSegment == null) return;

    final textLength = _lockedTTSSegment!['text'].length;
    final estimatedDuration = (textLength / 10).ceil();
    
    // 拆分生成阶段，模拟真实进度
    final stages = [
      {'name': '文本解析', 'progress': 20},
      {'name': '模型推理', 'progress': 60},
      {'name': '音频合成', 'progress': 100},
    ];

    // 逐个阶段更新进度
    for (var stage in stages) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _generateProgress = stage['progress']! as int;
      });
      // 同时更新对话框状态
      if (updateDialog != null) {
        updateDialog(() {});
      }
    }

    try {
      const defaultVoice = {
        'name': '温柔女声',
        'id': 'default',
        'style': '亲切自然'
      };

      final clonedSentence = {
        'id': DateTime.now().millisecond.toString(),
        'text': _lockedTTSSegment!['text'],
        'duration': estimatedDuration,
        'voiceName': defaultVoice['name'],
        'voiceStyle': defaultVoice['style'],
        'voiceId': defaultVoice['id']
      };

      setState(() {
        _clonedVoiceSentences = [clonedSentence];
      });
      // 更新对话框状态
      if (updateDialog != null) {
        updateDialog(() {});
      }
    } catch (error) {
      print('音色克隆失败: $error');
    }
  }

  void confirmInsertClonedVoice(Map<String, dynamic> sentence) {
    if (_lockedTTSSegment == null) return;

    final index = _lockedTTSSegment!['index'];
    final speaker = _getSpeakerName();
    
    setState(() {
      if (index == -1) {
        // 添加到末尾
        final newSeg = {
          'speaker': speaker,
          'time': '00:00 - 00:00',
          'text': sentence['text'],
          'isOriginal': false,
          'isTts': true,
          'confirmed': true,
          'isCloned': true,
          'voiceId': sentence['voiceId'],
          'voiceStyle': sentence['voiceStyle'],
          'tokens': _parseTranscriptToTokens(sentence['text']),
          'isGolden': false,
          'editTrace': {
            'oldText': '',
            'newText': sentence['text'],
            'type': 'AI 克隆语音插入',
            'timestamp': DateTime.now().toString(),
          },
        };
        _transcript.add(newSeg);
      } else {
        if (_insertPosition == 0) {
          // 插入到上方
          final newSeg = {
            'speaker': speaker,
            'time': '00:00 - 00:00',
            'text': sentence['text'],
            'isOriginal': false,
            'isTts': true,
            'confirmed': true,
            'isCloned': true,
            'voiceId': sentence['voiceId'],
            'voiceStyle': sentence['voiceStyle'],
            'tokens': _parseTranscriptToTokens(sentence['text']),
            'isGolden': false,
            'editTrace': {
              'oldText': '',
              'newText': sentence['text'],
              'type': 'AI 克隆语音插入',
              'timestamp': DateTime.now().toString(),
            },
          };
          _transcript.insert(index, newSeg);
        } else if (_insertPosition == 1) {
          // 插入到下方
          final newSeg = {
            'speaker': speaker,
            'time': '00:00 - 00:00',
            'text': sentence['text'],
            'isOriginal': false,
            'isTts': true,
            'confirmed': true,
            'isCloned': true,
            'voiceId': sentence['voiceId'],
            'voiceStyle': sentence['voiceStyle'],
            'tokens': _parseTranscriptToTokens(sentence['text']),
            'isGolden': false,
            'editTrace': {
              'oldText': '',
              'newText': sentence['text'],
              'type': 'AI 克隆语音插入',
              'timestamp': DateTime.now().toString(),
            },
          };
          _transcript.insert(index + 1, newSeg);
        } else if (_insertPosition == 2) {
          // 插入到内部，使用不同颜色标注
          final originalText = _transcript[index]['text'];
          final newText = originalText + ' ' + sentence['text'];
          _transcript[index]['text'] = newText;
          _transcript[index]['tokens'] = _parseTranscriptToTokens(newText);
          _transcript[index]['isOriginal'] = false;
          _transcript[index]['editTrace'] = {
            'oldText': originalText,
            'newText': newText,
            'type': 'AI 克隆语音内部插入',
            'timestamp': DateTime.now().toString(),
          };
        }
      }

      final record = {
        'id': sentence['id'],
        'text': sentence['text'],
        'voiceName': sentence['voiceName'],
        'voiceStyle': sentence['voiceStyle'],
        'voiceId': sentence['voiceId'],
        'transcriptIndex': index + 1,
        'createdAt': DateTime.now().toString().substring(11, 16)
      };

      _insertedVoiceRecords.insert(0, record);
      _clonedVoiceSentences = [];
      _lockedTTSSegment = null;
      _editSupplementText = '';
      _syncGoldenFromTranscript();
      _onSearch(_searchQuery);
    });
    _saveHistory();
  }

  void previewClonedVoice(Map<String, dynamic> sentence) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在预览${sentence['voiceName']}：${sentence['text'].substring(0, sentence['text'].length > 20 ? 20 : sentence['text'].length)}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void editInsertedVoice(Map<String, dynamic> record) {
    final seg = _transcript[record['transcriptIndex']];
    if (seg == null) return;

    setState(() {
      _lockedTTSSegment = {
        'index': record['transcriptIndex'],
        'text': seg['text'].toString().replaceAll('[TTS] ', ''),
        'isNew': false
      };
      _editSupplementText = _lockedTTSSegment!['text'];
    });
    _showVoiceLabDialog();
  }

  void _showInsertedVoiceRecordsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
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
                    const Text('插入记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('共 ${_insertedVoiceRecords.length} 条', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _insertedVoiceRecords.length,
                itemBuilder: (context, index) {
                  final record = _insertedVoiceRecords[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record['text'], style: const TextStyle(fontSize: 16, height: 1.5)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('${record['voiceName']} | ${record['createdAt']}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                editInsertedVoice(record);
                              },
                              child: const Text('编辑', style: TextStyle(fontSize: 14, color: Colors.blue)),
                            ),
                            const SizedBox(width: 20),
                            TextButton(
                              onPressed: () {
                                deleteInsertedVoice(record['id']);
                                Navigator.pop(context);
                                if (_insertedVoiceRecords.isNotEmpty) {
                                  _showInsertedVoiceRecordsDialog();
                                }
                              },
                              child: const Text('删除', style: TextStyle(fontSize: 14, color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void deleteInsertedVoice(String recordId) {
    final record = _insertedVoiceRecords.firstWhere((r) => r['id'] == recordId, orElse: () => {});
    if (record.isEmpty) return;

    setState(() {
      _transcript.removeAt(record['transcriptIndex']);
      _insertedVoiceRecords.removeWhere((r) => r['id'] == recordId);
      _syncGoldenFromTranscript();
      _onSearch(_searchQuery);
    });
    _saveHistory();
  }

  // ====================== 金句高光核心逻辑 ======================
  // 同步文稿金句状态到列表
  void _syncGoldenFromTranscript() {
    setState(() {
      _goldenSentences.clear();
      for(int i=0; i<_transcript.length; i++){
        final item = _transcript[i];
        if(item['isGolden'] == true){
          _goldenSentences.add({
            'id': 'golden_$i',
            'index': i,
            'text': item['text'],
            'speaker': item['speaker'],
            'time': item['time'],
          });
        }
      }
    });
  }

  // 切换单句金句
  void toggleGoldenSentence(int index) {
    setState(() {
      final item = _transcript[index];
      item['isGolden'] = !(item['isGolden'] ?? false);
      _syncGoldenFromTranscript();
    });
    _showGoldenSentenceDialog(index);
  }

  void _showGoldenSentenceDialog(int index) {
    final item = _transcript[index];
    final isGolden = item['isGolden'] ?? false;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade600,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isGolden ? '已添加金句' : '已取消金句',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.yellow.shade700),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.yellow.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isGolden ? Icons.star : Icons.star_border,
                        size: 16,
                        color: isGolden ? Colors.yellow.shade600 : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(item['text'], style: const TextStyle(fontSize: 16, height: 1.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(width: 28),
                      Text('${item['speaker']} | ${item['time']}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 一键提取金句（仅点击后生成，不重复覆盖）
  void extractGoldenSentences() {
    if(_hasExtractedGolden){
      _showGoldenSentencesDialog();
      return;
    }

    setState(() {
      // 收集已经手动标记的金句索引
      final manuallyMarkedIndexes = <int>[];
      for (int i = 0; i < _transcript.length; i++) {
        if (_transcript[i]['isGolden'] == true) {
          manuallyMarkedIndexes.add(i);
        }
      }

      // 从其他文字稿中选取金句（避免覆盖手动标记的）
      final goldenIndexes = <int>[];
      int count = 0;
      for (int i = 0; i < _transcript.length && count < 3; i++) {
        // 跳过已经手动标记的句子
        if (!manuallyMarkedIndexes.contains(i)) {
          goldenIndexes.add(i);
          count++;
        }
      }

      // 标记AI提取的金句
      for (int i in goldenIndexes) {
        if(i<_transcript.length){
          _transcript[i]['isGolden'] = true;
        }
      }

      _hasExtractedGolden = true;
      _syncGoldenFromTranscript();
    });

    _showGoldenSentencesDialog();
  }

  void _showGoldenSentencesDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: StatefulBuilder(
          builder: (context, setDialogState) => Column(
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
                          color: Colors.yellow.shade600,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('金句高光', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.yellow.shade700)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // 提取按钮（首次显示，已提取后隐藏）
              if(!_hasExtractedGolden)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    extractGoldenSentences();
                    setDialogState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('AI提取高光', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              
              // 金句列表
              if (!_hasExtractedGolden) ...[
                const Text('还没有提取金句，请点击上方按钮', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ] else if (_goldenSentences.isEmpty) ...[
                const Text('还没有提取金句，请点击上方按钮', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ] else ...[
                Text('共 ${_goldenSentences.length} 句', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _goldenSentences.length,
                    itemBuilder: (context, index) {
                      final sentence = _goldenSentences[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.yellow.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.yellow.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.star, size: 16, color: Colors.yellow.shade600),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(sentence['text'], style: const TextStyle(fontSize: 16, height: 1.5)),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      final idx = sentence['index'];
                                      if(idx >=0 && idx < _transcript.length){
                                        _transcript[idx]['isGolden'] = false;
                                      }
                                      _syncGoldenFromTranscript();
                                    });
                                    setDialogState(() {});
                                  },
                                  icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const SizedBox(width: 28),
                                Text('${sentence['speaker']} | ${sentence['time']}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  // ============================================================

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

  double _zoomLevel = 10.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                      final originalIndex = _transcript.indexOf(item);
                      
                      Widget content = _buildTranscriptItem(
                        originalIndex,
                        (item['speaker'] as String?) ?? '',
                        (item['time'] as String?) ?? '',
                        (item['tokens'] as List?)?.cast<Map<String, dynamic>>() ?? [],
                      );
                      
                      for (final summary in _aiSummaries) {
                        if (originalIndex == summary['startIndex']) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAISummaryCard(summary),
                              content,
                            ],
                          );
                        }
                      }
                      
                      return content;
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
                        extractGoldenSentences();
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
        final newItem = {
          'speaker': 'AI',
          'time': '32.00',
          'text': '[建议补充过渡句] 此处语义跳跃明显，建议补充一句过渡说明。',
          'isOriginal': false,
          'isTts': true,
          'confirmed': false,
          'tokens': _parseTranscriptToTokens('[建议补充过渡句] 此处语义跳跃明显，建议补充一句过渡说明。'),
          'isGolden': false,
          'editTrace': {
            'oldText': '',
            'newText': '逻辑优化建议',
            'type': 'AI 逻辑纠错',
            'timestamp': DateTime.now().toString(),
          }
        };
        _transcript.insert(5, newItem);
      }
      _onSearch(_searchQuery);
    });
    _saveHistory();
  }

  void _generateVoice() {
    setState(() {
      _lockedTTSSegment = {
        'index': -1,
        'text': '',
        'isNew': true
      };
      _editSupplementText = '';
    });
    _showVoiceLabDialog();
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 90, child: _buildToolBtn(Icons.description_outlined, '内容润色', _optimizeScript)),
            SizedBox(width: 90, child: _buildToolBtn(Icons.mic_none_outlined, '声演实验室', _generateVoice)),
            SizedBox(width: 90, child: _buildToolBtn(Icons.content_cut_outlined, '后期大师', _aiSpecialCut)),
            SizedBox(width: 90, child: _buildToolBtn(Icons.search, '高光提取', extractGoldenSentences)),
            SizedBox(width: 90, child: _buildToolBtn(Icons.high_quality_outlined, '声效修复', _audioEnhance)),
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

  Widget _buildTranscriptItem(int itemIndex, String speaker, String time, List<Map<String, dynamic>> tokens) {
    final item = _transcript[itemIndex];
    final bool isOriginal = item['isOriginal'] == true;
    final bool isTts = item['isTts'] == true;
    final bool confirmed = item['confirmed'] == true;
    final Map<String, dynamic>? editTrace = item['editTrace'] is Map ? Map<String, dynamic>.from(item['editTrace']) : null;
    final bool allowTokenEdit = !(isTts && !confirmed);
    final bool isGolden = item['isGolden'] ?? false;
    final bool hasInternalInsert = editTrace != null && editTrace['type'] == 'AI 克隆语音内部插入';

    return KeyedSubtree(
      key: _segmentKeyFor(itemIndex),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isGolden ? Colors.yellow[100]! : hasInternalInsert ? Colors.green.withOpacity(0.05) : (isOriginal ? Colors.white : Colors.pink.withOpacity(0.02)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isGolden ? Colors.yellow.shade400 : hasInternalInsert ? Colors.green.withOpacity(0.3) : (isOriginal ? Colors.grey[100]! : Colors.pink.withOpacity(0.1)),
            width: isGolden ? 2 : hasInternalInsert ? 1.5 : (isOriginal ? 1 : 1.5),
          ),
          boxShadow: isGolden ? [
            BoxShadow(
              color: Colors.yellow.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ] : hasInternalInsert ? [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ] : [],
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
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 100),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.auto_awesome, size: 7, color: Colors.amber[700]),
                                    const SizedBox(width: 1),
                                    Expanded(
                                      child: Text(
                                        editTrace['type'],
                                        style: TextStyle(fontSize: 7, color: Colors.amber[800], fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (isTts && !confirmed)
                          Flexible(
                            child: TextButton(
                              onPressed: () => _confirmTtsSegment(itemIndex),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_outline, size: 9),
                                  const SizedBox(width: 1),
                                  const Flexible(
                                    child: Text('确认', style: TextStyle(fontSize: 8), overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(horizontal: 1),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        if (!isOriginal && !hasInternalInsert)
                          Flexible(
                            child: IconButton(
                              onPressed: () => _deleteSegment(itemIndex),
                              icon: const Icon(Icons.delete_outline, size: 12, color: Colors.red),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        IconButton(
                          onPressed: () => toggleGoldenSentence(itemIndex),
                          icon: Icon(
                            isGolden ? Icons.star : Icons.star_border,
                            size: 12,
                            color: isGolden ? Colors.yellow[600] : Colors.grey[500],
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          onPressed: () => loadSegmentToVoiceLab(item, itemIndex),
                          icon: const Icon(Icons.add_circle_outline, size: 12, color: Colors.blue),
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

                    return TextSpan(
                      text: text,
                      recognizer: allowTokenEdit ? (TapGestureRecognizer()..onTap = () => _toggleTokenDelete(itemIndex, tokenIndex)) : null,
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        backgroundColor: bgColor,
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

  // 以下为未修改的通用组件方法
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

  Widget _buildAISummaryCard(Map<String, dynamic> summary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF0F9FF),
            const Color(0xFFE0F2FE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFBAE6FD),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'AI 总结 · 第 ${summary['sectionNumber']} 部分',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  summary['summary'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF334155),
                    height: 1.4,
                  ),
                ),
              ],
            ),
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
}