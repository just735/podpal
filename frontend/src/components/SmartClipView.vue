<template>
  <div class="flex-1 flex flex-col overflow-hidden">
    <!-- 工具�?-->
    <div class="p-4 border-b border-[#485F88]/30 bg-[#1a1f35]">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-4">
          <button
            @click="handleAutoClip"
            class="px-4 py-2 bg-[#485F88] text-white rounded-lg hover:bg-[#9DACCC] transition text-sm"
          >
            一键精华剪辑
          </button>
          <button
            @click="handleRemoveRedundancy"
            class="px-4 py-2 border border-[#485F88] text-[#9DACCC] rounded-lg hover:bg-[#485F88]/30 transition text-sm"
          >
            智能去冗余
          </button>
          <select
            v-model="clipTemplate"
            class="px-4 py-2 bg-[#1a1f35] border border-[#485F88] rounded-lg text-white text-sm focus:outline-none"
          >
            <option value="">选择剪辑模板</option>
            <option value="interview">访谈精华</option>
            <option value="highlights">观点集锦</option>
            <option value="summary">结尾总结</option>
          </select>
        </div>
        <div class="text-sm text-[#9DACCC]">
          {{ clips.length }} 个片段
        </div>
      </div>
    </div>

    <!-- 剪辑片段列表 -->
    <div class="flex-1 overflow-y-auto p-4">
      <div v-if="clips.length === 0" class="text-center py-12 text-[#9DACCC]">
        <p>还没有剪辑片段</p>
        <p class="text-sm mt-2">点击"一键精华剪辑"开始智能剪辑</p>
      </div>
      <div v-else class="space-y-4">
        <div
          v-for="(clip, index) in clips"
          :key="index"
          class="glass-card rounded-lg p-4"
        >
          <div class="flex items-start justify-between mb-2">
            <div class="flex items-center gap-2">
              <span class="text-xs text-[#9DACCC]">{{ formatTime(clip.start) }} - {{ formatTime(clip.end) }}</span>
              <span class="text-xs text-[#9DACCC]">时长: {{ formatDuration(clip.end - clip.start) }}</span>
            </div>
            <div class="flex gap-2">
              <button
                @click="handlePlayClip(clip)"
                class="p-2 hover:bg-[#485F88]/30 rounded-lg transition"
              >
                <svg class="w-5 h-5 text-[#9DACCC]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </button>
              <button
                @click="handleDeleteClip(index)"
                class="p-2 hover:bg-red-500/30 rounded-lg transition"
              >
                <svg class="w-5 h-5 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </div>
          </div>
          <p class="text-sm text-white mb-2">{{ clip.preview || '无预览文本' }}</p>
          <div v-if="clip.tags && clip.tags.length > 0" class="flex flex-wrap gap-2">
            <span
              v-for="tag in clip.tags"
              :key="tag"
              class="px-2 py-1 bg-[#485F88]/20 text-[#9DACCC] rounded text-xs"
            >
              {{ tag }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import api from '../services/api'

const props = defineProps({
  clips: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['update'])

const clipTemplate = ref('')

const formatTime = (seconds) => {
  if (!seconds) return '0:00'
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

const formatDuration = (seconds) => {
  if (!seconds) return '0:00'
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

const handlePlayClip = (clip) => {
  const event = new CustomEvent('audio-seek', { detail: { time: clip.start } })
  window.dispatchEvent(event)
}

const handleDeleteClip = (index) => {
  const updated = [...props.clips]
  updated.splice(index, 1)
  emit('update', updated)
}

const handleAutoClip = async () => {
  try {
    const response = await api.post('/ai/auto-clip', {
      template: clipTemplate.value || null
    })
    emit('update', response.data.clips)
  } catch (error) {
    console.error('自动剪辑失败:', error)
    alert('自动剪辑失败，请重试')
  }
}

const handleRemoveRedundancy = async () => {
  try {
    const response = await api.post('/ai/remove-redundancy')
    emit('update', response.data.clips)
  } catch (error) {
    console.error('去冗余失败:', error)
    alert('去冗余失败，请重试')
  }
}
</script>

