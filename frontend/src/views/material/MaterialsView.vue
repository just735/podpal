<template>
  <div class="min-h-screen bg-gradient-to-br from-[#121524] via-[#1a1f35] to-[#121524] pt-6 pb-12 px-6">
    <div class="container mx-auto max-w-7xl">
      <!-- 头部 -->
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-3xl font-bold text-white mb-2">素材管理</h1>
          <p class="text-[#9DACCC]">管理你的音频、视频素材</p>
        </div>
        <button
          @click="showUploadModal = true"
          class="px-6 py-2 bg-gradient-to-r from-[#485F88] to-[#9DACCC] text-white rounded-lg hover:from-[#9DACCC] hover:to-[#9DACCC] transition flex items-center gap-2"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          上传素材
        </button>
      </div>

      <!-- 筛选和搜索 -->
      <div class="glass-card rounded-xl p-4 mb-6">
        <div class="flex flex-col md:flex-row gap-4">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="搜索素材..."
            class="flex-1 px-4 py-2 bg-[#1a1f35] border border-[#485F88] rounded-lg text-white placeholder-[#9DACCC]/60 focus:outline-none focus:ring-2 focus:ring-[#485F88]"
          />
          <select
            v-model="filterType"
            class="px-4 py-2 bg-[#1a1f35] border border-[#485F88] rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-gray-900"
          >
            <option value="">全部类型</option>
            <option value="audio">音频</option>
            <option value="video">视频</option>
          </select>
          <select
            v-model="sortBy"
            class="px-4 py-2 bg-[#1a1f35] border border-[#485F88] rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-gray-900"
          >
            <option value="createdAt">按时间排序</option>
            <option value="name">按名称排序</option>
            <option value="size">按大小排序</option>
          </select>
        </div>
      </div>

      <!-- 素材列表 -->
      <div v-if="materialStore.loading" class="text-center py-12 text-[#9DACCC]">
        加载中...
      </div>
      <div v-else-if="filteredMaterials.length === 0" class="glass-card rounded-xl p-12 text-center">
        <p class="text-[#9DACCC] mb-4">还没有素材</p>
        <button
          @click="showUploadModal = true"
          class="px-6 py-2 bg-gradient-to-r from-[#485F88] to-[#9DACCC] text-white rounded-lg hover:from-[#9DACCC] hover:to-[#9DACCC] transition"
        >
          上传第一个素材
        </button>
      </div>
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div
          v-for="material in filteredMaterials"
          :key="material.id"
          class="glass-card rounded-xl p-6 hover:scale-105 transition-transform hover:shadow-lg relative group"
        >
          <div class="flex items-start justify-between mb-4">
            <div class="flex-1 min-w-0 pr-4">
              <h3 class="text-lg font-semibold text-white mb-1 truncate" :title="material.name">{{ material.name }}</h3>
              <p class="text-sm text-[#9DACCC]">{{ formatFileSize(material.size) }} · {{ formatDate(material.createdAt) }}</p>
            </div>
            <div class="flex gap-2">
              <button
                @click="previewMaterial(material)"
                class="p-2 hover:bg-[#1a1f35] rounded-lg transition text-[#9DACCC] hover:text-white"
                title="预览"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                </svg>
              </button>
              <button
                @click="deleteMaterial(material.id)"
                class="p-2 hover:bg-red-500/20 rounded-lg transition text-[#9DACCC] hover:text-red-400"
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
              :class="material.type === 'audio' ? 'bg-blue-900/50 text-blue-300 border border-blue-800' : 'bg-purple-900/50 text-purple-300 border border-purple-800'"
            >
              {{ material.type === 'audio' ? '音频' : '视频' }}
            </span>
            <span v-if="material.duration" class="text-xs text-[#9DACCC]/80">
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
import { useMaterialStore } from '../../stores/material'
import UploadModal from '../../components/UploadModal.vue'
import dayjs from 'dayjs'

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

