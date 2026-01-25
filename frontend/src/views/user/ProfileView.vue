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
            <button class="px-5 py-2.5 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-xl hover:shadow-lg hover:scale-105 transition-all duration-300 text-sm font-medium shadow-lg shadow-pink-300/50">
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

        <!-- 其他标签页内容（简化版，可根据需要扩展） -->
        <div v-else-if="activeTab === 'membership'" class="space-y-6 animate-fade-in">
          <h2 class="text-3xl font-bold mb-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">
            会员中心
          </h2>
          <p class="text-gray-600">会员功能开发中...</p>
        </div>

        <div v-else-if="activeTab === 'statistics'" class="space-y-6 animate-fade-in">
          <h2 class="text-3xl font-bold mb-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">
            数据统计
          </h2>
          <p class="text-gray-600">数据统计功能开发中...</p>
        </div>

        <div v-else-if="activeTab === 'projects'" class="space-y-6 animate-fade-in">
          <h2 class="text-3xl font-bold mb-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">
            播客项目
          </h2>
          <p class="text-gray-600">项目列表功能开发中...</p>
        </div>

        <div v-else-if="activeTab === 'security'" class="space-y-6 animate-fade-in">
          <h2 class="text-3xl font-bold mb-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">
            账号安全
          </h2>
          <p class="text-gray-600">安全设置功能开发中...</p>
        </div>

        <div v-else-if="activeTab === 'settings'" class="space-y-6 animate-fade-in">
          <h2 class="text-3xl font-bold mb-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">
            偏好设置
          </h2>
          <p class="text-gray-600">偏好设置功能开发中...</p>
        </div>

        <div v-else-if="activeTab === 'help'" class="space-y-6 animate-fade-in">
          <h2 class="text-3xl font-bold mb-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">
            帮助与支持
          </h2>
          <p class="text-gray-600">帮助支持功能开发中...</p>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '../../stores/user'
import { useProjectStore } from '../../stores/project'
import { useRouter } from 'vue-router'
import dayjs from 'dayjs'

const router = useRouter()
const userStore = useUserStore()
const projectStore = useProjectStore()

const tabs = [
  { key: 'basic', label: '基本信息', icon: '👤' },
  { key: 'membership', label: '会员中心', icon: '⭐' },
  { key: 'statistics', label: '数据统计', icon: '📊' },
  { key: 'projects', label: '播客项目', icon: '📁' },
  { key: 'security', label: '账号安全', icon: '🔒' },
  { key: 'settings', label: '偏好设置', icon: '⚙️' },
  { key: 'help', label: '帮助支持', icon: '❓' },
]

const activeTab = ref('basic')

const setActiveTab = (key) => {
  activeTab.value = key
  if (key === 'projects') {
    projectStore.fetchProjects()
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

onMounted(async () => {
  if (!userStore.user) {
    await userStore.fetchUserInfo()
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
