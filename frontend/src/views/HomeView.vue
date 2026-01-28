<script setup>
import { useRouter, RouterLink } from 'vue-router'
import { useUserStore } from '../stores/user'
import firstImage from '../assets/first.png'
import secondImage from '../assets/second.png'
import thirdImage from '../assets/third.png'

const router = useRouter()
const userStore = useUserStore()

const handleEnterFeature = (route) => {
  if (userStore.isAuthenticated) {
    router.push(route)
  } else {
    router.push('/login')
  }
}
</script>

<template>
  <div class="min-h-screen bg-white flex flex-col">
    <!-- 顶部横幅 -->
    <div class="container mx-auto max-w-7xl px-6 pt-24 mb-6">
      <div class="glass-card rounded-2xl p-8 md:p-12 bg-gradient-to-br from-pink-50/50 to-purple-50/50 border-2 border-pink-200/60">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 items-center">
          <div>
            <h1 class="text-4xl md:text-5xl font-bold mb-4 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">播客深度剪辑系统</h1>
            <p class="text-gray-600 mb-6">一站式完成策划、剪辑、优化与分发，让创作更高效。</p>
            <div class="flex flex-wrap gap-3">
              <RouterLink to="/clip-studio" class="px-6 py-3 rounded-xl bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white font-bold hover:shadow-lg hover:scale-105 transition">立即开始剪辑</RouterLink>
              <RouterLink to="/materials" class="px-6 py-3 rounded-xl bg-white border-2 border-pink-200/60 text-pink-700 hover:bg-pink-50 transition">上传素材</RouterLink>
              <RouterLink to="/register" class="px-6 py-3 rounded-xl bg-white border-2 border-pink-200/60 text-pink-700 hover:bg-pink-50 transition">注册账号</RouterLink>
            </div>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div class="rounded-xl p-4 bg-gradient-to-br from-pink-50 to-pink-100 border-2 border-pink-200/60">
              <div class="text-2xl">✨</div>
              <div class="mt-2 text-gray-900 font-semibold">智能剪辑</div>
              <div class="text-sm text-gray-600">自动提取高光片段</div>
            </div>
            <div class="rounded-xl p-4 bg-gradient-to-br from-purple-50 to-purple-100 border-2 border-purple-200/60">
              <div class="text-2xl">🎙️</div>
              <div class="mt-2 text-gray-900 font-semibold">音频优化</div>
              <div class="text-sm text-gray-600">降噪与音量均衡</div>
            </div>
            <div class="rounded-xl p-4 bg-gradient-to-br from-orange-50 to-orange-100 border-2 border-orange-200/60">
              <div class="text-2xl">📝</div>
              <div class="mt-2 text-gray-900 font-semibold">转写字幕</div>
              <div class="text-sm text-gray-600">多语言精准转写</div>
            </div>
            <div class="rounded-xl p-4 bg-gradient-to-br from-cyan-50 to-cyan-100 border-2 border-cyan-200/60">
              <div class="text-2xl">📤</div>
              <div class="mt-2 text-gray-900 font-semibold">多平台导出</div>
              <div class="text-sm text-gray-600">一键适配比例</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="container mx-auto max-w-7xl px-6 flex-1 flex items-center">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-8 md:gap-10 items-stretch justify-center">
        <!-- 播客策划室 - 暂时注释掉 -->
        <!-- 
        <div class="glass-card rounded-2xl p-8 md:p-10 hover:shadow-xl hover:-translate-y-1 transition-all duration-300 cursor-pointer group border-2 border-pink-300/60 bg-gradient-to-br from-pink-50 to-pink-100 flex flex-col shadow-lg">
          <div class="mb-6">
            <h2 class="text-2xl font-bold bg-gradient-to-r from-[#FF6B9D] to-[#FF8FAB] bg-clip-text text-transparent mb-3 flex items-center gap-2">
              <span class="text-3xl">💡</span>
              播客策划室
            </h2>
            <p class="text-gray-600 leading-relaxed text-sm">
              输入播客核心信息，AI助你一键生成专业策划方案。
            </p>
          </div>
          
          <div class="mb-8 h-40 flex items-center justify-center">
            <img :src="firstImage" alt="播客策划流程" class="h-full w-auto object-contain" />
          </div>
          
          <button
            @click="handleEnterFeature('/projects?action=create')"
            class="w-full py-3 bg-gradient-to-r from-[#FF6B9D] to-[#FF8FAB] text-white rounded-xl hover:shadow-lg hover:scale-105 transition-all font-bold mt-auto"
          >
            进入策划室
          </button>
        </div>
        -->

        <!-- 播客剪辑 -->
        <div class="glass-card rounded-2xl p-8 md:p-10 hover:shadow-xl hover:-translate-y-1 transition-all duration-300 cursor-pointer group border-2 border-orange-300/60 bg-gradient-to-br from-orange-50 to-orange-100 flex flex-col shadow-lg">
          <div class="mb-6">
            <h2 class="text-2xl font-bold bg-gradient-to-r from-[#FFB347] to-[#FFC875] bg-clip-text text-transparent mb-3 flex items-center gap-2">
              <span class="text-3xl">✂️</span>
              播客剪辑
            </h2>
            <p class="text-gray-600 leading-relaxed text-sm">
              让音频剪辑，像排版一样自然。
            </p>
          </div>
          
          <div class="mb-8 h-40 flex items-center justify-center">
            <img :src="secondImage" alt="播客剪辑" class="h-full w-auto object-contain" />
          </div>
          
          <button
            @click="handleEnterFeature('/clip-studio')"
            class="w-full py-3 bg-gradient-to-r from-[#FFB347] to-[#FFC875] text-white rounded-xl hover:shadow-lg hover:scale-105 transition-all font-bold mt-auto"
          >
            进入剪辑
          </button>
        </div>

        <!-- 内容增值工具 -->
        <div class="glass-card rounded-2xl p-8 md:p-10 hover:shadow-xl hover:-translate-y-1 transition-all duration-300 cursor-pointer group border-2 border-purple-300/60 bg-gradient-to-br from-purple-50 to-purple-100 flex flex-col shadow-lg">
          <div class="mb-6">
            <h2 class="text-2xl font-bold bg-gradient-to-r from-[#C084FC] to-[#D8B4FE] bg-clip-text text-transparent mb-3 flex items-center gap-2">
              <span class="text-3xl">🎨</span>
              内容增值
            </h2>
            <p class="text-gray-600 leading-relaxed text-sm">
              为播客创作者打造的频道运营工具，帮助每个创作者以更高效率持续表达。
            </p>
          </div>
          
          <div class="mb-8 h-40 flex items-center justify-center">
            <img :src="thirdImage" alt="内容增值" class="h-full w-auto object-contain" />
          </div>
          
          <button
            @click="handleEnterFeature('/tools')"
            class="w-full py-3 bg-gradient-to-r from-[#C084FC] to-[#D8B4FE] text-white rounded-xl hover:shadow-lg hover:scale-105 transition-all font-bold mt-auto"
          >
            进入工具
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
