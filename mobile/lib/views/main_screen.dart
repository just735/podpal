import 'package:flutter/material.dart';
import 'home_page.dart';
import 'steps/edit_step.dart';
import 'steps/enhance_step.dart';
import 'steps/publish_step.dart';
import 'steps/upload_step.dart';
import 'profile_page.dart';
import 'template_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const EditorPage(),
    const TemplatePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: const Color(0xFFFF6B9D),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_filter_outlined),
              activeIcon: Icon(Icons.movie_filter),
              label: '剪辑',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: '模板',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  int _currentStep = 0;
  bool _hasUploaded = false; // 追踪素材是否已上传

  void _goToStep(int index) {
    // 确保索引在有效范围内
    if (index < 0 || index > 3) {
      return;
    }
    if (index > 0 && !_hasUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先上传或选择素材再进行下一步')),
      );
      return;
    }
    setState(() {
      _currentStep = index;
    });
  }

  void _handleUploadSuccess() {
    setState(() {
      _hasUploaded = true;
    });
    _goToStep(1); // 上传成功后自动进入下一步
  }

  void _handlePublishSuccess() {
    setState(() {
      _hasUploaded = false;
      _currentStep = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. 进度条 (底层，居中，显著缩窄宽度)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100), // 增大内边距以缩窄进度条
                  child: _buildProgressBar(),
                ),
                
                // 2. 返回按钮 (左侧)
                if (_currentStep > 0)
                  Positioned(
                    left: 4,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black87),
                      onPressed: () => _goToStep(_currentStep - 1),
                    ),
                  ),
                  
                // 3. 前进按钮 (右侧)
                if (_currentStep > 0 && _currentStep < 3)
                  Positioned(
                    right: 4,
                    child: TextButton(
                      onPressed: () => _goToStep(_currentStep + 1),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentStep == 1 ? '内容增值' : '确认发布',
                            style: const TextStyle(color: Color(0xFFFF6B9D), fontWeight: FontWeight.bold, fontSize: 16)
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFFF6B9D)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentStep.clamp(0, 3),
        children: [
          UploadStep(onNext: _handleUploadSuccess),
          EditStep(onPrev: () => _goToStep(0), onNext: () => _goToStep(2)),
          EnhanceStep(onPrev: () => _goToStep(1), onNext: () => _goToStep(3)),
          PublishStep(onPrev: () => _goToStep(2), onPublishSuccess: _handlePublishSuccess),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final steps = ['上传', '剪辑', '增强', '发布'];
    return Row(
      children: List.generate(steps.length, (index) {
        final isActive = index <= _currentStep;
        final isCurrent = index == _currentStep;
        return Expanded(
          child: GestureDetector(
            onTap: () => _goToStep(index),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFFF6B9D) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 14, // 进一步增大字体大小
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? const Color(0xFFFF6B9D) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
