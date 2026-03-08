import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class VoiceClonePage extends StatefulWidget {
  const VoiceClonePage({super.key});

  @override
  State<VoiceClonePage> createState() => _VoiceClonePageState();
}

class _VoiceClonePageState extends State<VoiceClonePage> {
  bool _isTraining = false;
  double _trainingProgress = 0;
  String _statusText = '未开始';
  int _currentWizardStep = 0; // 0: 初始页面, 1: 权利确认, 2: 活体校验, 3: 训练
  bool _rightsConfirmed = false;
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String _verificationText = '';
  bool _verificationCompleted = false;
  
  final List<Map<String, String>> _history = [
    {'id': '1', 'name': '我的默认音色', 'date': '2024-01-20', 'status': '已完成'},
    {'id': '2', 'name': '专业播报音色', 'date': '2024-01-15', 'status': '已完成'},
  ];

  final List<String> _verificationTexts = [
    'PodPal 记录我的每一次发声',
    '用声音连接世界的每一个角落',
    '让每一次表达都充满力量',
    '声音是灵魂的窗口',
    '用心聆听，用爱表达',
  ];

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _startWizard() {
    setState(() {
      _currentWizardStep = 1;
      _rightsConfirmed = false;
      _verificationCompleted = false;
    });
  }

  void _startVerification() {
    final random = Random();
    setState(() {
      _verificationText = _verificationTexts[random.nextInt(_verificationTexts.length)];
      _currentWizardStep = 2;
    });
  }

  void _toggleRecording() {
    if (_isRecording) {
      // 停止录音
      _recordingTimer?.cancel();
      setState(() {
        _isRecording = false;
        _verificationCompleted = true;
      });
    } else {
      // 开始录音
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingSeconds++;
        });
      });
    }
  }

  void _startTraining() {
    setState(() {
      _currentWizardStep = 3;
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
          // 返回初始页面
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                _currentWizardStep = 0;
              });
            }
          });
        }
      });
    });
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
          onPressed: () {
            if (_currentWizardStep > 0) {
              setState(() {
                _currentWizardStep--;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _currentWizardStep == 0 ? '训练个人音色模型' : 
          _currentWizardStep == 1 ? '权利确认' :
          _currentWizardStep == 2 ? '活体校验' : '训练中',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentWizardStep) {
      case 0:
        return _buildMainPage();
      case 1:
        return _buildRightsConfirmationPage();
      case 2:
        return _buildVerificationPage();
      case 3:
        return _buildTrainingPage();
      default:
        return _buildMainPage();
    }
  }

  Widget _buildMainPage() {
    return SingleChildScrollView(
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
            buttonText: '开始录音训练',
            onPressed: _startWizard,
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
    );
  }

  Widget _buildRightsConfirmationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B9D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B9D),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.gavel,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '权利确认',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '第一步',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFFF6B9D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '权利声明',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '在使用 PodPal 的音色克隆服务之前，请您确认以下事项：',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRightsItem('您拥有所录制声音素材的完整权利'),
                _buildRightsItem('您已获得所有相关权利的必要授权'),
                _buildRightsItem('您不会使用此服务克隆他人的声音'),
                _buildRightsItem('您理解并同意我们的服务条款和隐私政策'),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          GestureDetector(
            onTap: () {
              setState(() {
                _rightsConfirmed = !_rightsConfirmed;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _rightsConfirmed ? const Color(0xFF10B981).withOpacity(0.1) : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _rightsConfirmed ? const Color(0xFF10B981) : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _rightsConfirmed ? const Color(0xFF10B981) : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _rightsConfirmed ? const Color(0xFF10B981) : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: _rightsConfirmed
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '我确认录音素材为本人声音，且已获得相关权利授权。',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _rightsConfirmed ? _startVerification : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: const Text(
                '下一步：活体校验',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightsItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B9D),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4B5563),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B5CF6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '活体校验',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '第二步（可选）',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '请朗读以下文本',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '这将帮助我们验证您对声音的控制权',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      '"$_verificationText"',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 录音按钮
          Center(
            child: GestureDetector(
              onTap: _toggleRecording,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _isRecording ? const Color(0xFFEF4444) : const Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording ? const Color(0xFFEF4444) : const Color(0xFF8B5CF6)).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRecording ? '停止录音' : '开始录音',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isRecording) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(_recordingSeconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          if (_verificationCompleted)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '录音完成',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        Text(
                          '录制时长: ${_formatDuration(_recordingSeconds)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 40),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _startTraining,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '跳过此步骤',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _verificationCompleted ? _startTraining : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: const Text(
                    '开始训练',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B9D).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                size: 60,
                color: Color(0xFFFF6B9D),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '正在训练您的音色模型',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请耐心等待，这可能需要几分钟时间',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _statusText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B9D),
                        ),
                      ),
                      Text(
                        '${(_trainingProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B9D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _trainingProgress,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[100]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber[700],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '训练完成后，您可以使用此音色进行语音合成',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
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
