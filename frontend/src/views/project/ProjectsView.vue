<template>
  <div class="min-h-screen bg-gradient-to-br from-[#121524] via-[#1a1f35] to-[#121524] pt-24 pb-12 px-6">
    <div class="container mx-auto max-w-7xl">
      <!-- 头部 -->
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-3xl font-bold text-white mb-2">项目管理</h1>
          <p class="text-[#9DACCC]">管理你的播客剪辑项目</p>
        </div>
        <button
          @click="showCreateModal = true"
          class="px-6 py-2 bg-gradient-to-r from-[#485F88] to-[#9DACCC] text-white rounded-lg hover:from-[#9DACCC] hover:to-[#9DACCC] transition flex items-center gap-2"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          新建项目
        </button>
      </div>

      <!-- 筛�?-->
      <div class="glass-card rounded-xl p-4 mb-6">
        <div class="flex flex-col md:flex-row gap-4">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="搜索项目..."
            class="flex-1 px-4 py-2 bg-[#1a1f35] border border-[#485F88] rounded-lg text-white placeholder-[#9DACCC] focus:outline-none focus:ring-2 focus:ring-[#485F88]"
          />
          <select
            v-model="filterStatus"
            class="px-4 py-2 bg-[#1a1f35] border border-[#485F88] rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-[#485F88]"
          >
            <option value="">全部状态</option>
            <option value="draft">草稿</option>
            <option value="processing">进行中</option>
            <option value="completed">已完成</option>
          </select>
        </div>
      </div>

      <!-- 项目列表 -->
      <div v-if="projectStore.loading" class="text-center py-12 text-[#9DACCC]">
        加载中...
      </div>
      <div v-else-if="filteredProjects.length === 0" class="glass-card rounded-xl p-12 text-center">
        <p class="text-[#9DACCC] mb-4">还没有项目</p>
        <button
          @click="showCreateModal = true"
          class="px-6 py-2 bg-gradient-to-r from-[#485F88] to-[#9DACCC] text-white rounded-lg hover:from-[#9DACCC] hover:to-[#9DACCC] transition"
        >
          创建第一个项目
        </button>
      </div>
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          v-for="project in filteredProjects"
          :key="project.id"
          class="bg-white border border-gray-200 rounded-xl p-6 cursor-pointer hover:scale-105 transition-transform hover:shadow-lg"
          @click="router.push(`/projects/${project.id}`)"
        >
          <div class="flex items-start justify-between mb-4">
            <h3 class="text-xl font-semibold text-gray-900 flex-1">{{ project.name }}</h3>
            <span
              class="px-2 py-1 rounded-full text-xs"
              :class="getStatusClass(project.status)"
            >
              {{ getStatusText(project.status) }}
            </span>
          </div>
          <p class="text-sm text-[#9DACCC] mb-4 line-clamp-2">{{ project.description || '暂无描述' }}</p>
          <div class="flex items-center justify-between text-xs text-[#9DACCC]">
            <span>{{ formatDate(project.updatedAt) }}</span>
            <span v-if="project.duration">时长: {{ formatDuration(project.duration) }}</span>
          </div>
          <div class="mt-4 flex gap-2">
            <button
              @click.stop="router.push(`/clip-studio/${project.id}`)"
              class="flex-1 px-4 py-2 bg-gradient-to-r from-[#485F88] to-[#9DACCC] text-white rounded-lg hover:from-[#9DACCC] hover:to-[#9DACCC] transition text-sm font-medium"
            >
              🎬 开始剪辑
            </button>
            <button
              @click.stop="router.push(`/editor/${project.id}`)"
              class="px-4 py-2 border border-[#485F88] text-[#9DACCC] rounded-lg hover:bg-[#485F88]/30 transition text-sm"
            >
              编辑器
            </button>
            <button
              @click.stop="deleteProject(project.id)"
              class="px-4 py-2 border border-red-500/50 text-red-400 rounded-lg hover:bg-red-500/20 transition text-sm"
            >
              删除
            </button>
          </div>
        </div>
      </div>

      <!-- 创建项目模态框 -->
      <CreateProjectModal
        v-if="showCreateModal"
        @close="showCreateModal = false"
        @created="handleCreated"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useProjectStore } from '../../stores/project'
import CreateProjectModal from '../../components/CreateProjectModal.vue'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'

dayjs.extend(relativeTime)

const router = useRouter()
const projectStore = useProjectStore()
const showCreateModal = ref(false)
const searchQuery = ref('')
const filterStatus = ref('')

const filteredProjects = computed(() => {
  let projects = [...projectStore.projects]

  if (searchQuery.value) {
    projects = projects.filter(p =>
      p.name.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      (p.description && p.description.toLowerCase().includes(searchQuery.value.toLowerCase()))
    )
  }

  if (filterStatus.value) {
    projects = projects.filter(p => p.status === filterStatus.value)
  }

  return projects.sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt))
})

const formatDate = (date) => {
  if (!date) return '未知'
  return dayjs(date).fromNow()
}

const formatDuration = (seconds) => {
  if (!seconds) return ''
  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

const getStatusClass = (status) => {
  const statusMap = {
    completed: 'bg-emerald-500/20 text-emerald-300',
    processing: 'bg-amber-500/20 text-amber-300',
    draft: 'bg-blue-500/20 text-blue-300'
  }
  return statusMap[status] || 'bg-[#485F88]/20 text-[#9DACCC]'
}

const getStatusText = (status) => {
  const statusMap = {
    completed: '已完成',
    processing: '进行中',
    draft: '草稿'
  }
  return statusMap[status] || '未知'
}

const deleteProject = async (id) => {
  if (confirm('确定要删除这个项目吗？')) {
    await projectStore.deleteProject(id)
  }
}

const handleCreated = (project) => {
  showCreateModal.value = false
  router.push(`/clip-studio/${project.id}`)
}

onMounted(() => {
  projectStore.fetchProjects()
})
</script>

