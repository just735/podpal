<script setup>
import { useRouter } from 'vue-router'
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

    <!-- 主要内容区域 -->
    <div class="container mx-auto max-w-7xl px-6 flex-1 flex items-center">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-8 items-stretch">
        <!-- 播客策划室 -->
        <div class="glass-card rounded-2xl p-8 hover:shadow-xl hover:-translate-y-1 transition-all duration-300 cursor-pointer group border-2 border-pink-300/60 bg-gradient-to-br from-pink-50 to-pink-100 flex flex-col shadow-lg">
          <div class="mb-6">
            <h2 class="text-2xl font-bold bg-gradient-to-r from-[#FF6B9D] to-[#FF8FAB] bg-clip-text text-transparent mb-3 flex items-center gap-2">
              <span class="text-3xl">💡</span>
              播客策划室
            </h2>
            <p class="text-gray-600 leading-relaxed text-sm">
              输入播客核心信息，AI助你一键生成专业策划方案。
            </p>
          </div>
          
          <!-- 插图区域 -->
          <div class="mb-6 h-32 flex items-center justify-center">
            <img :src="firstImage" alt="播客策划流程" class="h-full w-auto object-contain" />
          </div>
          
          <button
            @click="handleEnterFeature('/projects?action=create')"
            class="w-full py-3 bg-gradient-to-r from-[#FF6B9D] to-[#FF8FAB] text-white rounded-xl hover:shadow-lg hover:scale-105 transition-all font-bold mt-auto"
          >
            进入策划室
          </button>
        </div>

        <!-- 播客剪辑 -->
        <div class="glass-card rounded-2xl p-8 hover:shadow-xl hover:-translate-y-1 transition-all duration-300 cursor-pointer group border-2 border-orange-300/60 bg-gradient-to-br from-orange-50 to-orange-100 flex flex-col shadow-lg">
          <div class="mb-6">
            <h2 class="text-2xl font-bold bg-gradient-to-r from-[#FFB347] to-[#FFC875] bg-clip-text text-transparent mb-3 flex items-center gap-2">
              <span class="text-3xl">✂️</span>
              播客剪辑
            </h2>
            <p class="text-gray-600 leading-relaxed text-sm">
              让音频剪辑，像排版一样自然。
            </p>
          </div>
          
          <!-- 插图区域 -->
          <div class="mb-6 h-48 flex items-center justify-center">
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
        <div class="glass-card rounded-2xl p-8 hover:shadow-xl hover:-translate-y-1 transition-all duration-300 cursor-pointer group border-2 border-purple-300/60 bg-gradient-to-br from-purple-50 to-purple-100 flex flex-col shadow-lg">
          <div class="mb-6">
            <h2 class="text-2xl font-bold bg-gradient-to-r from-[#C084FC] to-[#D8B4FE] bg-clip-text text-transparent mb-3 flex items-center gap-2">
              <span class="text-3xl">🎨</span>
              内容增值
            </h2>
            <p class="text-gray-600 leading-relaxed text-sm">
              为播客创作者打造的频道运营工具，帮助每个创作者以更高效率持续表达。
            </p>
          </div>
          
          <!-- 插图区域 -->
          <div class="mb-6 h-32 flex items-center justify-center">
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
