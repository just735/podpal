<template>
  <div class="min-h-screen bg-gradient-to-br from-[#121524] via-[#1a1f35] to-[#121524] pt-24 pb-12 px-6">
    <div class="container mx-auto max-w-7xl" v-if="project">
      <div class="mb-8">
        <button
          @click="router.back()"
          class="mb-4 text-[#9DACCC] hover:text-white transition flex items-center gap-2"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
          返回
        </button>
        <h1 class="text-3xl font-bold text-white mb-2">{{ project.name }}</h1>
        <p class="text-[#9DACCC]">{{ project.description || '暂无描述' }}</p>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- 主内容区 -->
        <div class="lg:col-span-2 space-y-6">
          <div class="glass-card rounded-xl p-6">
            <h2 class="text-xl font-semibold text-white mb-4">项目信息</h2>
            <div class="space-y-3 text-sm">
              <div class="flex justify-between">
                <span class="text-[#9DACCC]">类型</span>
                <span class="text-white">{{ getPodcastTypeText(project.podcastType) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-[#9DACCC]">状态</span>
                <span class="text-white">{{ getStatusText(project.status) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-[#9DACCC]">创建时间</span>
                <span class="text-white">{{ formatDate(project.createdAt) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-[#9DACCC]">更新时间</span>
                <span class="text-white">{{ formatDate(project.updatedAt) }}</span>
              </div>
            </div>
          </div>

          <div class="glass-card rounded-xl p-6">
            <h2 class="text-xl font-semibold text-white mb-4">操作</h2>
            <div class="space-y-3">
              <button
                @click="router.push(`/clip-studio/${project.id}`)"
                class="w-full px-4 py-3 bg-gradient-to-r from-[#485F88] to-[#9DACCC] text-white rounded-lg hover:from-[#9DACCC] hover:to-[#9DACCC] transition font-medium shadow-lg"
              >
                🎬 进入剪辑工作台
              </button>
              <button
                @click="router.push(`/editor/${project.id}`)"
                class="w-full px-4 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-[#485F88]/30 transition"
              >
                进入编辑器
              </button>
              <button
                @click="router.push(`/projects/${project.id}/versions`)"
                class="w-full px-4 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-[#485F88]/30 transition"
              >
                版本管理
              </button>
            </div>
          </div>
        </div>

        <!-- 侧边�?-->
        <div class="space-y-6">
          <div class="glass-card rounded-xl p-6">
            <h3 class="text-lg font-semibold text-white mb-4">统计信息</h3>
            <div class="space-y-3 text-sm">
              <div>
                <div class="text-[#9DACCC]">转写片段</div>
                <div class="text-white text-xl mt-1">{{ project.transcript?.length || 0 }}</div>
              </div>
              <div>
                <div class="text-[#9DACCC]">剪辑片段</div>
                <div class="text-white text-xl mt-1">{{ project.clips?.length || 0 }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useProjectStore } from '../../stores/project'
import dayjs from 'dayjs'

const route = useRoute()
const router = useRouter()
const projectStore = useProjectStore()

const project = computed(() => projectStore.currentProject)

const getPodcastTypeText = (type) => {
  const typeMap = {
    knowledge: '知识类',
    companion: '陪伴类',
    interview: '访谈类',
    other: '其他'
  }
  return typeMap[type] || '未知'
}

const getStatusText = (status) => {
  const statusMap = {
    completed: '已完成',
    processing: '进行中',
    draft: '草稿'
  }
  return statusMap[status] || '未知'
}

const formatDate = (date) => {
  if (!date) return '未知'
  return dayjs(date).format('YYYY-MM-DD HH:mm')
}

onMounted(async () => {
  await projectStore.fetchProject(route.params.id)
})
</script>

