<template>
  <div class="flex-1 flex flex-col overflow-hidden">
    <!-- 工具�?-->
    <div class="p-4 border-b border-[#485F88]/30 bg-[#1a1f35]">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-4">
          <button
            @click="handleOptimize"
            class="px-4 py-2 bg-[#485F88] text-white rounded-lg hover:bg-[#9DACCC] transition text-sm"
          >
            AI优化文本
          </button>
          <button
            @click="handleExtractKeywords"
            class="px-4 py-2 border border-[#485F88] text-[#9DACCC] rounded-lg hover:bg-[#485F88]/30 transition text-sm"
          >
            提取关键词
          </button>
          <button
            @click="handleGenerateShownotes"
            class="px-4 py-2 border border-[#485F88] text-[#9DACCC] rounded-lg hover:bg-[#485F88]/30 transition text-sm"
          >
            生成Shownotes
          </button>
        </div>
        <div class="text-sm text-[#9DACCC]">
          {{ transcript.length }} 条转写片段
        </div>
      </div>
    </div>

    <!-- 转写文本列表 -->
    <div class="flex-1 overflow-y-auto p-4">
      <div v-if="transcript.length === 0" class="text-center py-12 text-[#9DACCC]">
        <p>还没有转写内容</p>
        <p class="text-sm mt-2">请先上传素材并开始转写</p>
      </div>
      <div v-else class="space-y-4">
        <div
          v-for="(item, index) in transcript"
          :key="index"
          class="glass-card rounded-lg p-4 cursor-pointer hover:bg-[#485F88]/10 transition"
          :class="{ 'ring-2 ring-[#485F88]': isCurrentSegment(item) }"
          @click="handleSegmentClick(item)"
        >
          <div class="flex items-start justify-between mb-2">
            <div class="flex items-center gap-2">
              <span class="text-xs text-[#9DACCC]">{{ formatTime(item.start) }} - {{ formatTime(item.end) }}</span>
              <span v-if="item.speaker" class="px-2 py-1 bg-[#485F88]/30 text-[#9DACCC] rounded text-xs">
                {{ item.speaker }}
              </span>
            </div>
            <div class="flex gap-2">
              <button
                @click.stop="handleDelete(index)"
                class="p-1 hover:bg-red-500/30 rounded transition"
              >
                <svg class="w-4 h-4 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </div>
          </div>
          <textarea
            v-model="item.text"
            @input="handleTextChange"
            class="w-full bg-transparent text-white resize-none focus:outline-none"
            rows="2"
            :placeholder="'转写文本...'"
          ></textarea>
          <div v-if="item.keywords && item.keywords.length > 0" class="mt-2 flex flex-wrap gap-2">
            <span
              v-for="keyword in item.keywords"
              :key="keyword"
              class="px-2 py-1 bg-[#485F88]/20 text-[#9DACCC] rounded text-xs"
            >
              {{ keyword }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import api from '../services/api'

const props = defineProps({
  transcript: {
    type: Array,
    required: true
  },
  currentTime: {
    type: Number,
    default: 0
  }
})

const emit = defineEmits(['update', 'seek'])

const isCurrentSegment = (item) => {
  return props.currentTime >= item.start && props.currentTime <= item.end
}

const formatTime = (seconds) => {
  if (!seconds) return '0:00'
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

const handleSegmentClick = (item) => {
  emit('seek', item.start)
}

const handleTextChange = () => {
  emit('update', [...props.transcript])
}

const handleDelete = (index) => {
  const updated = [...props.transcript]
  updated.splice(index, 1)
  emit('update', updated)
}

const handleOptimize = async () => {
  try {
    const response = await api.post('/ai/optimize-text', {
      transcript: props.transcript
    })
    emit('update', response.data.optimizedTranscript)
  } catch (error) {
    console.error('优化失败:', error)
    alert('文本优化失败，请重试')
  }
}

const handleExtractKeywords = async () => {
  try {
    const response = await api.post('/ai/extract-keywords', {
      transcript: props.transcript
    })
    // 更新关键词
    const updated = props.transcript.map((item, index) => ({
      ...item,
      keywords: response.data.keywords[index] || []
    }))
    emit('update', updated)
  } catch (error) {
    console.error('提取关键词失败:', error)
    alert('提取关键词失败，请重试')
  }
}

const handleGenerateShownotes = async () => {
  try {
    const response = await api.post('/ai/generate-shownotes', {
      transcript: props.transcript
    })
    // 可以打开一个新窗口或模态框显示shownotes
    console.log('Shownotes:', response.data.shownotes)
    alert('Shownotes已生成，请查看控制台')
  } catch (error) {
    console.error('生成Shownotes失败:', error)
    alert('生成Shownotes失败，请重试')
  }
}
</script>

