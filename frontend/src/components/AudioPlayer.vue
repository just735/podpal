<template>
  <div class="fixed bottom-0 left-0 right-0 bg-gradient-to-r from-pink-50 to-purple-50 border-t border-pink-200 p-4 z-40 shadow-lg">
    <div class="container mx-auto max-w-7xl">
      <div class="flex items-center gap-4">
        <!-- 播放控制 -->
        <button
          @click="togglePlay"
          class="w-12 h-12 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] rounded-full flex items-center justify-center hover:shadow-lg hover:scale-105 transition"
        >
          <svg v-if="!isPlaying" class="w-6 h-6 text-white ml-1" fill="currentColor" viewBox="0 0 24 24">
            <path d="M8 5v14l11-7z" />
          </svg>
          <svg v-else class="w-6 h-6 text-white" fill="currentColor" viewBox="0 0 24 24">
            <path d="M6 4h4v16H6V4zm8 0h4v16h-4V4z" />
          </svg>
        </button>

        <!-- 时间显示 -->
        <div class="text-sm text-gray-700 min-w-[100px] font-medium">
          {{ formatTime(currentTime) }} / {{ formatTime(duration) }}
        </div>

        <!-- 进度条-->
        <div class="flex-1 relative" @click="handleProgressClick">
          <div class="h-2 bg-pink-100 rounded-full overflow-hidden cursor-pointer">
            <div
              class="h-full bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] transition-all"
              :style="{ width: progressPercent + '%' }"
            ></div>
          </div>
        </div>

        <!-- 音量控制 -->
        <div class="flex items-center gap-2">
          <button @click="toggleMute" class="p-2 hover:bg-pink-100 rounded-lg transition">
            <svg v-if="!isMuted" class="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
            </svg>
            <svg v-else class="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2" />
            </svg>
          </button>
          <input
            v-model.number="volume"
            type="range"
            min="0"
            max="100"
            class="w-20 accent-pink-500"
            @input="handleVolumeChange"
          />
        </div>
      </div>
    </div>

    <audio
      ref="audioElement"
      :src="audioUrl"
      @loadedmetadata="handleLoadedMetadata"
      @timeupdate="handleTimeUpdate"
      @ended="handleEnded"
    ></audio>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'

const props = defineProps({
  audioUrl: {
    type: String,
    required: true
  },
  transcript: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['time-update'])

const audioElement = ref(null)
const isPlaying = ref(false)
const currentTime = ref(0)
const duration = ref(0)
const volume = ref(100)
const isMuted = ref(false)

const progressPercent = computed(() => {
  if (duration.value === 0) return 0
  return (currentTime.value / duration.value) * 100
})

const formatTime = (seconds) => {
  if (!seconds || isNaN(seconds)) return '0:00'
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

const togglePlay = () => {
  if (!audioElement.value) return
  
  if (isPlaying.value) {
    audioElement.value.pause()
  } else {
    audioElement.value.play()
  }
  isPlaying.value = !isPlaying.value
}

const toggleMute = () => {
  if (!audioElement.value) return
  isMuted.value = !isMuted.value
  audioElement.value.muted = isMuted.value
}

const handleProgressClick = (e) => {
  if (!audioElement.value || !duration.value) return
  const rect = e.currentTarget.getBoundingClientRect()
  const percent = (e.clientX - rect.left) / rect.width
  const newTime = percent * duration.value
  audioElement.value.currentTime = newTime
  currentTime.value = newTime
}

const handleVolumeChange = () => {
  if (!audioElement.value) return
  audioElement.value.volume = volume.value / 100
}

const handleLoadedMetadata = () => {
  if (audioElement.value) {
    duration.value = audioElement.value.duration
  }
}

const handleTimeUpdate = () => {
  if (audioElement.value) {
    currentTime.value = audioElement.value.currentTime
    emit('time-update', currentTime.value)
  }
}

const handleEnded = () => {
  isPlaying.value = false
  currentTime.value = 0
}

const handleSeek = (e) => {
  if (audioElement.value && e.detail?.time !== undefined) {
    audioElement.value.currentTime = e.detail.time
    currentTime.value = e.detail.time
  }
}

onMounted(() => {
  window.addEventListener('audio-seek', handleSeek)
  if (audioElement.value) {
    audioElement.value.volume = volume.value / 100
  }
})

onUnmounted(() => {
  window.removeEventListener('audio-seek', handleSeek)
})

watch(() => props.audioUrl, () => {
  if (audioElement.value) {
    audioElement.value.load()
  }
})
</script>

