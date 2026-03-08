import 'package:flutter/material.dart';

class UploadStep extends StatefulWidget {
  final VoidCallback onNext;
  const UploadStep({super.key, required this.onNext});

  @override
  State<UploadStep> createState() => _UploadStepState();
}

class _UploadStepState extends State<UploadStep> {
  bool _isUploading = false;
  int? _uploadingIndex;
  // 选中的素材索引集合
  final Set<int> _selectedAssetIndices = {};
  // 素材库（带分类标签）
  final List<Map<String, String>> _assets = [
    {'name': '播客素材 1.mp3', 'size': '12.5 MB', 'category': '人声'},
    {'name': '播客素材 2.mp3', 'size': '12.5 MB', 'category': '背景音'},
    {'name': '播客素材 3.mp3', 'size': '12.5 MB', 'category': '效果音'},
    {'name': '播客素材 4.mp3', 'size': '12.5 MB', 'category': '人声'},
  ];
  String _selectedCategory = '全部';
  // 前置操作（语音转写与音质增强）
  bool _preTranscribe = true;
  bool _preVoiceEnhance = true;
  bool _preEchoRemoval = false;

  List<Map<String, String>> get _filteredAssets {
    if (_selectedCategory == '全部') return _assets;
    return _assets.where((a) => a['category'] == _selectedCategory).toList();
  }

  void _handleMaterialSelect(int index, String fileName) {
    if (_isUploading) return;

    setState(() {
      if (_selectedAssetIndices.contains(index)) {
        _selectedAssetIndices.remove(index);
      } else {
        _selectedAssetIndices.add(index);
      }
    });
  }

  void _handleStartProcess() async {
    if (_selectedAssetIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择至少一个素材')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // 模拟上传延迟
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isUploading = false;
      });

      // 显示前置预处理面板
      await _showPreprocessSheet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          // 开始创作按钮区域
          GestureDetector(
            onTap: () {
              _selectedAssetIndices.clear();
              _showPreprocessSheet();
            },
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF6B9D), width: 2),
                boxShadow: [
                  BoxShadow(
                  color: const Color(0xFFFF6B9D).withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline, size: 48, color: Color(0xFFFF6B9D)),
                  const SizedBox(height: 12),
                  const Text(
                    '开始创作',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B9D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击上传音频素材',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          // 素材库区域
          const Text(
            '从素材库选择',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildCategoryChip('全部'),
              const SizedBox(width: 8),
              _buildCategoryChip('人声'),
              const SizedBox(width: 8),
              _buildCategoryChip('背景音'),
              const SizedBox(width: 8),
              _buildCategoryChip('效果音'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '点击选择素材，可多选',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: _filteredAssets.length,
              itemBuilder: (context, index) {
                final item = _filteredAssets[index];
                final fileName = item['name']!;
                final isSelected = _selectedAssetIndices.contains(index);

                return GestureDetector(
                  onTap: () => _handleMaterialSelect(index, fileName),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.pink[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFF6B9D) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.audio_file, 
                              color: isSelected ? const Color(0xFFFF6B9D) : Colors.blue,
                            ),
                            const Spacer(),
                            Text(
                              fileName,
                              style: TextStyle(
                                fontSize: 12, 
                                fontWeight: FontWeight.w500,
                                color: isSelected ? const Color(0xFFFF6B9D) : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['size'] ?? '',
                                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF1F5),
                                    border: Border.all(color: const Color(0xFFFBCFE8)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(item['category'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFFFF6B9D))),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (isSelected)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF6B9D),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, size: 16, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isUploading ? null : _handleStartProcess,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : Text('已选择 ${_selectedAssetIndices.length} 个素材，开始处理', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // 分类 Chip
  Widget _buildCategoryChip(String label) {
    final bool selected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF6B9D) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF6B9D)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : const Color(0xFFFF6B9D),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // 前置预处理 BottomSheet
  Future<void> _showPreprocessSheet() async {
    final selectedAssets = _selectedAssetIndices.map((index) => _assets[index]).toList();
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('已选择 ${selectedAssets.length} 个素材 · 前置预处理', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 显示选中的素材列表
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F5),
                        border: Border.all(color: const Color(0xFFFBCFE8)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: selectedAssets.length,
                        itemBuilder: (context, index) {
                          final asset = selectedAssets[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.audio_file, color: Color(0xFFFF6B9D)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    asset['name']!,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Text(
                                  asset['size']!,
                                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      value: _preTranscribe,
                      onChanged: (v) => setModalState(() => _preTranscribe = v),
                      title: const Text('语音转写', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('说话人分离、情绪提取、关键词', style: TextStyle(fontSize: 12)),
                      activeColor: const Color(0xFFFF6B9D),
                    ),
                    const Divider(height: 1),
                    CheckboxListTile(
                      value: _preVoiceEnhance,
                      onChanged: (v) => setModalState(() => _preVoiceEnhance = v ?? false),
                      title: const Text('人声增强', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xFFFF6B9D),
                    ),
                    CheckboxListTile(
                      value: _preEchoRemoval,
                      onChanged: (v) => setModalState(() => _preEchoRemoval = v ?? false),
                      title: const Text('去回声', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xFFFF6B9D),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFF6B9D)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('跳过', style: TextStyle(color: Color(0xFFFF6B9D))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _showProcessResult();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B9D),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('开始处理', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showProcessResult() async {
    setState(() {
      _isUploading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _isUploading = false;
    });

    showDialog(
      context: context,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
                const SizedBox(height: 20),
                const Text(
                  '处理完成',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_selectedAssetIndices.length} 个素材已成功处理',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_preTranscribe ? "✓ 转写" : "✗ 转写"} · ${_preVoiceEnhance ? "✓ 人声增强" : "✗ 人声增强"} · ${_preEchoRemoval ? "✓ 去回声" : "✗ 去回声"}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context);
    widget.onNext();
  }
}
