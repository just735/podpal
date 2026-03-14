<template>
  <div class="min-h-screen bg-gradient-to-br from-pink-50 via-white to-purple-50 pt-16">
    <!-- 顶部导航 -->
    <div class="bg-white border-b border-pink-200/60 shadow-sm sticky top-0 z-10">
      <div class="max-w-7xl mx-auto px-8 py-6">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">剪辑模板</h1>
            <p class="text-gray-500 mt-1">选择适合的模板快速开始剪辑</p>
          </div>
          <button
            @click="router.push('/clip-studio')"
            class="px-6 py-2 rounded-full text-sm font-medium bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white hover:shadow-lg hover:scale-105 transition-all duration-300"
          >
            返回工作台
          </button>
        </div>
      </div>
    </div>

    <!-- 分类标签 -->
    <div class="max-w-7xl mx-auto px-8 py-6">
      <div class="flex items-center gap-3 overflow-x-auto pb-2">
        <button
          v-for="category in categories"
          :key="category"
          @click="selectedCategory = category"
          class="px-6 py-3 text-sm rounded-full transition whitespace-nowrap font-medium"
          :class="selectedCategory === category ? 'bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white shadow-lg scale-105' : 'bg-white text-gray-600 hover:bg-gray-100 border border-gray-200 hover:shadow-md'"
        >
          {{ category }}
        </button>
      </div>
    </div>

    <!-- 模板列表 -->
    <div class="max-w-7xl mx-auto px-8 pb-12">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        <div
          v-for="template in filteredTemplates"
          :key="template.id"
          class="bg-white rounded-2xl border-2 cursor-pointer transition-all duration-300 hover:shadow-2xl hover:scale-105 transform hover:-translate-y-1"
          :style="{ borderColor: template.color + '40' }"
          @click="selectTemplate(template)"
        >
          <div class="p-6">
            <div class="flex items-start gap-4">
              <div
                class="w-16 h-16 rounded-2xl flex items-center justify-center text-3xl flex-shrink-0"
                :style="{ backgroundColor: template.color + '20' }"
              >
                {{ template.icon }}
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2 mb-2">
                  <h3 class="text-lg font-bold text-gray-900 truncate">{{ template.name }}</h3>
                  <span
                    class="text-xs px-3 py-1 rounded-full font-medium flex-shrink-0"
                    :style="{ backgroundColor: template.color + '20', color: template.color }"
                  >
                    {{ template.category }}
                  </span>
                </div>
                <p class="text-sm text-gray-500 line-clamp-2 mb-3">{{ template.description }}</p>
                <div class="flex items-center gap-2 text-xs text-gray-400">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  {{ template.duration }}
                </div>
              </div>
            </div>
            <div class="flex flex-wrap gap-2 mt-4 pt-4 border-t border-gray-100">
              <span
                v-for="feature in template.features"
                :key="feature"
                class="text-xs px-3 py-1.5 rounded-lg bg-gray-100 text-gray-600 font-medium transition-all hover:bg-gray-200"
              >
                {{ feature }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 模板详情弹窗 -->
    <div
      v-if="showTemplateDetail"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
      @click.self="showTemplateDetail = false"
    >
      <div class="bg-white rounded-2xl shadow-2xl w-[600px] max-h-[80vh] flex flex-col overflow-hidden animate-scaleIn">
        <div class="p-6 border-b border-gray-100 bg-gradient-to-r from-pink-50 to-purple-50">
          <div class="flex items-center justify-between">
            <h3 class="text-xl font-bold text-gray-900">模板详情</h3>
            <button @click="showTemplateDetail = false" class="text-gray-400 hover:text-gray-600 transition-all hover:scale-110">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>
        
        <div class="flex-1 overflow-y-auto p-6">
          <div class="text-center mb-6">
            <div
              class="w-24 h-24 rounded-2xl flex items-center justify-center text-5xl mx-auto mb-4 transition-all hover:scale-110"
              :style="{ backgroundColor: selectedTemplateData?.color + '20' }"
            >
              {{ selectedTemplateData?.icon }}
            </div>
            <h2 class="text-2xl font-bold text-gray-900 mb-2">{{ selectedTemplateData?.name }}</h2>
            <span
              class="inline-block px-4 py-1.5 rounded-full text-sm font-medium"
              :style="{ backgroundColor: selectedTemplateData?.color + '20', color: selectedTemplateData?.color }"
            >
              {{ selectedTemplateData?.category }}
            </span>
          </div>

          <div class="space-y-6">
            <div class="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
              <h4 class="text-sm font-bold text-gray-900 mb-2">模板描述</h4>
              <p class="text-gray-600">{{ selectedTemplateData?.description }}</p>
            </div>

            <div class="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
              <h4 class="text-sm font-bold text-gray-900 mb-3">功能特性</h4>
              <div class="flex flex-wrap gap-2">
                <span
                  v-for="feature in selectedTemplateData?.features"
                  :key="feature"
                  class="text-sm px-3 py-1.5 rounded-lg bg-gray-100 text-gray-700 font-medium transition-all hover:bg-gray-200"
                >
                  ✓ {{ feature }}
                </span>
              </div>
            </div>

            <div class="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
              <h4 class="text-sm font-bold text-gray-900 mb-2">适用时长</h4>
              <p class="text-gray-600">{{ selectedTemplateData?.duration }}</p>
            </div>
          </div>
        </div>

        <div class="p-6 border-t border-gray-100 bg-gray-50">
          <button
            @click="useTemplate"
            class="w-full py-3 rounded-xl text-base font-bold bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white hover:shadow-lg hover:scale-105 transition-all duration-300 transform hover:-translate-y-1"
          >
            使用此模板
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const categories = ['全部', '口播', '访谈', '故事', '知识', '娱乐']
const selectedCategory = ref('全部')
const showTemplateDetail = ref(false)
const selectedTemplateData = ref(null)

const templates = [
  {
    id: '1',
    name: '口播快剪',
    category: '口播',
    description: '适合知识分享、观点表达的快速剪辑模板，自动去除口癖，智能分段',
    icon: '🎙️',
    color: '#FF6B9D',
    duration: '3-5分钟',
    features: ['自动去口癖', '智能分段', '字幕生成']
  },
  {
    id: '2',
    name: '深度访谈',
    category: '访谈',
    description: '专业访谈节目制作模板，支持多轨剪辑，背景音乐混音',
    icon: '👥',
    color: '#8B5CF6',
    duration: '20-60分钟',
    features: ['多轨混音', '背景音乐', '章节标记']
  },
  {
    id: '3',
    name: '故事剧场',
    category: '故事',
    description: '沉浸式故事讲述模板，氛围感拉满，音效丰富',
    icon: '📖',
    color: '#10B981',
    duration: '10-30分钟',
    features: ['音效库', '氛围音乐', '转场特效']
  },
  {
    id: '4',
    name: '知识科普',
    category: '知识',
    description: '结构化知识分享，逻辑清晰，要点突出',
    icon: '📚',
    color: '#3B82F6',
    duration: '5-15分钟',
    features: ['要点提取', '时间轴', '资料卡片']
  },
  {
    id: '5',
    name: '轻松闲聊',
    category: '娱乐',
    description: '轻松愉快的闲聊节目模板，趣味性强',
    icon: '💬',
    color: '#F59E0B',
    duration: '15-40分钟',
    features: ['笑声检测', '趣味字幕', '表情包']
  },
  {
    id: '6',
    name: '新闻播报',
    category: '口播',
    description: '专业新闻播报风格，严肃正式，语速标准',
    icon: '📰',
    color: '#EF4444',
    duration: '2-10分钟',
    features: ['片头片尾', '标准语速', '清晰音质']
  },
  {
    id: '7',
    name: '情感电台',
    category: '故事',
    description: '温暖治愈的情感分享模板，温柔音效',
    icon: '❤️',
    color: '#EC4899',
    duration: '10-20分钟',
    features: ['温柔音效', '情感分析', '背景音乐']
  },
  {
    id: '8',
    name: '商业分析',
    category: '知识',
    description: '商业案例深度分析模板，数据可视化',
    icon: '📈',
    color: '#6366F1',
    duration: '15-30分钟',
    features: ['数据可视化', '图表插入', '专业术语']
  }
]

const filteredTemplates = computed(() => {
  if (selectedCategory.value === '全部') {
    return templates
  }
  return templates.filter(t => t.category === selectedCategory.value)
})

const selectTemplate = (template) => {
  selectedTemplateData.value = template
  showTemplateDetail.value = true
}

const useTemplate = () => {
  console.log('使用模板:', selectedTemplateData.value)
  alert(`已选择「${selectedTemplateData.value.name}」模板，即将跳转到剪辑工作台`)
  router.push(`/clip-studio?template=${selectedTemplateData.value.id}`)
}
</script>

<style scoped>
.animate-scaleIn {
  animation: scaleIn 0.3s ease-out;
}

@keyframes scaleIn {
  from {
    opacity: 0;
    transform: scale(0.9);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

/* 自定义滚动条 */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 10px;
}

::-webkit-scrollbar-thumb {
  background: #e879f9;
  border-radius: 10px;
}

::-webkit-scrollbar-thumb:hover {
  background: #d946ef;
}

/* 平滑滚动 */
html {
  scroll-behavior: smooth;
}
</style>
