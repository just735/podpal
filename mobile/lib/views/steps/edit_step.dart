import 'package:flutter/material.dart';

class EditStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrev;
  const EditStep({super.key, required this.onNext, required this.onPrev});

  @override
  State<EditStep> createState() => _EditStepState();
}

class _EditStepState extends State<EditStep> {
  final List<String> _fillerWords = ['就是', '然后', '那个', '嗯', '啊', '你知道', '其实', '对吧', '可以说', '怎么说呢'];
  
  List<Map<String, dynamic>> _transcript = [];

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
        'text': '这种理念非常契合我们产品的初衷。怎么说呢，技术只是工具，创意才是播客灵魂。'
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

    _transcript = rawData.map((item) {
      return {
        'speaker': item['speaker'],
        'time': item['time'],
        'text': item['text'],
        'isOriginal': true,
        'isTts': false,
        'confirmed': true,
        'tokens': _parseTranscriptToTokens(item['text'] as String),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _parseTranscriptToTokens(String text) {
    final List<Map<String, dynamic>> tokens = [];
    final wordPattern = RegExp(r'(\s+|[，。！？、；：,.!?…—-])');
    int lastIndex = 0;
    
    for (final match in wordPattern.allMatches(text)) {
      if (match.start > lastIndex) {
        _addTokenToTokens(text.substring(lastIndex, match.start), tokens);
      }
      tokens.add({'type': 'space', 'text': match.group(0)});
      lastIndex = match.end;
    }
    
    if (lastIndex < text.length) {
      _addTokenToTokens(text.substring(lastIndex), tokens);
    }
    
    // Check for fillers in the parsed tokens
    for (var token in tokens) {
      if (token['type'] == 'text' && _fillerWords.contains(token['text'])) {
        token['type'] = 'filler';
      }
    }
    
    return tokens;
  }

  void _addTokenToTokens(String text, List<Map<String, dynamic>> tokens) {
    final stutterRegex = RegExp(r'([\u4e00-\u9fa5A-Za-z])\1{1,}');
    if (stutterRegex.hasMatch(text)) {
      tokens.add({'type': 'stutter', 'text': text});
    } else {
      tokens.add({'type': 'text', 'text': text});
    }
  }

  String _tokensToText(List<Map<String, dynamic>> tokens) {
    return tokens.map((t) => t['text']).join();
  }

  List<Map<String, dynamic>> _filteredTranscript = [];
  String _searchQuery = '';
  bool _isSearching = false;
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
        for (var token in tokens) {
          if (token['type'] == 'filler' || token['type'] == 'stutter') {
            token['type'] = 'deleted';
          }
        }
      }
      _onSearch(_searchQuery);
    });
    _saveHistory();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI 已自动识别并处理冗余词汇')),
    );
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
        title: const Text('智能 Shownotes'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text('推荐标题：', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              _buildTitleItem('AI 时代的播客创作：从灵感到分发的全流程解析'),
              _buildTitleItem('如何利用 PodPal 打造你的第一个爆款播客？'),
              const SizedBox(height: 16),
              const Text('内容摘要：', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const Text(
                  '本期节目我们深入探讨了人工智能在播客创作领域的应用。从早期的语音转写到如今的智能剪辑、内容生成，AI 正在重塑音频内容的生产流程。我们邀请了资深播客制作人，分享他们使用 PodPal 提升效率的实战经验...',
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('确定')),
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
        // Revert (guess type)
        if (_fillerWords.contains(token['text'])) {
          token['type'] = 'filler';
        } else if (RegExp(r'([\u4e00-\u9fa5A-Za-z])\1{1,}').hasMatch(token['text'])) {
          token['type'] = 'stutter';
        } else {
          token['type'] = 'text';
        }
      } else {
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

  void _editSegmentText(int itemIndex) {
    final item = _transcript[itemIndex];
    final tokens = (item['tokens'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final bool isOriginal = item['isOriginal'] == true;
    final bool isTts = item['isTts'] == true;
    final bool confirmed = item['confirmed'] == true;

    if (isTts && !confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先确认加入该段补录')),
      );
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
                  item['tokens'] = _parseTranscriptToTokens(newText);
                  item['text'] = newText;
                  if (isOriginal) {
                    item['editTrace'] = {'oldText': oldText, 'newText': newText};
                  } else {
                    item['editTrace'] = null;
                  }
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('补录已确认，可继续编辑')),
    );
  }

  void _deleteSegment(int itemIndex) {
    setState(() {
      _transcript.removeAt(itemIndex);
      _onSearch(_searchQuery);
    });
    _saveHistory();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已删除该段文稿')),
    );
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
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('脚本优化', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.5,
              children: [
                _buildActionBtn('去口语冗余', '自动修正错别字、剔除口语化冗余', () => _applyOptimization('filler')),
                _buildActionBtn('逻辑纠错', '检测逻辑断层，推荐衔接句', () => _applyOptimization('logic')),
                _buildActionBtn('一键精华提取', '提取核心片段生成精华版', () => _applyOptimization('highlights')),
                _buildActionBtn('BGM智能匹配', '根据内容推荐背景音乐', () => _applyOptimization('bgm')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _applyOptimization(String type) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已应用脚本优化: $type')),
    );
  }

  void _generateVoice() {
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
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('语音生成', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildActionBtn('声线克隆', '根据当前项目的一段语音生成新的声线配置', () {})),
                const SizedBox(width: 10),
                Expanded(child: _buildActionBtn('多角色生成', '生成多个角色的对话语音', () {})),
              ],
            ),
            const SizedBox(height: 20),
            const Text('最近语音生成任务', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildVoiceTaskItem('补录片段_01', '已完成', '2024-03-21 14:30'),
            _buildVoiceTaskItem('金句补录_A', '生成中', '2024-03-21 15:00'),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceTaskItem(String title, String status, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.05),
        border: Border.all(color: Colors.pink.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == '已完成' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                color: status == '已完成' ? Colors.green : Colors.orange,
              ),
            ),
          ),
          if (status == '已完成')
            TextButton(
              onPressed: () => _insertTTS(title),
              child: const Text('插入', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已插入 AI 生成文稿')),
    );
  }

  void _aiSpecialCut() {
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
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('AI 专项剪辑', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            _buildStrategyOption('AI 全剪辑', '一键全剪，处理所有冗余内容'),
            _buildStrategyOption('AI 口癖剪辑', '只处理口癖（如：嗯、呃、这个等）'),
            _buildStrategyOption('AI 口吃剪辑', '只处理口吃（如：重复字词、结巴等）'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('正在生成剪辑建议...')),
                  );
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
      ),
    );
  }

  Widget _buildStrategyOption(String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.pink.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.radio_button_off, size: 20, color: Colors.pink),
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
    );
  }

  void _semanticSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                const Text('深度语义搜索与金句定位', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: '例如：搜索关于职场焦虑的对话片段',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.pink),
                  onPressed: () {},
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              ),
            ),
            const SizedBox(height: 20),
            const Text('推荐金句', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildGoldenSentence('AI 正在重塑音频内容的生产流程，这不仅是效率的提升，更是创意的解放。', '05:24', 95),
                  _buildGoldenSentence('未来播客的竞争力不再是剪辑技术，而是内容深度与情感共鸣。', '12:15', 88),
                ],
              ),
            ),
          ],
        ),
      ),
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
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('语音转写与分析', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('开始转写'),
              ),
            ),
          ],
        ),
      ),
    );
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
                const Text('音频画质增强', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildActionBtn(String title, String desc, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.pink.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            Text(desc, style: const TextStyle(fontSize: 9, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
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
                      SizedBox(width: 90, child: _buildToolBtn(Icons.description_outlined, '脚本优化', _optimizeScript)),
                      SizedBox(width: 90, child: _buildToolBtn(Icons.mic_none, '语音生成', _generateVoice)),
                      SizedBox(width: 90, child: _buildToolBtn(Icons.content_cut_outlined, 'AI专项剪辑', _aiSpecialCut)),
                      SizedBox(width: 90, child: _buildToolBtn(Icons.search, '深度搜索', _semanticSearch)),
                      SizedBox(width: 90, child: _buildToolBtn(Icons.analytics_outlined, '语音转写', _voiceAnalysis)),
                      SizedBox(width: 90, child: _buildToolBtn(Icons.high_quality_outlined, '音频增强', _audioEnhance)),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        track['name'],
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.lock_outline, size: 10, color: Colors.grey[300]),
                  ],
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 12,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOriginal ? Colors.blue.withOpacity(0.1) : Colors.pink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isOriginal ? 'Speaker $speaker' : 'AI 生成',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isOriginal ? Colors.blue : Colors.pink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (isTts && !confirmed)
                      TextButton.icon(
                        onPressed: () => _confirmTtsSegment(itemIndex),
                        icon: const Icon(Icons.check_circle_outline, size: 14),
                        label: const Text('确认', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    if (!isOriginal)
                      IconButton(
                        onPressed: () => _deleteSegment(itemIndex),
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        tooltip: '删除 AI 段落',
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        constraints: const BoxConstraints(),
                      ),
                    TextButton.icon(
                      onPressed: isTts && !confirmed ? null : () => _editSegmentText(itemIndex),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('编辑', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (editTrace != null && isOriginal) ...[
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history, size: 12, color: Colors.blue[300]),
                        const SizedBox(width: 4),
                        Text('修改痕迹', style: TextStyle(fontSize: 10, color: Colors.blue[300], fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      editTrace['oldText'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      editTrace['newText'] ?? '',
                      style: TextStyle(fontSize: 13, color: Colors.blue[700], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
            Wrap(
              spacing: 0,
              runSpacing: 4,
              children: List.generate(tokens.length, (tokenIndex) {
                final token = tokens[tokenIndex];
                final type = token['type'];
                final text = token['text'];

                if (type == 'space') {
                  return Text(text, style: const TextStyle(fontSize: 16));
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
                } else if (type == 'modified') {
                  textColor = Colors.blue[700]!;
                  bgColor = Colors.blue[50]!;
                }

                return GestureDetector(
                  onTap: () => _toggleTokenDelete(itemIndex, tokenIndex),
                  onLongPress: allowTokenEdit ? () => _editTokenText(itemIndex, tokenIndex) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: type == 'modified'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                token['oldText'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[400],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const Icon(Icons.arrow_right, size: 16, color: Colors.blue),
                              Text(
                                text,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor,
                                  decoration: decoration,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            text,
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                              decoration: decoration,
                            ),
                          ),
                  ),
                );
              }),
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
}
