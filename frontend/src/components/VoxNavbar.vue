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
      'backdrop-blur-sm bg-[#121524]/80 border-b border-[#485F88]/30',
      isClipStudio ? 'sticky top-0' : 'fixed'
    ]"
    :style="isClipStudio ? { paddingLeft: '5rem' } : {}"
  >
    <div class="flex items-center gap-4">
      <RouterLink 
        to="/" 
        class="text-xl font-bold transition text-white hover:opacity-80"
      >
        PodPal
      </RouterLink>
      <div 
        v-if="isClipStudio"
        class="h-4 w-px bg-[#485F88]"
      ></div>
      <div 
        v-if="isClipStudio"
        class="text-sm text-[#9DACCC]"
      >
        为播客创作者而生
      </div>
    </div>
    
    <div class="hidden md:flex gap-8 text-sm font-medium transition text-[#9DACCC]">
      <RouterLink 
        to="/" 
        class="transition"
        :class="$route.path === '/' ? 'text-white font-semibold' : 'hover:text-white'"
      >
        首页
      </RouterLink>
      <RouterLink
        v-if="userStore.isAuthenticated"
        to="/clip-studio"
        class="transition"
        :class="$route.path.startsWith('/clip-studio') ? 'text-white font-semibold' : 'hover:text-white'"
      >
        🎬 剪辑工作台
      </RouterLink>
      <RouterLink
        v-if="userStore.isAuthenticated"
        to="/projects"
        class="transition"
        :class="$route.path.startsWith('/projects') ? 'text-white font-semibold' : 'hover:text-white'"
      >
        项目管理
      </RouterLink>
      <RouterLink
        v-if="userStore.isAuthenticated"
        to="/materials"
        class="transition"
        :class="$route.path.startsWith('/materials') ? 'text-white font-semibold' : 'hover:text-white'"
      >
        素材管理
      </RouterLink>
      <a 
        href="#" 
        class="transition hover:text-white"
      >
        解决方案
      </a>
      <RouterLink 
        to="/profile" 
        class="transition"
        :class="$route.path === '/profile' ? 'text-white font-semibold' : 'hover:text-white'"
      >
        个人中心
      </RouterLink>
    </div>
    <div class="flex items-center gap-4">
      <RouterLink
        v-if="userStore.isAuthenticated"
        to="/profile"
        class="px-4 py-2 text-sm transition text-[#9DACCC] hover:text-white"
      >
        会员中心
      </RouterLink>
      <RouterLink
        v-if="!userStore.isAuthenticated"
        to="/login"
        class="px-4 py-2 text-sm transition text-[#9DACCC] hover:text-white"
      >
        登录/注册
      </RouterLink>
      <RouterLink
        v-if="userStore.isAuthenticated"
        to="/dashboard"
        class="px-6 py-2 rounded-full text-sm font-bold transition-all duration-300 bg-gradient-to-r from-[#485F88] to-[#9DACCC] text-white hover:from-[#9DACCC] hover:to-[#9DACCC]"
      >
        工作台
      </RouterLink>
      <RouterLink
        v-else-if="!isClipStudio"
        to="/login"
        class="px-6 py-2 rounded-full text-sm font-bold transition-all duration-300"
        :class="isHomePage 
          ? 'bg-gradient-to-r from-[#485F88] to-[#9DACCC] text-white hover:from-[#9DACCC] hover:to-[#9DACCC]' 
          : 'bg-[#485F88] text-white hover:bg-[#9DACCC]'"
      >
        立即开始
      </RouterLink>
      <button
        v-if="userStore.isAuthenticated"
        @click="handleLogout"
        class="px-4 py-2 text-sm text-[#9DACCC] hover:text-white transition"
      >
        退出
      </button>
    </div>
  </nav>
</template>
