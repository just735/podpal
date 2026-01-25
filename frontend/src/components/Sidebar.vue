<script setup>
import { RouterLink, useRoute } from 'vue-router'
import { computed } from 'vue'

const route = useRoute()

const menuItems = [
  { path: '/', icon: 'home', label: '首页' },
  { path: '/projects?action=create', icon: 'plus', label: '新建' },
  { path: '/clip-studio', icon: 'edit', label: '编辑' },
  { path: '/materials', icon: 'audio', label: '素材' },
  { path: '/tools', icon: 'refresh', label: '工具' }
]

const isActive = (path) => {
  if (path === '/') {
    return route.path === '/'
  }
  return route.path.startsWith(path.split('?')[0])
}
</script>

<template>
  <aside class="fixed left-0 top-0 h-full w-16 bg-gradient-to-b from-pink-50 to-purple-50 border-r border-pink-200 flex flex-col items-center py-6 z-40">
    <div class="flex flex-col gap-6">
      <RouterLink
        v-for="item in menuItems"
        :key="item.path"
        :to="item.path"
        class="w-12 h-12 flex items-center justify-center rounded-lg transition-all duration-200 group relative"
        :class="isActive(item.path) 
          ? 'bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white' 
          : 'text-gray-600 hover:bg-pink-100 hover:text-pink-600'"
        :title="item.label"
      >
        <!-- Home图标 -->
        <svg v-if="item.icon === 'home'" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
        </svg>
        <!-- Plus图标 -->
        <svg v-else-if="item.icon === 'plus'" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
        </svg>
        <!-- Edit图标 -->
        <svg v-else-if="item.icon === 'edit'" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
        </svg>
        <!-- Audio图标 -->
        <svg v-else-if="item.icon === 'audio'" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" />
        </svg>
        <!-- Refresh图标 -->
        <svg v-else-if="item.icon === 'refresh'" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
        </svg>
        
        <!-- 工具提示 -->
        <span class="absolute left-full ml-2 px-2 py-1 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white text-xs rounded whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none shadow-lg">
          {{ item.label }}
        </span>
      </RouterLink>
    </div>
  </aside>
</template>

