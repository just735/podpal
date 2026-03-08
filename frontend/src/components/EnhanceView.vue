<template>
  <div class="flex-1 flex overflow-hidden">
    <!-- 左：项目成果（作品仓库） -->
    <aside class="w-72 flex-none border-r border-pink-200 bg-gradient-to-b from-pink-50 to-purple-50 p-4 overflow-y-auto">
      <div class="flex items-center justify-between mb-3">
        <h3 class="text-sm font-bold text-gray-900 flex items-center gap-2">
          <span class="w-1 h-4 bg-pink-500 rounded-full"></span>
          项目成果（作品仓库）
        </h3>
        <button class="text-[11px] text-pink-600 hover:text-pink-700" @click="refreshWorks">刷新</button>
      </div>
      <div class="space-y-2">
        <div 
          v-for="w in works" 
          :key="w.id"
          @click="selectWork(w)"
          class="p-3 bg-white rounded-lg border border-pink-200 hover:border-pink-300 cursor-pointer transition group"
          :class="{ 'ring-2 ring-pink-300': selectedWork && selectedWork.id === w.id }"
        >
          <div class="flex items-center justify-between">
            <div class="text-sm font-medium text-gray-900 truncate">{{ w.title }}</div>
            <span class="text-[10px] text-gray-500">{{ formatDate(w.createdAt) }}</span>
          </div>
          <div class="mt-1 text-[11px] text-gray-600 truncate">{{ w.description || '导出的成品音频/视频' }}</div>
          <div class="mt-1 flex flex-wrap gap-1">
            <span v-for="t in w.tags || []" :key="t" class="text-[10px] px-1.5 py-0.5 rounded border bg-pink-50 text-pink-700 border-pink-200">#{{ t }}</span>
          </div>
        </div>
      </div>
    </aside>

    <!-- 中：作品预览与编辑 -->
    <main class="flex-1 overflow-y-auto p-6 space-y-6">
      <div class="flex items-center justify-between">
        <div>
          <h2 class="text-2xl font-bold text-gray-700">内容增值</h2> 
          <p class="text-gray-600 text-sm">围绕“成品作品”进行二次创作、预览与发布配置</p>
        </div>
        <div class="flex items-center gap-2">
          <button class="px-3 py-1.5 text-sm rounded bg-white border border-pink-200 hover:bg-pink-50 text-gray-700" @click="openSharePreview">生成预览页</button>
          <button v-if="shareUrl" class="px-3 py-1.5 text-sm rounded bg-pink-600 text-white hover:bg-pink-700" @click="copyShareUrl">复制预览链接</button>
        </div>
      </div>

      <!-- 作品播放预览 -->
      <div class="glass-card rounded-xl p-6">
        <div class="flex items-center justify-between mb-3">
          <h3 class="text-lg font-semibold text-gray-700">作品预览</h3>
          <div class="flex items-center gap-2">
            <select v-model="previewPlatform" class="text-xs px-2 py-1 bg-white border border-pink-200 rounded">
              <option value="weixin">微信听书</option>
              <option value="douyin">抖音</option>
              <option value="xiaohongshu">小红书</option>
              <option value="apple">Apple 播客</option>
              <option value="bilibili">Bilibili</option>
            </select>
          </div>
        </div>
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
          <div class="lg:col-span-2 space-y-3">
            <div class="aspect-video rounded-lg border border-pink-200 bg-gradient-to-br from-white to-pink-50 flex items-center justify-center text-gray-400 text-sm">
              <div class="text-center">
                <div class="text-xs mb-1">平台样式预览：{{ platformName(previewPlatform) }}</div>
                <div class="text-[11px]">封面 / 金句视频 / 标题区块示意</div>
              </div>
            </div>
            <div class="p-3 bg-white border border-pink-200 rounded-lg">
              <audio ref="audioRef" :src="selectedWork?.audioUrl || ''" controls class="w-full"></audio>
            </div>
          </div>
          <div class="space-y-2">
            <div class="text-xs font-medium text-gray-900">AI 传播预测</div>
            <div class="p-3 bg-white rounded border border-pink-200">
              <div class="flex items-center justify-between text-[11px] text-gray-600 mb-1"><span>完播率预测</span><span>{{ propagation.forecastCompletion }}%</span></div>
              <div class="flex items-center justify-between text-[11px] text-gray-600 mb-1"><span>收藏/转发倾向</span><span>{{ propagation.shareIntent }}%</span></div>
              <div class="flex items-center justify-between text-[11px] text-gray-600"><span>新客触达</span><span>{{ propagation.newAudience }}%</span></div>
            </div>
          </div>
        </div>
      </div>

      <!-- Shownotes（可编辑，含时间戳跳转） -->
      <div class="glass-card rounded-xl p-6">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-semibold text-gray-700">Show Notes（可编辑）</h3>
          <button class="px-3 py-1.5 text-sm rounded border border-pink-200 bg-white hover:bg-pink-50 text-gray-700" @click="toggleEditShownotes">
            {{ editingShownotes ? '完成' : '编辑' }}
          </button>
        </div>
        <div v-if="editingShownotes" class="space-y-3">
          <input v-model="shownotes.title" class="w-full px-3 py-2 border border-pink-200 rounded" placeholder="标题" />
          <textarea v-model="shownotes.summary" rows="3" class="w-full px-3 py-2 border border-pink-200 rounded" placeholder="简介"></textarea>
          <div class="space-y-2">
            <div v-for="(it, idx) in shownotes.timeline" :key="idx" class="grid grid-cols-5 gap-2">
              <input v-model="it.timestamp" class="col-span-1 px-2 py-1 text-xs border border-pink-200 rounded" />
              <input v-model="it.topic" class="col-span-2 px-2 py-1 text-xs border border-pink-200 rounded" />
              <input v-model="it.description" class="col-span-2 px-2 py-1 text-xs border border-pink-200 rounded" />
            </div>
            <button class="text-[11px] px-2 py-1 rounded border border-pink-200 bg-white hover:bg-pink-50 text-gray-700" @click="addTimelineItem">+ 增加一条</button>
          </div>
        </div>
        <div v-else class="space-y-4">
          <div v-if="shownotes.title" class="text-lg font-bold text-gray-800">{{ shownotes.title }}</div>
          <div v-if="shownotes.summary" class="text-sm text-gray-600">{{ shownotes.summary }}</div>
          <div v-if="shownotes.timeline.length" class="space-y-2">
            <div class="text-xs text-gray-700 font-medium">内容时间轴</div>
            <div v-for="(it, idx) in shownotes.timeline" :key="idx" class="flex items-start gap-3 p-2 rounded hover:bg-pink-50 cursor-pointer" @click="seekByTimestamp(it.timestamp)">
              <span class="flex-none font-mono text-xs text-pink-600 px-2 py-0.5 rounded bg-pink-50 border border-pink-200">{{ it.timestamp }}</span>
              <div class="text-xs">
                <div class="font-bold text-gray-800">{{ it.topic }}</div>
                <div class="text-gray-600">{{ it.description }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 文案生成（保留，支持编辑流） -->
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

      <!-- 金句短视频（seedance 分发试接入） -->
      <div class="glass-card rounded-xl p-6">
        <h3 class="text-lg font-semibold text-gray-700 mb-4">金句短视频</h3>
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
            生成预览视频
          </button>
          <div class="flex items-center justify-between">
            <span class="text-[11px] text-gray-600">试接入 seedance 分发工作台</span>
            <a href="https://seedance.ai" target="_blank" class="text-[11px] text-pink-600 hover:text-pink-700">打开工作台 →</a>
          </div>
        </div>
      </div>

      <!-- 智能分发建议 & 音色评分 -->
      <div class="glass-card rounded-xl p-6">
        <h3 class="text-lg font-semibold text-gray-700 mb-4">智能分发与音色评估</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div class="space-y-3">
            <div class="text-sm font-medium text-gray-900">智能分发建议</div>
            <div class="space-y-2">
              <div v-for="(s, i) in distributionSuggestions" :key="i" class="p-3 bg-white border border-pink-200 rounded text-xs flex items-center justify-between">
                <div>
                  <div class="font-medium text-gray-900">{{ s.platform }} · {{ s.time }}</div>
                  <div class="text-gray-600">{{ s.reason }}</div>
                </div>
                <button class="px-2 py-1 rounded bg-pink-500 text-white hover:bg-pink-600">加入计划</button>
              </div>
            </div>
          </div>
          <div class="space-y-3">
            <div class="text-sm font-medium text-gray-900">AI 音色评分</div>
            <div class="p-3 bg-white border border-pink-200 rounded space-y-2 text-xs">
              <div class="flex items-center justify-between"><span>音质清晰度</span><span>{{ voiceScore.clarity }}%</span></div>
              <div class="h-1 bg-pink-100 rounded"><div class="h-full bg-pink-500 rounded" :style="{ width: voiceScore.clarity + '%' }"></div></div>
              <div class="flex items-center justify-between"><span>自然度</span><span>{{ voiceScore.naturalness }}%</span></div>
              <div class="h-1 bg-pink-100 rounded"><div class="h-full bg-pink-500 rounded" :style="{ width: voiceScore.naturalness + '%' }"></div></div>
              <div class="flex items-center justify-between"><span>信噪比</span><span>{{ voiceScore.snr }}%</span></div>
              <div class="h-1 bg-pink-100 rounded"><div class="h-full bg-pink-500 rounded" :style="{ width: voiceScore.snr + '%' }"></div></div>
            </div>
            <div class="p-3 bg-white border border-pink-200 rounded text-xs">
              <div class="font-medium text-gray-900 mb-2">个人音色采集区</div>
              <ol class="list-decimal ml-4 space-y-1 text-gray-700">
                <li>权利确认：我确认录音素材为本人声线并已获授权</li>
                <li>活体校验（可选）：随机文本现场朗读以验证控制权</li>
              </ol>
              <div class="flex gap-2 mt-2">
                <button class="px-2 py-1 rounded bg-white border border-pink-200 hover:bg-pink-50">训练向导</button>
                <button class="px-2 py-1 rounded bg-pink-500 text-white hover:bg-pink-600">开始采集</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
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

// 作品仓库
const works = ref([])
const selectedWork = ref(null)
const previewPlatform = ref('weixin')
const audioRef = ref(null)
const shareUrl = ref('')

const isGenerating = ref(false)
const generatedResult = ref(null)

const editingShownotes = ref(false)
const shownotes = ref({
  title: '',
  summary: '',
  timeline: []
})

const propagation = ref({
  forecastCompletion: 78,
  shareIntent: 62,
  newAudience: 55
})

const distributionSuggestions = ref([
  { platform: '小红书', time: '周三 20:00', reason: '粉丝在线率高、算法推荐友好' },
  { platform: '抖音', time: '周五 12:30', reason: '午休短视频高峰，竖屏适配' },
  { platform: '微信听书', time: '周日 9:30', reason: '通勤/早间收听档位' }
])

const voiceScore = ref({
  clarity: 82,
  naturalness: 76,
  snr: 88
})

const refreshWorks = () => {
  const last = localStorage.getItem('lastExportedWork')
  const parsed = last ? JSON.parse(last) : null
  const presets = [
    { id: 'w-101', title: 'EP10 精华剪辑', createdAt: '2025-12-01T10:00:00Z', description: '访谈版精华 6 分钟', tags: ['精华', '访谈'] },
    { id: 'w-102', title: 'EP09 全量导出', createdAt: '2025-11-20T10:00:00Z', description: '完整版 45 分钟', tags: ['完整版'] }
  ]
  works.value = parsed ? [parsed, ...presets] : presets
  if (!selectedWork.value && works.value.length > 0) {
    selectedWork.value = works.value[0]
  }
}

const selectWork = (w) => {
  selectedWork.value = w
}

const openSharePreview = () => {
  const id = Date.now().toString(36)
  shareUrl.value = `${location.origin}/share/${id}`
  localStorage.setItem('sharePreview:'+id, JSON.stringify({
    work: selectedWork.value,
    shownotes: shownotes.value,
    platform: previewPlatform.value
  }))
}

const copyShareUrl = () => {
  if (!shareUrl.value) return
  navigator.clipboard.writeText(shareUrl.value)
  alert('已复制预览链接')
}

const toggleEditShownotes = () => {
  editingShownotes.value = !editingShownotes.value
}

const addTimelineItem = () => {
  shownotes.value.timeline.push({ timestamp: '00:00:00', topic: '新增条目', description: '描述' })
}

const seekByTimestamp = (ts) => {
  // 支持 HH:MM:SS 或 MM:SS
  const parts = ts.split(':').map(Number)
  let seconds = 0
  if (parts.length === 2) seconds = parts[0]*60 + parts[1]
  else if (parts.length === 3) seconds = parts[0]*3600 + parts[1]*60 + parts[2]
  if (audioRef.value) {
    audioRef.value.currentTime = seconds
    audioRef.value.play().catch(() => {})
  }
}

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

    const result = {
      id: 'shownotes',
      type: 'Show Notes (播客笔记)',
      content: mockShownotes,
      rawContent: `【推荐标题】\n${mockShownotes.title}\n\n【内容简介】\n${mockShownotes.summary}\n\n【时间轴】\n${mockShownotes.timeline.map(t => `${t.timestamp} ${t.topic}`).join('\n')}`
    }
    generatedResult.value = result
    // 同步到可编辑的 shownotes
    shownotes.value.title = result.content.title
    shownotes.value.summary = result.content.summary
    shownotes.value.timeline = result.content.timeline.map(t => ({ ...t }))
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

const platformName = (k) => {
  return { weixin: '微信听书', douyin: '抖音', xiaohongshu: '小红书', apple: 'Apple 播客', bilibili: 'Bilibili' }[k] || k
}

const formatDate = (iso) => {
  try { return new Date(iso).toLocaleDateString('zh-CN') } catch { return '' }
}

onMounted(() => {
  refreshWorks()
})
</script>
