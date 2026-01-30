import 'package:flutter/material.dart';

class CloudLibraryPage extends StatefulWidget {
  const CloudLibraryPage({super.key});

  @override
  State<CloudLibraryPage> createState() => _CloudLibraryPageState();
}

class _CloudLibraryPageState extends State<CloudLibraryPage> {
  String _searchQuery = '';
  String _filterType = '全部';
  
  final List<Map<String, dynamic>> _materials = [
    {
      'id': '1',
      'name': '访谈录音_20240125.mp3',
      'type': 'audio',
      'size': '24.5 MB',
      'duration': '45:12',
      'createdAt': '2024-01-25 14:30',
    },
    {
      'id': '2',
      'name': '播客片头音乐_欢快.wav',
      'type': 'audio',
      'size': '5.2 MB',
      'duration': '00:30',
      'createdAt': '2024-01-20 09:15',
    },
    {
      'id': '3',
      'name': '远程录制视频回放.mp4',
      'type': 'video',
      'size': '156.8 MB',
      'duration': '62:05',
      'createdAt': '2024-01-18 18:20',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('云端素材库', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFF6B9D)),
            onPressed: () => _showUploadBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterTabs(),
          Expanded(
            child: _buildMaterialsList(),
          ),
        ],
      ),
    );
  }

  void _showUploadBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '上传素材',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildUploadOption(
                    context,
                    Icons.audiotrack,
                    '音频文件',
                    Colors.blue,
                  ),
                  _buildUploadOption(
                    context,
                    Icons.videocam,
                    '视频文件',
                    Colors.purple,
                  ),
                  _buildUploadOption(
                    context,
                    Icons.cloud_upload,
                    '云端同步',
                    Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadOption(BuildContext context, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        
        // 显示正在上传的中间状态
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('正在准备$label...', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        );

        // 模拟文件选择和上传过程
        await Future.delayed(const Duration(seconds: 1));
        
        if (context.mounted) {
          Navigator.pop(context); // 关闭加载对话框
          
          // 进入模拟的上传新素材页面
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _NewUploadPage(type: label),
            ),
          );
        }
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: '搜索素材名称...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final types = ['全部', '音频', '视频'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: types.map((type) {
          final isSelected = _filterType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _filterType = type);
              },
              selectedColor: const Color(0xFFFF6B9D).withValues(alpha: 0.1),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide.none,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMaterialsList() {
    final filtered = _materials.where((m) {
      final matchesSearch = m['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _filterType == '全部' || 
          (_filterType == '音频' && m['type'] == 'audio') || 
          (_filterType == '视频' && m['type'] == 'video');
      return matchesSearch && matchesType;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('暂无相关素材', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final material = filtered[index];
        final isAudio = material['type'] == 'audio';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[100]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isAudio ? Colors.blue[50] : Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isAudio ? Icons.audiotrack : Icons.videocam,
                  color: isAudio ? Colors.blue : Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${material['size']} · ${material['duration']} · ${material['createdAt']}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                itemBuilder: (context) => [
                  const PopupMenuItem(child: Text('重命名')),
                  const PopupMenuItem(child: Text('下载')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('删除', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NewUploadPage extends StatefulWidget {
  final String type;
  const _NewUploadPage({required this.type});

  @override
  State<_NewUploadPage> createState() => _NewUploadPageState();
}

class _NewUploadPageState extends State<_NewUploadPage> {
  double _progress = 0.0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _startSimulatedUpload();
  }

  void _startSimulatedUpload() async {
    for (int i = 0; i <= 100; i += 5) {
      if (!mounted) return;
      setState(() {
        _progress = i / 100.0;
      });
      await Future.delayed(const Duration(milliseconds: 150));
    }
    if (mounted) {
      setState(() {
        _isFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('上传${widget.type}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isFinished ? Icons.check_circle : Icons.cloud_upload_outlined,
                size: 80,
                color: _isFinished ? Colors.green : const Color(0xFFFF6B9D),
              ),
              const SizedBox(height: 24),
              Text(
                _isFinished ? '上传成功' : '正在上传素材...',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (!_isFinished) ...[
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
                ),
                const SizedBox(height: 8),
                Text('${(_progress * 100).toInt()}%', style: TextStyle(color: Colors.grey[600])),
              ] else ...[
                const Text('素材已保存至您的云端素材库', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B9D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('返回素材库'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
