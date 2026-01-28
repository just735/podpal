﻿<script setup>
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
const isClipStudio = computed(() => route.path.startsWith('/clip-studio') || route.query.from === 'clip')
</script>

<template>
  <nav 
    class="w-full z-50 px-8 py-4 flex justify-between items-center transition-all duration-300"
    :class="[
      'bg-white border-b border-pink-200/60 shadow-sm',
      isClipStudio ? 'sticky top-0 pl-20' : 'fixed top-0 left-0 right-0'
    ]"
  >
    <div class="flex items-center gap-4">
      <RouterLink 
        to="/" 
        class="text-xl font-bold transition hover:opacity-80 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent"
      >
        PodPal
      </RouterLink>
      <div 
        v-if="isClipStudio"
        class="h-4 w-px bg-pink-200"
      ></div>
      <div 
        v-if="isClipStudio"
        class="text-sm text-gray-500"
      >
        为播客创作者而生
      </div>
    </div>
    
    <div class="hidden md:flex gap-8 text-sm font-medium transition text-pink-600">
      <RouterLink 
        to="/" 
        class="transition"
        :class="$route.path === '/' ? 'text-pink-700 font-semibold' : 'hover:text-pink-700'"
      >
        首页
      </RouterLink>
      <RouterLink
        v-if="userStore.isAuthenticated"
        to="/clip-studio"
        class="transition"
        :class="$route.path.startsWith('/clip-studio') ? 'text-pink-700 font-semibold' : 'hover:text-pink-700'"
      >
        🎬 剪辑工作台
      </RouterLink>
      <RouterLink
        v-if="userStore.isAuthenticated"
        to="/projects"
        class="transition"
        :class="$route.path.startsWith('/projects') ? 'text-pink-700 font-semibold' : 'hover:text-pink-700'"
      >
        项目管理
      </RouterLink>
      <RouterLink
        v-if="userStore.isAuthenticated"
        to="/materials"
        class="transition"
        :class="$route.path.startsWith('/materials') ? 'text-pink-700 font-semibold' : 'hover:text-pink-700'"
      >
        素材管理
      </RouterLink>
      <RouterLink 
        to="/solutions" 
        class="transition"
        :class="$route.path === '/solutions' ? 'text-pink-700 font-semibold' : 'hover:text-pink-700'"
      >
        解决方案
      </RouterLink>
      <RouterLink 
        to="/profile" 
        class="transition"
        :class="$route.path === '/profile' ? 'text-pink-700 font-semibold' : 'hover:text-pink-700'"
      >
        个人中心
      </RouterLink>
    </div>
    <div class="flex items-center gap-4">
      <RouterLink
        v-if="userStore.isAuthenticated"
        to="/profile"
        class="px-4 py-2 text-sm transition text-pink-600 hover:text-pink-700"
      >
        个人中心
      </RouterLink>
      <RouterLink
        v-if="!userStore.isAuthenticated"
        to="/login"
        class="px-4 py-2 text-sm transition text-pink-600 hover:text-pink-700"
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
        class="px-4 py-2 text-sm transition text-pink-600 hover:text-pink-700"
      >
        退出
      </button>
    </div>
  </nav>
</template>
