<script setup>
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { computed } from 'vue'

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
  <div class="min-h-screen bg-gradient-to-br from-[#121524] via-[#1a1f35] to-[#121524]">
    <!-- Header区域 -->
    <div class="bg-[#121524]/80 backdrop-blur-sm border-b border-[#485F88]/30">
      <div class="container mx-auto max-w-7xl px-6 py-6">
        <div class="flex items-center justify-between">
          <!-- Logo和标语 -->
          <div class="flex items-center gap-4">
            <div class="text-3xl font-bold text-white">PodPal</div>
            <div class="h-6 w-px bg-[#485F88]"></div>
            <div class="text-sm text-[#9DACCC]">为播客创作者而生</div>
          </div>
          
          <!-- 右侧信息 -->
          <div class="flex items-center gap-6">
            <button
              v-if="userStore.isAuthenticated"
              class="px-4 py-2 text-sm text-[#9DACCC] hover:text-white flex items-center gap-1 transition"
            >
              开通订阅
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>
            <div class="flex items-center gap-2 text-sm text-[#9DACCC]">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
              </svg>
              <span>85</span>
            </div>
            <div class="flex items-center gap-2 text-sm text-[#9DACCC]">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <span>2 h 30 m</span>
            </div>
            <div
              v-if="userStore.isAuthenticated"
              @click="router.push('/profile')"
              class="w-10 h-10 rounded-full bg-gradient-to-br from-purple-400 to-blue-500 cursor-pointer flex items-center justify-center text-white font-semibold hover:opacity-90 transition"
            >
              {{ userStore.user?.username?.charAt(0) || 'U' }}
            </div>
            <button
              v-else
              @click="router.push('/login')"
              class="w-10 h-10 rounded-full bg-[#1a1f35]/50 cursor-pointer flex items-center justify-center text-[#9DACCC] hover:bg-[#485F88]/30 transition"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="container mx-auto max-w-7xl px-6 py-16">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <!-- 播客策划室 -->
        <div class="glass-card rounded-xl p-8 hover:shadow-lg transition-all duration-300 cursor-pointer group">
          <div class="mb-6">
            <h2 class="text-2xl font-bold text-white mb-3">播客策划室</h2>
            <p class="text-[#9DACCC] leading-relaxed">
              输入播客核心信息，AI助你一键生成专业策划方案。
            </p>
          </div>
          
          <!-- 插图区域 -->
          <div class="mb-6 h-32 flex items-center justify-center">
            <div class="relative w-full h-full">
              <!-- 左侧图标组 -->
              <div class="absolute left-0 top-1/2 -translate-y-1/2 flex flex-col gap-3">
                <div class="w-8 h-8 border-2 border-gray-400 rounded flex items-center justify-center">
                  <div class="w-4 h-4 bg-gray-400 rounded"></div>
                </div>
                <div class="w-8 h-8 border-2 border-gray-400 rounded-full"></div>
                <div class="w-8 h-8 border-2 border-gray-400 rounded flex items-center justify-center">
                  <div class="w-3 h-3 border border-gray-400"></div>
                </div>
              </div>
              <!-- 连接线 -->
              <div class="absolute left-12 top-1/2 -translate-y-1/2 w-16 h-0.5 bg-gray-300"></div>
              <!-- 右侧文档 -->
              <div class="absolute right-0 top-1/2 -translate-y-1/2 w-20 h-16 border-2 border-gray-400 rounded">
                <div class="p-2 space-y-1">
                  <div class="h-1 bg-gray-300 rounded w-full"></div>
                  <div class="h-1 bg-gray-300 rounded w-3/4"></div>
                  <div class="h-1 bg-gray-300 rounded w-full"></div>
                  <div class="h-1 bg-gray-300 rounded w-2/3"></div>
                </div>
              </div>
            </div>
          </div>
          
          <button
            @click="handleEnterFeature('/projects?action=create')"
            class="w-full py-3 bg-gradient-to-r from-[#485F88] to-[#9DACCC] text-white rounded-lg hover:from-[#9DACCC] hover:to-[#9DACCC] transition font-medium group-hover:shadow-md"
          >
            进入策划室
          </button>
        </div>

        <!-- 播客剪辑 -->
        <div class="glass-card rounded-xl p-8 hover:shadow-lg transition-all duration-300 cursor-pointer group">
          <div class="mb-6">
            <h2 class="text-2xl font-bold text-white mb-3">播客剪辑</h2>
            <p class="text-[#9DACCC] leading-relaxed">
              让音频剪辑，像排版一样自然。
            </p>
          </div>
          
          <!-- 插图区域 -->
          <div class="mb-6 h-32 flex items-center justify-center">
            <div class="relative w-full h-full">
              <!-- 文本编辑器 -->
              <div class="absolute left-0 top-4 w-24 h-16 border-2 border-gray-400 rounded p-2">
                <div class="text-lg font-bold text-[#9DACCC]">A</div>
                <div class="mt-2 space-y-1">
                  <div class="h-0.5 bg-gray-300 rounded w-full"></div>
                  <div class="h-0.5 bg-gray-300 rounded w-3/4"></div>
                  <div class="h-0.5 bg-gray-300 rounded w-full"></div>
                </div>
              </div>
              <!-- 波形图 -->
              <div class="absolute left-0 bottom-4 w-24 h-8 flex items-end gap-1">
                <div class="w-1 bg-gray-400 rounded-t" style="height: 20%"></div>
                <div class="w-1 bg-gray-400 rounded-t" style="height: 60%"></div>
                <div class="w-1 bg-gray-400 rounded-t" style="height: 100%"></div>
                <div class="w-1 bg-gray-400 rounded-t" style="height: 40%"></div>
                <div class="w-1 bg-gray-400 rounded-t" style="height: 80%"></div>
                <div class="w-1 bg-gray-400 rounded-t" style="height: 30%"></div>
              </div>
              <!-- 剪刀 -->
              <div class="absolute right-4 top-1/2 -translate-y-1/2">
                <svg class="w-8 h-8 text-[#9DACCC]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.121 14.121L19 19m-7-7l7-7m-7 7l-2.879 2.879M12 12L9.121 9.121m0 5.758a3 3 0 10-4.243 4.243 3 3 0 004.243-4.243zm0-5.758a3 3 0 10-4.243-4.243 3 3 0 004.243 4.243z" />
                </svg>
              </div>
              <!-- 星星装饰 -->
              <div class="absolute right-2 top-2">
                <svg class="w-4 h-4 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                </svg>
              </div>
            </div>
          </div>
          
          <button
            @click="handleEnterFeature('/clip-studio')"
            class="w-full py-3 bg-gradient-to-r from-[#485F88] to-[#9DACCC] text-white rounded-lg hover:from-[#9DACCC] hover:to-[#9DACCC] transition font-medium group-hover:shadow-md"
          >
            进入剪辑
          </button>
        </div>

        <!-- 内容增值工具 -->
        <div class="glass-card rounded-xl p-8 hover:shadow-lg transition-all duration-300 cursor-pointer group">
          <div class="mb-6">
            <h2 class="text-2xl font-bold text-white mb-3">内容增值</h2>
            <p class="text-[#9DACCC] leading-relaxed">
              为播客创作者打造的频道运营工具，帮助每个创作者以更高效率持续表达。
            </p>
          </div>
          
          <!-- 插图区域 -->
          <div class="mb-6 h-32 flex items-center justify-center">
            <div class="relative w-full h-full">
              <!-- 打开的书籍 -->
              <div class="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2">
                <div class="w-24 h-16 border-2 border-gray-400 rounded relative">
                  <!-- 书页内容 -->
                  <div class="p-2 space-y-1">
                    <div class="h-0.5 bg-gray-300 rounded w-full"></div>
                    <div class="h-0.5 bg-gray-300 rounded w-4/5"></div>
                    <div class="h-0.5 bg-gray-300 rounded w-full"></div>
                  </div>
                  <!-- 书脊 -->
                  <div class="absolute left-1/2 top-0 bottom-0 w-0.5 bg-gray-400"></div>
                </div>
              </div>
              <!-- 从书中飞出的图标 -->
              <div class="absolute left-1/2 top-2 -translate-x-1/2 flex gap-2">
                <div class="w-6 h-6 border-2 border-blue-500 rounded flex items-center justify-center">
                  <div class="w-3 h-3 border border-blue-500 rounded"></div>
                </div>
                <div class="w-6 h-6 border-2 border-yellow-500 rounded flex items-center justify-center">
                  <div class="w-2 h-2 bg-yellow-500 rounded-full"></div>
                </div>
                <div class="w-6 h-6 border-2 border-green-500 rounded flex items-center justify-center">
                  <svg class="w-3 h-3 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M18 3a1 1 0 00-1.196-.98l-10 2A1 1 0 006 5v9.114A4.369 4.369 0 005 14c-1.657 0-3 .895-3 2s1.343 2 3 2 3-.895 3-2V7.82l8-1.6v5.894A4.37 4.37 0 0015 12c-1.657 0-3 .895-3 2s1.343 2 3 2 3-.895 3-2V3z" />
                  </svg>
                </div>
                <div class="w-6 h-6 border-2 border-teal-500 rounded flex items-center justify-center">
                  <svg class="w-3 h-3 text-teal-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                  </svg>
                </div>
              </div>
            </div>
          </div>
          
          <button
            @click="handleEnterFeature('/tools')"
            class="w-full py-3 bg-gradient-to-r from-[#485F88] to-[#9DACCC] text-white rounded-lg hover:from-[#9DACCC] hover:to-[#9DACCC] transition font-medium group-hover:shadow-md"
          >
            进入工具
          </button>
        </div>
      </div>
    </div>

    <!-- Footer区域 -->
    <div class="bg-[#1a1f35]/50 border-t border-[#485F88]/30 mt-20">
      <div class="container mx-auto max-w-7xl px-6 py-12">
        <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-8">
          <!-- 左侧Logo和标语 -->
          <div>
            <div class="text-2xl font-bold text-white mb-2">PodPal</div>
            <div class="text-sm text-[#9DACCC]">从音频到传播，一站式播客内容工作台</div>
          </div>
          
          <!-- 右侧友情链接 -->
          <div>
            <div class="text-sm font-medium text-white mb-4">友情链接</div>
            <div class="flex flex-wrap gap-4 text-sm text-[#9DACCC]">
              <a href="#" class="hover:text-white transition">PodPal海外版</a>
              <a href="#" class="hover:text-white transition">42号车库</a>
              <a href="#" class="hover:text-white transition">毫河风报</a>
              <a href="#" class="hover:text-white transition">AI神器大全</a>
              <a href="#" class="hover:text-white transition">AI工具集</a>
            </div>
          </div>
        </div>
        
        <!-- 版权信息 -->
        <div class="mt-8 pt-8 border-t border-[#485F88]/30 text-center text-sm text-[#9DACCC]">
          PodPal © 2024 沪ICP备18012441号-6
        </div>
      </div>
    </div>
  </div>
</template>
