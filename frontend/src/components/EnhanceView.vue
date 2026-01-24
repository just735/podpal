<template>
  <div class="flex-1 flex flex-col overflow-hidden">
    <div class="p-6 space-y-6 overflow-y-auto">
      <div>
        <h2 class="text-2xl font-bold text-white mb-4">内容增值</h2> 
        <p class="text-[#9DACCC]">为你的播客内容生成增值素材</p>
      </div>

      <!-- 文案生成 -->
      <div class="glass-card rounded-xl p-6">
        <h3 class="text-lg font-semibold text-white mb-4">文案生成</h3>
        <div class="space-y-4">
          <button
            @click="generateShownotes"
            class="w-full px-4 py-3 bg-[#485F88] text-white rounded-lg hover:bg-[#9DACCC] transition text-left"
          >
            <div class="font-medium">生成 Show Notes</div>
            <div class="text-sm text-[#9DACCC] mt-1">自动生成播客文字笔记，包含标题、核心亮点、时间轴要点</div>
          </button>
          <button
            @click="generatePromoCopy"
            class="w-full px-4 py-3 border border-[#485F88] text-[#9DACCC] rounded-lg hover:bg-[#485F88]/30 transition text-left"
          >
            <div class="font-medium">生成推广文案</div>
            <div class="text-sm text-[#9DACCC] mt-1">生成适配公众号、小红书、微博、短视频平台的推广文案</div>
          </button>
          <button
            @click="generateTitles"
            class="w-full px-4 py-3 border border-[#485F88] text-[#9DACCC] rounded-lg hover:bg-[#485F88]/30 transition text-left"
          >
            <div class="font-medium">生成标题</div>
            <div class="text-sm text-[#9DACCC] mt-1">AI推荐多个吸睛标题，支持自定义关键词优化</div>
          </button>
        </div>
      </div>

      <!-- 播客视频�?-->
      <div class="glass-card rounded-xl p-6">
        <h3 class="text-lg font-semibold text-white mb-4">播客视频</h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-[#C0C9DB] mb-2">视频尺寸</label>
            <select
              v-model="videoSettings.aspectRatio"
              class="w-full px-4 py-2 bg-[#1a1f35] border border-[#485F88] rounded-lg text-white"
            >
              <option value="9:16">竖屏 (9:16) - 抖音/快手</option>
              <option value="16:9">横屏 (16:9) - Bilibili/YouTube</option>
              <option value="1:1">方形 (1:1) - Instagram</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-[#C0C9DB] mb-2">视频模板</label>
            <select
              v-model="videoSettings.template"
              class="w-full px-4 py-2 bg-[#1a1f35] border border-[#485F88] rounded-lg text-white"
            >
              <option value="simple">简约风</option>
              <option value="tech">科技</option>
              <option value="artistic">文艺</option>
            </select>
          </div>
          <button
            @click="generateVideo"
            class="w-full px-4 py-3 bg-[#485F88] text-white rounded-lg hover:bg-[#9DACCC] transition"
          >
            生成视频
          </button>
        </div>
      </div>

      <!-- 交互式播�?-->
      <div class="glass-card rounded-xl p-6">
        <h3 class="text-lg font-semibold text-white mb-4">交互式播客生成</h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-[#C0C9DB] mb-2">互动节点频率</label>
            <input
              v-model.number="interactiveSettings.frequency"
              type="number"
              min="1"
              max="10"
              class="w-full px-4 py-2 bg-[#1a1f35] border border-[#485F88] rounded-lg text-white"
            />
            <p class="text-xs text-[#9DACCC] mt-1">N 分钟设置一个互动节点</p>
          </div>
          <button
            @click="generateInteractive"
            class="w-full px-4 py-3 bg-[#485F88] text-white rounded-lg hover:bg-[#9DACCC] transition"
          >
            生成交互式播客
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

const videoSettings = ref({
  aspectRatio: '9:16',
  template: 'simple'
})

const interactiveSettings = ref({
  frequency: 5
})

const generateShownotes = async () => {
  try {
    const response = await api.post(`/projects/${props.project?.id}/generate-shownotes`)
    // 显示结果
    console.log('Show Notes:', response.data.shownotes)
    alert('Show Notes已生成，请查看控制台')
  } catch (error) {
    console.error('生成失败:', error)
    alert('生成失败，请重试')
  }
}

const generatePromoCopy = async () => {
  try {
    const response = await api.post(`/projects/${props.project?.id}/generate-promo-copy`)
    console.log('推广文案:', response.data.copy)
    alert('推广文案已生成，请查看控制台')
  } catch (error) {
    console.error('生成失败:', error)
    alert('生成失败，请重试')
  }
}

const generateTitles = async () => {
  try {
    const response = await api.post(`/projects/${props.project?.id}/generate-titles`)
    console.log('标题:', response.data.titles)
    alert('标题已生成，请查看控制台')
  } catch (error) {
    console.error('生成失败:', error)
    alert('生成失败，请重试')
  }
}

const generateVideo = async () => {
  try {
    const response = await api.post(`/projects/${props.project?.id}/generate-video`, videoSettings.value)
    console.log('视频生成任务已创建', response.data.taskId)
    alert('视频生成任务已创建，请稍后查看')
  } catch (error) {
    console.error('生成失败:', error)
    alert('生成失败，请重试')
  }
}

const generateInteractive = async () => {
  try {
    const response = await api.post(`/projects/${props.project?.id}/generate-interactive`, interactiveSettings.value)
    console.log('交互式播客已生成:', response.data)
    alert('交互式播客已生成')
  } catch (error) {
    console.error('生成失败:', error)
    alert('生成失败，请重试')
  }
}
</script>

