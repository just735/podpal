import 'package:flutter/material.dart';
import 'membership_page.dart';
import 'cloud_library_page.dart';
import 'edit_history_page.dart';
import 'settings_page.dart';
import 'voice_clone_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 用户统计数据
  final Map<String, dynamic> userStats = {
    'videosCreated': 24,
    'videosCreatedThisMonth': 8,
    'onlineHours': 156.5,
    'onlineHoursThisWeek': 12.5,
    'clipMinutes': 480,
    'clipMinutesThisMonth': 120,
    'activeProjects': 3,
  };

  // 使用趋势数据（最近7天）
  final List<Map<String, dynamic>> usageTrend = [
    {'day': '周一', 'clipMinutes': 45, 'videos': 2},
    {'day': '周二', 'clipMinutes': 30, 'videos': 1},
    {'day': '周三', 'clipMinutes': 60, 'videos': 3},
    {'day': '周四', 'clipMinutes': 20, 'videos': 1},
    {'day': '周五', 'clipMinutes': 50, 'videos': 2},
    {'day': '周六', 'clipMinutes': 80, 'videos': 4},
    {'day': '周日', 'clipMinutes': 40, 'videos': 2},
  ];

  // 成就徽章
  final List<Map<String, dynamic>> badges = [
    {'name': '初出茅庐', 'icon': '🌱', 'unlocked': true},
    {'name': '剪辑达人', 'icon': '✂️', 'unlocked': true},
    {'name': '视频创作者', 'icon': '🎬', 'unlocked': true},
    {'name': '资深播客', 'icon': '⏱️', 'unlocked': true},
    {'name': '内容大师', 'icon': '🏆', 'unlocked': false},
    {'name': '连续创作', 'icon': '🔥', 'unlocked': false},
  ];

  String formatHours(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (h > 0) {
      return '${h}h${m > 0 ? '${m}m' : ''}';
    }
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('个人中心', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // 头像与基本信息
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF6B9D), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B9D).withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, size: 50, color: Color(0xFFFF6B9D)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '播客主理人',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '让技术服务于创意',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 核心统计卡片
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _buildStatCard(
                    '🎬',
                    '制作视频',
                    userStats['videosCreated'].toString(),
                    '本月+${userStats['videosCreatedThisMonth']}',
                    const Color(0xFFFFE4EC),
                    const Color(0xFFFF6B9D),
                  ),
                  _buildStatCard(
                    '⏱️',
                    '在线时长',
                    formatHours(userStats['onlineHours']),
                    '本周${formatHours(userStats['onlineHoursThisWeek'])}',
                    const Color(0xFFF3E8FF),
                    const Color(0xFF8B5CF6),
                  ),
                  _buildStatCard(
                    '✂️',
                    '剪辑时长',
                    '${userStats['clipMinutes']}分钟',
                    '本月${userStats['clipMinutesThisMonth']}分钟',
                    const Color(0xFFDBEAFE),
                    const Color(0xFF3B82F6),
                  ),
                  _buildStatCard(
                    '📊',
                    '项目数量',
                    userStats['activeProjects'].toString(),
                    '进行中',
                    const Color(0xFFD1FAE5),
                    const Color(0xFF10B981),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 使用趋势图表
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[200]!,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '使用趋势',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '最近7天的剪辑活动',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: usageTrend.map((day) {
                          final maxMinutes = usageTrend
                              .map((d) => d['clipMinutes'] as int)
                              .reduce((a, b) => a > b ? a : b);
                          final heightPercent = (day['clipMinutes'] as int) / maxMinutes;
                          
                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 24,
                                  height: 80 * heightPercent,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [Color(0xFFFF6B9D), Color(0xFFFF8FB0)],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  day['day'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 成就徽章
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '成就徽章',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: badges.map((badge) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: badge['unlocked']
                                ? const Color(0xFFFFE4EC)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: badge['unlocked']
                                  ? const Color(0xFFFF6B9D).withOpacity(0.3)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                badge['icon'] as String,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                badge['name'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: badge['unlocked']
                                      ? const Color(0xFFFF6B9D)
                                      : Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 功能列表
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(context, Icons.workspace_premium, '我的会员', Colors.amber, const MembershipPage()),
                    const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                    _buildMenuItem(context, Icons.mic_none, '训练音色模型', Colors.pink, const VoiceClonePage()),
                    const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                    _buildMenuItem(context, Icons.cloud_outlined, '云端素材库', Colors.blue, const CloudLibraryPage()),
                    const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                    _buildMenuItem(context, Icons.history, '剪辑历史', Colors.orange, const EditHistoryPage()),
                    const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                    _buildMenuItem(context, Icons.settings_outlined, '设置', Colors.grey, const SettingsPage()),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 退出按钮
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text(
                '退出登录',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String icon,
    String label,
    String value,
    String subtitle,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: iconColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9,
              color: iconColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, Color color, Widget destination) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }
}
