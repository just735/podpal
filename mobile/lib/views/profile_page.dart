import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        elevation: 0,
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
                      image: const DecorationImage(
                        image: NetworkImage('https://placeholder.com/user-avatar'),
                        fit: BoxFit.cover,
                      ),
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
                  _buildMenuItem(Icons.workspace_premium, '我的会员', Colors.amber),
                  _buildMenuItem(Icons.cloud_outlined, '云端素材库', Colors.blue),
                  _buildMenuItem(Icons.history, '剪辑历史', Colors.orange),
                  _buildMenuItem(Icons.settings_outlined, '设置', Colors.grey),
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

  Widget _buildMenuItem(IconData icon, String title, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {},
    );
  }
}
