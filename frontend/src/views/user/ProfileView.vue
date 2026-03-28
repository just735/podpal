<template>
  <section class="pt-32 pb-20 px-6 min-h-screen bg-white">
    <div class="container mx-auto max-w-7xl">
      <!-- 头部区域 -->
      <div class="mb-8">
        <h1 class="text-5xl font-bold mb-3 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">
          个人中心
        </h1>
        <p class="text-gray-600 text-lg">管理你的账号、项目和偏好设置</p>
      </div>

      <!-- 顶部标签切换 - 优化设计 -->
      <div class="mb-8">
        <div class="flex gap-3 overflow-x-auto pb-2 scrollbar-hide" style="scrollbar-width: none; -ms-overflow-style: none;">
          <button
            v-for="tab in tabs"
            :key="tab.key"
            type="button"
            class="px-5 py-3 text-sm font-medium rounded-xl transition-all duration-300 whitespace-nowrap flex items-center gap-2 relative group"
            :class="
              activeTab === tab.key
                ? 'bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white shadow-lg shadow-pink-300/50 scale-105'
                : 'bg-gray-50 text-gray-600 hover:text-pink-600 hover:bg-pink-50 border border-gray-200'
            "
            @click="setActiveTab(tab.key)"
          >
            <span class="text-lg transition-transform duration-300" :class="activeTab === tab.key ? 'scale-110' : ''">
              {{ tab.icon }}
            </span>
            <span>{{ tab.label }}</span>
            <span
              v-if="activeTab === tab.key"
              class="absolute bottom-0 left-0 right-0 h-0.5 bg-gradient-to-r from-transparent via-white to-transparent"
            ></span>
          </button>
        </div>
      </div>

      <!-- 内容区域 - 添加动画效果 -->
      <div class="glass-card rounded-2xl p-6 md:p-8 transition-all duration-300 hover:shadow-2xl hover:shadow-pink-200/50 bg-gradient-to-br from-pink-50/50 to-purple-50/50 border-2 border-pink-200/60">
        <!-- 基本信息 -->
        <div v-if="activeTab === 'basic'" class="space-y-6 animate-fade-in">
          <div class="flex items-center justify-between mb-6">
            <div>
              <h2 class="text-3xl font-bold mb-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">
                基本信息
              </h2>
              <p class="text-gray-600 text-sm">查看和管理你的账号信息</p>
            </div>
            <button 
              @click="showEditModal = true"
              class="px-5 py-2.5 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-xl hover:shadow-lg hover:scale-105 transition-all duration-300 text-sm font-medium shadow-lg shadow-pink-300/50"
            >
              编辑资料
            </button>
          </div>
          
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="space-y-4">
              <div class="info-card">
                <div class="flex items-center gap-3 mb-2">
                  <div class="w-10 h-10 bg-pink-100 rounded-lg flex items-center justify-center">
                    <span class="text-pink-600 text-lg">👤</span>
                  </div>
                  <div class="flex-1">
                    <div class="text-gray-500 text-xs mb-1">用户名</div>
                    <div class="text-gray-900 text-lg font-semibold">{{ userStore.user?.username || '未设置' }}</div>
                  </div>
                </div>
              </div>
              <div class="info-card">
                <div class="flex items-center gap-3 mb-2">
                  <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                    <span class="text-blue-600 text-lg">📧</span>
                  </div>
                  <div class="flex-1">
                    <div class="text-gray-500 text-xs mb-1">邮箱</div>
                    <div class="text-gray-900 text-lg font-semibold">{{ userStore.user?.email || '未设置' }}</div>
                  </div>
                </div>
              </div>
              <div class="info-card">
                <div class="flex items-center gap-3 mb-2">
                  <div class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                    <span class="text-green-600 text-lg">📱</span>
                  </div>
                  <div class="flex-1">
                    <div class="text-gray-500 text-xs mb-1">手机号</div>
                    <div class="text-gray-900 text-lg font-semibold">{{ userStore.user?.phone || '未绑定' }}</div>
                  </div>
                </div>
              </div>
            </div>
            <div class="space-y-4">
              <div class="info-card">
                <div class="flex items-center gap-3 mb-2">
                  <div class="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                    <span class="text-purple-600 text-lg">⭐</span>
                  </div>
                  <div class="flex-1">
                    <div class="text-gray-500 text-xs mb-1">账号类型</div>
                    <div class="text-lg font-semibold" :class="getMembershipTypeColor(userStore.user?.membershipType || '免费版')">
                      {{ userStore.user?.membershipType || '免费版' }}
                    </div>
                  </div>
                </div>
              </div>
              <div class="info-card">
                <div class="flex items-center gap-3 mb-2">
                  <div class="w-10 h-10 bg-amber-100 rounded-lg flex items-center justify-center">
                    <span class="text-amber-600 text-lg">📅</span>
                  </div>
                  <div class="flex-1">
                    <div class="text-gray-500 text-xs mb-1">注册时间</div>
                    <div class="text-gray-900 text-lg font-semibold">{{ userStore.user?.createdAt ? dayjs(userStore.user.createdAt).format('YYYY-MM-DD HH:mm') : '未知' }}</div>
                  </div>
                </div>
              </div>
              <div class="info-card">
                <div class="flex items-center gap-3 mb-2">
                  <div class="w-10 h-10 bg-cyan-100 rounded-lg flex items-center justify-center">
                    <span class="text-cyan-600 text-lg">🆔</span>
                  </div>
                  <div class="flex-1">
                    <div class="text-gray-500 text-xs mb-1">用户ID</div>
                    <div class="text-gray-900 text-lg font-semibold">#{{ userStore.user?.id || 'N/A' }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 训练个人音色模型 -->
        <div v-else-if="activeTab === 'voice-clone'" class="space-y-8 animate-fade-in">
          <div class="flex items-center justify-between mb-2">
            <div>
              <h2 class="text-3xl font-bold bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">
                训练个人音色模型
              </h2>
              <p class="text-gray-600 text-sm mt-1">通过少量录音克隆你的专属音色，用于 AI 语音合成</p>
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
            <!-- 步骤 1: 训练模型 -->
            <div class="glass-card rounded-2xl p-8 border-2 border-pink-100 bg-white hover:border-pink-300 transition-all duration-300 shadow-sm">
              <div class="flex items-center gap-4 mb-6">
                <div class="w-12 h-12 bg-pink-100 rounded-2xl flex items-center justify-center text-2xl">
                  1️⃣
                </div>
                <div>
                  <h3 class="text-xl font-bold text-gray-900">第一步：训练音色模型</h3>
                  <p class="text-xs text-gray-500">录制或上传 1-3 分钟的高质量音频</p>
                </div>
              </div>
              
              <div class="space-y-4 mb-8">
                <div class="p-4 bg-gray-50 rounded-xl border border-gray-100">
                  <div class="flex items-center justify-between mb-2">
                    <div class="text-sm font-bold text-gray-700">训练状态</div>
                    <div v-if="isTraining" class="text-sm text-pink-500 font-bold animate-pulse">{{ trainingProgress }}%</div>
                  </div>
                  <div class="flex items-center gap-3">
                    <div class="flex-1 h-3 bg-gray-200 rounded-full overflow-hidden">
                      <div 
                        class="h-full bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] transition-all duration-300" 
                        :style="{ width: trainingProgress + '%' }"
                      ></div>
                    </div>
                    <span class="text-sm font-bold" :class="isTraining ? 'text-pink-600' : 'text-gray-400'">
                      {{ trainingStatusText }}
                    </span>
                  </div>
                </div>
              </div>

              <button 
                @click="startTraining"
                :disabled="isTraining"
                class="w-full py-4 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-2xl font-bold hover:shadow-xl hover:shadow-pink-200 transition-all flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span v-if="!isTraining">🎙️ 开始录音训练</span>
                <span v-else>⏳ 正在训练中...</span>
              </button>
            </div>

            <!-- 步骤 2: 添加内容 -->
            <div 
              class="glass-card rounded-2xl p-8 border-2 transition-all duration-300"
              :class="trainingProgress === 100 ? 'border-pink-100 bg-white' : 'border-gray-100 bg-gray-50/50 opacity-60'"
            >
              <div class="flex items-center gap-4 mb-6">
                <div 
                  class="w-12 h-12 rounded-2xl flex items-center justify-center text-2xl"
                  :class="trainingProgress === 100 ? 'bg-pink-100' : 'bg-gray-200'"
                >
                  2️⃣
                </div>
                <div>
                  <h3 class="text-xl font-bold" :class="trainingProgress === 100 ? 'text-gray-900' : 'text-gray-400'">第二步：添加克隆内容</h3>
                  <p class="text-xs" :class="trainingProgress === 100 ? 'text-gray-500' : 'text-gray-400'">训练完成后添加文本即可克隆读出</p>
                </div>
              </div>
              
              <div v-if="trainingProgress < 100" class="p-4 border-2 border-dashed border-gray-200 rounded-xl flex flex-col items-center justify-center py-10">
                <span class="text-3xl mb-2">📝</span>
                <span class="text-sm text-gray-400">请先完成第一步训练</span>
              </div>
              <div v-else class="space-y-4 animate-fade-in">
                <textarea 
                  placeholder="转写文本..." 
                  class="w-full h-32 p-4 bg-gray-50 border border-pink-100 rounded-xl focus:ring-2 focus:ring-pink-300 outline-none text-sm resize-none"
                ></textarea>
                <button class="w-full py-3 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-xl font-bold hover:shadow-lg transition-all">
                  立即克隆并播放
                </button>
              </div>
            </div>
          </div>

          <!-- 历史训练记录 -->
          <div class="glass-card rounded-2xl p-8 border-2 border-pink-100 bg-white">
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-xl font-bold text-gray-900">历史训练记录</h3>
              <span class="text-xs text-gray-500">共 {{ voiceHistory.length }} 条记录</span>
            </div>
            <div class="space-y-4">
              <div v-if="voiceHistory.length === 0" class="text-center py-8 text-gray-400">
                暂无训练记录
              </div>
              <div 
                v-for="record in voiceHistory" 
                :key="record.id"
                class="flex items-center justify-between p-4 bg-gray-50 rounded-xl border border-gray-100 hover:border-pink-200 transition-all group"
              >
                <div class="flex items-center gap-4">
                  <div class="w-10 h-10 bg-pink-100 rounded-full flex items-center justify-center text-pink-600">
                    🎙️
                  </div>
                  <div>
                    <div class="font-bold text-gray-900">{{ record.name }}</div>
                    <div class="text-xs text-gray-500">{{ record.date }}</div>
                  </div>
                </div>
                <div class="flex items-center gap-4">
                  <span class="px-3 py-1 bg-green-100 text-green-700 text-xs rounded-full font-medium">
                    {{ record.status }}
                  </span>
                  <button class="text-pink-500 text-sm font-bold opacity-0 group-hover:opacity-100 transition-all">
                    使用此音色
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- 说明事项 -->
          <div class="rounded-2xl bg-amber-50 border border-amber-100 p-6">
            <h4 class="text-amber-800 font-bold mb-3 flex items-center gap-2">
              <span>💡</span> 训练指南
            </h4>
            <ul class="space-y-2 text-sm text-amber-700/80">
              <li>• 请在安静的环境下录音，避免背景噪音。</li>
              <li>• 建议录制 3 分钟以上，音色还原度更高。</li>
              <li>• 模型训练通常需要 5-10 分钟，完成后我们将通过邮件通知您。</li>
              <li>• 严禁克隆他人音色，仅限个人使用。</li>
            </ul>
          </div>
        </div>

        <!-- 其他标签页内容（简化版，可根据需要扩展） -->
        <div v-else-if="activeTab === 'membership'" class="space-y-6 animate-fade-in">
          <div class="flex items-center justify-between mb-2">
            <h2 class="text-3xl font-bold bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">
              会员中心
            </h2>
            <div class="px-3 py-1 rounded-xl bg-pink-100 text-pink-700 text-sm">
              当前：{{ userStore.user?.membershipType || '免费版' }}
            </div>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
            <div
              v-for="plan in plans"
              :key="plan.name"
              class="rounded-2xl border-2"
              :class="userStore.user?.membershipType === plan.name ? 'border-pink-400 bg-pink-50/60' : 'border-gray-200 bg-white'"
            >
              <div class="p-6">
                <div class="flex items-center justify-between mb-3">
                  <div class="text-xl font-bold" :class="userStore.user?.membershipType === plan.name ? 'text-pink-600' : 'text-gray-900'">{{ plan.name }}</div>
                  <div class="text-lg font-semibold" :class="userStore.user?.membershipType === plan.name ? 'text-pink-600' : 'text-gray-700'">{{ plan.price }}/月</div>
                </div>
                <div class="text-sm text-gray-600 mb-4">每月剪辑时长：{{ plan.minutes }} 分钟</div>
                <ul class="space-y-2 mb-6">
                  <li v-for="feat in plan.features" :key="feat" class="flex items-center gap-2 text-sm">
                    <span class="text-green-500">✔</span>
                    <span class="text-gray-700">{{ feat }}</span>
                  </li>
                </ul>
                <button
                  class="w-full px-4 py-2 rounded-xl text-sm font-medium transition"
                  :class="userStore.user?.membershipType === plan.name ? 'bg-gray-200 text-gray-700 cursor-default' : 'bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white hover:opacity-90'"
                  :disabled="userStore.user?.membershipType === plan.name"
                  @click="changePlan(plan)"
                >
                  {{ userStore.user?.membershipType === plan.name ? '当前套餐' : '切换到此套餐' }}
                </button>
              </div>
            </div>
          </div>
        </div>

        <div v-else-if="activeTab === 'statistics'" class="animate-fade-in">
          <StatisticsView />
        </div>

        <div v-else-if="activeTab === 'projects'" class="space-y-6 animate-fade-in">
          <div class="flex items-center justify-between mb-2">
            <h2 class="text-3xl font-bold bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">
              播客项目
            </h2>
            <button
              class="px-4 py-2 rounded-xl text-sm font-medium bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white hover:opacity-90"
              @click="showCreateProject = true"
            >
              新建项目
            </button>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div
              v-for="p in projectStore.projects"
              :key="p.id"
              class="rounded-2xl border-2 border-pink-200/60 bg-white p-6"
            >
              <div class="flex items-start justify-between mb-2">
                <div class="min-w-0 pr-2">
                  <div class="text-lg font-bold text-gray-900 truncate" :title="p.name">{{ p.name }}</div>
                  <div class="text-xs text-gray-500">类型：{{ p.podcastType || '未知' }}</div>
                </div>
                <div class="text-xs px-2 py-1 rounded bg-pink-100 text-pink-700">{{ p.status || 'draft' }}</div>
              </div>
              <div class="text-sm text-gray-600 mb-4 line-clamp-2">{{ p.description || '暂无描述' }}</div>
              <div class="flex items-center justify-end gap-3">
                <button class="px-3 py-1.5 text-sm rounded-lg border border-pink-200 hover:bg-pink-50" @click="router.push(`/projects/${p.id}`)">详情</button>
                <button class="px-3 py-1.5 text-sm rounded-lg border border-red-200 text-red-600 hover:bg-red-50" @click="removeProject(p.id)">删除</button>
              </div>
            </div>
            <div v-if="!projectStore.projects?.length" class="col-span-3 text-center text-gray-600 py-12">暂无项目，点击右上角“新建项目”开始你的创作</div>
          </div>
          <CreateProjectModal v-if="showCreateProject" @close="showCreateProject = false" @created="handleProjectCreated" />
        </div>

        <div v-else-if="activeTab === 'security'" class="space-y-6 animate-fade-in">
          <h2 class="text-3xl font-bold mb-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">账号安全</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <form @submit.prevent="handleChangePassword" class="rounded-2xl border-2 border-pink-200/60 bg-white p-6 space-y-4">
              <div class="text-lg font-bold text-gray-900">修改密码</div>
              <input v-model="securityForm.oldPassword" type="password" placeholder="旧密码" class="w-full px-4 py-3 bg-white border border-pink-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-pink-300" required />
              <input v-model="securityForm.newPassword" type="password" placeholder="新密码" class="w-full px-4 py-3 bg-white border border-pink-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-pink-300" required />
              <input v-model="securityForm.confirmPassword" type="password" placeholder="确认新密码" class="w-full px-4 py-3 bg-white border border-pink-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-pink-300" required />
              <div class="flex justify-end">
                <button type="submit" class="px-4 py-2 rounded-xl text-sm font-medium bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white hover:opacity-90">保存</button>
              </div>
            </form>
            <div class="rounded-2xl border-2 border-pink-200/60 bg-white p-6 space-y-4">
              <div class="text-lg font-bold text-gray-900">两步验证（2FA）</div>
              <div class="flex items-center justify-between">
                <div class="text-sm text-gray-600">增强账号安全，登录需额外验证码</div>
                <button @click="twoFAEnabled = !twoFAEnabled" class="w-12 h-6 rounded-full relative" :class="twoFAEnabled ? 'bg-pink-500' : 'bg-gray-300'">
                  <div class="w-5 h-5 bg-white rounded-full absolute top-0.5 transition-all" :class="twoFAEnabled ? 'left-6' : 'left-1'"></div>
                </button>
              </div>
              <div class="text-xs text-gray-500">当前状态：{{ twoFAEnabled ? '已开启' : '未开启' }}</div>
            </div>
          </div>
        </div>

        <div v-else-if="activeTab === 'settings'" class="space-y-6 animate-fade-in">
          <h2 class="text-3xl font-bold mb-4 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">偏好设置</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="rounded-2xl border-2 border-pink-200/60 bg-white p-6 space-y-4">
              <div class="text-lg font-bold text-gray-900">转写与字幕</div>
              <div class="flex items-center justify-between">
                <div class="text-sm text-gray-600">转写语言</div>
                <select v-model="prefs.transcriptLanguage" @change="savePreferences" class="px-3 py-2 border border-pink-200 rounded-lg">
                  <option value="zh">中文</option>
                  <option value="en">English</option>
                  <option value="ja">日本語</option>
                  <option value="es">Español</option>
                </select>
              </div>
              <div class="flex items-center justify-between">
                <div class="text-sm text-gray-600">自动生成字幕</div>
                <button @click="prefs.subtitleAutoGenerate = !prefs.subtitleAutoGenerate; savePreferences()" class="w-12 h-6 rounded-full relative" :class="prefs.subtitleAutoGenerate ? 'bg-pink-500' : 'bg-gray-300'">
                  <div class="w-5 h-5 bg-white rounded-full absolute top-0.5 transition-all" :class="prefs.subtitleAutoGenerate ? 'left-6' : 'left-1'"></div>
                </button>
              </div>
              <div class="flex items-center justify-between">
                <div class="text-sm text-gray-600">字幕语言</div>
                <select v-model="prefs.subtitleLanguage" @change="savePreferences" class="px-3 py-2 border border-pink-200 rounded-lg">
                  <option value="zh">中文</option>
                  <option value="en">English</option>
                </select>
              </div>
            </div>
            <div class="rounded-2xl border-2 border-pink-200/60 bg-white p-6 space-y-4">
              <div class="text-lg font-bold text-gray-900">智能剪辑</div>
              <div class="flex items-center justify-between">
                <div class="text-sm text-gray-600">目标片段时长（秒）</div>
                <input type="number" min="15" max="300" v-model.number="prefs.smartClipTargetLengthSec" @change="savePreferences" class="w-24 px-3 py-2 border border-pink-200 rounded-lg text-right" />
              </div>
              <div class="flex items-center justify-between">
                <div class="text-sm text-gray-600">只提取高光片段</div>
                <button @click="prefs.smartClipHighlightsOnly = !prefs.smartClipHighlightsOnly; savePreferences()" class="w-12 h-6 rounded-full relative" :class="prefs.smartClipHighlightsOnly ? 'bg-pink-500' : 'bg-gray-300'">
                  <div class="w-5 h-5 bg-white rounded-full absolute top-0.5 transition-all" :class="prefs.smartClipHighlightsOnly ? 'left-6' : 'left-1'"></div>
                </button>
              </div>
            </div>
            <div class="rounded-2xl border-2 border-pink-200/60 bg-white p-6 space-y-4">
              <div class="text-lg font-bold text-gray-900">音频优化</div>
              <div class="flex items-center justify-between">
                <div class="text-sm text-gray-600">降噪</div>
                <button @click="prefs.audioNoiseReduction = !prefs.audioNoiseReduction; savePreferences()" class="w-12 h-6 rounded-full relative" :class="prefs.audioNoiseReduction ? 'bg-pink-500' : 'bg-gray-300'">
                  <div class="w-5 h-5 bg-white rounded-full absolute top-0.5 transition-all" :class="prefs.audioNoiseReduction ? 'left-6' : 'left-1'"></div>
                </button>
              </div>
              <div class="flex items-center justify-between">
                <div class="text-sm text-gray-600">音量均衡</div>
                <button @click="prefs.audioLevelEqualize = !prefs.audioLevelEqualize; savePreferences()" class="w-12 h-6 rounded-full relative" :class="prefs.audioLevelEqualize ? 'bg-pink-500' : 'bg-gray-300'">
                  <div class="w-5 h-5 bg-white rounded-full absolute top-0.5 transition-all" :class="prefs.audioLevelEqualize ? 'left-6' : 'left-1'"></div>
                </button>
              </div>
            </div>
            <div class="rounded-2xl border-2 border-pink-200/60 bg-white p-6 space-y-4">
              <div class="text-lg font-bold text-gray-900">导出分发</div>
              <div class="flex items-center justify-between">
                <div class="text-sm text-gray-600">导出 MP3（播客）</div>
                <button @click="prefs.exportAudioMP3 = !prefs.exportAudioMP3; savePreferences()" class="w-12 h-6 rounded-full relative" :class="prefs.exportAudioMP3 ? 'bg-pink-500' : 'bg-gray-300'">
                  <div class="w-5 h-5 bg-white rounded-full absolute top-0.5 transition-all" :class="prefs.exportAudioMP3 ? 'left-6' : 'left-1'"></div>
                </button>
              </div>
              <div class="flex items-center justify-between">
                <div class="text-sm text-gray-600">导出 16:9（Bilibili/YouTube）</div>
                <button @click="prefs.exportVideo169 = !prefs.exportVideo169; savePreferences()" class="w-12 h-6 rounded-full relative" :class="prefs.exportVideo169 ? 'bg-pink-500' : 'bg-gray-300'">
                  <div class="w-5 h-5 bg-white rounded-full absolute top-0.5 transition-all" :class="prefs.exportVideo169 ? 'left-6' : 'left-1'"></div>
                </button>
              </div>
              <div class="flex items-center justify-between">
                <div class="text-sm text-gray-600">导出 9:16（抖音/Shorts）</div>
                <button @click="prefs.exportVideo916 = !prefs.exportVideo916; savePreferences()" class="w-12 h-6 rounded-full relative" :class="prefs.exportVideo916 ? 'bg-pink-500' : 'bg-gray-300'">
                  <div class="w-5 h-5 bg-white rounded-full absolute top-0.5 transition-all" :class="prefs.exportVideo916 ? 'left-6' : 'left-1'"></div>
                </button>
              </div>
            </div>
            <div class="rounded-2xl border-2 border-pink-200/60 bg-white p-6 space-y-4">
              <div class="text-lg font-bold text-gray-900">时间轴与编辑</div>
              <div class="flex items-center justify-between">
                <div class="text-sm text-gray-600">吸附到网格</div>
                <button @click="prefs.timelineSnap = !prefs.timelineSnap; savePreferences()" class="w-12 h-6 rounded-full relative" :class="prefs.timelineSnap ? 'bg-pink-500' : 'bg-gray-300'">
                  <div class="w-5 h-5 bg-white rounded-full absolute top-0.5 transition-all" :class="prefs.timelineSnap ? 'left-6' : 'left-1'"></div>
                </button>
              </div>
              <div class="flex items-center justify-between">
                <div class="text-sm text-gray-600">波纹编辑</div>
                <button @click="prefs.rippleEdit = !prefs.rippleEdit; savePreferences()" class="w-12 h-6 rounded-full relative" :class="prefs.rippleEdit ? 'bg-pink-500' : 'bg-gray-300'">
                  <div class="w-5 h-5 bg-white rounded-full absolute top-0.5 transition-all" :class="prefs.rippleEdit ? 'left-6' : 'left-1'"></div>
                </button>
              </div>
              <div class="flex items-center justify-between">
                <div class="text-sm text-gray-600">默认缩放</div>
                <input type="number" min="50" max="200" v-model.number="prefs.defaultZoomPercent" @change="savePreferences" class="w-24 px-3 py-2 border border-pink-200 rounded-lg text-right" />
              </div>
            </div>
            <div class="rounded-2xl border-2 border-pink-200/60 bg-white p-6 space-y-4">
              <div class="text-lg font-bold text-gray-900">其他</div>
              <div class="flex items-center justify-between">
                <div class="text-sm text-gray-600">默认 TTS 声线</div>
                <select v-model="prefs.ttsDefaultVoice" @change="savePreferences" class="px-3 py-2 border border-pink-200 rounded-lg">
                  <option value="female">Female</option>
                  <option value="male">Male</option>
                </select>
              </div>
              <div class="flex items-center justify-between">
                <div class="text-sm text-gray-600">添加水印</div>
                <button @click="prefs.watermarkEnabled = !prefs.watermarkEnabled; savePreferences()" class="w-12 h-6 rounded-full relative" :class="prefs.watermarkEnabled ? 'bg-pink-500' : 'bg-gray-300'">
                  <div class="w-5 h-5 bg-white rounded-full absolute top-0.5 transition-all" :class="prefs.watermarkEnabled ? 'left-6' : 'left-1'"></div>
                </button>
              </div>
            </div>
          </div>
        </div>

        <div v-else-if="activeTab === 'help'" class="space-y-6 animate-fade-in">
          <h2 class="text-3xl font-bold mb-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">帮助与支持</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="rounded-2xl border-2 border-pink-200/60 bg-white p-6">
              <div class="text-lg font-bold text-gray-900 mb-3">常见问题</div>
              <ul class="space-y-2 text-sm text-gray-700">
                <li>如何上传素材？在“素材管理”页面点击上传按钮。</li>
                <li>如何剪辑短视频？在“剪辑工作台”选择片段并导出。</li>
                <li>会员额度如何计算？按套餐每月剪辑时长统计。</li>
              </ul>
            </div>
            <form @submit.prevent="handleSupport" class="rounded-2xl border-2 border-pink-200/60 bg-white p-6 space-y-4">
              <div class="text-lg font-bold text-gray-900">联系支持</div>
              <input v-model="supportForm.subject" type="text" placeholder="问题主题" class="w-full px-4 py-3 bg-white border border-pink-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-pink-300" required />
              <textarea v-model="supportForm.message" rows="4" placeholder="问题描述" class="w-full px-4 py-3 bg-white border border-pink-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-pink-300" required></textarea>
              <div class="flex justify-end">
                <button type="submit" class="px-4 py-2 rounded-xl text-sm font-medium bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white hover:opacity-90">发送</button>
              </div>
            </form>
          </div>
        </div>
      </div>

      <!-- 编辑资料模态框 -->
      <div v-if="showEditModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50" @click.self="showEditModal = false">
        <div class="bg-white rounded-2xl p-6 max-w-md w-full mx-4">
          <h3 class="text-xl font-bold mb-4 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">编辑资料</h3>
          <form @submit.prevent="handleUpdateProfile" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">用户名</label>
              <input v-model="editForm.username" type="text" class="w-full px-4 py-2 border border-pink-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-pink-300" required />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">邮箱</label>
              <input v-model="editForm.email" type="email" class="w-full px-4 py-2 border border-pink-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-pink-300" required />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">手机号</label>
              <input v-model="editForm.phone" type="tel" class="w-full px-4 py-2 border border-pink-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-pink-300" />
            </div>
            <div class="flex gap-3 justify-end">
              <button type="button" @click="showEditModal = false" class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50">取消</button>
              <button type="submit" class="px-4 py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:opacity-90">保存</button>
            </div>
          </form>
        </div>
      </div>

      <!-- 训练向导模态框 -->
      <div v-if="showTrainingWizard" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50" @click.self="showTrainingWizard = false">
        <div class="bg-white rounded-2xl p-8 max-w-lg w-full mx-4">
          <!-- 步骤指示器 -->
          <div class="flex items-center justify-between mb-8">
            <div v-for="step in 3" :key="step" class="flex flex-col items-center">
              <div 
                class="w-10 h-10 rounded-full flex items-center justify-center text-lg font-bold mb-2 transition-all"
                :class="wizardStep >= step ? 'bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white' : 'bg-gray-200 text-gray-500'"
              >
                {{ step }}
              </div>
              <div 
                class="text-xs font-medium transition-all"
                :class="wizardStep >= step ? 'text-gray-900' : 'text-gray-400'"
              >
                {{ step === 1 ? '权利确认' : step === 2 ? '活体校验' : '训练中' }}
              </div>
            </div>
          </div>

          <!-- 步骤 1: 权利确认 -->
          <div v-if="wizardStep === 1" class="space-y-6">
            <h3 class="text-2xl font-bold text-gray-900">权利确认</h3>
            <p class="text-gray-600 text-sm">为了保护用户权益，我们需要您确认以下声明：</p>
            
            <div class="p-4 bg-gray-50 rounded-xl border border-gray-100">
              <div class="flex items-start gap-3">
                <input 
                  type="checkbox" 
                  v-model="rightsConfirmed"
                  class="w-5 h-5 text-pink-600 focus:ring-pink-500 rounded"
                />
                <div class="flex-1">
                  <p class="text-sm text-gray-700">
                    我确认录音素材为本人声音，且已获得相关权利授权。我承诺不会使用他人声音进行训练，否则将承担相应法律责任。
                  </p>
                </div>
              </div>
            </div>
          </div>

          <!-- 步骤 2: 活体校验 -->
          <div v-if="wizardStep === 2" class="space-y-6">
            <h3 class="text-2xl font-bold text-gray-900">活体校验</h3>
            <p class="text-gray-600 text-sm">请朗读以下文本，证明您对该声音拥有控制权：</p>
            
            <div class="p-6 bg-gradient-to-br from-pink-50 to-purple-50 rounded-xl border border-pink-100 text-center">
              <p class="text-lg font-medium text-gray-900 mb-4">"{{ verificationText }}"</p>
            </div>
            
            <!-- 录音按钮 -->
            <div class="flex justify-center">
              <button 
                @click="toggleRecording"
                class="w-24 h-24 rounded-full flex items-center justify-center flex-col transition-all"
                :class="isRecording ? 'bg-red-500 text-white' : 'bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white'"
              >
                <svg class="w-8 h-8 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path v-if="!isRecording" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" />
                  <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-.333-1.667-.333-2.43 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
                <span v-if="!isRecording" class="text-sm font-medium">开始录音</span>
                <span v-else class="text-sm font-medium">停止录音</span>
                <span v-if="isRecording" class="text-xs mt-1">{{ recordingSeconds }}s</span>
              </button>
            </div>
            
            <div v-if="verificationCompleted" class="p-4 bg-green-50 rounded-xl border border-green-100 flex items-center gap-3">
              <svg class="w-5 h-5 text-green-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
              <div>
                <p class="text-sm font-medium text-green-700">录音完成</p>
                <p class="text-xs text-green-600">录制时长: {{ recordingSeconds }}秒</p>
              </div>
            </div>
          </div>

          <!-- 步骤 3: 训练中 -->
          <div v-if="wizardStep === 3" class="space-y-6">
            <h3 class="text-2xl font-bold text-gray-900">正在训练</h3>
            <p class="text-gray-600 text-sm">模型训练中，请耐心等待...</p>
            
            <div class="p-6 bg-gray-50 rounded-xl border border-gray-100">
              <div class="flex items-center justify-between mb-3">
                <span class="text-sm font-medium text-gray-700">{{ trainingStatusText }}</span>
                <span class="text-sm font-bold text-pink-600">{{ trainingProgress }}%</span>
              </div>
              <div class="h-3 bg-gray-200 rounded-full overflow-hidden">
                <div 
                  class="h-full bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] transition-all duration-300" 
                  :style="{ width: trainingProgress + '%' }"
                ></div>
              </div>
            </div>
          </div>

          <!-- 底部按钮 -->
          <div class="mt-8 flex items-center justify-between">
            <button 
              v-if="wizardStep > 1"
              @click="prevStep"
              class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 text-gray-700"
            >
              上一步
            </button>
            <div v-else class="w-20"></div>
            
            <div class="flex gap-3">
              <button 
                v-if="wizardStep === 2"
                @click="skipVerification"
                class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 text-gray-700"
              >
                跳过此步骤
              </button>
              
              <button 
                @click="nextStep"
                :disabled="wizardStep === 3"
                class="px-6 py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {{ wizardStep === 3 ? '训练中...' : '下一步' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useUserStore } from '../../stores/user'
import { useProjectStore } from '../../stores/project'
import { useRouter } from 'vue-router'
import dayjs from 'dayjs'
import CreateProjectModal from '../../components/CreateProjectModal.vue'
import StatisticsView from './StatisticsView.vue'
import api from '../../services/api'

const router = useRouter()
const userStore = useUserStore()
const projectStore = useProjectStore()

const tabs = [
  { key: 'basic', label: '基本信息', icon: '👤' },
  { key: 'voice-clone', label: '训练音色', icon: '🎙️' },
  { key: 'membership', label: '会员中心', icon: '⭐' },
  { key: 'statistics', label: '数据统计', icon: '📊' },
  { key: 'projects', label: '播客项目', icon: '📁' },
  { key: 'security', label: '账号安全', icon: '🔒' },
  { key: 'settings', label: '偏好设置', icon: '⚙️' },
  { key: 'help', label: '帮助支持', icon: '❓' },
]

const activeTab = ref('basic')
const showCreateProject = ref(false)
const showEditModal = ref(false)
const securityForm = ref({ oldPassword: '', newPassword: '', confirmPassword: '' })
const twoFAEnabled = ref(false)
const isTraining = ref(false)
const trainingProgress = ref(0)
const trainingStatusText = ref('未开始')
const voiceHistory = ref([
  { id: 1, name: '我的默认音色', date: '2024-01-20', status: '已完成' },
  { id: 2, name: '专业播报音色', date: '2024-01-15', status: '已完成' }
])

// 训练向导状态
const showTrainingWizard = ref(false)
const wizardStep = ref(1) // 1: 权利确认, 2: 活体校验, 3: 训练中
const rightsConfirmed = ref(false)
const isRecording = ref(false)
const recordingSeconds = ref(0)
const verificationText = ref('PodPal 记录我的每一次发声')
const verificationCompleted = ref(false)

const startTraining = () => {
  showTrainingWizard.value = true
  wizardStep.value = 1
  rightsConfirmed.value = false
  verificationCompleted.value = false
  isRecording.value = false
  recordingSeconds.value = 0
}

const nextStep = () => {
  if (wizardStep.value === 1) {
    if (!rightsConfirmed.value) {
      alert('请确认权利声明')
      return
    }
    wizardStep.value = 2
  } else if (wizardStep.value === 2) {
    if (!verificationCompleted.value) {
      alert('请完成活体校验')
      return
    }
    startTrainingProcess()
  }
}

const prevStep = () => {
  if (wizardStep.value > 1) {
    wizardStep.value--
  }
}

const toggleRecording = () => {
  isRecording.value = !isRecording.value
  if (isRecording.value) {
    recordingSeconds.value = 0
    const interval = setInterval(() => {
      if (isRecording.value) {
        recordingSeconds.value++
      } else {
        clearInterval(interval)
      }
    }, 1000)
  } else {
    // 模拟录音完成
    verificationCompleted.value = true
  }
}

const startTrainingProcess = () => {
  wizardStep.value = 3
  isTraining.value = true
  trainingProgress.value = 0
  trainingStatusText.value = '准备中...'
  
  const interval = setInterval(() => {
    trainingProgress.value += Math.floor(Math.random() * 10) + 5
    
    if (trainingProgress.value < 30) {
      trainingStatusText.value = '上传音频中...'
    } else if (trainingProgress.value < 70) {
      trainingStatusText.value = '模型训练中...'
    } else if (trainingProgress.value < 100) {
      trainingStatusText.value = '音色生成中...'
    }
    
    if (trainingProgress.value >= 100) {
      trainingProgress.value = 100
      trainingStatusText.value = '训练完成'
      isTraining.value = false
      clearInterval(interval)
      
      // 添加到历史记录
      voiceHistory.value.unshift({
        id: Date.now(),
        name: `新训练音色_${dayjs().format('MMDD')}`,
        date: dayjs().format('YYYY-MM-DD'),
        status: '已完成'
      })
      
      // 关闭向导
      setTimeout(() => {
        showTrainingWizard.value = false
      }, 1000)
    }
  }, 500)
}

const skipVerification = () => {
  verificationCompleted.value = true
  nextStep()
}

const supportForm = ref({ subject: '', message: '' })
const editForm = ref({
  username: '',
  email: '',
  phone: ''
})
const prefs = ref({
  theme: userStore.preferences?.theme || 'dark',
  language: userStore.preferences?.language || 'zh',
  autoSave: userStore.preferences?.autoSave ?? true,
  emailNotify: userStore.preferences?.emailNotify ?? false,
  transcriptLanguage: userStore.preferences?.transcriptLanguage || 'zh',
  subtitleAutoGenerate: userStore.preferences?.subtitleAutoGenerate ?? true,
  subtitleLanguage: userStore.preferences?.subtitleLanguage || 'zh',
  smartClipTargetLengthSec: userStore.preferences?.smartClipTargetLengthSec ?? 60,
  smartClipHighlightsOnly: userStore.preferences?.smartClipHighlightsOnly ?? true,
  audioNoiseReduction: userStore.preferences?.audioNoiseReduction ?? true,
  audioLevelEqualize: userStore.preferences?.audioLevelEqualize ?? true,
  exportAudioMP3: userStore.preferences?.exportAudioMP3 ?? true,
  exportVideo169: userStore.preferences?.exportVideo169 ?? true,
  exportVideo916: userStore.preferences?.exportVideo916 ?? true,
  timelineSnap: userStore.preferences?.timelineSnap ?? true,
  rippleEdit: userStore.preferences?.rippleEdit ?? true,
  defaultZoomPercent: userStore.preferences?.defaultZoomPercent ?? 100,
  ttsDefaultVoice: userStore.preferences?.ttsDefaultVoice || 'female',
  watermarkEnabled: userStore.preferences?.watermarkEnabled ?? false
})

const setActiveTab = (key) => {
  activeTab.value = key
  if (key === 'projects') {
    projectStore.fetchProjects()
  }
  if (key === 'statistics') {
    projectStore.fetchProjects()
  }
  if (key === 'basic' && showEditModal.value) {
    showEditModal.value = false
  }
}

const getMembershipTypeColor = (type) => {
  const colorMap = {
    '免费版': 'text-gray-600',
    '基础会员': 'text-blue-500',
    '专业会员': 'text-purple-500',
    '团队会员': 'text-amber-500'
  }
  return colorMap[type] || 'text-gray-600'
}

const plans = [
  { name: '免费版', price: '¥0', minutes: 60, features: ['基础剪辑功能', '社区支持'] },
  { name: '基础会员', price: '¥29', minutes: 300, features: ['智能剪辑', '导出分发', '优先支持'] },
  { name: '专业会员', price: '¥99', minutes: 1200, features: ['多角色TTS', '多平台内容生成', '协作权限'] },
  { name: '团队会员', price: '¥299', minutes: 3000, features: ['团队协作', '商用资源库', '批量分发'] }
]

const currentPlanMinutes = computed(() => {
  const name = userStore.user?.membershipType || '免费版'
  const found = plans.find(p => p.name === name)
  return found ? found.minutes : 300
})

const monthlyClipMinutes = computed(() => userStore.usage?.monthlyClipMinutes || currentPlanMinutes.value)
const usedClipMinutes = computed(() => userStore.usage?.usedClipMinutes || 0)
const clipPercent = computed(() => {
  const total = monthlyClipMinutes.value || 1
  const used = Math.min(usedClipMinutes.value, total)
  return Math.round((used / total) * 100)
})
const projectsCount = computed(() => projectStore.projects?.length || 0)

// 用户统计数据
const userStats = ref({
  videosCreated: 24,
  videosCreatedThisMonth: 8,
  onlineHours: 156.5,
  onlineHoursThisWeek: 12.5,
  clipMinutes: 480,
  clipMinutesThisMonth: 120,
  activeProjects: 3
})

// 使用趋势数据（最近7天）
const usageTrend = ref([
  { date: '周一', clipMinutes: 45, videos: 2 },
  { date: '周二', clipMinutes: 30, videos: 1 },
  { date: '周三', clipMinutes: 60, videos: 3 },
  { date: '周四', clipMinutes: 20, videos: 1 },
  { date: '周五', clipMinutes: 50, videos: 2 },
  { date: '周六', clipMinutes: 80, videos: 4 },
  { date: '周日', clipMinutes: 40, videos: 2 }
])

const maxClipMinutes = computed(() => {
  return Math.max(...usageTrend.value.map(d => d.clipMinutes), 1)
})

// 成就徽章
const userBadges = ref([
  { id: 1, name: '初出茅庐', description: '创建第一个项目', icon: '🌱', unlocked: true },
  { id: 2, name: '剪辑达人', description: '累计剪辑100分钟', icon: '✂️', unlocked: true },
  { id: 3, name: '视频创作者', description: '生成10个视频', icon: '🎬', unlocked: true },
  { id: 4, name: '资深播客', description: '在线时长超过100小时', icon: '⏱️', unlocked: true },
  { id: 5, name: '内容大师', description: '生成50个视频', icon: '🏆', unlocked: false },
  { id: 6, name: '连续创作', description: '连续7天使用平台', icon: '🔥', unlocked: false }
])

// 格式化小时数
const formatHours = (hours) => {
  const h = Math.floor(hours)
  const m = Math.round((hours - h) * 60)
  if (h > 0) {
    return `${h}小时${m > 0 ? m + '分' : ''}`
  }
  return `${m}分钟`
}

const recentProjects = computed(() => {
  if (!projectStore.projects?.length) return []
  return [...projectStore.projects]
    .sort((a, b) => new Date(b.updatedAt || b.createdAt) - new Date(a.updatedAt || a.createdAt))
    .slice(0, 5)
})

const changePlan = (plan) => {
  userStore.setMembershipType(plan.name)
  userStore.updateUsage({ monthlyClipMinutes: plan.minutes })
}

const handleProjectCreated = async () => {
  showCreateProject.value = false
  await projectStore.fetchProjects()
}

const removeProject = async (id) => {
  await projectStore.deleteProject(id)
}

const handleChangePassword = async () => {
  if (securityForm.value.newPassword !== securityForm.value.confirmPassword) {
    alert('两次输入的新密码不一致')
    return
  }
  try {
    await api.post('/auth/change-password', {
      oldPassword: securityForm.value.oldPassword,
      newPassword: securityForm.value.newPassword
    })
    alert('密码已更新')
    securityForm.value = { oldPassword: '', newPassword: '', confirmPassword: '' }
  } catch (e) {
    alert('模拟环境：已保存密码表单')
    securityForm.value = { oldPassword: '', newPassword: '', confirmPassword: '' }
  }
}

const savePreferences = () => {
  userStore.setPreferences({ ...prefs.value })
}

const handleSupport = () => {
  const subject = encodeURIComponent(supportForm.value.subject)
  const body = encodeURIComponent(supportForm.value.message)
  window.open(`mailto:support@podpal.local?subject=${subject}&body=${body}`)
  supportForm.value = { subject: '', message: '' }
  alert('支持请求已发送！')
}

const handleUpdateProfile = async () => {
  try {
    // 更新用户信息
    if (userStore.user) {
      userStore.user = {
        ...userStore.user,
        username: editForm.value.username,
        email: editForm.value.email,
        phone: editForm.value.phone
      }
      localStorage.setItem('user', JSON.stringify(userStore.user))
      alert('资料已更新')
      showEditModal.value = false
    }
  } catch (e) {
    alert('更新失败，请重试')
  }
}

onMounted(async () => {
  if (!userStore.user) {
    await userStore.fetchUserInfo()
  }
  if (!projectStore.projects?.length) {
    await projectStore.fetchProjects()
  }
  // 初始化编辑表单
  if (userStore.user) {
    editForm.value = {
      username: userStore.user.username || '',
      email: userStore.user.email || '',
      phone: userStore.user.phone || ''
    }
  }
})
</script>

<style scoped>
@keyframes fade-in {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade-in {
  animation: fade-in 0.3s ease-out;
}

.info-card {
  @apply bg-white rounded-xl p-4 border border-pink-200/60 hover:border-pink-300 transition-all duration-300 hover:shadow-lg hover:shadow-pink-200/50;
}

.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}

.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
</style>
