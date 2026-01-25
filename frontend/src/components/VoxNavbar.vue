<script setup>
import { RouterLink, useRouter, useRoute } from 'vue-router'
import { useUserStore } from '../stores/user'
import { computed } from 'vue'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const handleLogout = () => {
  userStore.logout()
  router.push('/')
}

// 判断是否在首页，首页使用白色背景的导航栏
const isHomePage = computed(() => route.path === '/')
// 判断是否在剪辑工作台或素材管理页面，需要显示左侧导航栏
const isClipStudio = computed(() => route.path.startsWith('/clip-studio') || route.path.startsWith('/materials'))
</script>

<template>
  <nav 
    class="w-full z-50 px-8 py-4 flex justify-between items-center transition-all duration-300"
    :class="[
      'backdrop-blur-xl bg-white/90 border-b border-pink-200/60 shadow-sm',
      isClipStudio ? 'sticky top-0' : 'fixed'
    ]"
    :style="isClipStudio ? { paddingLeft: '5rem' } : {}"
  >
    <div class="flex items-center gap-4">
      <RouterLink 
        to="/" 
        class="text-xl font-black transition bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent hover:opacity-80"
      >
        PodPal
      </RouterLink>
      <div 
        v-if="isClipStudio"
        class="h-4 w-px bg-pink-300/50"
      ></div>
      <div 
        v-if="isClipStudio"
        class="text-sm text-gray-500 font-medium"
      >
        为播客创作者而生
      </div>
    </div>
    
    <div class="hidden md:flex gap-8 text-sm font-medium transition text-gray-600">
      <RouterLink 
        to="/" 
        class="transition"
        :class="$route.path === '/' ? 'text-pink-600 font-bold' : 'hover:text-pink-600'"
      >
        首页
      </RouterLink>
      <RouterLink
        v-if="userStore.isAuthenticated"
        to="/clip-studio"
        class="transition"
        :class="$route.path.startsWith('/clip-studio') ? 'text-pink-600 font-bold' : 'hover:text-pink-600'"
      >
        🎬 剪辑工作台
      </RouterLink>
      <RouterLink
        v-if="userStore.isAuthenticated"
        to="/projects"
        class="transition"
        :class="$route.path.startsWith('/projects') ? 'text-pink-600 font-bold' : 'hover:text-pink-600'"
      >
        项目管理
      </RouterLink>
      <RouterLink
        v-if="userStore.isAuthenticated"
        to="/materials"
        class="transition"
        :class="$route.path.startsWith('/materials') ? 'text-pink-600 font-bold' : 'hover:text-pink-600'"
      >
        素材管理
      </RouterLink>
      <a 
        href="#" 
        class="transition hover:text-pink-600"
      >
        解决方案
      </a>
      <RouterLink 
        to="/profile" 
        class="transition"
        :class="$route.path === '/profile' ? 'text-pink-600 font-bold' : 'hover:text-pink-600'"
      >
        个人中心
      </RouterLink>
    </div>
    <div class="flex items-center gap-4">
      <RouterLink
        v-if="userStore.isAuthenticated"
        to="/profile"
        class="px-4 py-2 text-sm transition text-gray-600 hover:text-pink-600 font-medium"
      >
        会员中心
      </RouterLink>
      <RouterLink
        v-if="!userStore.isAuthenticated"
        to="/login"
        class="px-4 py-2 text-sm transition text-gray-600 hover:text-pink-600 font-medium"
      >
        登录/注册
      </RouterLink>
      <RouterLink
        v-if="userStore.isAuthenticated"
        to="/dashboard"
        class="px-6 py-2 rounded-full text-sm font-bold transition-all duration-300 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white hover:shadow-lg hover:scale-105"
      >
        工作台
      </RouterLink>
      <RouterLink
        v-else-if="!isClipStudio"
        to="/login"
        class="px-6 py-2 rounded-full text-sm font-bold transition-all duration-300 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white hover:shadow-lg hover:scale-105"
      >
        立即开始
      </RouterLink>
      <button
        v-if="userStore.isAuthenticated"
        @click="handleLogout"
        class="px-4 py-2 text-sm text-gray-600 hover:text-pink-600 transition font-medium"
      >
        退出
      </button>
    </div>
  </nav>
</template>
