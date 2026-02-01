<template>
  <div class="flex-1 flex flex-col overflow-hidden">
    <div class="p-6 space-y-6 overflow-y-auto">
      <div>
        <h2 class="text-2xl font-bold text-gray-700 mb-4">内容增值</h2> 
        <p class="text-gray-600">为你的播客内容生成增值素材</p>
      </div>

      <!-- 文案生成 -->
      <div class="glass-card rounded-xl p-6">
        <h3 class="text-lg font-semibold text-gray-700 mb-4">文案生成</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <button
            @click="generateShownotes"
            :disabled="isGenerating"
            class="px-4 py-3 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition text-left disabled:opacity-50 disabled:scale-100"
          >
            <div class="font-medium">生成 Show Notes</div>
            <div class="text-[10px] text-white/80 mt-1 line-clamp-1">自动生成笔记、亮点与时间轴</div>
          </button>
          <button
            @click="generatePromoCopy"
            :disabled="isGenerating"
            class="px-4 py-3 border-2 border-pink-200/60 text-gray-600 rounded-lg hover:bg-pink-50 hover:border-pink-300 hover:text-pink-600 transition text-left disabled:opacity-50"
          >
            <div class="font-medium">生成推广文案</div>
            <div class="text-[10px] text-gray-500 mt-1 line-clamp-1">适配公众号、小红书、微博</div>
          </button>
          <button
            @click="generateTitles"
            :disabled="isGenerating"
            class="px-4 py-3 border-2 border-pink-200/60 text-gray-600 rounded-lg hover:bg-pink-50 hover:border-pink-300 hover:text-pink-600 transition text-left disabled:opacity-50"
          >
            <div class="font-medium">生成标题</div>
            <div class="text-[10px] text-gray-500 mt-1 line-clamp-1">AI推荐多个吸睛标题</div>
          </button>
        </div>

        <!-- 生成结果展示区 -->
        <div v-if="isGenerating || generatedResult" class="mt-6 border-t border-pink-100 pt-6 animate-fadeIn">
          <div v-if="isGenerating" class="flex flex-col items-center justify-center py-12">
            <div class="w-12 h-12 border-4 border-pink-100 border-t-pink-500 rounded-full animate-spin mb-4"></div>
            <p class="text-gray-500 text-sm">AI 正在为您精心准备内容...</p>
          </div>
          
          <div v-else-if="generatedResult" class="space-y-6">
            <div class="flex items-center justify-between">
              <h4 class="font-bold text-gray-800 flex items-center gap-2">
                <span class="w-1 h-5 bg-pink-500 rounded-full"></span>
                {{ generatedResult.type }}
              </h4>
              <button 
                @click="copyResult" 
                class="text-xs text-pink-600 hover:text-pink-700 flex items-center gap-1 bg-pink-50 px-2 py-1 rounded transition"
              >
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3" /></svg>
                复制全文
              </button>
            </div>

            <!-- Shownotes 特有样式 -->
            <div v-if="generatedResult.id === 'shownotes'" class="space-y-6 bg-white/50 rounded-xl p-4 border border-pink-50">
              <div v-if="generatedResult.content.title" class="space-y-2">
                <div class="text-xs font-bold text-pink-400 uppercase tracking-wider">推荐标题</div>
                <div class="text-lg font-bold text-gray-800">{{ generatedResult.content.title }}</div>
              </div>

              <div v-if="generatedResult.content.summary" class="space-y-2">
                <div class="text-xs font-bold text-pink-400 uppercase tracking-wider">核心内容简介</div>
                <p class="text-sm text-gray-600 leading-relaxed">{{ generatedResult.content.summary }}</p>
              </div>

              <div v-if="generatedResult.content.timeline && generatedResult.content.timeline.length > 0" class="space-y-4">
                <div class="text-xs font-bold text-pink-400 uppercase tracking-wider">内容时间轴</div>
                <div class="space-y-3">
                  <div 
                    v-for="(item, idx) in generatedResult.content.timeline" 
                    :key="idx"
                    class="flex gap-4 group cursor-pointer hover:bg-pink-50/50 p-2 rounded-lg transition-colors"
                  >
                    <div class="flex-none font-mono text-sm text-pink-500 font-bold bg-pink-50 px-2 py-0.5 rounded h-fit group-hover:bg-pink-100 transition-colors">
                      {{ item.timestamp }}
                    </div>
                    <div class="space-y-1">
                      <div class="text-sm font-bold text-gray-800">{{ item.topic }}</div>
                      <div class="text-xs text-gray-500 leading-relaxed">{{ item.description }}</div>
                    </div>
                  </div>
                </div>
              </div>

              <div v-if="generatedResult.content.highlights && generatedResult.content.highlights.length > 0" class="space-y-3">
                <div class="text-xs font-bold text-pink-400 uppercase tracking-wider">核心亮点</div>
                <ul class="space-y-2">
                  <li 
                    v-for="(highlight, idx) in generatedResult.content.highlights" 
                    :key="idx"
                    class="text-sm text-gray-600 flex gap-2 items-start"
                  >
                    <span class="text-pink-400 mt-1">✦</span>
                    {{ highlight }}
                  </li>
                </ul>
              </div>
            </div>

            <!-- 其他文案样式 -->
            <div v-else class="bg-white/50 rounded-xl p-4 border border-pink-50 whitespace-pre-wrap text-sm text-gray-600 leading-relaxed">
              {{ generatedResult.rawContent }}
            </div>
          </div>
        </div>
      </div>

      <!-- 播客视频�?-->
      <div class="glass-card rounded-xl p-6">
        <h3 class="text-lg font-semibold text-gray-700 mb-4">播客视频</h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">视频尺寸</label>
            <select
              v-model="videoSettings.aspectRatio"
              class="w-full px-4 py-2 bg-white border-2 border-pink-200/60 rounded-lg text-gray-700"
            >
              <option value="9:16">竖屏 (9:16) - 抖音/快手</option>
              <option value="16:9">横屏 (16:9) - Bilibili/YouTube</option>
              <option value="1:1">方形 (1:1) - Instagram</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">视频模板</label>
            <select
              v-model="videoSettings.template"
              class="w-full px-4 py-2 bg-white border-2 border-pink-200/60 rounded-lg text-gray-700"
            >
              <option value="simple">简约风</option>
              <option value="tech">科技</option>
              <option value="artistic">文艺</option>
            </select>
          </div>
          <button
            @click="generateVideo"
            class="w-full px-4 py-3 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition"
          >
            生成视频
          </button>
        </div>
      </div>

      <!-- 交互式播�?-->
      <div class="glass-card rounded-xl p-6">
        <h3 class="text-lg font-semibold text-gray-700 mb-4">交互式播客生成</h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">互动节点频率</label>
            <input
              v-model.number="interactiveSettings.frequency"
              type="number"
              min="1"
              max="10"
              class="w-full px-4 py-2 bg-white border-2 border-pink-200/60 rounded-lg text-gray-700"
            />
            <p class="text-xs text-gray-600 mt-1">N 分钟设置一个互动节点</p>
          </div>
          <button
            @click="generateInteractive"
            class="w-full px-4 py-3 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition"
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

const isGenerating = ref(false)
const generatedResult = ref(null)

const generateShownotes = async () => {
  isGenerating.value = true
  generatedResult.value = null
  
  try {
    // 模拟 API 延迟
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    // 模拟生成的 Shownotes 数据
    const mockShownotes = {
      title: "EP12: 人工智能如何重塑内容创作的未来",
      summary: "在这一期节目中，我们深入探讨了 AI 技术的最新进展，特别是生成式 AI 在文字、音频和视频创作中的实际应用。我们邀请到了资深产品专家，共同分析 AI 究竟是创作者的助手还是替代者。",
      timeline: [
        {
          timestamp: "00:00:45",
          topic: "开场介绍：为什么现在是关注 AI 创作的最佳时机？",
          description: "简述生成式 AI 的爆发背景以及对创作者生态的冲击。"
        },
        {
          timestamp: "05:12:00",
          topic: "核心技术拆解：LLM 与扩散模型的工作原理",
          description: "用通俗易懂的语言解释 AI 创作背后的黑盒逻辑。"
        },
        {
          timestamp: "12:30:15",
          topic: "实战案例：如何利用 PodPal 提升 10 倍制作效率",
          description: "详细展示从音频转录到智能剪辑的全流程优化。"
        },
        {
          timestamp: "28:45:00",
          topic: "争议与未来：版权、伦理与创作者的独特性",
          description: "探讨在 AI 时代，人类创作者的核心竞争力究竟在哪里。"
        }
      ],
      highlights: [
        "AI 不是在取代人类，而是在解放重复性劳动",
        "未来的创作者将是‘超级个体’，拥有指挥 AI 军团的能力",
        "工具的平民化将带来新一轮的内容创作大爆发"
      ]
    }

    generatedResult.value = {
      id: 'shownotes',
      type: 'Show Notes (播客笔记)',
      content: mockShownotes,
      rawContent: `【推荐标题】\n${mockShownotes.title}\n\n【内容简介】\n${mockShownotes.summary}\n\n【时间轴】\n${mockShownotes.timeline.map(t => `${t.timestamp} ${t.topic}`).join('\n')}`
    }
  } catch (error) {
    console.error('生成失败:', error)
    alert('生成失败，请重试')
  } finally {
    isGenerating.value = false
  }
}

const generatePromoCopy = async () => {
  isGenerating.value = true
  generatedResult.value = null
  
  try {
    await new Promise(resolve => setTimeout(resolve, 1500))
    
    const mockCopy = `【小红书风格文案】\nAI 创作要逆天了？😱 作为一个播客主，我真的被惊到了！\n\n最近试用了 PodPal，真的香！以前剪辑 3 小时，现在只要 10 分钟。这期节目带你拆解 AI 时代的创作新姿势！✨\n\n#播客 #AI #PodPal #效率工具 #内容创业\n\n------------------\n\n【公众号摘要】\n在内容创作的十字路口，你是选择拥抱技术，还是原地踏步？本文整理自最新一期播客内容，深度剖析 AI 创作的底层逻辑与实战技巧。`

    generatedResult.value = {
      id: 'promo',
      type: '推广文案',
      rawContent: mockCopy
    }
  } catch (error) {
    console.error('生成失败:', error)
  } finally {
    isGenerating.value = false
  }
}

const generateTitles = async () => {
  isGenerating.value = true
  generatedResult.value = null
  
  try {
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    const mockTitles = `1. AI 时代，创作者会被替代吗？\n2. 从 0 到 1，教你打造 AI 驱动的超级播客\n3. 深度访谈：生成式 AI 如何颠覆内容生态\n4. 别再手动剪辑了！这款神器让你效率翻倍`

    generatedResult.value = {
      id: 'titles',
      type: '推荐标题',
      rawContent: mockTitles
    }
  } catch (error) {
    console.error('生成失败:', error)
  } finally {
    isGenerating.value = false
  }
}

const copyResult = () => {
  if (!generatedResult.value) return
  const text = generatedResult.value.rawContent
  navigator.clipboard.writeText(text).then(() => {
    alert('已复制到剪贴板')
  })
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

