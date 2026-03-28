<template>
  <div class="min-h-screen bg-white pt-24 pb-12 px-6">
    <div class="container mx-auto max-w-7xl">
      <div class="mb-8">
        <h1 class="text-3xl font-bold bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent mb-2">工具箱</h1>
        <p class="text-gray-600">使用辅助工具提升创作效率</p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- 音频裁剪：跳转剪辑工作台（Clip Studio） -->
        <button
          type="button"
          class="glass-card rounded-xl p-6 text-left cursor-pointer hover:scale-105 transition-transform hover:shadow-lg bg-[#FF6B9D] text-white border-2 border-pink-200/60 focus:outline-none focus:ring-2 focus:ring-pink-300"
          @click="handleToolClick('audio-cut')"
        >
          <div class="flex items-center gap-4 mb-4">
            <div class="w-12 h-12 bg-[#FF6B9D] rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.121 14.121L19 19m-7-7l7-7m-7 7l-2.879 2.879M12 12L9.121 9.121m0 5.758a3 3 0 10-4.243 4.243 3 3 0 004.243-4.243zm0-5.758a3 3 0 10-4.243-4.243 3 3 0 004.243 4.243z" />
              </svg>
            </div>
            <div>
              <h3 class="text-lg font-semibold text-gray-900">音频裁剪</h3>
              <p class="text-xs text-pink-600 mt-1">打开剪辑工作台 · 时间线视图</p>
            </div>
          </div>
          <p class="text-sm text-gray-600">快速裁剪、拼接音频片段，在时间轴上精细调整内容。</p>
        </button>

        <!-- 格式转换：跳转编辑器的导出分发页 -->
        <button
          type="button"
          class="glass-card rounded-xl p-6 text-left cursor-pointer hover:scale-105 transition-transform hover:shadow-lg bg-[#FF6B9D] text-white border-2 border-pink-200/60 focus:outline-none focus:ring-2 focus:ring-pink-300"
          @click="handleToolClick('format-convert')"
        >
          <div class="flex items-center gap-4 mb-4">
            <div class="w-12 h-12 bg-orange-400 rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
            </div>
            <div>
              <h3 class="text-lg font-semibold text-gray-900">格式转换</h3>
              <p class="text-xs text-orange-600 mt-1">跳转到导出分发 · 格式设置</p>
            </div>
          </div>
          <p class="text-sm text-gray-600">在导出分发页面统一设置音频 / 视频 / 文本的导出格式和质量。</p>
        </button>

        <!-- 字幕编辑：跳转编辑器转写文本页 -->
        <button
          type="button"
          class="glass-card rounded-xl p-6 text-left cursor-pointer hover:scale-105 transition-transform hover:shadow-lg bg-[#FF6B9D] text-white border-2 border-pink-200/60 focus:outline-none focus:ring-2 focus:ring-pink-300"
          @click="handleToolClick('subtitle-edit')"
        >
          <div class="flex items-center gap-4 mb-4">
            <div class="w-12 h-12 bg-purple-400 rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
            </div>
            <div>
              <h3 class="text-lg font-semibold text-gray-900">字幕编辑</h3>
              <p class="text-xs text-purple-600 mt-1">跳转到编辑器 · 转写文本</p>
            </div>
          </div>
          <p class="text-sm text-gray-600">在转写文本页中精细修改字幕内容、时间轴及说话人信息。</p>
        </button>

        <!-- 背景音乐：跳转素材库 BGM 管理 -->
        <button
          type="button"
          class="glass-card rounded-xl p-6 text-left cursor-pointer hover:scale-105 transition-transform hover:shadow-lg bg-[#FF6B9D] text-white border-2 border-pink-200/60 focus:outline-none focus:ring-2 focus:ring-pink-300"
          @click="handleToolClick('bgm')"
        >
          <div class="flex items-center gap-4 mb-4">
            <div class="w-12 h-12 bg-cyan-400 rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" />
              </svg>
            </div>
            <div>
              <h3 class="text-lg font-semibold text-gray-900">背景音乐</h3>
              <p class="text-xs text-cyan-600 mt-1">跳转到素材库 · 背景音乐</p>
            </div>
          </div>
          <p class="text-sm text-gray-600">在素材管理中统一管理、预览并添加背景音乐到项目中。</p>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'

// 工具箱页面，展示各种辅助工具，并跳转到对应功能页
const router = useRouter()

const handleToolClick = (key) => {
  switch (key) {
    case 'audio-cut':
      // 音频裁剪 -> 剪辑工作台（时间线）
      router.push({ name: 'clip-studio' })
      break
    case 'format-convert':
      // 格式转换 -> 编辑器导出分发页
      router.push({ name: 'editor', query: { tab: 'export' } })
      break
    case 'subtitle-edit':
      // 字幕编辑 -> 编辑器转写文本页
      router.push({ name: 'editor', query: { tab: 'transcript' } })
      break
    case 'bgm':
      // 背景音乐 -> 素材管理页
      router.push({ name: 'materials' })
      break
  }
}
</script>

