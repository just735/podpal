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
  <!-- 稍深粉蓝渐变底色：色彩饱满，梦幻且有质感，无生硬分界 -->
  <div class="min-h-screen flex flex-col relative overflow-hidden bg-gradient-to-br from-pink-300 via-blue-200 to-purple-300 justify-between">
    <!-- 叠加双层柔焦光晕，强化梦幻感，模糊色彩分界，呼应深渐变 -->
    <div class="absolute inset-0 pointer-events-none">
      <div class="absolute top-1/4 left-1/6 w-[500px] h-[500px] rounded-full bg-pink-400/20 blur-3xl"></div>
      <div class="absolute bottom-1/4 right-1/6 w-[450px] h-[450px] rounded-full bg-purple-400/20 blur-3xl"></div>
      <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[400px] h-[400px] rounded-full bg-blue-400/20 blur-3xl"></div>
    </div>

    <!-- 顶部横幅（适配深粉蓝渐变，磨砂玻璃+精致光影） -->
    <div class="w-full px-6 pt-20 pb-2 relative z-10">
      <div class="glass-card rounded-2xl p-3 md:p-5 border border-white/70 shadow-[0_4px_20px_rgba(139,92,246,0.1),0_1px_3px_rgba(59,130,246,0.08),inset_0_1px_0_rgba(255,255,255,0.9)]">
        <div class="flex flex-col md:flex-row items-center justify-between gap-2 md:gap-0 w-full">
          <div class="flex-1 text-center md:text-left">
            <h1 class="text-3xl md:text-4xl font-bold mb-1 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent drop-shadow-[0_0_8px_rgba(192,132,252,0.3)]">PodPal</h1>
            <p class="text-gray-800 text-sm">一站式完成策划、剪辑、优化与分发，让创作更高效。</p>
          </div>
          <div class="flex flex-wrap gap-2 justify-center md:justify-end">
            <!-- 悬浮按钮（适配深粉蓝渐变，立体光影） -->
            <RouterLink to="/clip-studio" class="px-4 py-2 rounded-xl bg-gradient-to-r from-[#9333EA] via-[#EC4899] to-[#3B82F6] text-white font-bold hover:shadow-[0_8px_25px_rgba(147,51,234,0.25),0_0_12px_rgba(236,72,153,0.2)] hover:-translate-y-1 hover:border-purple-200/70 transition-all duration-300 text-sm border border-purple-500/30 shadow-[0_4px_15px_rgba(147,51,234,0.15),inset_0_1px_0_rgba(255,255,255,0.15)]">立即开始剪辑</RouterLink>
            <RouterLink to="/materials" class="px-4 py-2 rounded-xl bg-white/70 border border-purple-300/30 text-purple-900 hover:bg-white/90 hover:shadow-[0_4px_15px_rgba(147,51,234,0.08)] hover:-translate-y-0.5 transition-all duration-300 text-sm shadow-[0_2px_8px_rgba(0,0,0,0.05)]">上传素材</RouterLink>
            <RouterLink to="/register" class="px-4 py-2 rounded-xl bg-white/70 border border-purple-300/30 text-purple-900 hover:bg-white/90 hover:shadow-[0_4px_15px_rgba(147,51,234,0.08)] hover:-translate-y-0.5 transition-all duration-300 text-sm shadow-[0_2px_8px_rgba(0,0,0,0.05)]">注册账号</RouterLink>
          </div>
        </div>
      </div>
    </div>

    <!-- 主要内容区域（核心卡片，适配深粉蓝渐变，多层悬浮光影） -->
    <div class="container mx-auto max-w-5xl px-6 flex-1 flex items-center justify-center relative z-10 py-2">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 md:gap-8 items-stretch justify-center w-full">
        <!-- 播客剪辑卡片 -->
        <div class="glass-card rounded-2xl p-6 md:p-9 hover:shadow-[0_12px_35px_rgba(147,51,234,0.15),0_0_15px_rgba(245,158,11,0.08),inset_0_1px_0_rgba(255,255,255,0.9)] hover:-translate-y-1 transition-all duration-300 cursor-pointer group border border-white/70 flex flex-col shadow-[0_6px_20px_rgba(147,51,234,0.1),0_1px_3px_rgba(245,158,11,0.08),inset_0_1px_0_rgba(255,255,255,0.9)]">
          <div class="mb-3">
            <h2 class="text-2xl md:text-[clamp(1.5rem,3vw,2.5rem)] font-bold bg-gradient-to-r from-[#B45309] to-[#F59E0B] bg-clip-text text-transparent mb-1 flex items-center gap-2 drop-shadow-[0_0_6px_rgba(245,158,11,0.15)]">
              <span class="text-3xl">✂️</span>
              播客剪辑
            </h2>
            <p class="text-gray-900 leading-relaxed text-base">
              让音频剪辑，像排版一样自然。
            </p>
          </div>
          
          <div class="mb-4 h-36 flex items-center justify-center">
            <img :src="secondImage" alt="播客剪辑" class="h-full w-auto object-contain drop-shadow-[0_2px_8px_rgba(147,51,234,0.08)]" />
          </div>
          
          <!-- 核心悬浮按钮（适配深粉蓝渐变） -->
          <button
            @click="handleEnterFeature('/clip-studio')"
            class="w-full py-3 bg-gradient-to-r from-[#F59E0B] to-[#B45309] text-white rounded-xl hover:shadow-[0_8px_25px_rgba(245,158,11,0.25),0_0_10px_rgba(245,158,11,0.2)] hover:-translate-y-1 hover:border-amber-200/70 transition-all duration-300 font-bold mt-auto text-base border border-amber-500/30 shadow-[0_4px_15px_rgba(245,158,11,0.15),inset_0_1px_0_rgba(255,255,255,0.15)]"
          >
            进入剪辑
          </button>
        </div>

        <!-- 内容增值工具卡片 -->
        <div class="glass-card rounded-2xl p-6 md:p-9 hover:shadow-[0_12px_35px_rgba(147,51,234,0.15),0_0_15px_rgba(59,130,246,0.08),inset_0_1px_0_rgba(255,255,255,0.9)] hover:-translate-y-1 transition-all duration-300 cursor-pointer group border border-white/70 flex flex-col shadow-[0_6px_20px_rgba(147,51,234,0.1),0_1px_3px_rgba(59,130,246,0.08),inset_0_1px_0_rgba(255,255,255,0.9)]">
          <div class="mb-3">
            <h2 class="text-2xl md:text-[clamp(1.5rem,3vw,2.5rem)] font-bold bg-gradient-to-r from-[#3B82F6] via-[#9333EA] to-[#EC4899] bg-clip-text text-transparent mb-1 flex items-center gap-2 drop-shadow-[0_0_6px_rgba(147,51,234,0.15)]">
              <span class="text-3xl">🎨</span>
              内容增值
            </h2>
            <p class="text-gray-900 leading-relaxed text-base">
              为播客创作者打造的频道运营工具，帮助每个创作者以更高效率持续表达。
            </p>
          </div>
          
          <div class="mb-4 h-36 flex items-center justify-center">
            <img :src="thirdImage" alt="内容增值" class="h-full w-auto object-contain drop-shadow-[0_2px_8px_rgba(147,51,234,0.08)]" />
          </div>
          
          <!-- 核心悬浮按钮（适配深粉蓝渐变） -->
          <button
            @click="handleEnterFeature('/tools')"
            class="w-full py-3 bg-gradient-to-r from-[#3B82F6] to-[#9333EA] text-white rounded-xl hover:shadow-[0_8px_25px_rgba(147,51,234,0.25),0_0_10px_rgba(59,130,246,0.2)] hover:-translate-y-1 hover:border-purple-200/70 transition-all duration-300 font-bold mt-auto text-base border border-purple-500/30 shadow-[0_4px_15px_rgba(147,51,234,0.15),inset_0_1px_0_rgba(255,255,255,0.15)]"
          >
            进入工具
          </button>
        </div>
      </div>
    </div>

    <!-- 底部功能行（适配深粉蓝渐变，精致光影） -->
    <div class="w-full px-6 pb-3 relative z-10">
      <div class="glass-card rounded-2xl p-2 md:p-3 border border-white/70 shadow-[0_4px_15px_rgba(147,51,234,0.1),inset_0_1px_0_rgba(255,255,255,0.9)] w-full">
        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-2 md:gap-3">
          <div class="rounded-xl p-2 bg-white/70 hover:bg-white/90 hover:shadow-[0_2px_8px_rgba(147,51,234,0.08),0_0_6px_rgba(245,158,11,0.08)] hover:-translate-y-0.5 transition-all duration-300 flex items-center gap-2 border border-purple-300/50">
            <div class="w-8 h-8 rounded-full bg-gradient-to-br from-amber-400 to-amber-600 flex items-center justify-center shadow-[0_2px_6px_rgba(245,158,11,0.25)]">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-white" viewBox="0 0 20 20" fill="currentColor">
                <path d="M5 2a1 1 0 011 1v1h1a1 1 0 010 2H6v1a1 1 0 01-2 0V6H3a1 1 0 010-2h1V3a1 1 0 011-1zm0 10a1 1 0 011 1v1h1a1 1 0 110 2H6v1a1 1 0 11-2 0v-1H3a1 1 0 110-2h1v-1a1 1 0 011-1zM12 2a1 1 0 01.967.744L14.146 7.2 17.5 9.134a1 1 0 010 1.732l-3.354 1.935-1.18 4.455a1 1 0 01-1.933 0L9.854 12.8 6.5 10.866a1 1 0 010-1.732l3.354-1.935 1.18-4.455A1 1 0 0112 2z" />
              </svg>
            </div>
            <div>
              <div class="text-gray-900 font-semibold text-xs">智能剪辑</div>
              <div class="text-xs text-gray-700">自动提取高光片段</div>
            </div>
          </div>
          <div class="rounded-xl p-2 bg-white/70 hover:bg-white/90 hover:shadow-[0_2px_8px_rgba(147,51,234,0.08),0_0_6px_rgba(59,130,246,0.08)] hover:-translate-y-0.5 transition-all duration-300 flex items-center gap-2 border border-purple-300/50">
            <div class="w-8 h-8 rounded-full bg-gradient-to-br from-blue-400 to-blue-600 flex items-center justify-center shadow-[0_2px_6px_rgba(59,130,246,0.25)]">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-white" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M7 4a3 3 0 016 0v4a3 3 0 11-6 0V4zm4 10.93A7.001 7.001 0 0017 8a1 1 0 10-2 0A5 5 0 015 8a1 1 0 00-2 0 7.001 7.001 0 006 6.93V17H6a1 1 0 100 2h8a1 1 0 100-2h-3v-2.07z" clip-rule="evenodd" />
              </svg>
            </div>
            <div>
              <div class="text-gray-900 font-semibold text-xs">音频优化</div>
              <div class="text-xs text-gray-700">降噪与音量均衡</div>
            </div>
          </div>
          <div class="rounded-xl p-2 bg-white/70 hover:bg-white/90 hover:shadow-[0_2px_8px_rgba(147,51,234,0.08),0_0_6px_rgba(34,211,238,0.08)] hover:-translate-y-0.5 transition-all duration-300 flex items-center gap-2 border border-purple-300/50">
            <div class="w-8 h-8 rounded-full bg-gradient-to-br from-cyan-400 to-cyan-600 flex items-center justify-center shadow-[0_2px_6px_rgba(34,211,238,0.25)]">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-white" viewBox="0 0 20 20" fill="currentColor">
                <path d="M17.414 2.586a2 2 0 00-2.828 0L7 10.172V13h2.828l7.586-7.586a2 2 0 000-2.828z" />
                <path fill-rule="evenodd" d="M2 6a2 2 0 012-2h4a1 1 0 010 2H4v10h10v-4a1 1 0 112 0v4a2 2 0 01-2 2H4a2 2 0 01-2-2V6z" clip-rule="evenodd" />
              </svg>
            </div>
            <div>
              <div class="text-gray-900 font-semibold text-xs">转写字幕</div>
              <div class="text-xs text-gray-700">多语言精准转写</div>
            </div>
          </div>
          <div class="rounded-xl p-2 bg-white/70 hover:bg-white/90 hover:shadow-[0_2px_8px_rgba(147,51,234,0.08),0_0_6px_rgba(236,72,153,0.08)] hover:-translate-y-0.5 transition-all duration-300 flex items-center gap-2 border border-purple-300/50">
            <div class="w-8 h-8 rounded-full bg-gradient-to-br from-pink-400 to-pink-600 flex items-center justify-center shadow-[0_2px_6px_rgba(236,72,153,0.25)]">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-white" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM6.293 6.707a1 1 0 010-1.414l3-3a1 1 0 011.414 0l3 3a1 1 0 01-1.414 1.414L11 5.414V13a1 1 0 11-2 0V5.414L7.707 6.707a1 1 0 01-1.414 0z" clip-rule="evenodd" />
              </svg>
            </div>
            <div>
              <div class="text-gray-900 font-semibold text-xs">多平台导出</div>
              <div class="text-xs text-gray-700">一键适配比例</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 升级磨砂玻璃效果，适配深粉蓝渐变底色（透明白色磨砂，高区分度+饱满质感） */
.glass-card {
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
}

/* 滚动条适配深粉蓝梦幻渐变主题 */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-thumb {
  background: rgba(147, 51, 234, 0.25);
  border-radius: 4px;
  box-shadow: 0 2px 4px rgba(236, 72, 153, 0.08);
}

::-webkit-scrollbar-thumb:hover {
  background: rgba(147, 51, 234, 0.35);
}

::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.8);
}
</style>