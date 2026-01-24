<template>
  <div class="min-h-screen pt-20 pb-12">
    <div class="flex h-[calc(100vh-5rem)]">
      <!-- 左侧边栏 -->
      <div class="w-64 bg-[#1a1f35] border-r border-[#485F88]/30 flex flex-col">
        <div class="p-4 border-b border-[#485F88]/30">
          <h2 class="text-lg font-semibold text-white mb-4">{{ project?.name || '未命名项目' }}</h2>
          <div class="space-y-2">
            <button
              @click="activeTab = 'transcript'"
              class="w-full text-left px-4 py-2 rounded-lg transition"
              :class="activeTab === 'transcript' ? 'bg-[#485F88] text-white' : 'text-[#9DACCC] hover:bg-[#485F88]/30'"
            >
              转写文本
            </button>
            <button
              @click="activeTab = 'clips'"
              class="w-full text-left px-4 py-2 rounded-lg transition"
              :class="activeTab === 'clips' ? 'bg-[#485F88] text-white' : 'text-[#9DACCC] hover:bg-[#485F88]/30'"
            >
              智能剪辑
            </button>
            <button
              @click="activeTab = 'enhance'"
              class="w-full text-left px-4 py-2 rounded-lg transition"
              :class="activeTab === 'enhance' ? 'bg-[#485F88] text-white' : 'text-[#9DACCC] hover:bg-[#485F88]/30'"
            >
              内容增值
            </button>
            <button
              @click="activeTab = 'export'"
              class="w-full text-left px-4 py-2 rounded-lg transition"
              :class="activeTab === 'export' ? 'bg-[#485F88] text-white' : 'text-[#9DACCC] hover:bg-[#485F88]/30'"
            >
              导出分发
            </button>
          </div>
        </div>

        <!-- 项目信息 -->
        <div class="p-4 space-y-4 flex-1 overflow-y-auto">
          <div>
            <h3 class="text-sm font-medium text-[#9DACCC] mb-2">项目信息</h3>
            <div class="text-xs text-[#9DACCC] space-y-1">
              <div>类型: {{ getPodcastTypeText(project?.podcastType) }}</div>
              <div v-if="project?.duration">时长: {{ formatDuration(project.duration) }}</div>
              <div>状态: {{ getStatusText(project?.status) }}</div>
            </div>
          </div>

          <!-- 快捷操作 -->
          <div>
            <h3 class="text-sm font-medium text-[#9DACCC] mb-2">快捷操作</h3>
            <div class="space-y-2">
              <button
                @click="startTranscription"
                :disabled="transcribing"
                class="w-full px-3 py-2 text-sm bg-[#485F88] text-white rounded-lg hover:bg-[#9DACCC] transition disabled:opacity-50"
              >
                {{ transcribing ? '转写中...' : '开始转写' }}
              </button>
              <button
                @click="startSmartClip"
                :disabled="clipping"
                class="w-full px-3 py-2 text-sm bg-[#485F88] text-white rounded-lg hover:bg-[#9DACCC] transition disabled:opacity-50"
              >
                {{ clipping ? '剪辑中...' : '智能剪辑' }}
              </button>
              <button
                @click="saveProject"
                class="w-full px-3 py-2 text-sm border border-[#485F88] text-[#9DACCC] rounded-lg hover:bg-[#485F88]/30 transition"
              >
                保存项目
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- 主内容区 -->
      <div class="flex-1 flex flex-col">
        <!-- 转写文本视图 -->
        <TranscriptEditor
          v-if="activeTab === 'transcript'"
          :transcript="transcript"
          :current-time="currentTime"
          @update="handleTranscriptUpdate"
          @seek="handleSeek"
        />

        <!-- 智能剪辑视图 -->
        <SmartClipView
          v-if="activeTab === 'clips'"
          :clips="clips"
          @update="handleClipsUpdate"
        />

        <!-- 内容增值视图-->
        <EnhanceView
          v-if="activeTab === 'enhance'"
          :project="project"
        />

        <!-- 导出分发视图 -->
        <ExportView
          v-if="activeTab === 'export'"
          :project="project"
        />
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
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useProjectStore } from '../stores/project'
import TranscriptEditor from '../components/TranscriptEditor.vue'
import SmartClipView from '../components/SmartClipView.vue'
import EnhanceView from '../components/EnhanceView.vue'
import ExportView from '../components/ExportView.vue'
import AudioPlayer from '../components/AudioPlayer.vue'
import api from '../services/api'

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

const formatDuration = (seconds) => {
  if (!seconds) return '0:00'
  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60
  return `${mins}:${secs.toString().padStart(2, '0')}`
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

const startTranscription = async () => {
  transcribing.value = true
  try {
    const response = await api.post(`/projects/${projectId.value}/transcribe`)
    transcript.value = response.data.transcript
  } catch (error) {
    console.error('转写失败:', error)
    alert('转写失败，请重试')
  } finally {
    transcribing.value = false
  }
}

const startSmartClip = async () => {
  clipping.value = true
  try {
    const response = await api.post(`/projects/${projectId.value}/smart-clip`, {
      podcastType: project.value?.podcastType || 'knowledge'
    })
    clips.value = response.data.clips
  } catch (error) {
    console.error('智能剪辑失败:', error)
    alert('智能剪辑失败，请重试')
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

const saveProject = async () => {
  try {
    await projectStore.updateProject(projectId.value, {
      transcript: transcript.value,
      clips: clips.value
    })
    alert('保存成功')
  } catch (error) {
    console.error('保存失败:', error)
    alert('保存失败，请重试')
  }
}

onMounted(async () => {
  if (projectId.value) {
    await projectStore.fetchProject(projectId.value)
    if (project.value?.materialId) {
      // 获取素材URL
      const materialResponse = await api.get(`/materials/${project.value.materialId}`)
      audioUrl.value = materialResponse.data.url
    }
    if (project.value?.transcript) {
      transcript.value = project.value.transcript
    }
    if (project.value?.clips) {
      clips.value = project.value.clips
    }
  }
})
</script>

