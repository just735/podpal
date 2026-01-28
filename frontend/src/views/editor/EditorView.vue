<template>
  <div class="min-h-screen bg-white flex flex-col">
    <!-- 顶部导航栏 -->
    <header class="h-16 border-b border-pink-200 bg-gradient-to-r from-pink-50 to-purple-50 px-6 flex items-center justify-between sticky top-0 z-50">
      <div class="flex items-center gap-4">
        <button
          @click="router.back()"
          class="p-2 text-gray-600 hover:text-pink-600 hover:bg-pink-100 rounded-lg transition"
          title="返回"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </button>
        <div class="h-6 w-px bg-pink-200"></div>
        <div class="flex items-center gap-3">
          <h1 class="text-lg font-bold bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">
            {{ project?.name || '未命名项目' }}
          </h1>
          <span
            class="px-2 py-1 rounded-full text-xs font-medium"
            :class="getStatusClass(project?.status)"
          >
            {{ getStatusText(project?.status) }}
          </span>
        </div>
      </div>
      <div class="flex items-center gap-4">
        <div v-if="saving" class="flex items-center gap-2 text-sm text-gray-600">
          <svg class="w-4 h-4 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
          </svg>
          保存中...
        </div>
        <div v-else-if="lastSaved" class="text-xs text-gray-500">
          已保存 {{ formatRelativeTime(lastSaved) }}
        </div>
        <button
          @click="saveProject"
          :disabled="saving"
          class="px-4 py-2 text-sm bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
          保存
        </button>
      </div>
    </header>

    <div class="flex flex-1 overflow-hidden">
      <!-- 左侧边栏 -->
      <div class="w-64 bg-gradient-to-b from-pink-50 to-purple-50 border-r border-pink-200 flex flex-col">
        <div class="p-4 border-b border-pink-200">
          <div class="space-y-2">
            <button
              v-for="tab in tabs"
              :key="tab.key"
              @click="activeTab = tab.key"
              class="w-full text-left px-4 py-3 rounded-lg transition-all duration-200 flex items-center gap-3 group"
              :class="activeTab === tab.key 
                ? 'bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white shadow-lg' 
                : 'text-gray-600 hover:bg-pink-100 hover:text-pink-700'"
            >
              <span class="text-lg">{{ tab.icon }}</span>
              <span class="font-medium">{{ tab.label }}</span>
              <span v-if="activeTab === tab.key" class="ml-auto">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                </svg>
              </span>
            </button>
          </div>
        </div>

        <!-- 项目信息 -->
        <div class="p-4 space-y-4 flex-1 overflow-y-auto">
          <div class="glass-card rounded-xl p-4 bg-gradient-to-br from-pink-50/50 to-purple-50/50 border-2 border-pink-200/60">
            <h3 class="text-sm font-semibold text-gray-700 mb-3 flex items-center gap-2">
              <svg class="w-4 h-4 text-pink-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              项目信息
            </h3>
            <div class="text-xs text-gray-600 space-y-2">
              <div class="flex justify-between">
                <span class="text-gray-500">类型:</span>
                <span class="font-medium text-gray-900">{{ getPodcastTypeText(project?.podcastType) }}</span>
              </div>
              <div v-if="project?.duration" class="flex justify-between">
                <span class="text-gray-500">时长:</span>
                <span class="font-medium text-gray-900">{{ formatDuration(project.duration) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-500">创建时间:</span>
                <span class="font-medium text-gray-900">{{ formatDate(project?.createdAt) }}</span>
              </div>
            </div>
          </div>

          <!-- 快捷操作 -->
          <div class="glass-card rounded-xl p-4 bg-gradient-to-br from-pink-50/50 to-purple-50/50 border-2 border-pink-200/60">
            <h3 class="text-sm font-semibold text-gray-700 mb-3 flex items-center gap-2">
              <svg class="w-4 h-4 text-pink-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
              </svg>
              快捷操作
            </h3>
            <div class="space-y-2">
              <button
                @click="startTranscription"
                :disabled="transcribing || loading"
                class="w-full px-3 py-2.5 text-sm bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                <svg v-if="transcribing" class="w-4 h-4 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                </svg>
                <span>{{ transcribing ? '转写中...' : '开始转写' }}</span>
              </button>
              <button
                @click="startSmartClip"
                :disabled="clipping || loading || !transcript.length"
                class="w-full px-3 py-2.5 text-sm bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                <svg v-if="clipping" class="w-4 h-4 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                </svg>
                <span>{{ clipping ? '剪辑中...' : '智能剪辑' }}</span>
              </button>
              <button
                @click="router.push(`/clip-studio/${projectId}`)"
                class="w-full px-3 py-2.5 text-sm border-2 border-pink-200/60 text-gray-600 rounded-lg hover:bg-pink-50 hover:border-pink-300 hover:text-pink-600 transition flex items-center justify-center gap-2"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                进入剪辑工作台
              </button>
            </div>
          </div>

          <!-- 统计信息 -->
          <div class="glass-card rounded-xl p-4 bg-gradient-to-br from-pink-50/50 to-purple-50/50 border-2 border-pink-200/60">
            <h3 class="text-sm font-semibold text-gray-700 mb-3 flex items-center gap-2">
              <svg class="w-4 h-4 text-pink-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
              </svg>
              统计信息
            </h3>
            <div class="text-xs text-gray-600 space-y-2">
              <div class="flex justify-between">
                <span class="text-gray-500">转写片段:</span>
                <span class="font-medium text-pink-600">{{ transcript.length }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-500">剪辑片段:</span>
                <span class="font-medium text-purple-600">{{ clips.length }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 主内容区 -->
      <div class="flex-1 flex flex-col overflow-hidden relative">
        <!-- 加载状态 -->
        <div v-if="loading" class="absolute inset-0 bg-white/80 backdrop-blur-sm flex items-center justify-center z-50">
          <div class="text-center glass-card rounded-xl p-8 bg-gradient-to-br from-pink-50/50 to-purple-50/50 border-2 border-pink-200/60">
            <svg class="w-12 h-12 text-pink-600 animate-spin mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            <p class="text-gray-700 font-medium">加载中...</p>
          </div>
        </div>

        <!-- 错误提示 -->
        <div v-if="error" class="m-4 glass-card rounded-xl p-4 bg-gradient-to-br from-red-50/50 to-pink-50/50 border-2 border-red-200/60 flex items-center justify-between">
          <div class="flex items-center gap-3">
            <svg class="w-5 h-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span class="text-red-700 font-medium">{{ error }}</span>
          </div>
          <button @click="error = ''" class="text-red-500 hover:text-red-700 transition">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <!-- 转写文本视图 -->
        <div v-show="activeTab === 'transcript'" class="flex-1 overflow-auto">
          <TranscriptEditor
            :transcript="transcript"
            :current-time="currentTime"
            @update="handleTranscriptUpdate"
            @seek="handleSeek"
          />
        </div>

        <!-- 智能剪辑视图 -->
        <div v-show="activeTab === 'clips'" class="flex-1 overflow-auto">
          <SmartClipView
            :clips="clips"
            @update="handleClipsUpdate"
          />
        </div>

        <!-- 内容增值视图-->
        <div v-show="activeTab === 'enhance'" class="flex-1 overflow-auto">
          <EnhanceView
            :project="project"
          />
        </div>

        <!-- 导出分发视图 -->
        <div v-show="activeTab === 'export'" class="flex-1 overflow-auto">
          <ExportView
            :project="project"
          />
        </div>
      </div>
    </div>

    <!-- 底部播放器控制栏 -->
    <AudioPlayer
      v-if="audioUrl"
      :audio-url="audioUrl"
      :transcript="transcript"
      @time-update="handleTimeUpdate"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useProjectStore } from '../../stores/project'
import TranscriptEditor from '../../components/TranscriptEditor.vue'
import SmartClipView from '../../components/SmartClipView.vue'
import EnhanceView from '../../components/EnhanceView.vue'
import ExportView from '../../components/ExportView.vue'
import AudioPlayer from '../../components/AudioPlayer.vue'
import api from '../../services/api'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'

dayjs.extend(relativeTime)

const route = useRoute()
const router = useRouter()
const projectStore = useProjectStore()

const projectId = computed(() => route.params.id)
const project = computed(() => projectStore.currentProject)
const activeTab = ref('transcript')
const transcript = ref([])
const clips = ref([])
const audioUrl = ref('')
const currentTime = ref(0)
const transcribing = ref(false)
const clipping = ref(false)
const loading = ref(false)
const saving = ref(false)
const error = ref('')
const lastSaved = ref(null)
let autoSaveTimer = null

const tabs = [
  { key: 'transcript', label: '转写文本', icon: '📝' },
  { key: 'clips', label: '智能剪辑', icon: '✂️' },
  { key: 'enhance', label: '内容增值', icon: '✨' },
  { key: 'export', label: '导出分发', icon: '📤' }
]

// 支持通过路由 query(tab) 指定初始激活的功能页，比如 /editor?tab=export
if (route.query.tab && tabs.some(t => t.key === route.query.tab)) {
  activeTab.value = route.query.tab
}

const formatDuration = (seconds) => {
  if (!seconds) return '0:00'
  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

const formatDate = (date) => {
  if (!date) return '未知'
  return dayjs(date).format('YYYY-MM-DD HH:mm')
}

const formatRelativeTime = (date) => {
  if (!date) return ''
  return dayjs(date).fromNow()
}

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

const getStatusClass = (status) => {
  const statusMap = {
    completed: 'bg-emerald-100 text-emerald-700',
    processing: 'bg-amber-100 text-amber-700',
    draft: 'bg-pink-100 text-pink-700'
  }
  return statusMap[status] || 'bg-gray-100 text-gray-600'
}

const startTranscription = async () => {
  if (!projectId.value) {
    error.value = '项目ID不存在'
    return
  }
  transcribing.value = true
  error.value = ''
  try {
    const response = await api.post(`/projects/${projectId.value}/transcribe`)
    transcript.value = response.data.transcript || []
    // 自动保存
    await autoSave()
  } catch (err) {
    console.error('转写失败:', err)
    error.value = err.response?.data?.message || '转写失败，请重试'
  } finally {
    transcribing.value = false
  }
}

const startSmartClip = async () => {
  if (!projectId.value) {
    error.value = '项目ID不存在'
    return
  }
  if (!transcript.value.length) {
    error.value = '请先完成转写'
    return
  }
  clipping.value = true
  error.value = ''
  try {
    const response = await api.post(`/projects/${projectId.value}/smart-clip`, {
      podcastType: project.value?.podcastType || 'knowledge'
    })
    clips.value = response.data.clips || []
    // 自动保存
    await autoSave()
  } catch (err) {
    console.error('智能剪辑失败:', err)
    error.value = err.response?.data?.message || '智能剪辑失败，请重试'
  } finally {
    clipping.value = false
  }
}

const handleTranscriptUpdate = (updatedTranscript) => {
  transcript.value = updatedTranscript
}

const handleClipsUpdate = (updatedClips) => {
  clips.value = updatedClips
}

const handleSeek = (time) => {
  currentTime.value = time
  // 触发音频播放器跳转
  const event = new CustomEvent('audio-seek', { detail: { time } })
  window.dispatchEvent(event)
}

const handleTimeUpdate = (time) => {
  currentTime.value = time
}

const autoSave = async () => {
  if (!projectId.value || saving.value) return
  saving.value = true
  try {
    await projectStore.updateProject(projectId.value, {
      transcript: transcript.value,
      clips: clips.value
    })
    lastSaved.value = new Date()
  } catch (err) {
    console.error('自动保存失败:', err)
    // 自动保存失败不显示错误，避免打扰用户
  } finally {
    saving.value = false
  }
}

const saveProject = async () => {
  if (!projectId.value) {
    error.value = '项目ID不存在'
    return
  }
  saving.value = true
  error.value = ''
  try {
    await projectStore.updateProject(projectId.value, {
      transcript: transcript.value,
      clips: clips.value
    })
    lastSaved.value = new Date()
    // 显示成功提示
    const successMsg = document.createElement('div')
    successMsg.className = 'fixed top-20 right-6 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white px-4 py-2 rounded-lg shadow-lg z-50 flex items-center gap-2'
    successMsg.innerHTML = `
      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
      </svg>
      <span>保存成功</span>
    `
    document.body.appendChild(successMsg)
    setTimeout(() => {
      if (document.body.contains(successMsg)) {
        document.body.removeChild(successMsg)
      }
    }, 2000)
  } catch (err) {
    console.error('保存失败:', err)
    error.value = err.response?.data?.message || '保存失败，请重试'
  } finally {
    saving.value = false
  }
}

// 监听数据变化，自动保存
watch([transcript, clips], () => {
  if (autoSaveTimer) {
    clearTimeout(autoSaveTimer)
  }
  autoSaveTimer = setTimeout(() => {
    autoSave()
  }, 3000) // 3秒后自动保存
}, { deep: true })

// 键盘快捷键
const handleKeydown = (e) => {
  // Ctrl/Cmd + S 保存
  if ((e.ctrlKey || e.metaKey) && e.key === 's') {
    e.preventDefault()
    saveProject()
  }
  // Ctrl/Cmd + 1-4 切换标签
  if ((e.ctrlKey || e.metaKey) && e.key >= '1' && e.key <= '4') {
    e.preventDefault()
    const index = parseInt(e.key) - 1
    if (tabs[index]) {
      activeTab.value = tabs[index].key
    }
  }
}

onMounted(async () => {
  loading.value = true
  error.value = ''
  
  try {
    if (projectId.value) {
      await projectStore.fetchProject(projectId.value)
      
      if (!project.value) {
        error.value = '项目不存在'
        loading.value = false
        return
      }

      // 获取素材URL
      if (project.value?.materialId) {
        try {
          const materialResponse = await api.get(`/materials/${project.value.materialId}`)
          audioUrl.value = materialResponse.data.url || ''
        } catch (err) {
          console.warn('获取素材URL失败:', err)
          // 素材获取失败不影响其他功能
        }
      }

      // 加载转写数据
      if (project.value?.transcript) {
        transcript.value = Array.isArray(project.value.transcript) 
          ? project.value.transcript 
          : []
      }

      // 加载剪辑数据
      if (project.value?.clips) {
        clips.value = Array.isArray(project.value.clips) 
          ? project.value.clips 
          : []
      }

      lastSaved.value = project.value?.updatedAt ? new Date(project.value.updatedAt) : null
    } else {
      error.value = '缺少项目ID'
    }
  } catch (err) {
    console.error('加载项目失败:', err)
    error.value = err.response?.data?.message || '加载项目失败，请重试'
  } finally {
    loading.value = false
  }

  // 添加键盘快捷键监听
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  // 清理定时器
  if (autoSaveTimer) {
    clearTimeout(autoSaveTimer)
  }
  // 移除键盘快捷键监听
  document.removeEventListener('keydown', handleKeydown)
})
</script>

