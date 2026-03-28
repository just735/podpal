<template>
  <div class="min-h-screen bg-white pt-24 pb-12 px-6">
    <div class="container mx-auto max-w-7xl">
      <!-- 头部 -->
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-3xl font-bold bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent mb-2">项目管理</h1>
          <p class="text-gray-600">管理你的播客剪辑项目</p>
        </div>
        <button
          @click="showCreateModal = true"
          class="px-6 py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition flex items-center gap-2"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          新建项目
        </button>
      </div>

      <!-- 筛�?-->
      <div class="glass-card rounded-xl p-4 mb-6 bg-gradient-to-br from-pink-50/50 to-purple-50/50 border-2 border-pink-200/60">
        <div class="flex flex-col md:flex-row gap-4">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="搜索项目..."
            class="flex-1 px-4 py-2 bg-white border border-pink-200 rounded-lg text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-pink-300 focus:border-pink-300"
          />
          <select
            v-model="filterStatus"
            class="px-4 py-2 bg-white border border-pink-200 rounded-lg text-gray-900 focus:outline-none focus:ring-2 focus:ring-pink-300 focus:border-pink-300"
          >
            <option value="">全部状态</option>
            <option value="draft">草稿</option>
            <option value="processing">进行中</option>
            <option value="completed">已完成</option>
          </select>
        </div>
      </div>

      <!-- 项目列表 -->
      <div v-if="projectStore.loading" class="text-center py-12 text-gray-600">
        加载中...
      </div>
      <div v-else-if="filteredProjects.length === 0" class="glass-card rounded-xl p-12 text-center bg-gradient-to-br from-pink-50/50 to-purple-50/50 border-2 border-pink-200/60">
        <p class="text-gray-600 mb-4">还没有项目</p>
        <button
          @click="showCreateModal = true"
          class="px-6 py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition"
        >
          创建第一个项目
        </button>
      </div>
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          v-for="project in filteredProjects"
          :key="project.id"
          class="bg-white border-2 border-pink-200/60 rounded-xl p-6 cursor-pointer hover:scale-105 transition-transform hover:shadow-lg"
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
          <p class="text-sm text-gray-600 mb-4 line-clamp-2">{{ project.description || '暂无描述' }}</p>
          <div class="flex items-center justify-between text-xs text-gray-500">
            <span>{{ formatDate(project.updatedAt) }}</span>
            <span v-if="project.duration">时长: {{ formatDuration(project.duration) }}</span>
          </div>
          <div class="mt-4 flex gap-2">
            <button
              @click.stop="router.push(`/clip-studio/${project.id}`)"
              class="flex-1 px-4 py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition text-sm font-medium"
            >
              🎬 开始剪辑
            </button>
            <button
              @click.stop="router.push(`/editor/${project.id}`)"
              class="px-4 py-2 border border-pink-200 text-gray-600 rounded-lg hover:bg-pink-50 hover:border-pink-300 hover:text-pink-600 transition text-sm"
            >
              编辑器
            </button>
            <button
              @click.stop="deleteProject(project.id)"
              class="px-4 py-2 border border-red-300 text-red-600 rounded-lg hover:bg-red-50 transition text-sm"
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

