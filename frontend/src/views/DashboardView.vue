﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿﻿<template>
  <div class="min-h-screen bg-white pt-24 pb-12 px-6">
    <div class="container mx-auto max-w-7xl">
      <!-- 欢迎区域 -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent mb-2">
          欢迎回来，{{ userStore.user?.username || '用户' }}！
        </h1>
        <p class="text-gray-600">开始你的播客创作之旅</p>
      </div>

      <!-- 快速操作卡片 -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div
          class="glass-card rounded-xl p-6 cursor-pointer hover:scale-105 transition-transform hover:shadow-lg bg-gradient-to-br from-pink-50 to-pink-100 border-2 border-pink-200/60"
          @click="router.push('/clip-studio')"
        >
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-900">🎬 剪辑工作台</h3>
            <div class="w-12 h-12 bg-gradient-to-br from-[#FF6B9D] to-[#FF8FAB] rounded-lg flex items-center justify-center">
              <span class="text-2xl">✂️</span>
            </div>
          </div>
          <p class="text-sm text-gray-600">专业的播客剪辑工具</p>
        </div>

        <div
          class="glass-card rounded-xl p-6 cursor-pointer hover:scale-105 transition-transform hover:shadow-lg bg-gradient-to-br from-orange-50 to-orange-100 border-2 border-orange-200/60"
          @click="router.push('/materials')"
        >
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-900">上传素材</h3>
            <div class="w-12 h-12 bg-gradient-to-br from-[#FFB347] to-[#FFC875] rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
              </svg>
            </div>
          </div>
          <p class="text-sm text-gray-600">上传音频或视频文件开始创作</p>
        </div>

        <div
          class="glass-card rounded-xl p-6 cursor-pointer hover:scale-105 transition-transform hover:shadow-lg bg-gradient-to-br from-purple-50 to-purple-100 border-2 border-purple-200/60"
          @click="router.push('/projects?action=create')"
        >
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-900">新建项目</h3>
            <div class="w-12 h-12 bg-gradient-to-br from-[#C084FC] to-[#D8B4FE] rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
              </svg>
            </div>
          </div>
          <p class="text-sm text-gray-600">创建新的播客剪辑项目</p>
        </div>

        <div
          class="glass-card rounded-xl p-6 cursor-pointer hover:scale-105 transition-transform hover:shadow-lg bg-gradient-to-br from-cyan-50 to-cyan-100 border-2 border-cyan-200/60"
          @click="router.push('/tools')"
        >
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-900">工具箱</h3>
            <div class="w-12 h-12 bg-gradient-to-br from-[#4ECDC4] to-[#6EE7D7] rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
            </div>
          </div>
          <p class="text-sm text-gray-600">使用辅助工具提升效率</p>
        </div>
      </div>

      <!-- 最近项目 -->
      <div class="mb-8">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-xl font-semibold text-gray-900">最近项目</h2>
          <RouterLink to="/projects" class="text-sm text-pink-600 hover:text-pink-700 transition">
            查看全部 →
          </RouterLink>
        </div>
        <div v-if="projectStore.loading" class="text-center py-12 text-gray-600">
          加载中...
        </div>
        <div v-else-if="projectStore.projects.length === 0" class="glass-card rounded-xl p-12 text-center bg-gradient-to-br from-pink-50/50 to-purple-50/50 border-2 border-pink-200/60">
          <p class="text-gray-600 mb-4">还没有项目</p>
          <button
            @click="router.push('/projects?action=create')"
            class="px-6 py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition"
          >
            创建第一个项目
          </button>
        </div>
        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            v-for="project in projectStore.projects.slice(0, 6)"
            :key="project.id"
            class="glass-card rounded-xl p-6 cursor-pointer hover:scale-105 transition-transform hover:shadow-lg bg-white border-2 border-pink-200/60"
            @click="router.push(`/projects/${project.id}`)"
          >
            <h3 class="text-lg font-semibold text-gray-900 mb-2">{{ project.name }}</h3>
            <p class="text-sm text-gray-600 mb-4 line-clamp-2">{{ project.description || '暂无描述' }}</p>
            <div class="flex items-center justify-between text-xs text-gray-500">
              <span>{{ formatDate(project.updatedAt) }}</span>
              <span
                class="px-2 py-1 rounded-full"
                :class="getStatusClass(project.status)"
              >
                {{ getStatusText(project.status) }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- 统计信息 -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div class="glass-card rounded-xl p-6 bg-gradient-to-br from-pink-50 to-pink-100 border-2 border-pink-200/60">
          <div class="text-2xl font-bold text-gray-900 mb-1">{{ projectStore.projects.length }}</div>
          <div class="text-sm text-gray-600">总项目数</div>
        </div>
        <div class="glass-card rounded-xl p-6 bg-gradient-to-br from-purple-50 to-purple-100 border-2 border-purple-200/60">
          <div class="text-2xl font-bold text-gray-900 mb-1">{{ completedProjects }}</div>
          <div class="text-sm text-gray-600">已完成</div>
        </div>
        <div class="glass-card rounded-xl p-6 bg-gradient-to-br from-orange-50 to-orange-100 border-2 border-orange-200/60">
          <div class="text-2xl font-bold text-gray-900 mb-1">{{ materialStore.materials.length }}</div>
          <div class="text-sm text-gray-600">素材数量</div>
        </div>
        <div class="glass-card rounded-xl p-6 bg-gradient-to-br from-cyan-50 to-cyan-100 border-2 border-cyan-200/60">
          <div class="text-2xl font-bold text-gray-900 mb-1">{{ userStore.user?.membershipType || '免费版' }}</div>
          <div class="text-sm text-gray-600">会员类型</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { useProjectStore } from '../stores/project'
import { useMaterialStore } from '../stores/material'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'

dayjs.extend(relativeTime)

const router = useRouter()
const userStore = useUserStore()
const projectStore = useProjectStore()
const materialStore = useMaterialStore()

const completedProjects = computed(() => {
  return projectStore.projects.filter(p => p.status === 'completed').length
})

const formatDate = (date) => {
  if (!date) return '未知'
  return dayjs(date).fromNow()
}

const getStatusClass = (status) => {
  const statusMap = {
    completed: 'bg-emerald-100 text-emerald-700',
    processing: 'bg-amber-100 text-amber-700',
    draft: 'bg-blue-100 text-blue-700'
  }
  return statusMap[status] || 'bg-gray-100 text-gray-600'
}

const getStatusText = (status) => {
  const statusMap = {
    completed: '已完成',
    processing: '进行中',
    draft: '草稿'
  }
  return statusMap[status] || '未知'
}

onMounted(async () => {
  await Promise.all([
    projectStore.fetchProjects(),
    materialStore.fetchMaterials()
  ])
})
</script>
