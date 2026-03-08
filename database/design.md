# PodPal 数据库设计文档

## 一、概述

### 1.1 设计目标
为 PodPal 播客创作平台设计一套完整的数据库结构，支持：
- 用户管理与会员体系
- 播客项目管理与素材存储
- 音频转写与智能剪辑
- AI 功能（音色克隆、TTS、内容生成）
- 多平台发布与导出

### 1.2 技术选型
- **数据库**: MySQL 8.0+
- **字符集**: utf8mb4 (支持 emoji 和中文)
- **引擎**: InnoDB (支持事务和外键)

---

## 二、数据库表结构

### 2.1 用户与权限模块

#### users (用户表)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 用户ID |
| username | VARCHAR(50) | 用户名 |
| email | VARCHAR(100) | 邮箱(唯一) |
| phone | VARCHAR(20) | 手机号 |
| password_hash | VARCHAR(255) | 密码哈希 |
| avatar_url | VARCHAR(500) | 头像URL |
| membership_type | ENUM | 会员类型: free/pro/enterprise |
| membership_expire_at | TIMESTAMP | 会员到期时间 |
| status | ENUM | 账号状态 |
| created_at | TIMESTAMP | 创建时间 |
| updated_at | TIMESTAMP | 更新时间 |

#### user_preferences (用户偏好设置表)
存储用户在设置页面配置的所有偏好选项，包括主题、语言、剪辑参数等。

#### user_platform_auth (用户第三方平台授权表)
存储用户授权的各个发布平台（公众号、小红书、抖音等）的令牌信息。

### 2.2 会员与计费模块

#### membership_plans (会员套餐表)
| 字段 | 说明 |
|------|------|
| name | 套餐名称 |
| code | 套餐代码: free/pro/enterprise |
| price_monthly/yearly | 月付/年付价格 |
| max_projects | 最大项目数(-1无限制) |
| max_storage_gb | 存储空间(GB) |
| max_clip_minutes_monthly | 每月剪辑时长(分钟) |
| max_voice_clones | 最大音色克隆数 |

#### user_subscriptions (用户订阅记录表)
记录用户的订阅历史，包括计费周期、金额、状态等。

#### user_usage_quota (用户使用额度表)
跟踪用户的各类使用额度：
- clip_minutes: 剪辑时长
- storage_gb: 存储空间
- tts_chars: TTS字符数
- ai_requests: AI请求次数

### 2.3 项目与素材模块

#### projects (播客项目表)
核心表，存储播客项目的基本信息：
| 字段 | 说明 |
|------|------|
| name | 项目名称 |
| podcast_type | 类型: knowledge/companion/interview/story/news |
| status | 状态: draft/processing/completed/published/archived |
| duration | 音频时长(秒) |
| audio_url | 主音频文件URL |
| transcript | 完整转写文本 |
| transcript_segments | 转写分段JSON |
| settings | 项目设置JSON |

#### materials (素材库表)
用户上传的音频、视频、图片等素材。
| 字段 | 说明 |
|------|------|
| file_type | 文件类型: audio/video/image/document |
| category | 分类: voice/background/effect/music/other |
| waveform_data | 波形数据JSON |
| is_favorite | 是否收藏 |

#### project_materials (项目素材关联表)
多对多关系表，记录项目中使用的素材及其在时间轴上的位置。

### 2.4 编辑与转写模块

#### transcript_segments (转写片段表)
存储 AI 转写后的文本片段：
| 字段 | 说明 |
|------|------|
| speaker_label | 说话人标识(A/B/C) |
| speaker_name | 说话人名称 |
| start/end_time_ms | 起止时间(毫秒) |
| text | 转写文本 |
| confidence | 置信度 |
| is_filler_word | 是否填充词(嗯、啊等) |

#### edit_history (编辑历史记录表)
记录项目的所有编辑操作，支持撤销/重做功能。

#### smart_clips (智能剪辑片段表)
AI 自动识别的高光片段，包含质量评分。

### 2.5 AI 功能模块

#### voice_clones (音色克隆表)
| 字段 | 说明 |
|------|------|
| sample_audio_url | 样本音频URL |
| model_id | AI模型ID |
| status | 状态: training/ready/failed |
| training_progress | 训练进度0-100 |
| is_default | 是否默认音色 |

#### tts_tasks (TTS任务表)
文本转语音任务队列。

#### ai_generated_content (AI生成内容表)
存储 AI 生成的各类内容：
- shownotes: 节目笔记
- mindmap: 思维导图
- social_text: 社交媒体文案
- title/summary/tags: 标题/摘要/标签

### 2.6 导出与发布模块

#### export_tasks (导出任务表)
异步导出任务队列，支持音频、视频、字幕等格式。

#### publish_records (发布记录表)
记录向各平台（Apple Podcast、Spotify、抖音、小红书等）的发布历史。

### 2.7 系统与日志模块

#### system_configs (系统配置表)
存储系统级配置参数。

#### operation_logs (操作日志表)
记录用户操作日志，用于审计和问题排查。

---

## 三、ER 图关系

```
users (1) ────< (N) projects
   │
   ├──< (1) user_preferences
   ├──< (N) user_platform_auth
   ├──< (N) user_subscriptions
   ├──< (N) user_usage_quota
   ├──< (N) materials
   ├──< (N) voice_clones
   └──< (N) tts_tasks

projects (1) ──< (N) transcript_segments
   ├──< (N) project_materials >──(N) materials
   ├──< (N) edit_history
   ├──< (N) smart_clips
   ├──< (N) ai_generated_content
   ├──< (N) export_tasks
   └──< (N) publish_records
```

---

## 四、关键业务场景

### 4.1 创建播客项目流程
1. 用户创建 project 记录
2. 上传音频素材到 materials
3. 关联 project_materials
4. AI 转写生成 transcript_segments
5. 用户编辑更新 edit_history

### 4.2 智能剪辑流程
1. AI 分析生成 smart_clips
2. 用户选择片段
3. 生成导出任务 export_tasks
4. 可选择发布到各平台 publish_records

### 4.3 音色克隆流程
1. 用户上传样本到 voice_clones
2. 异步训练更新 training_progress
3. 训练完成后可用于 tts_tasks

---

## 五、索引设计

### 高频查询索引
```sql
-- 用户项目列表
CREATE INDEX idx_user_status ON projects(user_id, status);

-- 转写片段按时间查询
CREATE INDEX idx_project_time ON transcript_segments(project_id, start_time_ms);

-- 素材分类查询
CREATE INDEX idx_user_category ON materials(user_id, category);

-- 导出任务状态查询
CREATE INDEX idx_user_status ON export_tasks(user_id, status);
```

---

## 六、数据安全

1. **密码存储**: 使用 bcrypt 等算法哈希存储
2. **敏感字段**: API Token 等加密存储
3. **软删除**: projects 表使用 is_deleted 标记
4. **审计日志**: operation_logs 记录所有操作
