<template>
  <div class="min-h-screen bg-white pt-24 pb-12 px-6">
    <div class="container mx-auto max-w-7xl" v-if="project">
      <div class="mb-8">
        <button
          @click="router.back()"
          class="mb-4 text-gray-600 hover:text-pink-600 transition flex items-center gap-2"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
          返回
        </button>
        <h1 class="text-3xl font-bold bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent mb-2">{{ project.name }}</h1>
        <p class="text-gray-600">{{ project.description || '暂无描述' }}</p>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- 主内容区 -->
        <div class="lg:col-span-2 space-y-6">
          <div class="glass-card rounded-xl p-6 bg-gradient-to-br from-pink-50/50 to-purple-50/50 border-2 border-pink-200/60">
            <h2 class="text-xl font-semibold text-gray-900 mb-4">项目信息</h2>
            <div class="space-y-3 text-sm">
              <div class="flex justify-between">
                <span class="text-gray-600">类型</span>
                <span class="text-gray-900">{{ getPodcastTypeText(project.podcastType) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-600">状态</span>
                <span class="text-gray-900">{{ getStatusText(project.status) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-600">创建时间</span>
                <span class="text-gray-900">{{ formatDate(project.createdAt) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-600">更新时间</span>
                <span class="text-gray-900">{{ formatDate(project.updatedAt) }}</span>
              </div>
            </div>
          </div>

          <div class="glass-card rounded-xl p-6 bg-gradient-to-br from-pink-50/50 to-purple-50/50 border-2 border-pink-200/60">
            <h2 class="text-xl font-semibold text-gray-900 mb-4">操作</h2>
            <div class="space-y-3">
              <button
                @click="router.push(`/clip-studio/${project.id}`)"
                class="w-full px-4 py-3 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition font-medium"
              >
                🎬 进入剪辑工作台
              </button>
              <button
                @click="router.push(`/editor/${project.id}`)"
                class="w-full px-4 py-3 border border-pink-200 text-gray-600 rounded-lg hover:bg-pink-50 hover:border-pink-300 hover:text-pink-600 transition"
              >
                进入编辑器
              </button>
              <button
                @click="router.push(`/projects/${project.id}/versions`)"
                class="w-full px-4 py-3 border border-pink-200 text-gray-600 rounded-lg hover:bg-pink-50 hover:border-pink-300 hover:text-pink-600 transition"
              >
                版本管理
              </button>
            </div>
          </div>
        </div>

        <!-- 侧边�?-->
        <div class="space-y-6">
          <div class="glass-card rounded-xl p-6 bg-gradient-to-br from-pink-50/50 to-purple-50/50 border-2 border-pink-200/60">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">统计信息</h3>
            <div class="space-y-3 text-sm">
              <div>
                <div class="text-gray-600">转写片段</div>
                <div class="text-gray-900 text-xl mt-1">{{ project.transcript?.length || 0 }}</div>
              </div>
              <div>
                <div class="text-gray-600">剪辑片段</div>
                <div class="text-gray-900 text-xl mt-1">{{ project.clips?.length || 0 }}</div>
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

