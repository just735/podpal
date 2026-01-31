import 'package:flutter/material.dart';
import 'membership_page.dart';
import 'cloud_library_page.dart';
import 'edit_history_page.dart';
import 'settings_page.dart';
import 'voice_clone_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
            const SizedBox(height: 40),
            // 头像与基本信息
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF6B9D), width: 3),
                    ),
                    child: const Icon(Icons.person, size: 60, color: Color(0xFFFF6B9D)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '播客主理人',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '让技术服务于创意',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // 数据统计
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('项目', '12'),
                  _buildStat('时长', '340min'),
                  _buildStat('发布', '8'),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 功能列表
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildMenuItem(context, Icons.workspace_premium, '我的会员', Colors.amber, const MembershipPage()),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildMenuItem(context, Icons.mic_none, '训练音色模型', Colors.pink, const VoiceClonePage()),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildMenuItem(context, Icons.cloud_outlined, '云端素材库', Colors.blue, const CloudLibraryPage()),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildMenuItem(context, Icons.history, '剪辑历史', Colors.orange, const EditHistoryPage()),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildMenuItem(context, Icons.settings_outlined, '设置', Colors.grey, const SettingsPage()),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
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

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, Color color, Widget destination) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }
}
