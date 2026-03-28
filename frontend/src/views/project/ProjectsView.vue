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
          <div class="flex gap-2">
            <button
              v-if="selectedProjects.length > 0"
              @click="handleBatchDelete"
              class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition"
            >
              批量删除 ({{ selectedProjects.length }})
            </button>
            <button
              @click="showBatchActions = !showBatchActions"
              class="px-4 py-2 border border-pink-200 rounded-lg hover:bg-pink-50 transition"
            >
              {{ showBatchActions ? '取消选择' : '批量操作' }}
            </button>
          </div>
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
          class="bg-white border-2 rounded-xl p-6 cursor-pointer hover:scale-105 transition-transform hover:shadow-lg relative"
          :class="selectedProjects.includes(project.id) ? 'border-pink-500 bg-pink-50' : 'border-pink-200/60'"
          @click="showBatchActions ? toggleSelect(project.id) : router.push(`/projects/${project.id}`)"
        >
          <div v-if="showBatchActions" class="absolute top-4 right-4">
            <input
              type="checkbox"
              :checked="selectedProjects.includes(project.id)"
              @click.stop="toggleSelect(project.id)"
              class="w-5 h-5 text-pink-600 rounded focus:ring-pink-500"
            />
          </div>
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
              class="flex-1 px-4 py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition text-sm font-medium flex items-center justify-center gap-1"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              开始剪辑
            </button>
            <button
              @click.stop="router.push(`/editor/${project.id}`)"
              class="px-4 py-2 border border-pink-200 text-gray-600 rounded-lg hover:bg-pink-50 hover:border-pink-300 hover:text-pink-600 transition text-sm flex items-center gap-1"
              title="文本编辑器"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
              </svg>
              编辑
            </button>
            <button
              @click.stop="duplicateProject(project)"
              class="px-3 py-2 border border-gray-200 text-gray-600 rounded-lg hover:bg-gray-50 transition text-sm"
              title="复制项目"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
              </svg>
            </button>
            <button
              @click.stop="deleteProject(project.id)"
              class="px-3 py-2 border border-red-300 text-red-600 rounded-lg hover:bg-red-50 transition text-sm"
              title="删除项目"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
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
const showBatchActions = ref(false)
const selectedProjects = ref([])
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

const stats = computed(() => {
  const projects = projectStore.projects
  return {
    processing: projects.filter(p => p.status === 'processing').length,
    completed: projects.filter(p => p.status === 'completed').length,
    draft: projects.filter(p => p.status === 'draft').length
  }
})

const toggleSelect = (projectId) => {
  const index = selectedProjects.value.indexOf(projectId)
  if (index > -1) {
    selectedProjects.value.splice(index, 1)
  } else {
    selectedProjects.value.push(projectId)
  }
}

const handleBatchDelete = async () => {
  if (selectedProjects.value.length === 0) return
  if (confirm(`确定要删除选中的 ${selectedProjects.value.length} 个项目吗？`)) {
    for (const id of selectedProjects.value) {
      await projectStore.deleteProject(id)
    }
    selectedProjects.value = []
    showBatchActions.value = false
  }
}

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

const duplicateProject = async (project) => {
  const newProject = {
    ...project,
    name: project.name + ' (副本)',
    id: undefined
  }
  delete newProject.id
  const created = await projectStore.createProject(newProject)
  if (created) {
    router.push(`/clip-studio/${created.id}`)
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

