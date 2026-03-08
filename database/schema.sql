-- ============================================
-- PodPal 播客创作平台数据库设计
-- ============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS podpal CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE podpal;

-- ============================================
-- 1. 用户与权限模块
-- ============================================

-- 用户表
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL COMMENT '用户名',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT '邮箱',
    phone VARCHAR(20) COMMENT '手机号',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    avatar_url VARCHAR(500) COMMENT '头像URL',
    membership_type ENUM('free', 'pro', 'enterprise') DEFAULT 'free' COMMENT '会员类型：免费版/专业版/企业版',
    membership_expire_at TIMESTAMP NULL COMMENT '会员到期时间',
    status ENUM('active', 'inactive', 'banned') DEFAULT 'active' COMMENT '账号状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_membership (membership_type)
) ENGINE=InnoDB COMMENT='用户表';

-- 用户偏好设置表
CREATE TABLE user_preferences (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    theme ENUM('light', 'dark') DEFAULT 'dark' COMMENT '主题',
    language VARCHAR(10) DEFAULT 'zh' COMMENT '语言',
    auto_save BOOLEAN DEFAULT TRUE COMMENT '自动保存',
    email_notify BOOLEAN DEFAULT FALSE COMMENT '邮件通知',
    transcript_language VARCHAR(10) DEFAULT 'zh' COMMENT '转写语言',
    smart_clip_target_length_sec INT DEFAULT 60 COMMENT '智能剪辑目标时长(秒)',
    smart_clip_highlights_only BOOLEAN DEFAULT TRUE COMMENT '仅高亮片段',
    audio_noise_reduction BOOLEAN DEFAULT TRUE COMMENT '音频降噪',
    audio_level_equalize BOOLEAN DEFAULT TRUE COMMENT '音频均衡',
    export_audio_mp3 BOOLEAN DEFAULT TRUE COMMENT '导出MP3',
    export_video_169 BOOLEAN DEFAULT TRUE COMMENT '导出16:9视频',
    export_video_916 BOOLEAN DEFAULT TRUE COMMENT '导出9:16视频',
    subtitle_language VARCHAR(10) DEFAULT 'zh' COMMENT '字幕语言',
    subtitle_auto_generate BOOLEAN DEFAULT TRUE COMMENT '自动生成字幕',
    timeline_snap BOOLEAN DEFAULT TRUE COMMENT '时间轴吸附',
    ripple_edit BOOLEAN DEFAULT TRUE COMMENT '波纹编辑',
    default_zoom_percent INT DEFAULT 100 COMMENT '默认缩放比例',
    tts_default_voice VARCHAR(50) DEFAULT 'female' COMMENT '默认TTS声音',
    watermark_enabled BOOLEAN DEFAULT FALSE COMMENT '启用水印',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_id (user_id)
) ENGINE=InnoDB COMMENT='用户偏好设置表';

-- 用户第三方平台授权表
CREATE TABLE user_platform_auth (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    platform ENUM('apple_podcast', 'spotify', 'youtube', 'bilibili', 'douyin', 'shorts', 'wechat', 'xiaohongshu', 'weibo') NOT NULL COMMENT '平台',
    is_enabled BOOLEAN DEFAULT TRUE COMMENT '是否启用',
    auth_token VARCHAR(500) COMMENT '授权令牌',
    refresh_token VARCHAR(500) COMMENT '刷新令牌',
    expire_at TIMESTAMP NULL COMMENT '过期时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_platform (user_id, platform)
) ENGINE=InnoDB COMMENT='用户第三方平台授权表';

-- ============================================
-- 2. 会员与计费模块
-- ============================================

-- 会员套餐表
CREATE TABLE membership_plans (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL COMMENT '套餐名称',
    code VARCHAR(20) NOT NULL UNIQUE COMMENT '套餐代码',
    description TEXT COMMENT '套餐描述',
    price_monthly DECIMAL(10,2) COMMENT '月付价格',
    price_yearly DECIMAL(10,2) COMMENT '年付价格',
    features JSON COMMENT '功能特性列表',
    max_projects INT DEFAULT -1 COMMENT '最大项目数(-1无限制)',
    max_storage_gb INT DEFAULT 10 COMMENT '最大存储空间(GB)',
    max_clip_minutes_monthly INT DEFAULT 300 COMMENT '每月剪辑时长(分钟)',
    max_voice_clones INT DEFAULT 1 COMMENT '最大音色克隆数',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='会员套餐表';

-- 用户订阅记录表
CREATE TABLE user_subscriptions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    plan_id BIGINT NOT NULL,
    billing_cycle ENUM('monthly', 'yearly') NOT NULL COMMENT '计费周期',
    amount DECIMAL(10,2) NOT NULL COMMENT '金额',
    currency VARCHAR(3) DEFAULT 'CNY' COMMENT '货币',
    status ENUM('active', 'cancelled', 'expired', 'pending') DEFAULT 'pending' COMMENT '状态',
    start_at TIMESTAMP NOT NULL COMMENT '开始时间',
    end_at TIMESTAMP NOT NULL COMMENT '结束时间',
    cancelled_at TIMESTAMP NULL COMMENT '取消时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES membership_plans(id),
    INDEX idx_user_status (user_id, status)
) ENGINE=InnoDB COMMENT='用户订阅记录表';

-- 用户使用额度表
CREATE TABLE user_usage_quota (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    quota_type ENUM('clip_minutes', 'storage_gb', 'tts_chars', 'ai_requests') NOT NULL COMMENT '额度类型',
    total_quota INT NOT NULL COMMENT '总额度',
    used_quota INT DEFAULT 0 COMMENT '已使用额度',
    reset_period ENUM('daily', 'monthly', 'yearly', 'one_time') NOT NULL COMMENT '重置周期',
    reset_at TIMESTAMP NULL COMMENT '下次重置时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_quota_type (user_id, quota_type)
) ENGINE=InnoDB COMMENT='用户使用额度表';

-- ============================================
-- 3. 项目与素材模块
-- ============================================

-- 播客项目表
CREATE TABLE projects (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    name VARCHAR(200) NOT NULL COMMENT '项目名称',
    description TEXT COMMENT '项目描述',
    podcast_type ENUM('knowledge', 'companion', 'interview', 'story', 'news') COMMENT '播客类型：知识/陪伴/访谈/故事/新闻',
    status ENUM('draft', 'processing', 'completed', 'published', 'archived') DEFAULT 'draft' COMMENT '状态',
    duration INT COMMENT '音频时长(秒)',
    audio_url VARCHAR(500) COMMENT '主音频文件URL',
    transcript TEXT COMMENT '完整转写文本',
    transcript_segments JSON COMMENT '转写分段数据',
    settings JSON COMMENT '项目设置',
    is_deleted BOOLEAN DEFAULT FALSE COMMENT '软删除标记',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_status (user_id, status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB COMMENT='播客项目表';

-- 素材库表
CREATE TABLE materials (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    project_id BIGINT COMMENT '关联项目ID(可选)',
    name VARCHAR(200) NOT NULL COMMENT '素材名称',
    file_url VARCHAR(500) NOT NULL COMMENT '文件URL',
    file_type ENUM('audio', 'video', 'image', 'document') NOT NULL COMMENT '文件类型',
    file_size BIGINT COMMENT '文件大小(字节)',
    file_format VARCHAR(20) COMMENT '文件格式(mp3/wav等)',
    category ENUM('voice', 'background', 'effect', 'music', 'other') DEFAULT 'other' COMMENT '分类：人声/背景音/效果音/音乐/其他',
    duration INT COMMENT '时长(秒)',
    waveform_data JSON COMMENT '波形数据',
    is_favorite BOOLEAN DEFAULT FALSE COMMENT '是否收藏',
    tags JSON COMMENT '标签',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
    INDEX idx_user_category (user_id, category)
) ENGINE=InnoDB COMMENT='素材库表';

-- 项目素材关联表
CREATE TABLE project_materials (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    project_id BIGINT NOT NULL,
    material_id BIGINT NOT NULL,
    track_type ENUM('main', 'voice', 'background', 'effect') DEFAULT 'main' COMMENT '轨道类型',
    track_order INT DEFAULT 0 COMMENT '轨道顺序',
    start_time_ms BIGINT DEFAULT 0 COMMENT '在时间轴上的起始位置(毫秒)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (material_id) REFERENCES materials(id) ON DELETE CASCADE,
    UNIQUE KEY uk_project_material (project_id, material_id, track_type)
) ENGINE=InnoDB COMMENT='项目素材关联表';

-- ============================================
-- 4. 编辑与转写模块
-- ============================================

-- 转写片段表
CREATE TABLE transcript_segments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    project_id BIGINT NOT NULL,
    speaker_label VARCHAR(10) COMMENT '说话人标识(A/B/C等)',
    speaker_name VARCHAR(50) COMMENT '说话人名称',
    start_time_ms BIGINT NOT NULL COMMENT '开始时间(毫秒)',
    end_time_ms BIGINT NOT NULL COMMENT '结束时间(毫秒)',
    text TEXT NOT NULL COMMENT '转写文本',
    confidence DECIMAL(3,2) COMMENT '置信度',
    is_filler_word BOOLEAN DEFAULT FALSE COMMENT '是否填充词',
    is_deleted BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    INDEX idx_project_time (project_id, start_time_ms)
) ENGINE=InnoDB COMMENT='转写片段表';

-- 编辑历史记录表
CREATE TABLE edit_history (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    project_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    action_type ENUM('create', 'update', 'delete', 'split', 'merge', 'trim', 'replace') NOT NULL COMMENT '操作类型',
    action_detail JSON COMMENT '操作详情',
    before_state JSON COMMENT '操作前状态',
    after_state JSON COMMENT '操作后状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_project_created (project_id, created_at)
) ENGINE=InnoDB COMMENT='编辑历史记录表';

-- 智能剪辑片段表
CREATE TABLE smart_clips (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    project_id BIGINT NOT NULL,
    name VARCHAR(200) COMMENT '片段名称',
    start_time_ms BIGINT NOT NULL COMMENT '开始时间(毫秒)',
    end_time_ms BIGINT NOT NULL COMMENT '结束时间(毫秒)',
    clip_type ENUM('highlight', 'intro', 'outro', 'quote') DEFAULT 'highlight' COMMENT '片段类型',
    score DECIMAL(3,2) COMMENT '质量评分',
    is_selected BOOLEAN DEFAULT FALSE COMMENT '是否被选中',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='智能剪辑片段表';

-- ============================================
-- 5. AI 功能模块
-- ============================================

-- 音色克隆表
CREATE TABLE voice_clones (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL COMMENT '音色名称',
    description TEXT COMMENT '描述',
    sample_audio_url VARCHAR(500) COMMENT '样本音频URL',
    model_id VARCHAR(100) COMMENT 'AI模型ID',
    status ENUM('training', 'ready', 'failed') DEFAULT 'training' COMMENT '状态',
    training_progress INT DEFAULT 0 COMMENT '训练进度(0-100)',
    is_default BOOLEAN DEFAULT FALSE COMMENT '是否默认音色',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_status (user_id, status)
) ENGINE=InnoDB COMMENT='音色克隆表';

-- TTS 任务表
CREATE TABLE tts_tasks (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    project_id BIGINT COMMENT '关联项目',
    voice_clone_id BIGINT COMMENT '使用的音色',
    text_content TEXT NOT NULL COMMENT '文本内容',
    audio_url VARCHAR(500) COMMENT '生成音频URL',
    status ENUM('pending', 'processing', 'completed', 'failed') DEFAULT 'pending' COMMENT '状态',
    settings JSON COMMENT 'TTS设置(语速/音调等)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL COMMENT '完成时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
    FOREIGN KEY (voice_clone_id) REFERENCES voice_clones(id) ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='TTS任务表';

-- AI 生成内容表
CREATE TABLE ai_generated_content (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    project_id BIGINT NOT NULL,
    content_type ENUM('shownotes', 'mindmap', 'social_text', 'title', 'summary', 'tags') NOT NULL COMMENT '内容类型',
    platform VARCHAR(50) COMMENT '目标平台(社交媒体用)',
    content TEXT NOT NULL COMMENT '生成内容',
    metadata JSON COMMENT '元数据',
    is_applied BOOLEAN DEFAULT FALSE COMMENT '是否已应用',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    INDEX idx_project_type (project_id, content_type)
) ENGINE=InnoDB COMMENT='AI生成内容表';

-- ============================================
-- 6. 导出与发布模块
-- ============================================

-- 导出任务表
CREATE TABLE export_tasks (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    project_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    export_type ENUM('audio', 'video', 'transcript', 'clips') NOT NULL COMMENT '导出类型',
    format VARCHAR(20) NOT NULL COMMENT '格式(mp3/mp4/srt等)',
    file_url VARCHAR(500) COMMENT '导出文件URL',
    file_size BIGINT COMMENT '文件大小',
    settings JSON COMMENT '导出设置',
    status ENUM('pending', 'processing', 'completed', 'failed') DEFAULT 'pending' COMMENT '状态',
    progress INT DEFAULT 0 COMMENT '进度(0-100)',
    error_message TEXT COMMENT '错误信息',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL COMMENT '完成时间',
    expires_at TIMESTAMP NULL COMMENT '文件过期时间',
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_status (user_id, status)
) ENGINE=InnoDB COMMENT='导出任务表';

-- 发布记录表
CREATE TABLE publish_records (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    project_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    platform ENUM('apple_podcast', 'spotify', 'youtube', 'bilibili', 'douyin', 'xiaohongshu', 'weibo', 'custom_rss') NOT NULL COMMENT '发布平台',
    platform_content_id VARCHAR(200) COMMENT '平台内容ID',
    platform_url VARCHAR(500) COMMENT '平台链接',
    title VARCHAR(200) COMMENT '发布标题',
    description TEXT COMMENT '发布描述',
    tags JSON COMMENT '标签',
    cover_image_url VARCHAR(500) COMMENT '封面图URL',
    audio_url VARCHAR(500) COMMENT '音频URL',
    video_url VARCHAR(500) COMMENT '视频URL',
    status ENUM('pending', 'publishing', 'published', 'failed') DEFAULT 'pending' COMMENT '状态',
    published_at TIMESTAMP NULL COMMENT '发布时间',
    error_message TEXT COMMENT '错误信息',
    analytics JSON COMMENT '发布数据统计',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_project_platform (project_id, platform)
) ENGINE=InnoDB COMMENT='发布记录表';

-- ============================================
-- 7. 系统与日志模块
-- ============================================

-- 系统配置表
CREATE TABLE system_configs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    config_key VARCHAR(100) NOT NULL UNIQUE COMMENT '配置键',
    config_value TEXT COMMENT '配置值',
    description VARCHAR(500) COMMENT '描述',
    is_editable BOOLEAN DEFAULT TRUE COMMENT '是否可编辑',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='系统配置表';

-- 操作日志表
CREATE TABLE operation_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT COMMENT '操作用户',
    action VARCHAR(100) NOT NULL COMMENT '操作类型',
    resource_type VARCHAR(50) COMMENT '资源类型',
    resource_id BIGINT COMMENT '资源ID',
    request_data JSON COMMENT '请求数据',
    response_data JSON COMMENT '响应数据',
    ip_address VARCHAR(50) COMMENT 'IP地址',
    user_agent VARCHAR(500) COMMENT '用户代理',
    duration_ms INT COMMENT '执行时长(毫秒)',
    status ENUM('success', 'failed') DEFAULT 'success' COMMENT '状态',
    error_message TEXT COMMENT '错误信息',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_created (user_id, created_at),
    INDEX idx_action (action)
) ENGINE=InnoDB COMMENT='操作日志表';

-- ============================================
-- 初始化数据
-- ============================================

-- 初始化会员套餐
INSERT INTO membership_plans (name, code, description, price_monthly, price_yearly, features, max_projects, max_storage_gb, max_clip_minutes_monthly, max_voice_clones) VALUES
('免费版', 'free', '适合个人用户体验', 0, 0, '["基础剪辑", "标准音质", "社区支持"]', 3, 1, 30, 1),
('专业版', 'pro', '适合专业播客创作者', 49, 499, '["无限项目", "高清音质", "AI增强", "音色克隆", "优先支持"]', -1, 50, 600, 5),
('企业版', 'enterprise', '适合团队和企业', 199, 1999, '["团队协作", "API访问", "专属客服", "定制功能", "SLA保障"]', -1, 500, -1, -1);

-- 初始化系统配置
INSERT INTO system_configs (config_key, config_value, description) VALUES
('site.name', 'PodPal', '网站名称'),
('site.logo', '/logo.png', '网站Logo'),
('upload.max_file_size', '524288000', '最大上传文件大小(字节)'),
('upload.allowed_audio_formats', '["mp3","wav","m4a","flac"]', '允许的音频格式'),
('ai.transcript_enabled', 'true', '是否启用AI转写'),
('ai.tts_enabled', 'true', '是否启用TTS'),
('storage.cdn_domain', '', 'CDN域名');
