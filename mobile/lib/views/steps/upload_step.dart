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

  void _handleMaterialClick(int index, String fileName) async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
      _uploadingIndex = index;
    });

    // 模拟上传延迟
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isUploading = false;
        _uploadingIndex = null;
      });

      // 延迟一小会儿后跳转到下一步
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        widget.onNext();
      }
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
            onTap: widget.onNext,
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
          Text(
            '点击素材可直接上传并开始剪辑',
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
              itemCount: 4,
              itemBuilder: (context, index) {
                final fileName = '播客素材 ${index + 1}.mp3';
                final isCurrentUploading = _uploadingIndex == index;

                return GestureDetector(
                  onTap: () => _handleMaterialClick(index, fileName),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrentUploading ? Colors.pink[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrentUploading ? const Color(0xFFFF6B9D) : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.audio_file, 
                              color: isCurrentUploading ? const Color(0xFFFF6B9D) : Colors.blue,
                            ),
                            const Spacer(),
                            Text(
                              fileName,
                              style: TextStyle(
                                fontSize: 12, 
                                fontWeight: FontWeight.w500,
                                color: isCurrentUploading ? const Color(0xFFFF6B9D) : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '12.5 MB',
                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        if (isCurrentUploading)
                          const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
