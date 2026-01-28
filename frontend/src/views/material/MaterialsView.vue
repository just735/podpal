<template>
  <div class="min-h-screen bg-white pt-24 pb-12 px-6">
    <div class="container mx-auto max-w-7xl">
      <!-- 头部 -->
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-3xl font-bold bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent mb-2">素材管理</h1>
          <p class="text-gray-600">管理你的音频、视频素材</p>
        </div>
        <button
          @click="showUploadModal = true"
          class="px-6 py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition flex items-center gap-2"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          上传素材
        </button>
      </div>

      <!-- 筛选和搜索 -->
      <div class="glass-card rounded-xl p-4 mb-6 bg-gradient-to-br from-pink-50/50 to-purple-50/50 border-2 border-pink-200/60">
        <div class="flex flex-col md:flex-row gap-4">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="搜索素材..."
            class="flex-1 px-4 py-2 bg-white border border-pink-200 rounded-lg text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-pink-300 focus:border-pink-300"
          />
          <select
            v-model="filterType"
            class="px-4 py-2 bg-white border border-pink-200 rounded-lg text-gray-900 focus:outline-none focus:ring-2 focus:ring-pink-300 focus:border-pink-300"
          >
            <option value="">全部类型</option>
            <option value="audio">音频</option>
            <option value="video">视频</option>
          </select>
          <select
            v-model="sortBy"
            class="px-4 py-2 bg-white border border-pink-200 rounded-lg text-gray-900 focus:outline-none focus:ring-2 focus:ring-pink-300 focus:border-pink-300"
          >
            <option value="createdAt">按时间排序</option>
            <option value="name">按名称排序</option>
            <option value="size">按大小排序</option>
          </select>
        </div>
      </div>

      <!-- 素材列表 -->
      <div v-if="materialStore.loading" class="text-center py-12 text-gray-600">
        加载中...
      </div>
      <div v-else-if="filteredMaterials.length === 0" class="glass-card rounded-xl p-12 text-center bg-gradient-to-br from-pink-50/50 to-purple-50/50 border-2 border-pink-200/60">
        <p class="text-gray-600 mb-4">还没有素材</p>
        <button
          @click="showUploadModal = true"
          class="px-6 py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition"
        >
          上传第一个素材
        </button>
      </div>
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div
          v-for="material in filteredMaterials"
          :key="material.id"
          class="glass-card rounded-xl p-6 hover:scale-105 transition-transform hover:shadow-lg relative group bg-white border-2 border-pink-200/60"
        >
          <div class="flex items-start justify-between mb-4">
            <div class="flex-1 min-w-0 pr-4">
              <h3 class="text-lg font-semibold text-gray-900 mb-1 truncate" :title="material.name">{{ material.name }}</h3>
              <p class="text-sm text-gray-600">{{ formatFileSize(material.size) }} · {{ formatDate(material.createdAt) }}</p>
            </div>
            <div class="flex gap-2">
              <button
                @click="previewMaterial(material)"
                class="p-2 hover:bg-pink-50 rounded-lg transition text-gray-600 hover:text-pink-600"
                title="预览"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                </svg>
              </button>
              <button
                @click="addToProject(material)"
                class="p-2 hover:bg-blue-50 rounded-lg transition text-gray-600 hover:text-blue-600"
                title="添加到项目"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                </svg>
              </button>
              <button
                @click="deleteMaterial(material.id)"
                class="p-2 hover:bg-red-50 rounded-lg transition text-gray-600 hover:text-red-600"
                title="删除"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </div>
          </div>
          <div class="flex items-center gap-2">
            <span
              class="px-2 py-1 rounded text-xs"
              :class="material.type === 'audio' ? 'bg-blue-100 text-blue-700 border border-blue-300' : 'bg-purple-100 text-purple-700 border border-purple-300'"
            >
              {{ material.type === 'audio' ? '音频' : '视频' }}
            </span>
            <span v-if="material.duration" class="text-xs text-gray-500">
              时长: {{ formatDuration(material.duration) }}
            </span>
          </div>
        </div>
      </div>

      <!-- 上传模态框 -->
      <UploadModal
        v-if="showUploadModal"
        @close="showUploadModal = false"
        @uploaded="handleUploaded"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useMaterialStore } from '../../stores/material'
import UploadModal from '../../components/UploadModal.vue'
import dayjs from 'dayjs'

const router = useRouter()

const materialStore = useMaterialStore()
const showUploadModal = ref(false)
const searchQuery = ref('')
const filterType = ref('')
const sortBy = ref('createdAt')

const filteredMaterials = computed(() => {
  let materials = [...materialStore.materials]

  if (searchQuery.value) {
    materials = materials.filter(m =>
      m.name.toLowerCase().includes(searchQuery.value.toLowerCase())
    )
  }

  if (filterType.value) {
    materials = materials.filter(m => m.type === filterType.value)
  }

  materials.sort((a, b) => {
    if (sortBy.value === 'name') {
      return a.name.localeCompare(b.name)
    } else if (sortBy.value === 'size') {
      return b.size - a.size
    } else {
      return new Date(b.createdAt) - new Date(a.createdAt)
    }
  })

  return materials
})

const formatFileSize = (bytes) => {
  if (!bytes) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
}

const formatDate = (date) => {
  if (!date) return '未知'
  return dayjs(date).format('YYYY-MM-DD HH:mm')
}

const formatDuration = (seconds) => {
  if (!seconds) return ''
  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

const previewMaterial = (material) => {
  // 简单的预览反馈，实际项目中可以弹出一个播放器模态框
  alert(`正在预览: ${material.name}\n类型: ${material.type === 'audio' ? '音频' : '视频'}`)
}

const addToProject = (material) => {
  // 显示项目选择对话框，让用户选择要添加到的项目
  const projectId = prompt('请输入项目ID，或留空创建新项目:')
  if (projectId) {
    router.push(`/clip-studio/${projectId}?material=${material.id}`)
  } else {
    router.push(`/projects?create=true&material=${material.id}`)
  }
}

const deleteMaterial = async (id) => {
  if (confirm('确定要删除这个素材吗？')) {
    await materialStore.deleteMaterial(id)
  }
}

const handleUploaded = () => {
  showUploadModal.value = false
  materialStore.fetchMaterials()
}

onMounted(async () => {
  const result = await materialStore.fetchMaterials()
  
  // 如果获取失败或列表为空（可能是因为没有后端），注入模拟数据以便演示
  if (!result.success || materialStore.materials.length === 0) {
    console.log('Using mock data for demonstration')
    materialStore.materials = [
      { 
        id: 1, 
        name: 'Interview_Guest_A.mp3', 
        type: 'audio', 
        size: 15 * 1024 * 1024, 
        duration: 1200, 
        createdAt: new Date().toISOString() 
      },
      { 
        id: 2, 
        name: 'Background_Jazz.mp3', 
        type: 'audio', 
        size: 5 * 1024 * 1024, 
        duration: 300, 
        createdAt: new Date(Date.now() - 86400000).toISOString() 
      },
      { 
        id: 3, 
        name: 'Intro_Animation.mp4', 
        type: 'video', 
        size: 50 * 1024 * 1024, 
        duration: 15, 
        createdAt: new Date(Date.now() - 172800000).toISOString() 
      },
      { 
        id: 4, 
        name: 'Sound_Effect_Click.wav', 
        type: 'audio', 
        size: 500 * 1024, 
        duration: 2, 
        createdAt: new Date(Date.now() - 259200000).toISOString() 
      },
      {
        id: 5,
        name: 'Demo_Podcast_Ep1.mp4',
        type: 'video',
        size: 120 * 1024 * 1024,
        duration: 2400,
        createdAt: new Date(Date.now() - 345600000).toISOString()
      }
    ]
  }
})
</script>

