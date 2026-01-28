<template>
  <div class="flex-1 flex flex-col overflow-hidden">
    <div class="p-6 space-y-6 overflow-y-auto">
      <div>
        <h2 class="text-2xl font-bold text-gray-700 mb-4">导出与分发</h2>
        <p class="text-gray-700">导出你的作品并分发到各个平台</p>
      </div>

      <!-- 音频导出 -->
      <div class="glass-card rounded-xl p-6">
        <h3 class="text-lg font-semibold text-gray-700 mb-4">音频导出</h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">导出格式</label>
            <select
              v-model="audioExport.format"
              class="w-full px-4 py-2 bg-white border-2 border-pink-200/60 rounded-lg text-gray-700"
            >
              <option value="mp3">MP3</option>
              <option value="wav">WAV</option>
              <option value="m4a">M4A</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">音质</label>
            <select
              v-model="audioExport.quality"
              class="w-full px-4 py-2 bg-white border-2 border-pink-200/60 rounded-lg text-gray-700"
            >
              <option value="low">(64kbps)</option>
              <option value="medium">(128kbps)</option>
              <option value="high">(192kbps)</option>
              <option value="lossless">无损</option>
            </select>
          </div>
          <button
            @click="exportAudio"
            class="w-full px-4 py-3 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition"
          >
            导出音频
          </button>
        </div>
      </div>

      <!-- 视频导出 -->
      <div class="glass-card rounded-xl p-6">
        <h3 class="text-lg font-semibold text-gray-700 mb-4">视频导出</h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">分辨率</label>
            <select
              v-model="videoExport.resolution"
              class="w-full px-4 py-2 bg-white border-2 border-pink-200/60 rounded-lg text-gray-700"
            >
              <option value="720p">720P</option>
              <option value="1080p">1080P</option>
              <option value="4k">4K</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">格式</label>
            <select
              v-model="videoExport.format"
              class="w-full px-4 py-2 bg-white border-2 border-pink-200/60 rounded-lg text-gray-700"
            >
              <option value="mp4">MP4</option>
              <option value="mov">MOV</option>
            </select>
          </div>
          <button
            @click="exportVideo"
            class="w-full px-4 py-3 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition"
          >
            导出视频
          </button>
        </div>
      </div>

      <!-- 文本导出 -->
      <div class="glass-card rounded-xl p-6">
        <h3 class="text-lg font-semibold text-gray-700 mb-4">文本导出</h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">导出格式</label>
            <select
              v-model="textExport.format"
              class="w-full px-4 py-2 bg-white border-2 border-pink-200/60 rounded-lg text-gray-700"
            >
              <option value="txt">TXT</option>
              <option value="word">Word</option>
              <option value="markdown">Markdown</option>
            </select>
          </div>
          <button
            @click="exportText"
            class="w-full px-4 py-3 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition"
          >
            导出文本
          </button>
        </div>
      </div>

      <!-- 一键分�?-->
      <div class="glass-card rounded-xl p-6">
        <h3 class="text-lg font-semibold text-gray-700 mb-4">一键分发</h3>
        <div class="space-y-3">
          <label class="flex items-center">
            <input type="checkbox" v-model="platforms.ximalaya" class="mr-2" />
            <span class="text-gray-700">喜马拉雅</span>
          </label>
          <label class="flex items-center">
            <input type="checkbox" v-model="platforms.xiaoyuzhou" class="mr-2" />
            <span class="text-gray-700">小宇</span>
          </label>
          <label class="flex items-center">
            <input type="checkbox" v-model="platforms.apple" class="mr-2" />
            <span class="text-gray-700">Apple Podcasts</span>
          </label>
          <label class="flex items-center">
            <input type="checkbox" v-model="platforms.douyin" class="mr-2" />
            <span class="text-gray-700">抖音</span>
          </label>
          <label class="flex items-center">
            <input type="checkbox" v-model="platforms.bilibili" class="mr-2" />
            <span class="text-gray-700">Bilibili</span>
          </label>
          <button
            @click="publishToPlatforms"
            class="w-full px-4 py-3 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition mt-4"
          >
            发布到选中平台
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import api from '../services/api'

const props = defineProps({
  project: {
    type: Object,
    default: null
  }
})

const audioExport = ref({
  format: 'mp3',
  quality: 'high'
})

const videoExport = ref({
  format: 'mp4',
  resolution: '1080p'
})

const textExport = ref({
  format: 'txt'
})

const platforms = ref({
  ximalaya: false,
  xiaoyuzhou: false,
  apple: false,
  douyin: false,
  bilibili: false
})

const exportAudio = async () => {
  try {
    const response = await api.post(`/projects/${props.project?.id}/export/audio`, audioExport.value)
    // 创建下载链接
    const url = response.data.downloadUrl
    window.open(url, '_blank')
  } catch (error) {
    console.error('导出失败:', error)
    alert('导出失败，请重试')
  }
}

const exportVideo = async () => {
  try {
    const response = await api.post(`/projects/${props.project?.id}/export/video`, videoExport.value)
    const url = response.data.downloadUrl
    window.open(url, '_blank')
  } catch (error) {
    console.error('导出失败:', error)
    alert('导出失败，请重试')
  }
}

const exportText = async () => {
  try {
    const response = await api.post(`/projects/${props.project?.id}/export/text`, textExport.value)
    const url = response.data.downloadUrl
    window.open(url, '_blank')
  } catch (error) {
    console.error('导出失败:', error)
    alert('导出失败，请重试')
  }
}

const publishToPlatforms = async () => {
  const selectedPlatforms = Object.entries(platforms.value)
    .filter(([_, selected]) => selected)
    .map(([platform]) => platform)

  if (selectedPlatforms.length === 0) {
    alert('请至少选择一个平台')
    return
  }

  try {
    const response = await api.post(`/projects/${props.project?.id}/publish`, {
      platforms: selectedPlatforms
    })
    alert('发布任务已创建，请稍后查看')
  } catch (error) {
    console.error('发布失败:', error)
    alert('发布失败，请重试')
  }
}
</script>

