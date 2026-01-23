<script setup>
import { ref } from 'vue'

const tabs = [
  { key: 'basic', label: '基本信息' },
  { key: 'projects', label: '播客项目' },
  { key: 'settings', label: '偏好设置' },
]

const activeTab = ref('basic')

const setActiveTab = (key) => {
  activeTab.value = key
}
</script>

<template>
  <section class="pt-32 pb-20 px-6">
    <div class="container mx-auto text-white">
      <h1 class="text-4xl font-bold mb-6">个人中心</h1>

      <!-- 顶部标签切换 -->
      <div class="flex gap-4 mb-8 border-b border-[#485F88]/60 pb-2">
        <button
          v-for="tab in tabs"
          :key="tab.key"
          type="button"
          class="px-3 py-1 text-sm font-medium rounded-full transition-all duration-200"
          :class="
            activeTab === tab.key
              ? 'bg-[#485F88] text-white shadow'
              : 'text-[#9DACCC] hover:text-white hover:bg-[#384C65]'
          "
          @click="setActiveTab(tab.key)"
        >
          {{ tab.label }}
        </button>
      </div>

      <!-- 内容区域：根据当前标签切换展示 -->
      <div class="glass-card rounded-2xl p-6 md:p-8">
        <!-- 基本信息 -->
        <div v-if="activeTab === 'basic'" class="space-y-4">
          <h2 class="text-2xl font-semibold mb-2">基本信息</h2>
          <p class="text-sm text-[#9DACCC] mb-4">
            这里可以展示当前登录用户的基础资料，比如昵称、邮箱、账号状态等。后续你可以接入后端接口来填充真实数据。
          </p>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
            <div>
              <div class="text-[#9DACCC]">昵称</div>
              <div class="text-white mt-1">播客创作者 A</div>
            </div>
            <div>
              <div class="text-[#9DACCC]">邮箱</div>
              <div class="text-white mt-1">creator@example.com</div>
            </div>
            <div>
              <div class="text-[#9DACCC]">账号类型</div>
              <div class="text-white mt-1">试用版</div>
            </div>
            <div>
              <div class="text-[#9DACCC]">创建时间</div>
              <div class="text-white mt-1">2026-01-01</div>
            </div>
          </div>
        </div>

        <!-- 播客项目 -->
        <div v-else-if="activeTab === 'projects'" class="space-y-4">
          <h2 class="text-2xl font-semibold mb-2">播客项目</h2>
          <p class="text-sm text-[#9DACCC] mb-4">
            这里可以列出最近处理的播客项目，展示剪辑进度、时长、最后更新时间等。
          </p>
          <div class="space-y-3">
            <div
              class="flex items-center justify-between rounded-xl border border-[#485F88]/60 px-4 py-3 bg-black/20"
            >
              <div>
                <div class="font-medium">《从 0 到 1 搭建播客工作流》</div>
                <div class="text-xs text-[#9DACCC] mt-1">上次编辑：2 小时前 · 时长 42:18</div>
              </div>
              <span
                class="text-xs px-2 py-1 rounded-full bg-emerald-500/20 text-emerald-300 border border-emerald-500/40"
              >
                剪辑完成
              </span>
            </div>

            <div
              class="flex items-center justify-between rounded-xl border border-[#485F88]/60 px-4 py-3 bg-black/20"
            >
              <div>
                <div class="font-medium">《深度访谈 · AI 与内容创作》</div>
                <div class="text-xs text-[#9DACCC] mt-1">上次编辑：1 天前 · 时长 58:03</div>
              </div>
              <span
                class="text-xs px-2 py-1 rounded-full bg-amber-500/20 text-amber-300 border border-amber-500/40"
              >
                剪辑中
              </span>
            </div>
          </div>
        </div>

        <!-- 偏好设置 -->
        <div v-else-if="activeTab === 'settings'" class="space-y-4">
          <h2 class="text-2xl font-semibold mb-2">偏好设置</h2>
          <p class="text-sm text-[#9DACCC] mb-4">
            这里可以配置默认语言、剪辑风格偏好等，当前展示的是示例占位内容。
          </p>
          <div class="space-y-3 text-sm">
            <div class="flex items-center justify-between">
              <div>
                <div class="text-white">默认剪辑风格</div>
                <div class="text-xs text-[#9DACCC] mt-1">更多保留对话节奏与情绪</div>
              </div>
              <span class="text-xs px-2 py-1 rounded-full bg-[#485F88] text-white">陪伴型</span>
            </div>
            <div class="flex items-center justify-between">
              <div>
                <div class="text-white">导出格式</div>
                <div class="text-xs text-[#9DACCC] mt-1">音频 + 时间轴标注（JSON）</div>
              </div>
              <span class="text-xs px-2 py-1 rounded-full bg-[#384C65] text-[#C0C9DB]">MP3 / WAV</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
