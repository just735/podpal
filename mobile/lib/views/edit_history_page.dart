import 'package:flutter/material.dart';

class EditHistoryPage extends StatefulWidget {
  const EditHistoryPage({super.key});

  @override
  State<EditHistoryPage> createState() => _EditHistoryPageState();
}

class _EditHistoryPageState extends State<EditHistoryPage> {
  final List<Map<String, dynamic>> _projects = [
    {
      'id': '1',
      'name': '科技周报 #42: AI 的未来',
      'type': '访谈类',
      'status': '已发布',
      'date': '2024-01-28',
      'duration': '45:12',
    },
    {
      'id': '2',
      'name': '创业者日记: 从 0 到 1',
      'type': '独白类',
      'status': '草稿',
      'date': '2024-01-25',
      'duration': '12:30',
    },
    {
      'id': '3',
      'name': '读书会: 《非暴力沟通》',
      'type': '多人对谈',
      'status': '处理中',
      'date': '2024-01-20',
      'duration': '32:15',
    },
  ];

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('剪辑历史', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _projects.isEmpty 
        ? _buildEmptyState()
        : AnimatedList(
            key: _listKey,
            initialItemCount: _projects.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index, animation) {
              return _buildProjectCard(_projects[index], animation, index);
            },
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text('暂无剪辑项目', style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project, Animation<double> animation, int index) {
    final statusColor = _getStatusColor(project['status']);
    
    return SizeTransition(
      sizeFactor: animation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    project['status'],
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  project['date'],
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              project['name'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoTag(Icons.category_outlined, project['type']),
                const SizedBox(width: 12),
                _buildInfoTag(Icons.timer_outlined, project['duration']),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _handleDelete(index),
                  child: const Text('删除', style: TextStyle(color: Colors.redAccent)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // 跳转到剪辑页面
                    Navigator.pushNamed(context, '/editor', arguments: project['id']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text('继续编辑'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleDelete(int index) {
    final removedProject = _projects[index];
    
    // 1. 显示确认对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除项目《${removedProject['name']}》吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDeleteAction(index, removedProject);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _performDeleteAction(int index, Map<String, dynamic> removedProject) {
    // 从列表中移除并触发动画
    _projects.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildProjectCard(removedProject, animation, index),
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildInfoTag(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '已发布': return Colors.green;
      case '草稿': return Colors.grey;
      case '处理中': return Colors.orange;
      default: return Colors.blue;
    }
  }
}
