import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
        title: const Text('设置', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSection('账号信息', [
              _buildSettingItem(Icons.person_outline, '修改昵称', '播客主理人'),
              _buildSettingItem(Icons.mail_outline, '绑定邮箱', 'podpal@example.com'),
              _buildSettingItem(Icons.phone_android_outlined, '绑定手机', '138****8888'),
              _buildSettingItem(Icons.lock_outline, '修改密码', ''),
            ]),
            const SizedBox(height: 20),
            _buildSection('偏好设置', [
              _buildSettingItem(Icons.notifications_none, '消息推送', '', isSwitch: true, switchValue: true),
              _buildSettingItem(Icons.dark_mode_outlined, '深色模式', '', isSwitch: true, switchValue: false),
              _buildSettingItem(Icons.language, '语言设置', '简体中文'),
            ]),
            const SizedBox(height: 20),
            _buildSection('关于', [
              _buildSettingItem(Icons.info_outline, '当前版本', 'v1.0.0'),
              _buildSettingItem(Icons.description_outlined, '用户协议', ''),
              _buildSettingItem(Icons.privacy_tip_outlined, '隐私政策', ''),
              _buildSettingItem(Icons.help_outline, '帮助与反馈', ''),
            ]),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.redAccent, width: 1),
                    ),
                  ),
                  child: const Text('退出登录', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String value, {bool isSwitch = false, bool switchValue = false}) {
    return ListTile(
      leading: Icon(icon, size: 22, color: Colors.grey[600]),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: isSwitch 
        ? Switch(
            value: switchValue, 
            onChanged: (v) {},
            activeColor: const Color(0xFFFF6B9D),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value.isNotEmpty)
                Text(value, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 20, color: Colors.grey[300]),
            ],
          ),
      onTap: isSwitch ? null : () {},
    );
  }
}
