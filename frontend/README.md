# PodPal 前端应用

播客深度剪辑系统的前端应用，基于 Vue 3 + Vite 构建。

## 功能特性

### 核心功能模块

1. **用户管理模块**
   - 用户注册/登录（支持第三方登录）
   - 个人中心（基本信息、项目列表、偏好设置）
   - 权限管理

2. **素材管理模块**
   - 多格式素材上传（音频/视频）
   - 素材库管理（分类、标签、搜索）
   - 素材预览和删除

3. **AI智能剪辑核心模块**
   - 音频转写（ASR）
   - 文本化编辑（像编辑Word一样编辑音频）
   - 智能剪辑（一键精华剪辑、去冗余）
   - 音频优化（降噪、音量均衡）

4. **内容增值模块**
   - 文案生成（Show Notes、推广文案、标题）
   - 播客视频化（多平台适配）
   - 交互式播客生成

5. **导出与分发模块**
   - 多格式导出（音频、视频、文本）
   - 一键分发到多个平台

6. **项目管理模块**
   - 项目创建和管理
   - 版本管理
   - 项目协作（团队版）

## 技术栈

- **框架**: Vue 3 (Composition API)
- **构建工具**: Vite
- **路由**: Vue Router 4
- **状态管理**: Pinia
- **HTTP客户端**: Axios
- **样式**: Tailwind CSS (CDN)
- **音频处理**: Wavesurfer.js
- **工具库**: VueUse, Day.js

## 项目结构

```
frontend/
├── src/
│   ├── components/          # 组件
│   │   ├── AudioPlayer.vue      # 音频播放器
│   │   ├── TranscriptEditor.vue # 转写文本编辑器
│   │   ├── SmartClipView.vue    # 智能剪辑视图
│   │   ├── EnhanceView.vue      # 内容增值视图
│   │   ├── ExportView.vue        # 导出视图
│   │   ├── UploadModal.vue      # 上传模态框
│   │   ├── CreateProjectModal.vue # 创建项目模态框
│   │   └── ...
│   ├── views/               # 页面
│   │   ├── HomeView.vue          # 首页
│   │   ├── LoginView.vue         # 登录页
│   │   ├── RegisterView.vue     # 注册页
│   │   ├── DashboardView.vue     # 工作台
│   │   ├── ProjectsView.vue      # 项目列表
│   │   ├── ProjectDetailView.vue # 项目详情
│   │   ├── EditorView.vue        # 编辑器（核心）
│   │   ├── MaterialsView.vue     # 素材管理
│   │   ├── ProfileView.vue       # 个人中心
│   │   └── ToolsView.vue         # 工具箱
│   ├── stores/              # Pinia状态管理
│   │   ├── user.js               # 用户状态
│   │   ├── project.js            # 项目状态
│   │   └── material.js           # 素材状态
│   ├── services/            # 服务层
│   │   └── api.js                # API封装
│   ├── router/              # 路由配置
│   │   └── index.js
│   ├── App.vue              # 根组件
│   └── main.js              # 入口文件
├── package.json
└── vite.config.js
```

## 安装和运行

### 安装依赖

```bash
cd frontend
npm install
```

### 开发模式

```bash
npm run dev
```

应用将在 `http://localhost:5173` 启动

### 构建生产版本

```bash
npm run build
```

### 预览生产构建

```bash
npm run preview
```

## 环境变量

创建 `.env` 文件（参考 `.env.example`）：

```env
VITE_API_BASE_URL=http://localhost:8080/api
```

## 主要功能说明

### 编辑器（EditorView）

编辑器是核心功能模块，包含：

1. **转写文本视图**
   - 显示音频转写结果
   - 支持文本编辑（修改转写文本）
   - 点击文本片段跳转到对应音频位置
   - AI优化文本、提取关键词、生成Shownotes

2. **智能剪辑视图**
   - 一键精华剪辑
   - 智能去冗余
   - 剪辑模板选择
   - 片段预览和删除

3. **内容增值视图**
   - 文案生成
   - 播客视频化
   - 交互式播客生成

4. **导出分发视图**
   - 音频/视频/文本导出
   - 一键分发到多个平台

### 音频播放器

底部固定播放器，支持：
- 播放/暂停
- 进度控制
- 音量调节
- 静音
- 时间跳转

### 素材管理

- 拖拽上传
- 批量上传
- 上传进度显示
- 素材预览
- 素材删除

## API 接口说明

所有API请求通过 `src/services/api.js` 统一处理：

- 自动添加认证token
- 统一错误处理
- 401自动跳转登录

主要API端点（需要后端实现）：

- `/auth/login` - 登录
- `/auth/register` - 注册
- `/user/info` - 获取用户信息
- `/projects` - 项目列表
- `/projects/:id` - 项目详情
- `/projects/:id/transcribe` - 音频转写
- `/projects/:id/smart-clip` - 智能剪辑
- `/materials` - 素材列表
- `/materials/upload` - 上传素材
- `/ai/optimize-text` - 文本优化
- `/ai/extract-keywords` - 提取关键词
- `/ai/generate-shownotes` - 生成Shownotes
- `/projects/:id/export/audio` - 导出音频
- `/projects/:id/export/video` - 导出视频
- `/projects/:id/publish` - 发布到平台

## 开发注意事项

1. **路由守卫**: 已实现路由守卫，需要登录的页面会自动跳转到登录页
2. **状态管理**: 使用Pinia进行状态管理，数据持久化到localStorage
3. **响应式设计**: 使用Tailwind CSS实现响应式布局
4. **错误处理**: API调用统一错误处理，用户友好的错误提示

## 后续开发建议

1. 实现音频波形可视化（使用Wavesurfer.js）
2. 实现时间轴编辑器
3. 实现实时协作功能（WebSocket）
4. 优化移动端体验
5. 添加更多AI功能集成
6. 实现离线缓存功能
