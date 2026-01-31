<template>
  <div class="min-h-screen bg-white flex flex-col">
    <!-- 1. 顶部导航 & 用户管理 (Feature 1, 6) -->
    <header class="h-16 border-b border-pink-200 bg-gradient-to-r from-pink-50 to-purple-50 px-6 flex items-center justify-between sticky top-0 z-50">
      <div class="flex items-center gap-4">
        <h1 class="text-xl font-bold bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent tracking-tight">PodPal Studio</h1>
        <div class="h-6 w-px bg-pink-200 mx-2"></div>
        <div class="flex items-center gap-2 text-sm text-gray-600 hover:text-pink-600 cursor-pointer transition">
          <span>{{ currentProject.name || '未命名项目' }}</span>
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" /></svg>
        </div>
        <span class="text-xs px-2 py-0.5 rounded bg-blue-100 text-blue-700 border border-blue-300">自动保存</span>
      </div>
      
      <div class="flex items-center gap-6">
        <!-- 团队协作 (Feature 6) -->
        <div class="flex -space-x-2">
          <div class="w-8 h-8 rounded-full bg-indigo-500 flex items-center justify-center text-xs text-white border-2 border-white" title="Team Member A">A</div>
          <div class="w-8 h-8 rounded-full bg-emerald-500 flex items-center justify-center text-xs text-white border-2 border-white" title="Team Member B">B</div>
        <button
          class="w-8 h-8 rounded-full bg-white flex items-center justify-center text-gray-600 border-2 border-dashed border-pink-200 hover:text-pink-600 hover:border-pink-400 transition"
          @click="addTrack"
          title="新建轨道"
        >
          +
        </button>
        </div>
        
        <!-- 用户菜单 (Feature 1) -->
        <div class="flex items-center gap-3 pl-6 border-l border-pink-200">
          <div class="text-right hidden md:block">
            <div class="text-sm text-gray-900">Alex (Pro)</div>
            <div class="text-xs text-gray-600">Team Admin</div>
          </div>
          <div class="w-9 h-9 rounded-full bg-gradient-to-br from-blue-500 to-purple-600"></div>
        </div>
      </div>
    </header>

    <div class="flex-1 flex overflow-hidden">
      <!-- 垂直流程导航栏 -->
      <nav class="w-20 flex-none bg-white border-r border-pink-100 flex flex-col items-center py-8 gap-10 relative">
        <!-- 进度背景线 -->
        <div class="absolute left-1/2 top-14 bottom-14 w-0.5 bg-pink-50 -translate-x-1/2">
          <div 
            class="absolute top-0 w-full bg-gradient-to-b from-[#FF6B9D] to-[#C084FC] transition-all duration-500 rounded-full"
            :style="{ height: progressHeightPercent + '%' }"
          ></div>
        </div>

        <!-- 步骤节点 -->
        <div 
          v-for="(tab, i) in toolTabs" 
          :key="tab.id"
          @click="handleTabClick(tab)"
          class="relative z-10 flex flex-col items-center gap-2 cursor-pointer group"
          :class="{ 'opacity-40 cursor-not-allowed': tab.id !== 'upload' && !hasUploaded }"
        >
          <!-- 图标容器 -->
          <div 
            class="w-12 h-12 rounded-2xl flex items-center justify-center transition-all duration-300 border-2"
            :class="[
              i <= stepIndex ? 'bg-gradient-to-br from-[#FF6B9D] to-[#C084FC] border-transparent text-white shadow-lg shadow-pink-100' : 'bg-white border-pink-100 text-pink-300 group-hover:border-pink-300',
              activeToolTab === tab.id ? 'scale-110 ring-4 ring-pink-50' : 'hover:scale-105'
            ]"
          >
            <div v-html="tab.icon"></div>
          </div>
          <!-- 标签 -->
          <span 
            class="text-[10px] font-bold tracking-tighter transition-colors text-center px-1"
            :class="i <= stepIndex ? 'text-pink-600' : 'text-gray-400'"
          >
            {{ tab.name }}
          </span>
          <!-- 节点状态圆点 (当前步骤) -->
          <div 
            v-if="activeToolTab === tab.id"
            class="absolute -left-1 top-5 w-1.5 h-1.5 bg-pink-500 rounded-full animate-pulse"
          ></div>
        </div>
      </nav>

      <!-- 2. 左侧：素材与资产管理 (Feature 2) -->
      <aside class="w-80 flex-none bg-gradient-to-b from-pink-50 to-purple-50 border-r border-pink-200 flex flex-col">
        <div class="p-4 border-b border-pink-200">
          <h2 class="text-sm font-semibold text-gray-700 uppercase tracking-wider mb-4">素材库</h2>
          <!-- 上传/导入 -->
          <div class="grid grid-cols-2 gap-2 mb-4">
            <button @click="triggerFileUpload" class="flex flex-col items-center justify-center p-4 bg-white rounded-lg hover:bg-pink-50 transition border border-dashed border-pink-200 hover:border-blue-400 group">
              <svg class="w-6 h-6 text-gray-600 group-hover:text-blue-500 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" /></svg>
              <span class="text-xs text-gray-600 group-hover:text-gray-900">本地上传</span>
            </button>
            <button @click="showLinkModal = true" class="flex flex-col items-center justify-center p-4 bg-white rounded-lg hover:bg-purple-50 transition border border-dashed border-pink-200 hover:border-purple-400 group">
              <svg class="w-6 h-6 text-gray-600 group-hover:text-purple-500 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1" /></svg>
              <span class="text-xs text-gray-600 group-hover:text-gray-900">链接导入</span>
            </button>
          </div>
          <input ref="fileInput" type="file" accept="audio/*,video/*" class="hidden" @change="handleFileSelect">
        </div>

        <!-- 素材列表 -->
        <div class="flex-1 overflow-y-auto p-4 space-y-2">
          <div 
            v-for="asset in assets" 
            :key="asset.id" 
            class="p-3 bg-white rounded-lg border border-pink-200 hover:border-pink-300 hover:bg-pink-50 cursor-pointer group transition-all duration-200"
            @click="selectAsset(asset)"
            draggable="true"
            @dragstart="handleAssetDragStart($event, asset)"
          >
            <div class="flex items-start justify-between mb-2">
              <div class="flex items-center gap-2 flex-1 min-w-0">
                <div class="w-8 h-8 rounded flex items-center justify-center flex-shrink-0" :class="asset.type === 'audio' ? 'bg-blue-500/20' : 'bg-orange-500/20'">
                  <svg v-if="asset.type === 'audio'" class="w-4 h-4" :class="asset.type === 'audio' ? 'text-blue-400' : 'text-orange-400'" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" />
                  </svg>
                  <svg v-else class="w-4 h-4 text-orange-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
                  </svg>
                </div>
                <div class="flex-1 min-w-0">
                  <div class="text-sm text-gray-900 font-medium truncate">{{ asset.name }}</div>
                  <div class="text-xs text-gray-600 mt-0.5">{{ asset.duration }}</div>
                </div>
              </div>
              <button 
                class="p-1.5 text-gray-600 hover:text-pink-600 hover:bg-pink-100 rounded opacity-0 group-hover:opacity-100 transition"
                @click.stop="showAssetMenu(asset)"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
                </svg>
              </button>
            </div>
            <div class="flex items-center justify-between text-xs mt-2 pt-2 border-t border-pink-100">
              <span class="text-gray-600">{{ asset.duration }}</span>
              <span class="bg-pink-100 px-2 py-0.5 rounded text-pink-700 border border-pink-200">{{ asset.format }}</span>
            </div>
          </div>
        </div>
      </aside>

      <!-- 3. 中间：工作区 (Feature 3, 9) -->
      <main class="flex-1 min-w-0 flex flex-col bg-white overflow-hidden relative">
        <!-- Upload View -->
        <div v-if="activeToolTab === 'upload'" class="flex-1 overflow-y-auto bg-gray-50 p-8 animate-fadeIn">
           <div class="max-w-4xl mx-auto space-y-6">
              <div class="flex items-center justify-between">
                <h2 class="text-2xl font-bold text-gray-900">上传素材</h2>
              </div>
              <div class="bg-white rounded-xl border border-pink-200 shadow-sm overflow-hidden p-6">
                <div v-if="!inlineUploading" class="space-y-4">
                  <div 
                    class="border-2 border-dashed border-pink-200 rounded-xl p-8 bg-pink-50/50 hover:bg-pink-50 transition cursor-pointer text-center"
                    @click="triggerInlineUpload"
                    @dragover.prevent
                    @dragenter.prevent
                    @drop="handleInlineDrop($event)"
                  >
                    <div class="text-sm text-gray-900 mb-2">点击选择文件或拖拽到此处</div>
                    <div class="text-xs text-gray-500">支持: mp3, wav, m4a, mp4, mov</div>
                  </div>
                  <input ref="inlineFileInput" type="file" accept="audio/*,video/*" class="hidden" @change="handleInlineSelect">
                  <div class="flex items-center justify-between">
                    <button class="px-3 py-1.5 text-xs bg-blue-500 text-white rounded hover:bg-blue-600" @click="useSampleAsset">使用示例素材</button>
                    <span class="text-xs text-gray-500">完成后将自动进入智能剪辑</span>
                  </div>
                </div>
                <div v-else class="space-y-3">
                  <div class="text-sm text-gray-900">正在上传: {{ inlineFilename }}</div>
                  <div class="h-3 w-full bg-pink-100 rounded-full overflow-hidden">
                    <div class="h-full bg-pink-500 rounded-full transition-all" :style="{ width: inlineProgress + '%' }"></div>
                  </div>
                  <div class="text-sm font-bold text-gray-500">请稍候...</div>
                </div>
              </div>
           </div>
        </div>
        <!-- Editor View -->
        <div v-show="activeToolTab === 'edit'" class="flex-none flex flex-col overflow-hidden relative" :style="{ height: totalEditorHeightPx + 'px' }" ref="editorColumn">
        <!-- 播放器预览 -->
        <div class="h-[600px] border-b border-pink-200 p-6 flex flex-col relative bg-gradient-to-b from-white via-pink-50/30 to-white">
          <!-- 视图切换按钮 -->
          <div class="flex items-center justify-between mb-4">
            <div class="flex items-center gap-2">
              <button
                @click="showWaveform = false"
                class="px-3 py-1.5 text-sm rounded-lg transition"
                :class="!showWaveform ? 'bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white' : 'text-gray-600 hover:bg-pink-100'"
              >
                📝 文字稿
              </button>
              <button
                @click="showWaveform = true"
                class="px-3 py-1.5 text-sm rounded-lg transition"
                :class="showWaveform ? 'bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white' : 'text-gray-600 hover:bg-pink-100'"
              >
                📊 波形图
              </button>
            </div>
          </div>

          <!-- 波形可视化区域 -->
          <div v-if="showWaveform" class="flex-1 flex items-center justify-center mb-4">
            <div class="w-full max-w-5xl h-32 flex items-end justify-center gap-0.5 px-4 relative">
              <!-- 播放指示线 -->
              <div 
                class="absolute top-0 bottom-0 w-0.5 bg-gradient-to-b from-red-500 via-pink-500 to-transparent z-10 pointer-events-none transition-all duration-100"
                :style="{ left: (currentTime / audioDuration * 100) + '%' }"
              >
                <div class="absolute -top-2 left-1/2 -translate-x-1/2 w-3 h-3 bg-red-500 rounded-full shadow-lg"></div>
              </div>
              <!-- 波形条 -->
              <div 
                v-for="i in 120" 
                :key="i" 
                class="flex-1 bg-gradient-to-t from-pink-400 via-purple-400 to-pink-400 rounded-t transition-all duration-300 hover:from-pink-500 hover:via-purple-500 hover:to-pink-500 cursor-pointer"
                :class="{ 'opacity-50': Math.abs((i / 120) * 100 - (currentTime / audioDuration * 100)) > 5 }"
                :style="{ 
                  height: (Math.sin(i * 0.15) * 25 + 40) + '%',
                  minHeight: '8px',
                  animationDelay: i * 0.02 + 's',
                  animation: isPlaying ? `wave ${0.5 + Math.random() * 0.5}s ease-in-out infinite` : 'none'
                }"
                @click="seekToPercentage(i / 120)"
              ></div>
            </div>
          </div>

          <!-- 文字稿区域（可编辑 & 口癖高亮） -->
          <div v-else ref="transcriptContainer" class="flex-1 bg-white rounded-lg border border-pink-200 p-4 overflow-y-auto relative">
            <!-- 标注说明 -->
            <div class="sticky top-0 z-10 bg-white/90 backdrop-blur-sm pb-2 mb-2 border-b border-pink-100 flex items-center gap-4 text-[10px] text-gray-500">
              <span class="flex items-center gap-1">
                <span class="w-2 h-2 rounded bg-yellow-100 border border-yellow-200"></span>
                口癖/冗余
              </span>
              <span class="flex items-center gap-1">
                <span class="w-2 h-2 rounded bg-purple-100 border border-purple-200"></span>
                口吃/重复
              </span>
              <span class="flex items-center gap-1">
                <span class="w-2 h-2 bg-gray-400 line-through decoration-red-400"></span>
                已删除内容
              </span>
              <span class="flex items-center gap-1 ml-auto">
                <i class="ri-information-line text-pink-400"></i>
                点击文字可进行智能处理
              </span>
            </div>
            <div class="space-y-3">
              <div 
                v-for="(segment, index) in mockTranscript" 
                :key="index"
                :ref="el => setSegmentRef(el, index)"
                class="p-3 rounded-lg cursor-pointer transition-all duration-200 group relative"
                :class="[
                  isCurrentSegment(segment) ? 'bg-gradient-to-r from-pink-100 to-purple-100 border-l-4 border-pink-500' : 'hover:bg-pink-50',
                  isSegmentHighlighted(index) ? 'ring-2 ring-pink-400 ring-inset bg-pink-50/50' : '',
                  segment.text.startsWith('[TTS]') && !segment.confirmed ? 'border border-dashed border-blue-300 bg-blue-50/30' : '',
                  segment.text.startsWith('[TTS]') && segment.confirmed ? 'border border-blue-200 bg-blue-50' : ''
                ]"
                @click="seekToTime(segment.startTime)"
              >
                <div class="flex items-center justify-between mb-1">
                  <div class="flex items-center gap-2">
                    <span class="text-xs text-gray-500 font-mono">{{ formatTime(segment.startTime) }} - {{ formatTime(segment.endTime) }}</span>
                    <span v-if="segment.text.startsWith('[TTS]')" class="text-[10px] bg-blue-500 text-white px-1.5 rounded">TTS</span>
                    <span v-if="deletedCount(segment.text) > 0" class="text-[10px] bg-red-100 text-red-700 px-1.5 rounded">已留痕</span>
                  </div>
                  <div class="flex items-center gap-2">
                    <button 
                      @click.stop="insertTTS(index)"
                      class="hidden group-hover:flex text-[10px] text-pink-500 hover:text-pink-700 font-medium"
                    >+ 插入补录</button>
                    <button 
                      v-if="segment.text.startsWith('[TTS]')"
                      @click.stop="deleteTTSSegment(index)"
                      class="hidden group-hover:flex text-[10px] text-red-500 hover:text-red-700 font-medium"
                    >删除补录</button>
                    <span class="text-xs px-2 py-0.5 rounded-full" :class="segment.speaker === 'A' ? 'bg-blue-100 text-blue-700' : (segment.speaker === 'AI' ? 'bg-purple-100 text-purple-700' : 'bg-green-100 text-green-700')">
                      {{ segment.speaker === 'AI' ? 'AI 合成' : '说话人' + segment.speaker }}
                    </span>
                  </div>
                </div>
                
                <!-- 增强的文本编辑模式 (仅针对 TTS) -->
                <div 
                  v-if="editingSegmentId === index && segment.text.startsWith('[TTS]')"
                  class="mt-1"
                >
                  <textarea
                    v-model="segment.text"
                    v-focus
                    class="w-full text-sm text-gray-900 leading-relaxed bg-white border border-blue-300 rounded-md px-2 py-1 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
                    rows="3"
                    @click.stop
                  />
                  <div class="mt-2 flex justify-end gap-2">
                    <div v-if="segment.warning" class="mr-auto text-[10px] text-amber-600 flex items-center gap-1">
                      <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                      </svg>
                      {{ segment.warning }}
                    </div>
                    <button 
                      @click.stop="confirmTTS(index)"
                      class="px-3 py-1.5 text-xs bg-blue-500 text-white rounded hover:bg-blue-600"
                    >确认加入</button>
                    <button 
                      @click.stop="editingSegmentId = null"
                      class="px-3 py-1.5 text-xs text-gray-600 hover:bg-gray-100 rounded"
                    >取消</button>
                  </div>
                </div>

                <!-- 删除编辑模式（非 TTS，允许任意选区删除并留痕） -->
                <div 
                  v-else-if="editingSegmentId === index && !segment.text.startsWith('[TTS]')"
                  class="mt-1 text-sm leading-relaxed min-h-[1.5rem] whitespace-pre-wrap border border-pink-200 rounded px-2 py-1"
                  contenteditable="true"
                  @keydown="onSegmentKeydown(segment, $event, index)"
                  @paste.prevent
                >
                  <template v-for="(token, tIndex) in parseSegmentText(segment.text)" :key="tIndex">
                    <span 
                      v-if="token.type === 'filler'" 
                      :data-token-index="tIndex"
                      class="mx-0.5 px-1 py-0.5 rounded bg-yellow-100 text-yellow-800 border border-yellow-200"
                    >{{ token.text }}</span>
                    <span 
                      v-else-if="token.type === 'stutter'"
                      :data-token-index="tIndex"
                      class="mx-0.5 px-1 py-0.5 rounded bg-purple-100 text-purple-800 border border-purple-200"
                    >{{ token.text }}</span>
                    <span 
                      v-else-if="token.type === 'deleted'"
                      :data-token-index="tIndex"
                      class="text-gray-400 line-through decoration-red-400 decoration-2 mx-0.5"
                    >{{ token.text }}</span>
                    <span 
                      v-else-if="token.type === 'space'"
                      :data-token-index="tIndex"
                    >{{ token.text }}</span>
                    <span 
                      v-else
                      :data-token-index="tIndex"
                    >{{ token.text }}</span>
                  </template>
                </div>

                <!-- 预览模式（点击进入删除模式；口癖/已删除仍可单点切换） -->
                <div 
                  v-else
                  class="mt-1 text-sm leading-relaxed min-h-[1.5rem] whitespace-pre-wrap"
                  :class="segment.text.startsWith('[TTS]') ? 'text-blue-800 italic' : 'text-gray-900'"
                >
                  <template v-for="(token, tIndex) in parseSegmentText(segment.text)" :key="tIndex">
                    <!-- 口癖 Token -->
                    <span 
                      v-if="token.type === 'filler'" 
                      @click.stop="toggleTokenDelete(segment, tIndex)"
                      :data-token-index="tIndex"
                      class="inline-flex items-center mx-0.5 px-1 py-0.5 rounded bg-yellow-100 text-yellow-800 border border-yellow-200 cursor-pointer hover:bg-yellow-200 transition"
                    >
                      {{ token.text }}
                    </span>
                    <!-- 口吃 Token -->
                    <span 
                      v-else-if="token.type === 'stutter'"
                      @click.stop="toggleTokenDelete(segment, tIndex)"
                      :data-token-index="tIndex"
                      class="inline-flex items-center mx-0.5 px-1 py-0.5 rounded bg-purple-100 text-purple-800 border border-purple-200 cursor-pointer hover:bg-purple-200 transition"
                    >
                      {{ token.text }}
                    </span>
                    <!-- 已删除 Token -->
                    <span 
                      v-else-if="token.type === 'deleted'"
                      @click.stop="toggleTokenDelete(segment, tIndex)"
                      :data-token-index="tIndex"
                      class="text-gray-400 line-through decoration-red-400 decoration-2 mx-0.5 cursor-pointer hover:text-gray-600 transition"
                    >
                      {{ token.text }}
                    </span>
                    <!-- 空白 Token -->
                    <span 
                      v-else-if="token.type === 'space'"
                      :data-token-index="tIndex"
                      @click.stop="editingSegmentId = index"
                    >{{ token.text }}</span>
                    <!-- 普通文本 Token -->
                    <span 
                      v-else
                      :data-token-index="tIndex"
                      @click.stop="editingSegmentId = index"
                      class="cursor-pointer hover:bg-pink-100/50 rounded px-0.5 transition"
                    >
                      {{ token.text }}
                    </span>
                  </template>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 时间显示和进度条 -->
          <div class="mb-4">
            <div class="flex items-center justify-between text-sm mb-3">
              <div class="flex items-center gap-4">
                <div class="flex items-center gap-2">
                  <button 
                    @click="showTimeInput = !showTimeInput"
                    class="font-mono text-gray-700 font-semibold hover:text-pink-600 transition px-2 py-1 hover:bg-pink-50 rounded"
                    title="点击输入时间"
                  >
                    {{ formatTime(currentTime) }}
                  </button>
                  <span class="text-gray-400">/</span>
                  <span class="font-mono text-gray-600">{{ formatTime(audioDuration) }}</span>
                </div>
                <!-- 时间输入框 -->
                <div v-if="showTimeInput" class="flex items-center gap-2">
                  <input 
                    v-model="timeInputValue"
                    @keyup.enter="jumpToTime"
                    @keyup.esc="showTimeInput = false"
                    type="text" 
                    placeholder="00:00:00"
                    class="w-24 px-2 py-1 text-xs border border-pink-200 rounded focus:ring-2 focus:ring-pink-300 outline-none"
                    ref="timeInput"
                  >
                  <button @click="jumpToTime" class="px-2 py-1 text-xs bg-pink-100 text-pink-600 rounded hover:bg-pink-200">跳转</button>
                </div>
                <span class="text-xs text-gray-500 px-2 py-1 bg-pink-50 rounded">
                  剩余: {{ formatTime(audioDuration - currentTime) }}
                </span>
                <!-- 选择区域显示 -->
                <div v-if="selectionStart !== null && selectionEnd !== null" class="flex items-center gap-2 text-xs text-blue-600">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                  </svg>
                  <span>已选择: {{ formatTime(selectionEnd - selectionStart) }}</span>
                </div>
              </div>
              <div class="flex items-center gap-3">
                <!-- 播放速度控制 -->
                <div class="flex items-center gap-2">
                  <span class="text-xs text-gray-600">速度:</span>
                  <select v-model="playbackSpeed" class="text-xs px-2 py-1 bg-white border border-pink-200 rounded focus:ring-2 focus:ring-pink-300">
                    <option value="0.5">0.5x</option>
                    <option value="0.75">0.75x</option>
                    <option value="1">1.0x</option>
                    <option value="1.25">1.25x</option>
                    <option value="1.5">1.5x</option>
                    <option value="2">2.0x</option>
                  </select>
                </div>
                <!-- 循环播放 -->
                <button 
                  @click="loopMode = !loopMode"
                  class="p-1.5 text-gray-600 hover:text-pink-600 hover:bg-pink-100 rounded transition"
                  :class="{ 'text-pink-600 bg-pink-100': loopMode }"
                  title="循环播放 (L)"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                  </svg>
                </button>
                <!-- 标记点管理 -->
                <div class="relative">
                  <button 
                    @click="showMarkersPanel = !showMarkersPanel"
                    class="p-1.5 text-gray-600 hover:text-pink-600 hover:bg-pink-100 rounded transition relative"
                    title="标记点 (M)"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
                    </svg>
                    <span v-if="markers.length > 0" class="absolute -top-1 -right-1 w-4 h-4 bg-pink-500 text-white text-[8px] rounded-full flex items-center justify-center">{{ markers.length }}</span>
                  </button>
                  <!-- 标记点面板 -->
                  <div v-if="showMarkersPanel" class="absolute right-0 top-full mt-2 w-64 bg-white border border-pink-200 rounded-lg shadow-xl z-50 p-3">
                    <div class="flex items-center justify-between mb-2">
                      <span class="text-xs font-medium text-gray-900">标记点 ({{ markers.length }})</span>
                      <button @click="showMarkersPanel = false" class="text-gray-400 hover:text-gray-600">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                      </button>
                    </div>
                    <div class="space-y-1 max-h-48 overflow-y-auto">
                      <div 
                        v-for="marker in markers" 
                        :key="marker.id"
                        class="flex items-center justify-between p-2 hover:bg-pink-50 rounded cursor-pointer group"
                        @click="seekToTime(marker.time)"
                      >
                        <div class="flex items-center gap-2 flex-1">
                          <div class="w-2 h-2 bg-yellow-400 rounded-full"></div>
                          <span class="text-xs text-gray-700">{{ marker.label }}</span>
                          <span class="text-[10px] text-gray-500">{{ formatTime(marker.time) }}</span>
                        </div>
                        <button 
                          @click.stop="deleteMarker(marker.id)"
                          class="opacity-0 group-hover:opacity-100 text-red-500 hover:text-red-700 transition"
                        >
                          <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                          </svg>
                        </button>
                      </div>
                    </div>
                    <button 
                      @click="addMarker"
                      class="w-full mt-2 px-3 py-1.5 text-xs bg-pink-100 text-pink-600 rounded hover:bg-pink-200 transition"
                    >
                      + 添加标记点
                    </button>
                  </div>
                </div>
              </div>
            </div>
            <!-- 增强的进度条 -->
            <div class="relative">
              <!-- 选择区域高亮 -->
              <div 
                v-if="selectionStart !== null && selectionEnd !== null"
                class="absolute top-0 bottom-0 bg-blue-200/30 border-l-2 border-r-2 border-blue-400 z-5 pointer-events-none"
                :style="{ 
                  left: (selectionStart / audioDuration * 100) + '%',
                  width: ((selectionEnd - selectionStart) / audioDuration * 100) + '%'
                }"
              ></div>
              <!-- 进度条 -->
              <div 
                class="relative h-[3px] bg-pink-100 rounded-full overflow-visible cursor-pointer group flex items-center" 
                @click="seekTo" 
                @mousemove="onProgressHover"
                @mouseleave="hoverTime = null"
                @mousedown="startSelection"
              >
                <!-- 进度填充 -->
                <div 
                  class="absolute inset-y-0 left-0 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] rounded-full transition-all duration-100"
                  :style="{ width: (currentTime / audioDuration * 100) + '%' }"
                ></div>
                <!-- 标记点 -->
                <div 
                  v-for="marker in markers" 
                  :key="marker.id"
                  class="absolute top-0 bottom-0 w-0.5 bg-yellow-400 z-10 cursor-pointer hover:bg-yellow-500 transition shadow-sm"
                  :style="{ left: (marker.time / audioDuration * 100) + '%' }"
                  :title="marker.label || formatTime(marker.time)"
                  @click.stop="seekToTime(marker.time)"
                >
                  <div class="absolute -top-1 left-1/2 -translate-x-1/2 w-2 h-2 bg-yellow-400 rounded-full border border-yellow-600"></div>
                </div>
                <!-- 播放指示器（缩小尺寸） -->
                <div 
                  class="absolute top-1/2 -translate-y-1/2 w-3 h-3 bg-white rounded-full shadow-lg border-2 border-pink-500 opacity-0 group-hover:opacity-100 transition-opacity z-20 cursor-grab active:cursor-grabbing"
                  :style="{ left: `calc(${currentTime / audioDuration * 100}% - 6px)` }"
                  @mousedown.stop="startDraggingProgress"
                >
                  <div class="absolute inset-0 flex items-center justify-center">
                    <div class="w-1 h-1 bg-pink-500 rounded-full"></div>
                  </div>
                </div>
                <!-- 悬停时间提示 -->
                <div 
                  v-if="hoverTime !== null"
                  class="absolute -top-8 left-1/2 -translate-x-1/2 px-2 py-1 bg-gray-900 text-white text-xs rounded shadow-lg pointer-events-none z-30 whitespace-nowrap"
                  :style="{ left: hoverTime + '%' }"
                >
                  {{ formatTime((hoverTime / 100) * audioDuration) }}
                  <div class="absolute top-full left-1/2 -translate-x-1/2 w-0 h-0 border-l-4 border-r-4 border-t-4 border-transparent border-t-gray-900"></div>
                </div>
              </div>
              <!-- 进度条下方信息 -->
              <div class="flex items-center justify-between mt-1 text-[10px] text-gray-500">
                <span>开始</span>
                <span v-if="selectionStart !== null && selectionEnd !== null">
                  选择: {{ formatTime(selectionStart) }} - {{ formatTime(selectionEnd) }}
                </span>
                <span>结束</span>
              </div>
            </div>
          </div>
          
          <!-- 播放控制 -->
          <div class="flex items-center justify-center gap-4">
            <button 
              @click="skipBackward(5)"
              class="p-2.5 text-gray-600 hover:text-pink-600 hover:bg-pink-100 rounded-lg transition" 
              title="后退5秒"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12.066 11.2a1 1 0 000 1.6l5.334 4A1 1 0 0019 16V8a1 1 0 00-1.6-.8l-5.333 4zM4.066 11.2a1 1 0 000 1.6l5.334 4A1 1 0 0011 16V8a1 1 0 00-1.6-.8l-5.334 4z" />
              </svg>
              <span class="text-[10px] text-gray-500 mt-0.5 block">-5s</span>
            </button>
            <button 
              @click="togglePlay" 
              class="w-16 h-16 rounded-full bg-gradient-to-br from-[#FF6B9D] to-[#C084FC] text-white flex items-center justify-center hover:shadow-2xl hover:scale-110 transition-all duration-300 shadow-lg"
            >
              <svg v-if="!isPlaying" class="w-7 h-7 ml-1" fill="currentColor" viewBox="0 0 20 20">
                <path d="M6.3 2.841A1.5 1.5 0 004 4.11V15.89a1.5 1.5 0 002.3 1.269l9.344-5.89a1.5 1.5 0 000-2.538L6.3 2.84z" />
              </svg>
              <svg v-else class="w-7 h-7" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zM7 8a1 1 0 012 0v4a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v4a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
              </svg>
            </button>
            <button 
              @click="skipForward(5)"
              class="p-2.5 text-gray-600 hover:text-pink-600 hover:bg-pink-100 rounded-lg transition" 
              title="前进5秒"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.933 12.8a1 1 0 000-1.6L6.6 7.2A1 1 0 005 8v8a1 1 0 001.6.8l5.333-4zM19.933 12.8a1 1 0 000-1.6l-5.333-4A1 1 0 0013 8v8a1 1 0 001.6.8l5.333-4z" />
              </svg>
              <span class="text-[10px] text-gray-500 mt-0.5 block">+5s</span>
            </button>
            <button 
              @click="addMarker"
              class="p-2.5 text-gray-600 hover:text-pink-600 hover:bg-pink-100 rounded-lg transition" 
              title="添加标记点"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
              </svg>
            </button>
          </div>
        </div>

        <!-- 底部：轨道/编辑器 (Feature 7) -->
        <div class="flex-1 bg-white flex flex-col border-t border-pink-200 overflow-hidden min-h-[360px]">
          <!-- 工具栏 -->
          <div class="flex items-center justify-between px-4 py-2 border-b border-pink-200 bg-pink-50/50 flex-shrink-0">
            <div class="flex items-center gap-3">
              <button 
                @click="addTrack"
                class="text-xs font-medium text-white bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] px-4 py-2 rounded-lg hover:shadow-lg hover:scale-105 transition flex items-center gap-2"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                </svg>
                添加轨道
              </button>
              <div class="h-5 w-px bg-pink-200"></div>
              <div class="flex items-center gap-1">
                <button 
                  @click="splitAtCurrentTime"
                  class="p-2 text-gray-600 hover:text-pink-600 hover:bg-pink-100 rounded transition" 
                  title="在当前位置分割 (S)"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.121 14.121L19 19m-7-7l7-7m-7 7l-2.879 2.879M12 12L9.121 9.121m0 5.758a3 3 0 10-4.243 4.243 3 3 0 004.243-4.243zm0-5.758a3 3 0 10-4.243-4.243 3 3 0 004.243 4.243z" />
                  </svg>
                </button>
                <button 
                  @click="deleteSelected"
                  class="p-2 text-gray-600 hover:text-red-600 hover:bg-red-100 rounded transition" 
                  title="删除选中 (Delete)"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                  </svg>
                </button>
                <button 
                  @click="addFadeIn"
                  class="p-2 text-gray-600 hover:text-pink-600 hover:bg-pink-100 rounded transition" 
                  title="淡入"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
                  </svg>
                </button>
                <button 
                  @click="addFadeOut"
                  class="p-2 text-gray-600 hover:text-pink-600 hover:bg-pink-100 rounded transition" 
                  title="淡出"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 17h8m0 0V9m0 8l-8-8-4 4-6-6" />
                  </svg>
                </button>
                <button 
                  @click="undo"
                  class="p-2 text-gray-600 hover:text-pink-600 hover:bg-pink-100 rounded transition" 
                  title="撤销 (Ctrl+Z)"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6" />
                  </svg>
                </button>
                <button 
                  @click="redo"
                  class="p-2 text-gray-600 hover:text-pink-600 hover:bg-pink-100 rounded transition" 
                  title="重做 (Ctrl+Y)"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 10h-10a8 8 0 00-8 8v2M21 10l-6 6m6-6l-6-6" />
                  </svg>
                </button>
              </div>
            </div>
            <div class="flex items-center gap-4">
              <!-- 缩放控制 -->
              <div class="flex items-center gap-2 text-xs text-gray-600">
                <button 
                  @click="zoomOut"
                  class="px-2 py-1 bg-white border border-pink-200 rounded hover:bg-pink-50 transition"
                  :disabled="zoomLevel <= 0.25"
                >
                  <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM13 10H7" />
                  </svg>
                </button>
                <span class="w-16 text-center font-mono">{{ Math.round(zoomLevel * 100) }}%</span>
                <button 
                  @click="zoomIn"
                  class="px-2 py-1 bg-white border border-pink-200 rounded hover:bg-pink-50 transition"
                  :disabled="zoomLevel >= 4"
                >
                  <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v6m3-3H7" />
                  </svg>
                </button>
              </div>
              <!-- 吸附功能 -->
              <div class="flex items-center gap-2">
                <label class="flex items-center gap-2 text-xs text-gray-600 cursor-pointer">
                  <input type="checkbox" v-model="snapToGrid" class="rounded border-pink-200 text-pink-600">
                  <span>吸附网格</span>
                </label>
              </div>
            </div>
          </div>
          
          <!-- 时间轴和轨道 -->
          <div class="flex-shrink-0 flex flex-col overflow-hidden border-t border-pink-200" :style="{ height: fixedTimelineHeightPx + 'px' }">
            <!-- 时间轴标尺（固定在顶部） -->
            <div 
              class="h-20 border-b-2 border-pink-300 bg-gradient-to-b from-pink-50 to-white flex-shrink-0 relative overflow-x-auto overflow-y-visible sticky top-0 z-20"
              ref="timelineRuler"
              @scroll="onTimelineScroll"
            >
              <div class="relative h-full" :style="{ width: timelineWidth + 'px', minWidth: '100%' }">
                <!-- 网格背景 -->
                <div class="absolute inset-0 opacity-15 pointer-events-none">
                  <div 
                    v-for="tick in timeTicks" 
                    :key="'grid-' + tick.time"
                    class="absolute top-0 bottom-0 w-px"
                    :class="tick.isMajor ? 'bg-pink-300' : 'bg-pink-200'"
                    :style="{ left: (tick.time / audioDuration * timelineWidth) + 'px' }"
                  ></div>
                </div>
                <!-- 时间刻度线和标签 -->
                <div 
                  v-for="tick in timeTicks" 
                  :key="tick.time"
                  class="absolute top-0 bottom-0"
                  :style="{ left: (tick.time / audioDuration * timelineWidth) + 'px' }"
                >
                  <!-- 主刻度线 -->
                  <div 
                    v-if="tick.isMajor"
                    class="absolute top-0 w-0.5 h-full bg-pink-400 z-10"
                  ></div>
                  <!-- 次要刻度线 -->
                  <div 
                    v-else
                    class="absolute top-0 w-px h-3/4 bg-pink-200"
                  ></div>
                  <!-- 时间标签 - 主刻度（确保所有主刻度都显示） -->
                  <div 
                    v-if="tick.isMajor"
                    class="absolute top-2 left-0 transform -translate-x-1/2 whitespace-nowrap z-20"
                  >
                    <span class="text-xs font-mono text-gray-800 font-bold bg-white px-2 py-1 rounded border border-pink-300 shadow-sm">
                      {{ formatTime(tick.time) }}
                    </span>
                  </div>
                  <!-- 时间标签 - 次要刻度（放大时显示） -->
                  <div 
                    v-else-if="zoomLevel >= 1.5 && tick.time % 5 === 0"
                    class="absolute top-3 left-0 transform -translate-x-1/2 z-20"
                  >
                    <span class="text-[10px] font-mono text-gray-600 bg-white/90 px-1.5 py-0.5 rounded border border-pink-200">
                      {{ formatTime(tick.time) }}
                    </span>
                  </div>
                </div>
                <!-- 播放指示线 -->
                <div 
                  class="absolute top-0 bottom-0 w-0.5 bg-red-500 z-30 pointer-events-none shadow-lg"
                  :style="{ left: (currentTime / audioDuration * timelineWidth) + 'px' }"
                >
                  <div class="absolute -top-2 left-1/2 -translate-x-1/2 w-3 h-3 bg-red-500 rounded-full border-2 border-white shadow-md"></div>
                  <div class="absolute top-full left-1/2 -translate-x-1/2 w-0 h-0 border-l-4 border-r-4 border-t-4 border-transparent border-t-red-500"></div>
                </div>
              </div>
            </div>
            
            <!-- 轨道区域（可滚动，与标尺垂直对齐） -->
            <div class="flex-1 overflow-auto relative"
              ref="timelineContainer"
              @scroll="onTimelineScroll"
            >
            <div class="flex" :style="{ height: timelineContentHeightPx + 'px' }">
                <!-- 固定左侧轨道控制栏 -->
                <div class="sticky left-0 z-10 bg-white border-r-2 border-pink-300 flex-shrink-0" style="width: 240px;">
                  <!-- 轨道列表 -->
                  <div class="space-y-0">
                    <div 
                      v-for="(track, index) in tracks" 
                      :key="track.id"
                      class="h-[104px] box-border bg-white border-b border-pink-200 flex flex-col overflow-hidden relative isolate cursor-pointer"
                      :class="{ 'bg-pink-50/30': selectedTrackId === track.id }"
                      @click="selectTrack(track.id)"
                    >
                      <!-- 轨道控制面板 -->
                      <div class="flex-1 flex flex-col px-3 py-2 overflow-hidden relative">
                        <!-- 轨道头部 -->
                        <div class="flex items-center gap-2 mb-2 flex-shrink-0 z-10 relative">
                          <!-- 折叠按钮 -->
                          <button 
                            @click.stop="toggleTrackCollapse(track.id)"
                            class="p-0.5 text-gray-400 hover:text-gray-600 transition flex-shrink-0"
                          >
                            <svg class="w-3 h-3 transition-transform" :class="{ '-rotate-90': track.collapsed }" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                            </svg>
                          </button>
                          <!-- 锁定按钮 -->
                          <button 
                            @click.stop="toggleTrackLock(track.id)"
                            class="p-0.5 text-gray-400 hover:text-gray-600 transition flex-shrink-0"
                            :class="{ 'text-yellow-500': track.locked }"
                            title="锁定轨道"
                          >
                            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path v-if="!track.locked" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 11V7a4 4 0 118 0m-4 8v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2z" />
                              <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                            </svg>
                          </button>
                          <!-- 颜色标识 -->
                          <div 
                            class="w-3 h-3 rounded-full flex-shrink-0 cursor-pointer border border-gray-300"
                            :class="track.color"
                            @click.stop="showTrackColorPicker(track.id)"
                            :title="'轨道颜色: ' + track.name"
                          ></div>
                          <!-- 轨道名称 -->
                          <div class="flex-1 min-w-0" @click.stop="selectTrack(track.id)">
                            <div class="text-xs font-medium text-gray-900 truncate">{{ track.name }}</div>
                            <div class="text-[10px] text-gray-500">{{ track.type }}</div>
                          </div>
                        </div>
                        <!-- 轨道控制区域 -->
                        <div v-if="!track.collapsed" class="flex-1 flex flex-col gap-2 overflow-hidden">
                          <!-- 静音/独奏/录音 -->
                          <div class="flex items-center gap-1 flex-shrink-0">
                            <button 
                              @click.stop="toggleMute(track.id)"
                              class="p-1.5 text-gray-500 hover:text-red-600 rounded transition flex-shrink-0"
                              :class="{ 'text-red-500 bg-red-50': track.muted }"
                              title="静音 (M)"
                            >
                              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path v-if="!track.muted" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
                                <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15zM18 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2" />
                              </svg>
                            </button>
                            <button 
                              @click.stop="toggleSolo(track.id)"
                              class="p-1.5 text-gray-500 hover:text-yellow-600 rounded transition flex-shrink-0"
                              :class="{ 'text-yellow-500 bg-yellow-50': track.solo }"
                              title="独奏 (S)"
                            >
                              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                              </svg>
                            </button>
                            <button 
                              @click.stop="toggleRecord(track.id)"
                              class="p-1.5 text-gray-500 hover:text-red-600 rounded transition flex-shrink-0"
                              :class="{ 'text-red-500 bg-red-50 animate-pulse': track.recording }"
                              title="录音 (R)"
                            >
                              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                                <circle cx="12" cy="12" r="10" />
                              </svg>
                            </button>
                            <!-- 删除按钮 -->
                            <button 
                              @click.stop="deleteTrack(track.id)"
                              class="p-1.5 text-gray-400 hover:text-red-500 rounded transition flex-shrink-0"
                              title="删除轨道"
                            >
                              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                              </svg>
                            </button>
                          </div>
                          <!-- 音量控制 -->
                          <div class="space-y-1 flex-shrink-0 relative z-0">
                            <div class="flex items-center justify-between">
                              <span class="text-[10px] text-gray-600">音量</span>
                              <span class="text-[10px] text-gray-500 font-mono">{{ track.volume }}%</span>
                            </div>
                            <div class="relative overflow-hidden" style="padding: 0 2px; max-height: 6px;">
                              <input 
                                type="range" 
                                min="0" 
                                max="100" 
                                v-model="track.volume"
                                @click.stop
                                class="w-full h-1.5 bg-pink-100 rounded-lg appearance-none cursor-pointer relative z-0"
                                style="background: linear-gradient(to right, #FF6B9D 0%, #FF6B9D var(--volume), #fce7f3 var(--volume), #fce7f3 100%);"
                                :style="{ '--volume': track.volume + '%' }"
                              />
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                
                <!-- 可滚动的轨道内容区域 -->
                <div class="flex-1 overflow-x-auto overflow-y-auto relative z-0" :style="{ width: `calc(100% - 240px)` }">
                  <div class="relative" :style="{ width: timelineWidth + 'px' }">
                    <!-- 轨道内容列表 -->
                    <div class="space-y-0">
                      <div 
                        v-for="(track, index) in tracks" 
                        :key="'content-' + track.id"
                        class="h-[104px] box-border border-b border-pink-200 bg-white relative"
                        :class="{ 'bg-pink-50/30': selectedTrackId === track.id }"
                      >
                        <!-- 轨道内容区域 -->
                        <div 
                          v-if="!track.collapsed"
                          class="absolute inset-0"
                          @click="selectTrack(track.id)"
                        >
                          <!-- 网格对齐线 -->
                          <div class="absolute inset-0 opacity-10 pointer-events-none">
                            <div 
                              v-for="tick in timeTicks" 
                              :key="'grid-' + track.id + '-' + tick.time"
                              class="absolute top-0 bottom-0 w-px bg-pink-200"
                              :style="{ left: (tick.time / audioDuration * timelineWidth) + 'px' }"
                            ></div>
                          </div>
                          <!-- 波形预览背景 -->
                          <div class="absolute inset-0 opacity-15 pointer-events-none">
                            <div class="h-full flex items-end gap-0.5 px-1">
                              <div 
                                v-for="i in Math.min(100, Math.floor(timelineWidth / 8))" 
                                :key="'wave-' + track.id + '-' + i"
                                class="flex-1 bg-gradient-to-t from-pink-400 to-transparent rounded-t"
                                :style="{ 
                                  height: (Math.sin(i * 0.2) * 15 + 30) + '%',
                                  minHeight: '4px'
                                }"
                              ></div>
                            </div>
                          </div>
                          <!-- 音频片段 -->
                          <div 
                            v-for="clip in track.clips" 
                            :key="clip.id"
                            class="absolute top-2 bottom-2 rounded border-2 cursor-move hover:shadow-lg transition group z-10"
                            :class="[
                              clip.color,
                              { 
                                'ring-2 ring-blue-400': selectedClipId === clip.id,
                                'opacity-50 cursor-not-allowed': track.locked
                              }
                            ]"
                            :style="{
                              left: (clip.start / audioDuration * timelineWidth) + 'px',
                              width: ((clip.end - clip.start) / audioDuration * timelineWidth) + 'px',
                              minWidth: '40px'
                            }"
                            @mousedown.stop="!track.locked && startDragClip(clip, $event)"
                            @click.stop="selectClip(clip)"
                            @dblclick.stop="editClip(clip)"
                          >
                            <!-- 片段内容 -->
                            <div class="h-full flex flex-col justify-between px-2 py-1">
                              <div class="flex items-center justify-between">
                                <span class="text-[10px] text-white font-medium truncate">{{ clip.name }}</span>
                                <div class="flex items-center gap-1">
                                  <!-- 淡入淡出指示 -->
                                  <div v-if="clip.fadeIn" class="w-1.5 h-1.5 bg-white/50 rounded-full" title="淡入"></div>
                                  <div v-if="clip.fadeOut" class="w-1.5 h-1.5 bg-white/50 rounded-full" title="淡出"></div>
                                </div>
                              </div>
                              <!-- 时间显示 -->
                              <div class="text-[9px] text-white/80 font-mono">
                                {{ formatTime(clip.start) }} - {{ formatTime(clip.end) }}
                              </div>
                            </div>
                            <!-- 调整大小手柄 -->
                            <div 
                              class="absolute left-0 top-0 bottom-0 w-2 cursor-ew-resize hover:bg-white/30 rounded-l transition"
                              @mousedown.stop="!track.locked && startResizeClip(clip, 'start', $event)"
                            ></div>
                            <div 
                              class="absolute right-0 top-0 bottom-0 w-2 cursor-ew-resize hover:bg-white/30 rounded-r transition"
                              @mousedown.stop="!track.locked && startResizeClip(clip, 'end', $event)"
                            ></div>
                          </div>
                          <!-- 播放指示线（在轨道内） -->
                          <div 
                            class="absolute top-0 bottom-0 w-0.5 bg-red-500 z-20 pointer-events-none"
                            :style="{ left: (currentTime / audioDuration * timelineWidth) + 'px' }"
                          >
                            <div class="absolute -top-1 left-1/2 -translate-x-1/2 w-2 h-2 bg-red-500 rounded-full border border-white"></div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        </div>

        <!-- Content Enhancement View -->
        <div v-if="activeToolTab === 'enhance'" class="flex-1 overflow-y-auto bg-gray-50 p-8 animate-fadeIn">
          <div class="max-w-5xl mx-auto space-y-8">
             <div class="flex items-center justify-between">
                <h2 class="text-2xl font-bold text-gray-900">内容增值工作台</h2>
                <div class="text-sm text-gray-500">利用 AI 为您的播客创造更多价值</div>
             </div>
             
             <!-- 1. Shownotes 生成 -->
             <section class="bg-white rounded-xl border border-pink-200 shadow-sm p-6">
                <div class="flex items-center gap-3 mb-6">
                  <div class="w-10 h-10 rounded-full bg-purple-100 flex items-center justify-center text-purple-600">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" /></svg>
                  </div>
                  <div>
                    <h3 class="text-lg font-bold text-gray-900">智能 Shownotes</h3>
                    <p class="text-xs text-gray-500">一键生成标题、摘要、时间戳和思维导图</p>
                  </div>
                </div>
                
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                   <!-- 生成选项 -->
                   <div class="space-y-4">
                      <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">播客类型</label>
                        <select v-model="podcastType" class="w-full rounded-lg border-gray-300 border p-2 text-sm focus:ring-2 focus:ring-pink-300 focus:border-pink-300">
                          <option value="knowledge">知识分享类 (干货提取)</option>
                          <option value="companion">情感陪伴类 (氛围描述)</option>
                          <option value="interview">访谈对话类 (观点碰撞)</option>
                          <option value="story">故事叙述类 (情节梳理)</option>
                        </select>
                      </div>
                      
                      <div>
                         <label class="block text-sm font-medium text-gray-700 mb-2">包含内容</label>
                         <div class="space-y-2">
                           <label class="flex items-center gap-2 text-sm text-gray-600">
                             <input type="checkbox" checked class="rounded border-gray-300 text-pink-600 focus:ring-pink-500">
                             SEO 优化标题 (5个备选)
                           </label>
                           <label class="flex items-center gap-2 text-sm text-gray-600">
                             <input type="checkbox" checked class="rounded border-gray-300 text-pink-600 focus:ring-pink-500">
                             内容摘要 (300字)
                           </label>
                           <label class="flex items-center gap-2 text-sm text-gray-600">
                             <input type="checkbox" checked class="rounded border-gray-300 text-pink-600 focus:ring-pink-500">
                             带跳转的时间戳
                           </label>
                         </div>
                      </div>

                      <button 
                        @click="generateShownotes"
                        :disabled="isGeneratingShownotes"
                        class="w-full py-2.5 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-lg hover:shadow-lg transition font-medium disabled:opacity-50 flex items-center justify-center gap-2"
                      >
                         <svg v-if="isGeneratingShownotes" class="animate-spin h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                           <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                           <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                         </svg>
                         {{ isGeneratingShownotes ? 'AI 正在生成...' : '立即生成 Shownotes' }}
                      </button>
                   </div>

                   <!-- 结果预览 -->
                   <div class="bg-gray-50 rounded-lg border border-gray-200 p-4 min-h-[300px]">
                      <div v-if="!shownotesData" class="h-full flex flex-col items-center justify-center text-gray-400">
                         <svg class="w-12 h-12 mb-2 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" /></svg>
                         <span class="text-sm">点击生成查看结果</span>
                      </div>
                      <div v-else class="space-y-4 animate-fadeIn">
                         <div class="space-y-2">
                            <h4 class="text-xs font-bold text-gray-500 uppercase">推荐标题</h4>
                            <div class="space-y-1">
                               <div v-for="(title, idx) in shownotesData.titles" :key="idx" class="p-2 bg-white border border-gray-200 rounded text-sm text-gray-800 hover:border-pink-300 cursor-pointer transition flex items-center justify-between group">
                                  <span>{{ title }}</span>
                                  <button class="text-xs text-pink-600 opacity-0 group-hover:opacity-100">复制</button>
                               </div>
                            </div>
                         </div>
                         <div class="space-y-2">
                            <h4 class="text-xs font-bold text-gray-500 uppercase">摘要</h4>
                            <p class="text-sm text-gray-700 bg-white p-3 rounded border border-gray-200 leading-relaxed">{{ shownotesData.summary }}</p>
                         </div>
                         <div class="pt-2">
                            <button @click="showMindMap = true" class="text-sm text-purple-600 hover:text-purple-800 flex items-center gap-1">
                               <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0121 18.382V7.618a1 1 0 01-.553-.894L15 7m0 13V7" /></svg>
                               查看思维导图
                            </button>
                         </div>
                      </div>
                   </div>
                </div>
             </section>

             <!-- 2. 视频化与分发 -->
             <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                <!-- 视频播客生成 -->
                <section class="bg-white rounded-xl border border-pink-200 shadow-sm p-6">
                   <div class="flex items-center gap-3 mb-4">
                      <div class="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-600">
                         <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" /></svg>
                      </div>
                      <div>
                         <h3 class="text-lg font-bold text-gray-900">视频播客生成</h3>
                         <p class="text-xs text-gray-500">将音频转化为短视频，抢占视频平台流量</p>
                      </div>
                   </div>
                   
                   <div class="space-y-4">
                      <div class="grid grid-cols-2 gap-3">
                         <div 
                           class="p-3 border rounded-lg cursor-pointer transition hover:border-pink-400"
                           :class="videoTemplate === 'digital-human' ? 'border-pink-500 bg-pink-50' : 'border-gray-200'"
                           @click="videoTemplate = 'digital-human'"
                         >
                            <div class="text-sm font-medium text-gray-900 mb-1">AI 数字人口播</div>
                            <div class="text-xs text-gray-500">根据音频口型驱动数字人</div>
                         </div>
                         <div 
                           class="p-3 border rounded-lg cursor-pointer transition hover:border-pink-400"
                           :class="videoTemplate === 'waveform' ? 'border-pink-500 bg-pink-50' : 'border-gray-200'"
                           @click="videoTemplate = 'waveform'"
                         >
                            <div class="text-sm font-medium text-gray-900 mb-1">波形可视化</div>
                            <div class="text-xs text-gray-500">动态波形 + 滚动字幕</div>
                         </div>
                      </div>
                      
                      <div class="bg-gray-50 p-3 rounded border border-gray-200">
                         <div class="text-xs text-gray-500 mb-2">选择金句片段</div>
                         <div class="flex flex-wrap gap-2">
                           <button 
                             v-for="s in goldenSentences" 
                             :key="s.id"
                             @click="toggleGoldenSentence(s)"
                             class="px-2 py-1 rounded text-xs transition border"
                             :class="selectedSentences.includes(s.id) ? 'bg-blue-500 text-white border-blue-600' : 'bg-white text-gray-700 border-gray-200 hover:border-pink-300'"
                           >
                             金句片段 {{ s.id - 100 }} ({{ Math.max(1, Math.round((s.endTime - s.startTime))) }}s)
                           </button>
                         </div>
                      </div>

                      <button 
                        @click="generateVideoPreview"
                        :disabled="isGeneratingVideo"
                        class="w-full py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition text-sm disabled:opacity-50 flex items-center justify-center gap-2"
                      >
                         <svg v-if="isGeneratingVideo" class="animate-spin h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                           <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                           <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                         </svg>
                         {{ isGeneratingVideo ? '正在生成视频...' : '生成预览视频' }}
                      </button>

                      <!-- 生成结果列表 -->
                      <div v-if="generatedVideos.length" class="space-y-2 pt-2 border-t border-gray-100">
                        <div class="text-xs font-medium text-gray-900">已生成视频</div>
                        <div v-for="(video, idx) in generatedVideos" :key="video.id" class="flex gap-3 p-3 bg-gray-50 rounded border border-gray-200 hover:border-pink-200 transition group">
                           <div class="w-24 h-16 bg-gray-300 rounded overflow-hidden flex-shrink-0 relative cursor-pointer" @click="previewVideo(video)">
                             <img :src="video.thumbnail" class="w-full h-full object-cover">
                             <div class="absolute bottom-0.5 right-0.5 px-1 py-0.5 bg-black/50 text-[8px] text-white rounded">{{ video.duration }}</div>
                             <div class="absolute inset-0 bg-black/30 hidden group-hover:flex items-center justify-center transition">
                                <svg class="w-8 h-8 text-white opacity-80 hover:opacity-100" fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
                             </div>
                           </div>
                           <div class="flex-1 min-w-0 flex flex-col justify-between py-0.5">
                              <div>
                                <div class="text-xs font-medium text-gray-900 truncate">视频预览_{{ video.id }}</div>
                                <div class="text-[10px] text-gray-500 mt-0.5">模板: {{ video.template === 'digital-human' ? '数字人' : '波形可视化' }}</div>
                              </div>
                              <div class="flex gap-3">
                                 <button @click="previewVideo(video)" class="text-[10px] text-blue-600 hover:text-blue-800 flex items-center gap-1">
                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                                    查看详情
                                 </button>
                                 <button class="text-[10px] text-gray-500 hover:text-gray-700">删除</button>
                              </div>
                           </div>
                        </div>
                      </div>
                   </div>
                </section>

                <!-- 社交媒体文案 -->
                <section class="bg-white rounded-xl border border-pink-200 shadow-sm p-6">
                   <div class="flex items-center gap-3 mb-4">
                      <div class="w-10 h-10 rounded-full bg-green-100 flex items-center justify-center text-green-600">
                         <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" /></svg>
                      </div>
                      <div>
                         <h3 class="text-lg font-bold text-gray-900">多平台文案</h3>
                         <p class="text-xs text-gray-500">针对不同平台调性生成推广文案</p>
                      </div>
                   </div>
                   
                   <div class="space-y-3">
                      <div class="flex gap-2 border-b border-gray-100 pb-2">
                         <button 
                           @click="socialPlatform = 'wechat'"
                           class="px-3 py-1 text-xs rounded-full transition"
                           :class="socialPlatform === 'wechat' ? 'bg-green-100 text-green-700' : 'text-gray-600 hover:bg-gray-50'"
                         >公众号</button>
                         <button 
                           @click="socialPlatform = 'xiaohongshu'"
                           class="px-3 py-1 text-xs rounded-full transition"
                           :class="socialPlatform === 'xiaohongshu' ? 'bg-red-100 text-red-700' : 'text-gray-600 hover:bg-gray-50'"
                         >小红书</button>
                         <button 
                           @click="socialPlatform = 'weibo'"
                           class="px-3 py-1 text-xs rounded-full transition"
                           :class="socialPlatform === 'weibo' ? 'bg-blue-100 text-blue-700' : 'text-gray-600 hover:bg-gray-50'"
                         >微博</button>
                      </div>
                      <div class="relative">
                        <textarea 
                          v-model="socialCopyContent"
                          class="w-full h-32 p-3 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-green-200 focus:border-green-400 resize-none" 
                          :placeholder="isGeneratingCopy ? 'AI 正在思考中...' : 'AI 将在此生成适配该平台的推广文案...'"
                          :disabled="isGeneratingCopy"
                        ></textarea>
                        <div v-if="isGeneratingCopy" class="absolute inset-0 bg-white/50 flex items-center justify-center">
                          <svg class="animate-spin h-6 w-6 text-green-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                          </svg>
                        </div>
                      </div>
                      <div class="flex justify-end gap-2">
                         <button 
                           @click="generateSocialCopy"
                           :disabled="isGeneratingCopy"
                           class="px-3 py-1.5 text-xs text-gray-600 hover:bg-gray-100 rounded disabled:opacity-50"
                         >
                           {{ socialCopyContent ? '重新生成' : '立即生成' }}
                         </button>
                         <button 
                           @click="copySocialCopy"
                           :disabled="!socialCopyContent"
                           class="px-3 py-1.5 text-xs bg-green-500 text-white rounded hover:bg-green-600 disabled:opacity-50 disabled:bg-gray-300"
                         >
                           复制文案
                         </button>
                      </div>
                   </div>
                </section>

               <!-- MindMap Modal -->
               <div v-if="showMindMap" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm" @click.self="showMindMap = false">
                  <div class="bg-white rounded-xl shadow-2xl w-[800px] h-[600px] flex flex-col overflow-hidden animate-scaleIn">
                     <div class="flex items-center justify-between p-4 border-b border-gray-100">
                        <h3 class="text-lg font-bold text-gray-900">思维导图预览</h3>
                        <button @click="showMindMap = false" class="text-gray-400 hover:text-gray-600">
                           <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
                        </button>
                     </div>
                     <div class="flex-1 bg-gray-50 p-6 overflow-auto flex items-center justify-center">
                        <!-- Simple CSS Mindmap Visualization -->
                        <div class="flex flex-col items-center gap-8">
                           <div class="bg-pink-100 text-pink-700 px-6 py-3 rounded-lg font-bold border border-pink-200 shadow-sm">
                              {{ shownotesData.mindmap?.root || 'AI 播客创作' }}
                           </div>
                           <div class="flex gap-12 relative">
                              <!-- Connector Lines (Simplified) -->
                              <div class="absolute top-[-2rem] left-1/2 -translate-x-1/2 w-[80%] h-8 border-t-2 border-l-2 border-r-2 border-gray-300 rounded-t-xl"></div>
                              
                              <div v-for="(node, idx) in shownotesData.mindmap?.children" :key="idx" class="flex flex-col items-center gap-4 relative">
                                  <div class="w-0.5 h-4 bg-gray-300 absolute -top-4"></div>
                                  <div class="bg-white border border-gray-200 px-4 py-2 rounded-lg font-medium shadow-sm text-sm text-center min-w-[100px]">
                                     <div>{{ node.label }}</div>
                                     <div v-if="node.time" class="text-xs text-gray-400 mt-0.5">{{ node.time }}</div>
                                  </div>
                                  <div v-if="node.children" class="flex flex-col gap-2 relative pt-4">
                                     <div class="w-0.5 h-4 bg-gray-300 absolute top-0 left-1/2 -translate-x-1/2"></div>
                                     <div v-for="(child, cIdx) in node.children" :key="cIdx" class="bg-gray-50 border border-gray-100 px-3 py-1.5 rounded text-xs text-gray-600 flex flex-col items-center gap-0.5 min-w-[80px]">
                                        <span>{{ child.label }}</span>
                                        <span v-if="child.time" class="text-[10px] text-gray-400">{{ child.time }}</span>
                                     </div>
                                  </div>
                               </div>
                           </div>
                        </div>
                     </div>
                     <div class="p-4 border-t border-gray-100 flex justify-end gap-2 bg-gray-50">
                        <button class="px-4 py-2 text-sm text-gray-600 hover:bg-gray-200 rounded-lg">导出图片</button>
                        <button class="px-4 py-2 text-sm bg-pink-500 text-white rounded-lg hover:bg-pink-600 shadow-sm">导出 PDF</button>
                     </div>
                  </div>
               </div>

               <!-- Video Preview Modal -->
               <div v-if="showVideoPreview" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm" @click.self="showVideoPreview = false">
                  <div class="bg-white rounded-xl shadow-2xl w-[640px] flex flex-col overflow-hidden animate-scaleIn">
                     <div class="flex items-center justify-between p-4 border-b border-gray-100">
                        <h3 class="text-lg font-bold text-gray-900">视频预览</h3>
                        <button @click="showVideoPreview = false" class="text-gray-400 hover:text-gray-600">
                           <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
                        </button>
                     </div>
                     <div class="aspect-video bg-black flex items-center justify-center relative group">
                        <!-- Mock Video Player -->
                        <img :src="currentVideo?.thumbnail" class="w-full h-full object-cover opacity-80">
                        <div class="absolute inset-0 flex items-center justify-center">
                           <div class="w-16 h-16 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center cursor-pointer hover:scale-110 transition">
                              <svg class="w-8 h-8 text-white ml-1" fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
                           </div>
                        </div>
                        <div class="absolute bottom-4 left-4 right-4 h-1 bg-white/30 rounded-full overflow-hidden">
                           <div class="h-full w-1/3 bg-pink-500 rounded-full"></div>
                        </div>
                        <div class="absolute bottom-8 left-4 text-white text-xs">{{ currentVideo?.duration }}</div>
                     </div>
                     <div class="p-4 border-t border-gray-100 flex justify-end gap-2 bg-gray-50">
                        <button class="px-4 py-2 text-sm text-gray-600 hover:bg-gray-200 rounded-lg">下载视频</button>
                        <button class="px-4 py-2 text-sm bg-pink-500 text-white rounded-lg hover:bg-pink-600 shadow-sm">分享</button>
                     </div>
                  </div>
               </div>
            </div>
          </div>
        </div>

        <!-- Export Distribution View -->
        <div v-if="activeToolTab === 'export'" class="flex-1 overflow-y-auto bg-gray-50 p-8 animate-fadeIn">
           <div class="max-w-4xl mx-auto space-y-8">
              <div class="flex items-center justify-between">
                <h2 class="text-2xl font-bold text-gray-900">导出与分发</h2>
                <button @click="doExport" class="px-6 py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg shadow-lg hover:shadow-xl hover:scale-105 transition font-bold">
                   立即导出
                </button>
             </div>

             <div class="bg-white rounded-xl border border-pink-200 shadow-sm overflow-hidden">
                <div class="p-6 border-b border-gray-100">
                   <h3 class="text-lg font-bold text-gray-900 mb-4">导出设置</h3>
                   <div class="grid grid-cols-2 gap-6">
                      <div>
                         <label class="block text-sm font-medium text-gray-700 mb-2">文件格式</label>
                         <div class="flex gap-4">
                            <label class="flex items-center gap-2 cursor-pointer">
                               <input type="radio" name="format" class="text-pink-600 focus:ring-pink-500" checked>
                               <span class="text-sm text-gray-800">MP3 (推荐)</span>
                            </label>
                            <label class="flex items-center gap-2 cursor-pointer">
                               <input type="radio" name="format" class="text-pink-600 focus:ring-pink-500">
                               <span class="text-sm text-gray-800">WAV (无损)</span>
                            </label>
                            <label class="flex items-center gap-2 cursor-pointer">
                               <input type="radio" name="format" class="text-pink-600 focus:ring-pink-500">
                               <span class="text-sm text-gray-800">M4A</span>
                            </label>
                         </div>
                      </div>
                      <div>
                         <label class="block text-sm font-medium text-gray-700 mb-2">音质比特率</label>
                         <select class="w-full rounded border-gray-300 text-sm py-1.5">
                            <option>128 kbps (标准)</option>
                            <option selected>192 kbps (高品质)</option>
                            <option>320 kbps (超高品质)</option>
                         </select>
                      </div>
                   </div>
                </div>
                
                <div class="p-6 bg-gray-50/50">
                   <h3 class="text-lg font-bold text-gray-900 mb-4">一键分发</h3>
                   <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
                      <div 
                        class="flex flex-col items-center justify-center p-4 bg-white border rounded-lg transition cursor-pointer group"
                        :class="selectedPlatforms.includes('weixin') ? 'border-green-500 shadow-md' : 'border-gray-200 hover:border-green-400 hover:shadow-md'"
                        @click="togglePlatform('weixin')"
                      >
                         <img :src="weixinIcon" class="w-10 h-10 mb-2 transition" :class="selectedPlatforms.includes('weixin') ? '' : 'grayscale group-hover:grayscale-0'" />
                         <span class="text-sm font-medium text-gray-700">微信听书</span>
                         <span class="text-xs mt-1" :class="selectedPlatforms.includes('weixin') ? 'text-green-600' : 'text-gray-400'">{{ selectedPlatforms.includes('weixin') ? '已选中' : '未绑定' }}</span>
                      </div>
                      <div 
                        class="flex flex-col items-center justify-center p-4 bg-white border rounded-lg transition cursor-pointer group"
                        :class="selectedPlatforms.includes('douyin') ? 'border-black shadow-md' : 'border-gray-200 hover:border-black hover:shadow-md'"
                        @click="togglePlatform('douyin')"
                      >
                         <img :src="douyinIcon" class="w-10 h-10 mb-2 transition" :class="selectedPlatforms.includes('douyin') ? '' : 'grayscale group-hover:grayscale-0'" />
                         <span class="text-sm font-medium text-gray-700">抖音</span>
                         <span class="text-xs mt-1" :class="selectedPlatforms.includes('douyin') ? 'text-black' : 'text-gray-400'">{{ selectedPlatforms.includes('douyin') ? '已选中' : '未绑定' }}</span>
                      </div>
                      <div 
                        class="flex flex-col items-center justify-center p-4 bg-white border rounded-lg transition cursor-pointer group"
                        :class="selectedPlatforms.includes('qq') ? 'border-blue-500 shadow-md' : 'border-gray-200 hover:border-blue-400 hover:shadow-md'"
                        @click="togglePlatform('qq')"
                      >
                         <img :src="qqIcon" class="w-10 h-10 mb-2 transition" :class="selectedPlatforms.includes('qq') ? '' : 'grayscale group-hover:grayscale-0'" />
                         <span class="text-sm font-medium text-gray-700">QQ 音乐</span>
                         <span class="text-xs mt-1" :class="selectedPlatforms.includes('qq') ? 'text-blue-600' : 'text-gray-400'">{{ selectedPlatforms.includes('qq') ? '已选中' : '未绑定' }}</span>
                      </div>
                      <div 
                        class="flex flex-col items-center justify-center p-4 bg-white border rounded-lg transition cursor-pointer group"
                        :class="selectedPlatforms.includes('xiaohongshu') ? 'border-red-500 shadow-md' : 'border-gray-200 hover:border-red-400 hover:shadow-md'"
                        @click="togglePlatform('xiaohongshu')"
                      >
                         <img :src="xiaohongshuIcon" class="w-10 h-10 mb-2 transition" :class="selectedPlatforms.includes('xiaohongshu') ? '' : 'grayscale group-hover:grayscale-0'" />
                         <span class="text-sm font-medium text-gray-700">小红书</span>
                         <span class="text-xs mt-1" :class="selectedPlatforms.includes('xiaohongshu') ? 'text-red-600' : 'text-gray-400'">{{ selectedPlatforms.includes('xiaohongshu') ? '已选中' : '未绑定' }}</span>
                      </div>
                      <div 
                        class="flex flex-col items-center justify-center p-4 bg-white border rounded-lg transition cursor-pointer group"
                        :class="selectedPlatforms.includes('apple') ? 'border-orange-500 shadow-md' : 'border-gray-200 hover:border-orange-400 hover:shadow-md'"
                        @click="togglePlatform('apple')"
                      >
                         <img :src="appleIcon" class="w-10 h-10 mb-2 transition" :class="selectedPlatforms.includes('apple') ? '' : 'grayscale group-hover:grayscale-0'" />
                         <span class="text-sm font-medium text-gray-700">Apple 播客</span>
                         <span class="text-xs mt-1" :class="selectedPlatforms.includes('apple') ? 'text-orange-600' : 'text-gray-400'">{{ selectedPlatforms.includes('apple') ? '已选中' : '未绑定' }}</span>
                      </div>
                      <div 
                        class="flex flex-col items-center justify-center p-4 bg-white border rounded-lg transition cursor-pointer group"
                        :class="selectedPlatforms.includes('xiaoyuzhou') ? 'border-yellow-500 shadow-md' : 'border-gray-200 hover:border-yellow-400 hover:shadow-md'"
                        @click="togglePlatform('xiaoyuzhou')"
                      >
                         <img :src="xiaoyuzhouIcon" class="w-10 h-10 mb-2 transition" :class="selectedPlatforms.includes('xiaoyuzhou') ? '' : 'grayscale group-hover:grayscale-0'" />
                         <span class="text-sm font-medium text-gray-700">小宇宙</span>
                         <span class="text-xs mt-1" :class="selectedPlatforms.includes('xiaoyuzhou') ? 'text-yellow-600' : 'text-gray-400'">{{ selectedPlatforms.includes('xiaoyuzhou') ? '已选中' : '未绑定' }}</span>
                      </div>
                   </div>
                </div>
             </div>
           </div>
        </div>

      </main>

      <!-- 4. 右侧：AI 智能工具箱 (Feature 3, 4, 5) -->
      <aside v-show="activeToolTab === 'edit'" class="w-96 flex-none bg-gradient-to-b from-pink-50 to-purple-50 border-l border-pink-200 flex flex-col" :style="{ height: totalEditorHeightPx + 'px' }">
        <div class="p-6 space-y-8 overflow-y-auto" :style="rightPanelStyle">
          
          <!-- Tab 1: 智能剪辑 (Feature 3) -->
          <div v-if="activeToolTab === 'edit'" class="space-y-6 animate-fadeIn">
            <!-- 脚本优化 -->
            <section>
              <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-blue-500 rounded-full"></span>
                脚本优化
              </h3>
              <div class="grid grid-cols-2 gap-2">
                <button
                  class="p-2 bg-white border border-pink-200 rounded text-xs text-gray-900 hover:border-pink-400 hover:text-pink-600 transition"
                  title="自动修正错别字、剔除口语化冗余"
                  @click="applyScriptOptimization('filler')"
                >
                  去口语冗余
                </button>
                <button
                  class="p-2 bg-white border border-pink-200 rounded text-xs text-gray-900 hover:border-pink-400 hover:text-pink-600 transition"
                  title="检测逻辑断层，推荐衔接句"
                  @click="applyScriptOptimization('logic')"
                >
                  逻辑纠错
                </button>
                <button
                  class="p-2 bg-white border border-pink-200 rounded text-xs text-gray-900 hover:border-pink-400 hover:text-pink-600 transition"
                  title="提取核心片段生成精华版"
                  @click="applyScriptOptimization('highlights')"
                >
                  一键精华提取
                </button>
                <button
                  class="p-2 bg-white border border-pink-200 rounded text-xs text-gray-900 hover:border-pink-400 hover:text-pink-600 transition"
                  title="根据内容推荐背景音乐"
                  @click="applyScriptOptimization('bgm')"
                >
                  BGM智能匹配
                </button>
              </div>
              <div v-if="scriptOptimizeMessage" class="mt-2 text-[11px] text-gray-600">{{ scriptOptimizeMessage }}</div>
            </section>

             <!-- 语音生成（示例交互） -->
             <section>
              <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-pink-500 rounded-full"></span>
                语音生成
              </h3>
               <div class="space-y-3">
                 <div class="grid grid-cols-2 gap-2">
                    <button
                      class="p-2 bg-white border border-pink-200 rounded text-xs text-gray-900 hover:border-pink-400 hover:text-pink-600 transition flex items-center justify-center gap-1"
                      @click="handleVoiceTool('clone')"
                    >
                      <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" /></svg>
                      声线克隆
                    </button>
                     <button
                      class="p-2 bg-white border border-pink-200 rounded text-xs text-gray-900 hover:border-pink-400 hover:text-pink-600 transition"
                      @click="handleVoiceTool('multi')"
                    >
                      多角色生成
                    </button>
                 </div>
                 <!-- 最近语音生成任务列表 -->
                 <div v-if="voiceTasks.length" class="pt-2 border-t border-pink-100 space-y-1">
                  <div class="text-xs font-medium text-gray-900">最近语音生成任务</div>
                  <div
                    v-for="task in voiceTasks"
                    :key="task.id"
                  class="flex items-center justify-between px-2 py-1 rounded bg-pink-50 border border-pink-100 text-[11px] text-gray-700"
                  >
                    <div class="flex-1 min-w-0">
                      <div class="font-medium text-gray-900 truncate">{{ task.label }}</div>
                      <div class="text-[10px] text-gray-500 truncate">{{ task.note }}</div>
                    </div>
                  <div class="ml-2 text-right flex items-center gap-2">
                      <div class="text-[10px] text-gray-400">{{ task.createdAt }}</div>
                      <div
                        class="mt-0.5 inline-flex items-center px-2 py-0.5 rounded-full text-[10px]"
                        :class="task.status === '已完成' ? 'bg-emerald-100 text-emerald-700' : 'bg-amber-100 text-amber-700'"
                      >
                        {{ task.status }}
                      </div>
                   <button 
                     v-if="task.status === '已完成'"
                     @click="openTTSPreview(task)"
                     class="px-2 py-0.5 rounded border text-[10px] hover:bg-pink-50"
                     :class="task.inserted ? 'border-blue-500 text-blue-600' : 'border-pink-300 text-gray-900'"
                   >
                     {{ task.inserted ? '已插入' : '查看' }}
                   </button>
                    </div>
                  </div>
                 </div>
               </div>
            </section>

            <section>
              <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-indigo-500 rounded-full"></span>
                AI 专项剪辑
              </h3>
              <div class="p-4 bg-white border border-pink-200 rounded-lg space-y-4">
                <div class="text-xs font-medium text-gray-900 mb-2">请选择 AI 剪辑方案</div>
                <div class="space-y-2.5">
                  <label class="flex items-start gap-2.5 text-sm text-gray-700 cursor-pointer hover:text-pink-600 transition p-2 rounded hover:bg-pink-50 group">
                    <input type="radio" name="cuttingStrategy" class="w-4 h-4 mt-0.5 border-2 border-pink-300 text-pink-600 focus:ring-2 focus:ring-pink-300 focus:ring-offset-0" v-model="cuttingStrategy" value="all">
                    <div class="flex-1">
                      <div class="font-medium">AI 全剪辑</div>
                      <div class="text-xs text-gray-500 mt-0.5">一键全剪，处理所有冗余内容</div>
                    </div>
                  </label>
                  <label class="flex items-start gap-2.5 text-sm text-gray-700 cursor-pointer hover:text-pink-600 transition p-2 rounded hover:bg-pink-50 group">
                    <input type="radio" name="cuttingStrategy" class="w-4 h-4 mt-0.5 border-2 border-pink-300 text-pink-600 focus:ring-2 focus:ring-pink-300 focus:ring-offset-0" v-model="cuttingStrategy" value="filler">
                    <div class="flex-1">
                      <div class="font-medium">AI 口癖剪辑</div>
                      <div class="text-xs text-gray-500 mt-0.5">只处理口癖（如：嗯、呃、这个、那个等语气词）</div>
                    </div>
                  </label>
                  <label class="flex items-start gap-2.5 text-sm text-gray-700 cursor-pointer hover:text-pink-600 transition p-2 rounded hover:bg-pink-50 group">
                    <input type="radio" name="cuttingStrategy" class="w-4 h-4 mt-0.5 border-2 border-pink-300 text-pink-600 focus:ring-2 focus:ring-pink-300 focus:ring-offset-0" v-model="cuttingStrategy" value="stutter">
                    <div class="flex-1">
                      <div class="font-medium">AI 口吃剪辑</div>
                      <div class="text-xs text-gray-500 mt-0.5">只处理口吃（如：重复字词、结巴等）</div>
                    </div>
                  </label>
                  <label class="flex items-start gap-2.5 text-sm text-gray-700 cursor-pointer hover:text-pink-600 transition p-2 rounded hover:bg-pink-50 group">
                    <input type="radio" name="cuttingStrategy" class="w-4 h-4 mt-0.5 border-2 border-pink-300 text-pink-600 focus:ring-2 focus:ring-pink-300 focus:ring-offset-0" v-model="cuttingStrategy" value="both">
                    <div class="flex-1">
                      <div class="font-medium">AI 口癖&口吃剪辑</div>
                      <div class="text-xs text-gray-500 mt-0.5">同时处理口癖和口吃，保留说话风格</div>
                    </div>
                  </label>
                </div>
                <div class="pt-2">
                  <button 
                    @click="generateCutSuggestions" 
                    :disabled="isGenerating"
                    class="w-full py-2.5 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white text-sm font-medium rounded-lg transition shadow-lg hover:shadow-xl hover:scale-[1.02] disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100 flex items-center justify-center gap-2"
                  >
                    <svg v-if="isGenerating" class="animate-spin h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    <span>{{ isGenerating ? '生成中...' : '立即生成剪辑建议' }}</span>
                  </button>
                  <div class="mt-2 text-[10px] text-gray-500 text-center">该功能面向会员限时免费</div>
                </div>
                <div v-if="cutSuggestions.length" class="space-y-2">
                  <div v-for="s in cutSuggestions" :key="s.id" class="p-3 bg-white border border-pink-200 rounded text-xs text-gray-700 flex flex-col gap-2">
                    <div class="flex items-center justify-between">
                      <div class="font-medium text-gray-900">{{ s.label }}</div>
                      <span class="px-2 py-0.5 rounded bg-pink-100 text-pink-700 border border-pink-200 text-[10px]">{{ s.tag }}</span>
                    </div>
                    <div class="text-[10px] text-gray-600 leading-relaxed bg-gray-50 p-2 rounded border border-dashed border-gray-200" v-html="s.previewHtml"></div>
                    <div class="flex justify-end gap-2 mt-1">
                      <button 
                        @click="applyCutSuggestion(s)"
                        class="px-3 py-1 bg-pink-500 text-white rounded-full text-[10px] hover:bg-pink-600 transition shadow-sm"
                      >应用建议</button>
                      <button 
                        @click="cutSuggestions = cutSuggestions.filter(item => item.id !== s.id)"
                        class="px-3 py-1 bg-white text-gray-500 border border-gray-200 rounded-full text-[10px] hover:bg-gray-50 transition"
                      >忽略</button>
                    </div>
                  </div>
                </div>
                <div v-if="samplePreview.length" class="space-y-3 pt-2 border-t border-pink-100">
                  <div class="text-xs font-bold text-gray-900">优化预览</div>
                  <div v-for="group in samplePreview" :key="group.id" class="space-y-2">
                    <div class="text-[11px] px-2 py-1 rounded bg-pink-50 border border-pink-200 text-pink-700 inline-block">{{ group.label }}</div>
                    <div v-for="entry in group.entries" :key="entry.id" class="p-3 bg-white border border-pink-200 rounded">
                      <div class="flex items-center justify-between">
                        <div class="text-[11px] text-gray-600">{{ entry.speaker }} · {{ entry.time }}</div>
                        <span class="text-[10px] px-2 py-0.5 rounded border"
                          :class="entry.type === '口癖' ? 'bg-yellow-100 text-yellow-800 border-yellow-200' : 'bg-cyan-100 text-cyan-800 border-cyan-200'">{{ entry.type }}</span>
                      </div>
                      <div class="mt-1 text-xs text-gray-900">{{ entry.content }}</div>
                      <div class="mt-1 flex flex-wrap gap-1">
                        <span v-for="tag in entry.tags" :key="tag.text" class="text-[10px] px-2 py-0.5 rounded border"
                          :class="tag.type === '口癖' ? 'bg-yellow-100 text-yellow-800 border-yellow-200' : 'bg-cyan-100 text-cyan-800 border-cyan-200'">{{ tag.text }}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </section>

            <!-- 深度语义搜索与金句定位 -->
            <section>
              <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-emerald-500 rounded-full"></span>
                深度语义搜索与金句定位
              </h3>
              <div class="p-4 bg-white border border-pink-200 rounded-lg space-y-3">
                <div class="space-y-2">
                  <label class="text-xs font-medium text-gray-900">语义搜索</label>
                  <div class="flex gap-2">
                    <input 
                      v-model="semanticSearchQuery" 
                      type="text" 
                      placeholder="例如：搜索关于职场焦虑的对话片段"
                      class="flex-1 px-3 py-2 text-xs border border-pink-200 rounded-lg focus:ring-2 focus:ring-pink-300 focus:border-pink-400 outline-none"
                      @keyup.enter="performSemanticSearch"
                    >
                    <button 
                      @click="performSemanticSearch"
                      :disabled="isSearching"
                      class="px-4 py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white text-xs rounded-lg hover:shadow-lg transition disabled:opacity-50"
                    >
                      {{ isSearching ? '搜索中...' : '搜索' }}
                    </button>
                  </div>
                </div>
                <div v-if="searchResults.length" class="space-y-2 pt-2 border-t border-pink-100">
                  <div class="text-xs font-medium text-gray-900">搜索结果</div>
                  <div v-for="result in searchResults" :key="result.id" 
                    class="p-2 bg-pink-50 border border-pink-200 rounded text-xs cursor-pointer hover:bg-pink-100 transition"
                    @click="seekToTime(result.startTime)"
                  >
                    <div class="font-medium text-gray-900">{{ result.title }}</div>
                    <div class="text-[10px] text-gray-600 mt-1">{{ result.preview }}</div>
                    <div class="flex items-center justify-between mt-1">
                      <span class="text-[10px] text-pink-600">{{ formatTime(result.startTime) }} - {{ formatTime(result.endTime) }}</span>
                      <span class="px-2 py-0.5 bg-purple-100 text-purple-700 rounded text-[10px]">相关度: {{ result.relevance }}%</span>
                    </div>
                  </div>
                </div>
                <div v-if="topicHeatmap.length" class="pt-2 border-t border-pink-100">
                  <div class="text-xs font-medium text-gray-900 mb-2">话题热度分布</div>
                  <div class="space-y-1">
                    <div v-for="topic in topicHeatmap" :key="topic.id" class="flex items-center gap-2">
                      <div class="flex-1 h-2 bg-pink-100 rounded-full overflow-hidden">
                        <div class="h-full bg-gradient-to-r from-pink-400 to-purple-400 rounded-full transition-all" 
                          :style="{ width: topic.intensity + '%' }"></div>
                      </div>
                      <span class="text-[10px] text-gray-600 w-20 truncate">{{ topic.name }}</span>
                      <span class="text-[10px] text-gray-500">{{ topic.intensity }}%</span>
                    </div>
                  </div>
                </div>
                <button 
                  @click="extractGoldenSentences"
                  :disabled="isExtracting"
                  class="w-full py-2 bg-gradient-to-r from-emerald-500 to-teal-500 text-white text-xs rounded-lg hover:shadow-lg transition disabled:opacity-50 flex items-center justify-center gap-2"
                >
                  <svg v-if="isExtracting" class="animate-spin h-3 w-3" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  <span>{{ isExtracting ? '提取中...' : '自动提取金句' }}</span>
                </button>
                <div v-if="goldenSentences.length" class="space-y-2 pt-2 border-t border-pink-100">
                  <div class="text-xs font-medium text-gray-900">推荐金句</div>
                  <div v-for="sentence in goldenSentences" :key="sentence.id" 
                    class="p-3 bg-gradient-to-r from-yellow-50 to-orange-50 border border-yellow-200 rounded-lg cursor-pointer hover:shadow-md transition"
                    @click="seekToTime(sentence.startTime)"
                  >
                    <div class="flex items-start justify-between mb-1">
                      <span class="text-[10px] text-gray-600">{{ formatTime(sentence.startTime) }} - {{ formatTime(sentence.endTime) }}</span>
                      <span class="px-2 py-0.5 bg-yellow-200 text-yellow-800 rounded text-[10px] font-medium">金句</span>
                    </div>
                    <div class="text-xs text-gray-900 font-medium">{{ sentence.content }}</div>
                    <div class="flex items-center gap-2 mt-2">
                      <span class="text-[10px] text-gray-600">传播潜力: {{ sentence.viralPotential }}%</span>
                      <span class="text-[10px] text-gray-600">逻辑完整度: {{ sentence.logicScore }}%</span>
                    </div>
                  </div>
                </div>
              </div>
            </section>

            <!-- 语音分析 -->
            <section>
              <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-purple-500 rounded-full"></span>
                语音转写与分析
              </h3>
              <div class="space-y-3">
                <div class="flex items-center justify-between p-3 bg-white border border-pink-200 rounded-lg">
                  <span class="text-sm text-gray-900">说话人分离</span>
                  <button class="w-10 h-5 bg-blue-600 rounded-full relative transition"><div class="w-3 h-3 bg-white rounded-full absolute right-1 top-1"></div></button>
                </div>
                <div class="flex items-center justify-between p-3 bg-white border border-pink-200 rounded-lg">
                  <span class="text-sm text-gray-900">智能情绪提取</span>
                  <button class="w-10 h-5 bg-gray-600 rounded-full relative transition"><div class="w-3 h-3 bg-white rounded-full absolute left-1 top-1"></div></button>
                </div>
                <!-- 新增：转写语言选择 -->
                <div class="flex items-center justify-between p-3 bg-white border border-pink-200 rounded-lg">
                  <span class="text-sm text-gray-900">转写语言</span>
                  <select class="bg-white text-xs text-gray-900 rounded px-2 py-1 border border-pink-200 focus:ring-2 focus:ring-pink-300">
                     <option>自动识别</option>
                     <option>中文</option>
                     <option>English</option>
                     <option>中英混合</option>
                  </select>
                </div>
                <button 
                  @click="startTranscription"
                  :disabled="isTranscribing"
                  class="w-full py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] hover:shadow-lg hover:scale-105 text-sm text-white rounded transition disabled:opacity-50 disabled:hover:scale-100"
                >
                  {{ isTranscribing ? '转写中...' : '开始转写' }}
                </button>
              </div>
            </section>
            
            <!-- 音频优化 -->
             <section>
              <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-green-500 rounded-full"></span>
                音频画质增强
              </h3>
              <div class="space-y-4">
                <div class="space-y-1">
                  <div class="flex justify-between text-xs text-gray-600"><span>智能降噪</span><span>80%</span></div>
                  <!-- 调小滑动条高度与宽度 -->
                  <div class="h-0.5 w-3/4 bg-pink-100 rounded-full overflow-hidden">
                    <div class="w-[80%] h-full bg-green-500"></div>
                  </div>
                </div>
                <div class="space-y-1">
                  <div class="flex justify-between text-xs text-gray-600"><span>音量均衡</span><span>On</span></div>
                   <div class="flex items-center gap-2">
                      <button
                        class="text-[10px] px-2 py-0.5 rounded border text-gray-900 hover:bg-pink-50"
                        :class="voiceEnhanceEnabled ? 'bg-pink-500 border-pink-500 text-white' : 'bg-white border-pink-200'"
                        @click="toggleVoiceEnhance"
                      >
                        人声增强
                      </button>
                      <button
                        class="text-[10px] px-2 py-0.5 rounded border text-gray-900 hover:bg-pink-50"
                        :class="echoRemovalEnabled ? 'bg-pink-500 border-pink-500 text-white' : 'bg-white border-pink-200'"
                        @click="toggleEchoRemoval"
                      >
                        去回声
                      </button>
                   </div>
                </div>
              </div>
            </section>
          </div>



        </div>
      </aside>
    </div>
    
    <!-- TTS 预览与插入 Modal -->
    <div v-if="showTTSModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm" @click.self="showTTSModal = false">
      <div class="bg-white rounded-xl shadow-2xl w-[720px] flex flex-col overflow-hidden">
        <div class="flex items-center justify-between p-4 border-b border-gray-100">
          <h3 class="text-lg font-bold text-gray-900">TTS 预览与插入</h3>
          <button @click="showTTSModal = false" class="text-gray-400 hover:text-gray-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
          </button>
        </div>
        <div class="p-4 space-y-3">
          <div class="text-sm text-gray-600">任务：{{ currentTTSTask?.label }}（{{ currentTTSTask?.status }}）</div>
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <div class="text-xs text-gray-500">合成文稿</div>
              <textarea 
                v-model="ttsDraftText"
                class="w-full h-40 p-3 text-sm border border-blue-300 rounded-lg focus:ring-2 focus:ring-blue-200 focus:border-blue-400"
                placeholder="请输入将用于合成的文本..."
              ></textarea>
            </div>
            <div class="space-y-2">
              <div class="text-xs text-gray-500">试听（占位）</div>
              <div class="h-40 rounded-lg bg-gradient-to-b from-blue-900 to-black flex items-center justify-center">
                <button class="px-3 py-1.5 text-xs bg-white/20 text-white rounded hover:bg-white/30">播放预览</button>
              </div>
            </div>
          </div>
        </div>
        <div class="p-4 border-t border-gray-100 flex justify-end gap-2 bg-gray-50">
          <button @click="confirmTTSInsertToTranscript" class="px-4 py-2 text-sm bg-blue-500 text-white rounded hover:bg-blue-600">插入文字稿</button>
          <button @click="showTTSModal = false" class="px-4 py-2 text-sm text-gray-700 hover:bg-gray-200 rounded">关闭</button>
        </div>
      </div>
    </div>
    
    <!-- 导出成功 Modal -->
    <div v-if="showExportSuccess" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm" @click.self="showExportSuccess = false">
      <div class="bg-white rounded-xl shadow-2xl w-[520px] overflow-hidden">
        <div class="p-4 border-b border-gray-100 flex items-center justify-between">
          <h3 class="text-lg font-bold text-gray-900">导出成功</h3>
          <button @click="showExportSuccess = false" class="text-gray-400 hover:text-gray-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
          </button>
        </div>
        <div class="p-6 space-y-3">
          <div class="text-sm text-gray-700">音频文件已成功导出。</div>
          <div class="text-xs text-gray-500">已选分发平台：</div>
          <div class="flex flex-wrap gap-2">
            <span v-for="p in selectedPlatforms" :key="p" class="px-2 py-0.5 text-xs rounded bg-pink-100 text-pink-700 border border-pink-200">
              {{ platformNames[p] || p }}
            </span>
            <span v-if="selectedPlatforms.length === 0" class="text-xs text-gray-400">暂无选择</span>
          </div>
        </div>
        <div class="p-4 border-t border-gray-100 flex justify-end gap-2 bg-gray-50">
          <button @click="showExportSuccess = false" class="px-4 py-2 text-sm bg-pink-500 text-white rounded hover:bg-pink-600">好的</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { useProjectStore } from '../../stores/project'
import weixinIcon from '../../static/weixin.png'
import douyinIcon from '../../static/douyin.png'
import qqIcon from '../../static/QQ.png'
import xiaohongshuIcon from '../../static/xiaohongshu.png'
import appleIcon from '../../static/Apple播客.png'
import xiaoyuzhouIcon from '../../static/小宇宙.png'

const route = useRoute()
const projectStore = useProjectStore()

// 状态管理
const currentProject = ref({ name: '未命名项目', id: null })
const isPlaying = ref(false)
const currentTime = ref(45)
const audioDuration = ref(3600)
const cuttingStrategy = ref('all')
const cutSuggestions = ref([])
const samplePreview = ref([])
const isGenerating = ref(false)

// 文本编辑与同步相关状态
const editingSegmentId = ref(null)
const transcriptContainer = ref(null)
const segmentRefs = ref([])
const setSegmentRef = (el, index) => {
  if (el) segmentRefs.value[index] = el
}

// 自定义指令：自动聚焦
const vFocus = {
  mounted: (el) => el.focus()
}

// 监听播放进度，自动滚动文本稿
import { watch, nextTick } from 'vue'

watch(currentTime, (newTime) => {
  // 仅在非编辑状态下且正在播放时滚动
  if (!isPlaying.value && !isDraggingProgress.value) return
  
  const currentSegIndex = mockTranscript.value.findIndex(seg => 
    newTime >= seg.startTime && newTime <= seg.endTime
  )
  
  if (currentSegIndex !== -1 && segmentRefs.value[currentSegIndex]) {
    const el = segmentRefs.value[currentSegIndex]
    const container = transcriptContainer.value
    
    if (container && el) {
      // 检查元素是否在可视区域内，如果不在则滚动
      const containerRect = container.getBoundingClientRect()
      const elRect = el.getBoundingClientRect()
      
      if (elRect.top < containerRect.top || elRect.bottom > containerRect.bottom) {
        el.scrollIntoView({ behavior: 'smooth', block: 'center' })
      }
    }
  }
})

// 解析文本，识别口癖与删除状态（词级）
const parseSegmentText = (text) => {
  if (!text) return []
  const tokens = []
  let isTTS = false
  let processText = text
  if (text.startsWith('[TTS]')) {
    isTTS = true
    processText = text.substring(5)
  }
  const fillerRegex = fillerWords.map(w => w.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|')
  const mainRegex = new RegExp(`(~~.*?~~|${fillerRegex})`, 'g')
  const parts = processText.split(mainRegex)
  parts.forEach(part => {
    if (!part) return
    if (part.startsWith('~~') && part.endsWith('~~')) {
      tokens.push({ type: 'deleted', text: part.substring(2, part.length - 2), isTTS })
      return
    }
    if (new RegExp(`^(${fillerRegex})$`).test(part)) {
      tokens.push({ type: 'filler', text: part, isTTS })
      return
    }
    const wordRegex = /(\s+|[，。！？、；：,.!?…—-])/g
    const subs = part.split(wordRegex)
    const stutterRegex = /([\u4e00-\u9fa5A-Za-z])\1{1,}/
    subs.forEach(sub => {
      if (!sub) return
      if (wordRegex.test(sub)) {
        tokens.push({ type: 'space', text: sub, isTTS })
      } else {
        if (stutterRegex.test(sub)) {
          tokens.push({ type: 'stutter', text: sub, isTTS })
        } else {
          tokens.push({ type: 'text', text: sub, isTTS })
        }
      }
    })
  })
  return tokens
}

// 切换文本的删除状态（留痕模式，跳过空白）
const toggleTokenDelete = (segment, tokenIndex) => {
  const tokens = parseSegmentText(segment.text)
  const token = tokens[tokenIndex]
  if (!token || token.type === 'space') return
  if (token.type === 'deleted') {
    token.type = 'text'
  } else {
    token.type = 'deleted'
  }
  let prefix = segment.text.startsWith('[TTS]') ? '[TTS]' : ''
  const contentText = tokens.map(t => {
    if (t.type === 'deleted') return `~~${t.text}~~`
    return t.text
  }).join('')
  segment.text = prefix + contentText
}

// 插入 TTS 片段（待确认）
const insertTTS = (index) => {
  const baseSeg = mockTranscript.value[index]
  const baseEnd = baseSeg?.endTime ?? 0
  const newSeg = {
    startTime: baseEnd,
    endTime: baseEnd + 5,
    speaker: 'AI',
    text: '[TTS]请输入合成文本...',
    originalText: baseSeg?.text || '', // 保存原文参考
    confirmed: false
  }
  mockTranscript.value.splice(index + 1, 0, newSeg)
  editingSegmentId.value = index + 1
}

// 确认 TTS 片段内容
const confirmTTS = (index) => {
  const seg = mockTranscript.value[index]
  if (!seg || !seg.text.startsWith('[TTS]')) return
  
  // 校验逻辑：确保生成的 TTS 文案与原始文稿内容在语义上保持一致
  // 在实际场景中，这里可以调用 AI 接口进行语义相似度校验
  const originalText = seg.originalText || ''
  const ttsText = seg.text.replace('[TTS]', '')
  
  if (originalText && ttsText !== originalText) {
    console.warn(`TTS 文案与原文不一致: 原文="${originalText}", TTS="${ttsText}"`)
    seg.warning = '文案与原文内容不一致，请确认是否继续'
  } else {
    delete seg.warning
  }
  
  seg.confirmed = true
  editingSegmentId.value = null
}

// 删除 TTS 片段
const deleteTTSSegment = (index) => {
  const seg = mockTranscript.value[index]
  if (!seg || !seg.text.startsWith('[TTS]')) return
  mockTranscript.value.splice(index, 1)
}

// 文稿删除编辑：阻止输入，仅支持选择后按删除键做留痕
const onSegmentKeydown = (segment, event, index) => {
  // 禁止输入与换行
  if (event.key.length === 1 || event.key === 'Enter' || event.key === 'Tab') {
    event.preventDefault()
    return
  }
  // ESC 退出编辑
  if (event.key === 'Escape') {
    editingSegmentId.value = null
    event.preventDefault()
    return
  }
  // Delete/Backspace：对已选文本做留痕
  if (event.key === 'Delete' || event.key === 'Backspace') {
    const sel = window.getSelection()
    const selectedText = sel ? sel.toString() : ''
    if (!selectedText || !selectedText.trim()) {
      event.preventDefault()
      return
    }
    event.preventDefault()
    const prefix = segment.text.startsWith('[TTS]') ? '[TTS]' : ''
    const raw = prefix ? segment.text.slice(5) : segment.text
    const idx = raw.indexOf(selectedText)
    if (idx === -1) return
    const next = raw.slice(0, idx) + '~~' + selectedText + '~~' + raw.slice(idx + selectedText.length)
    segment.text = prefix + next
    // 选区清除
    sel.removeAllRanges()
    return
  }
}
// 播放器增强功能
// 统计留痕删除标记数量
const deletedCount = (text) => {
  return parseSegmentText(text).filter(t => t.type === 'deleted').length
}
// 播放器增强功能
const playbackSpeed = ref(1)
const loopMode = ref(false)
const markers = ref([])
const hoverTime = ref(null)
const showTimeInput = ref(false)
const timeInputValue = ref('')
const showMarkersPanel = ref(false)
const showWaveform = ref(false) // 默认不显示波形图，显示文字稿
const selectionStart = ref(null)
const selectionEnd = ref(null)
const isDraggingProgress = ref(false)
const isSelecting = ref(false)

// 时间轴和轨道
const zoomLevel = ref(1)
const timelineWidth = ref(10000) // 时间轴总宽度（像素）
const snapToGrid = ref(true)
const selectedTrackId = ref(null)
const selectedClipId = ref(null)
const timelineContainer = ref(null)
const timelineRuler = ref(null)
const centerPanelHeight = ref(0)
const editorColumn = ref(null)
const TRACK_ROW_HEIGHT = 104
const TIMELINE_RULER_HEIGHT = 80
const PLAYER_HEIGHT = 600
const VISIBLE_TRACKS_CAP = 6

// 轨道内容的总高度（所有轨道）
const timelineContentHeightPx = computed(() => {
  return tracks.value.length * TRACK_ROW_HEIGHT
})

// 时间轴区域的高度（标尺 + 6个轨道的高度 + 底部预留空间）
const fixedTimelineHeightPx = computed(() => {
  return TIMELINE_RULER_HEIGHT + (VISIBLE_TRACKS_CAP * TRACK_ROW_HEIGHT) + 10
})

// 整个编辑器区域的总高度（播放器 + 时间轴区域）
const totalEditorHeightPx = computed(() => {
  return PLAYER_HEIGHT + fixedTimelineHeightPx.value
})

const rightPanelStyle = computed(() => ({
  height: totalEditorHeightPx.value + 'px',
  overflowY: 'auto'
}))

// 轨道数据
const tracks = ref([
  {
    id: 1,
    name: '主人声 A',
    type: '音频',
    color: 'bg-[#6366F1]',
    muted: false,
    solo: false,
    volume: 100,
    pan: 0,
    collapsed: false,
    locked: false,
    recording: false,
    clips: [
      {
        id: 1,
        name: '大家好，欢迎来到今天的播客节目',
        start: 0,
        end: 7.5,
        color: 'bg-gradient-to-r from-[#6366F1]/80 to-[#818CF8]/80 border-[#818CF8]',
        fadeIn: true,
        fadeOut: false
      },
      {
        id: 2,
        name: '没错，比如 PodPal 平台',
        start: 16,
        end: 24,
        color: 'bg-gradient-to-r from-[#6366F1]/80 to-[#818CF8]/80 border-[#818CF8]',
        fadeIn: false,
        fadeOut: false
      },
      {
        id: 3,
        name: '这种个性化的处理方式',
        start: 32.5,
        end: 40,
        color: 'bg-gradient-to-r from-[#6366F1]/80 to-[#818CF8]/80 border-[#818CF8]',
        fadeIn: false,
        fadeOut: false
      },
      {
        id: 4,
        name: '说得太好了。其实，创作的本质',
        start: 47.5,
        end: 55,
        color: 'bg-gradient-to-r from-[#6366F1]/80 to-[#818CF8]/80 border-[#818CF8]',
        fadeIn: false,
        fadeOut: false
      },
      {
        id: 5,
        name: '这种理念非常契合我们产品的初衷',
        start: 62.5,
        end: 70,
        color: 'bg-gradient-to-r from-[#6366F1]/80 to-[#818CF8]/80 border-[#818CF8]',
        fadeIn: false,
        fadeOut: false
      }
    ]
  },
  {
    id: 2,
    name: '背景音乐',
    type: '音频',
    color: 'bg-[#F59E0B]',
    muted: false,
    solo: false,
    volume: 60,
    pan: 0,
    collapsed: false,
    locked: false,
    recording: false,
    clips: [
      {
        id: 3,
        name: 'BGM',
        start: 0,
        end: 1800,
        color: 'bg-gradient-to-r from-[#F59E0B]/80 to-[#FBBF24]/80 border-[#FBBF24]',
        fadeIn: true,
        fadeOut: true
      }
    ]
  },
  {
    id: 3,
    name: '嘉宾声 B',
    type: '音频',
    color: 'bg-[#10B981]',
    muted: false,
    solo: false,
    volume: 90,
    pan: 0,
    collapsed: false,
    locked: false,
    recording: false,
    clips: [
      {
        id: 301,
        name: '是的，这确实是一个很有趣的话题',
        start: 7.5,
        end: 16,
        color: 'bg-gradient-to-r from-[#10B981]/80 to-[#34D399]/80 border-[#34D399]',
        fadeIn: true,
        fadeOut: true
      },
      {
        id: 302,
        name: '而且它它它还能够根据不同的播客类型',
        start: 24,
        end: 32.5,
        color: 'bg-gradient-to-r from-[#10B981]/80 to-[#34D399]/80 border-[#34D399]',
        fadeIn: false,
        fadeOut: false
      },
      {
        id: 303,
        name: '我觉得最核心的优势在于',
        start: 40,
        end: 47.5,
        color: 'bg-gradient-to-r from-[#10B981]/80 to-[#34D399]/80 border-[#34D399]',
        fadeIn: false,
        fadeOut: false
      },
      {
        id: 304,
        name: '没错，我们不应该为了追求完美',
        start: 55,
        end: 62.5,
        color: 'bg-gradient-to-r from-[#10B981]/80 to-[#34D399]/80 border-[#34D399]',
        fadeIn: false,
        fadeOut: false
      }
    ]
  },
  {
    id: 4,
    name: '片头/片尾',
    type: '音频',
    color: 'bg-[#EC4899]',
    muted: false,
    solo: false,
    volume: 80,
    pan: 0,
    collapsed: false,
    locked: false,
    recording: false,
    clips: [
      {
        id: 401,
        name: 'Intro',
        start: 0,
        end: 5,
        color: 'bg-gradient-to-r from-[#EC4899]/80 to-[#F472B6]/80 border-[#F472B6]',
        fadeIn: true,
        fadeOut: true
      }
    ]
  }
])

// 深度语义搜索与金句定位
const semanticSearchQuery = ref('')
const searchResults = ref([])
const isSearching = ref(false)
const topicHeatmap = ref([])
const goldenSentences = ref([])
const isExtracting = ref(false)

const loadSampleGoldenSentences = () => {
  goldenSentences.value = [
    { id: 101, content: '播客的核心在于真实性的表达，这才是打动听众的关键。', startTime: 12.5, endTime: 18.2 },
    { id: 102, content: '我们不应该为了追求完美而牺牲了内容的自然流动。', startTime: 45.8, endTime: 52.1 },
    { id: 103, content: '技术只是工具，创意才是播客的灵魂所在。', startTime: 88.4, endTime: 94.7 }
  ]
}

const generateShownotes = async () => {
  if (isGeneratingShownotes.value) return
  isGeneratingShownotes.value = true
  
  // Simulate API delay
  await new Promise(resolve => setTimeout(resolve, 2000))
  
  shownotesData.value = {
    titles: [
      'AI 时代的播客创作：从灵感到分发的全流程解析',
      '如何利用 PodPal 打造你的第一个爆款播客？',
      '播客制作新范式：技术如何赋能内容创作',
      '声音的艺术：探索 AI 音频编辑的无限可能',
      '从零开始做播客：新手必看的 AI 工具指南'
    ],
    summary: '本期节目我们深入探讨了人工智能在播客创作领域的应用。从早期的语音转写到如今的智能剪辑、内容生成，AI 正在重塑音频内容的生产流程。我们邀请了资深播客制作人，分享他们使用 PodPal 提升效率的实战经验，并展望了未来播客行业的发展趋势。无论你是刚入门的新手，还是经验丰富的创作者，本期内容都将为你带来全新的启发。',
    mindmap: {
      root: 'AI 播客创作',
      children: [
        { 
          label: '前期策划', 
          time: '02:30',
          children: [
            { label: '选题灵感', time: '03:15' }, 
            { label: '脚本撰写', time: '05:45' }
          ] 
        },
        { 
          label: '中期制作', 
          time: '12:00',
          children: [
            { label: '智能录音', time: '14:20' }, 
            { label: 'AI 剪辑', time: '18:10' }
          ] 
        },
        { 
          label: '后期分发', 
          time: '25:30',
          children: [
            { label: 'Shownotes', time: '26:45' }, 
            { label: '多平台分发', time: '28:30' }
          ] 
        }
      ]
    }
  }
  
  isGeneratingShownotes.value = false
}

// 视频生成相关
const generateVideoPreview = async () => {
  if (isGeneratingVideo.value) return
  isGeneratingVideo.value = true
  
  await new Promise(resolve => setTimeout(resolve, 3000))
  
  generatedVideos.value.push({
    id: Date.now(),
    url: '#', // 实际项目中为视频 URL
    thumbnail: 'https://placehold.co/320x180/FF6B9D/ffffff?text=Video+Preview',
    duration: '00:15',
    template: videoTemplate.value,
    sentences: [...selectedSentences.value]
  })
  
  isGeneratingVideo.value = false
}

const showVideoPreview = ref(false)
const currentVideo = ref(null)

const previewVideo = (video) => {
  currentVideo.value = video
  showVideoPreview.value = true
}

// 社交文案相关
const socialPlatform = ref('wechat') // 'wechat' | 'xiaohongshu' | 'weibo'
const socialCopyContent = ref('')
const isGeneratingCopy = ref(false)

const generateSocialCopy = async () => {
  if (isGeneratingCopy.value) return
  isGeneratingCopy.value = true
  socialCopyContent.value = ''
  
  await new Promise(resolve => setTimeout(resolve, 1500))
  
  const copies = {
    wechat: `【深度好文】AI 如何改变播客创作？\n\n今天想和大家聊聊 AI 在音频领域的应用。🎙️\n\n从语音转写到智能剪辑，AI 正在悄然改变我们的创作方式。本期节目，我们邀请到了资深制作人，一起探讨技术背后的无限可能。\n\n🎧 收听指南：\n03:15 AI 剪辑的优势\n12:30 内容创作者的机遇\n\n#播客 #AI #内容创作`,
    xiaohongshu: `宝藏播客推荐！✨ AI 搞定播客制作？\n\n姐妹们！发现了一个超级好用的播客制作神器 PodPal！🎤\n\n以前剪辑要花好几个小时，现在 AI 一键搞定！真的太香了！😭\n\n本期节目干货满满，想做播客的宝子们千万不要错过！\n\n#播客 #宝藏App #AI工具 #高效工作`,
    weibo: `AI 时代的播客创作新范式。🎙️\n\n本期节目聊了聊 AI 技术对音频内容生产的影响。在这个效率至上的时代，创作者该如何利用工具赋能？\n\n点击链接收听完整节目 👇\n\n#播客 #科技 #AI`
  }
  
  socialCopyContent.value = copies[socialPlatform.value] || copies.wechat
  isGeneratingCopy.value = false
}

const copySocialCopy = () => {
  if (!socialCopyContent.value) return
  navigator.clipboard.writeText(socialCopyContent.value)
  // 实际项目中可以加一个 Toast 提示
  alert('文案已复制到剪贴板')
}

// 口癖 / 语气词列表，用于高亮和一键删除
const fillerWords = ['就是', '然后', '那个', '嗯', '啊', '你知道', '其实', '对吧', '可以说', '怎么说呢']

// 音频增强开关
const voiceEnhanceEnabled = ref(false)
const echoRemovalEnabled = ref(false)

// 模拟转写文本数据
const mockTranscript = ref([
  {
    startTime: 0,
    endTime: 7.5,
    speaker: 'A',
    text: '大家好，欢迎来到今天的播客节目。那个，今天我们要聊的话题是关于人工智能在创作领域的应用。'
  },
  {
    startTime: 7.5,
    endTime: 16,
    speaker: 'B', 
    text: '是的，这确实是一个很有趣的话题。我觉得AI在音频剪辑方面已经有了很大的突破。嗯，比如自动去除口癖。'
  },
  {
    startTime: 16,
    endTime: 24,
    speaker: 'A',
    text: '没错，比如我们现在使用的这个PodPal平台，就能够智能识别语音内容，自动生成剪辑建议。其实，它还能识别口吃。'
  },
  {
    startTime: 24,
    endTime: 32.5,
    speaker: 'B',
    text: '而且它它它还能够根据不同的播客类型，比如知识分享类或者情感陪伴类，采用不同的剪辑策略。你知道，这很有用。'
  },
  {
    startTime: 32.5,
    endTime: 40,
    speaker: 'A',
    text: '这种个性化的处理方式确实很智能。怎么说呢，那么你觉得AI剪辑的优势主要体现在哪些方面呢？'
  },
  {
    startTime: 40,
    endTime: 47.5,
    speaker: 'B',
    text: '我觉得最核心的优势在于，AI能够帮助创作者从繁琐的机械劳动中解放出来。这就是播客创作的未来，让技术服务于创意。'
  },
  {
    startTime: 47.5,
    endTime: 55,
    speaker: 'A',
    text: '说得太好了。其实，创作的本质在于真实性的表达，这才是真正能打动听众的关键所在。'
  },
  {
    startTime: 55,
    endTime: 62.5,
    speaker: 'B',
    text: '没错，我们不应该为了追求完美而牺牲了内容的自然流动。技术的进步应当是无感的，让听众更专注于内容本身。'
  },
  {
    startTime: 62.5,
    endTime: 70,
    speaker: 'A',
    text: '这种理念非常契合我们产品的初衷。怎么说呢，技术只是工具，创意才是播客的灵魂所在。'
  }
])

// 语音转写状态与新增计数
const isTranscribing = ref(false)
const transcribeNewCount = ref(0)

// 确保当前时间在时间轴视窗内可见，并同步标尺与轨道滚动
const ensureVisibleCurrentTime = () => {
  const px = (currentTime.value / audioDuration.value) * timelineWidth.value
  const container = timelineContainer.value
  const ruler = timelineRuler.value
  if (container) {
    const target = Math.max(0, px - container.clientWidth / 2)
    container.scrollLeft = target
  }
  if (ruler) {
    const target = Math.max(0, px - ruler.clientWidth / 2)
    ruler.scrollLeft = target
  }
}

// 开始语音转写（前端示例：渐进添加片段）
const startTranscription = async () => {
  if (isTranscribing.value) return
  isTranscribing.value = true
  transcribeNewCount.value = 0

  const lastEnd = mockTranscript.value.length
    ? mockTranscript.value[mockTranscript.value.length - 1].endTime
    : 0

  const newSegments = [
    {
      startTime: lastEnd + 0,
      endTime: lastEnd + 12,
      speaker: 'A',
      text: '继续刚才的话题，我们来结合一个实际的剪辑案例，那个，看看如何提升听感。'
    },
    {
      startTime: lastEnd + 12,
      endTime: lastEnd + 27,
      speaker: 'B',
      text: '首先，去除口癖会让信息更凝练，比如把“就是说、然后呢、那个那个”等词清理掉。'
    },
    {
      startTime: lastEnd + 27,
      endTime: lastEnd + 41,
      speaker: 'A',
      text: '其次，补充过渡句可以减少语义跳跃，让让让听众更容易跟上思路。'
    }
  ]

  for (const seg of newSegments) {
    await new Promise(resolve => setTimeout(resolve, 600))
    mockTranscript.value.push(seg)
    transcribeNewCount.value += 1
  }

  isTranscribing.value = false
}

// 场景自适应设置
const podcastType = ref('knowledge') // 'knowledge' | 'companion'

// Shownotes 生成
const shownotesData = ref(null)
const isGeneratingShownotes = ref(false)
const showMindMap = ref(false)

// 视频播客生成
const selectedSentences = ref([])
const videoTemplate = ref('digital-human')
const isGeneratingVideo = ref(false)
const generatedVideos = ref([])

const toggleGoldenSentence = (s) => {
  const idx = selectedSentences.value.indexOf(s.id)
  if (idx >= 0) {
    selectedSentences.value.splice(idx, 1)
  } else {
    selectedSentences.value.push(s.id)
  }
}

// 分发平台映射
const platformNames = {
  weixin: '微信听书',
  douyin: '抖音',
  qq: 'QQ 音乐',
  xiaohongshu: '小红书',
  apple: 'Apple 播客',
  xiaoyuzhou: '小宇宙'
}

// 分发平台选择
const selectedPlatforms = ref([])
const togglePlatform = (platform) => {
  const idx = selectedPlatforms.value.indexOf(platform)
  if (idx >= 0) {
    selectedPlatforms.value.splice(idx, 1)
  } else {
    selectedPlatforms.value.push(platform)
  }
}

// 素材库 Mock Data (Feature 2)
const assets = ref([
  { id: 1, name: '原始录音_Track1.wav', type: 'audio', duration: '45:20', format: 'WAV' },
  { id: 2, name: '背景音乐_Jazz.mp3', type: 'audio', duration: '03:15', format: 'MP3' },
  { id: 3, name: 'Intro_Video.mp4', type: 'video', duration: '00:15', format: 'MP4' },
])

// 工具栏 Tabs
const hasUploaded = ref(false)
const activeToolTab = ref('upload')
const toolTabs = [
  { 
    id: 'upload', 
    name: '上传素材', 
    icon: `<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" /></svg>` 
  },
  { 
    id: 'edit', 
    name: '智能剪辑', 
    icon: `<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.121 14.121L19 19m-7-7l7-7m-7 7l-2.879 2.879M12 12L9.121 9.121m0 5.758a3 3 0 10-4.243 4.243 3 3 0 004.243-4.243zm0-5.758a3 3 0 10-4.243-4.243 3 3 0 004.243 4.243z" /></svg>` 
  },
  { 
    id: 'enhance', 
    name: '内容增值', 
    icon: `<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-7.714 2.143L11 21l-2.286-6.857L1 12l7.714-2.143L11 3z" /></svg>` 
  },
  { 
    id: 'export', 
    name: '导出分发', 
    icon: `<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" /></svg>` 
  }
]
const handleTabClick = (tab) => {
  if (tab.id !== 'upload' && !hasUploaded.value) {
    activeToolTab.value = 'upload'
    return
  }
  activeToolTab.value = tab.id
}

// 顶部步骤进度
const stepIndex = computed(() => toolTabs.findIndex(t => t.id === activeToolTab.value))
const progressHeightPercent = computed(() => {
  return (stepIndex.value / (toolTabs.length - 1)) * 100
})

const showLinkModal = ref(false)
const fileInput = ref(null)
const inlineFileInput = ref(null)
const inlineUploading = ref(false)
const inlineProgress = ref(0)
const inlineFilename = ref('')
const triggerInlineUpload = () => inlineFileInput.value?.click()

const handleAssetDragStart = (e, asset) => {
  e.dataTransfer.setData('assetId', asset.id)
  e.dataTransfer.effectAllowed = 'copy'
}

const handleInlineDrop = async (e) => {
  e.preventDefault()
  
  // 检查是否是从外部拖入的文件
  const files = e.dataTransfer.files
  if (files && files.length > 0) {
    const f = files[0]
    inlineFilename.value = f.name
    inlineUploading.value = true
    inlineProgress.value = 0
    for (let i = 0; i <= 100; i += 10) {
      await new Promise(r => setTimeout(r, 150))
      inlineProgress.value = i
    }
    assets.value.unshift({
      id: Date.now(),
      name: f.name,
      type: f.type.startsWith('video') ? 'video' : 'audio',
      duration: '00:00',
      format: f.name.split('.').pop().toUpperCase()
    })
    hasUploaded.value = true
    inlineUploading.value = false
    activeToolTab.value = 'edit'
    return
  }
  
  // 检查是否是从左侧素材库拖入的素材
  const assetId = e.dataTransfer.getData('assetId')
  if (assetId) {
    const asset = assets.value.find(a => a.id == assetId)
    if (asset) {
      inlineUploading.value = true
      inlineFilename.value = asset.name
      inlineProgress.value = 0
      for (let i = 0; i <= 100; i += 10) {
        await new Promise(r => setTimeout(r, 80))
        inlineProgress.value = i
      }
      hasUploaded.value = true
      inlineUploading.value = false
      activeToolTab.value = 'edit'
    }
  }
}

const handleInlineSelect = async (e) => {
  const f = e.target.files?.[0]
  if (!f) return
  inlineFilename.value = f.name
  inlineUploading.value = true
  inlineProgress.value = 0
  for (let i = 0; i <= 100; i += 10) {
    await new Promise(r => setTimeout(r, 150))
    inlineProgress.value = i
  }
  assets.value.unshift({
    id: Date.now(),
    name: f.name,
    type: f.type.startsWith('video') ? 'video' : 'audio',
    duration: '00:00',
    format: f.name.split('.').pop().toUpperCase()
  })
  hasUploaded.value = true
  inlineUploading.value = false
  activeToolTab.value = 'edit'
}
const useSampleAsset = async () => {
  inlineUploading.value = true
  inlineFilename.value = '示例播客音频.mp3'
  inlineProgress.value = 0
  for (let i = 0; i <= 100; i += 10) {
    await new Promise(r => setTimeout(r, 120))
    inlineProgress.value = i
  }
  assets.value.unshift({
    id: Date.now(),
    name: '示例播客音频.mp3',
    type: 'audio',
    duration: '10:00',
    format: 'MP3'
  })
  hasUploaded.value = true
  inlineUploading.value = false
  activeToolTab.value = 'edit'
}

// Methods
const formatTime = (seconds) => {
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  const s = Math.floor(seconds % 60)
  if (h > 0) {
    return `${h}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
  }
  return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
}

const togglePlay = () => {
  isPlaying.value = !isPlaying.value
  if (isPlaying.value) {
    simulatePlayback()
  }
}

const simulatePlayback = () => {
  if (isPlaying.value && currentTime.value < audioDuration.value) {
    setTimeout(() => {
      currentTime.value += 1
      ensureVisibleCurrentTime()
      simulatePlayback()
    }, 1000)
  } else {
    isPlaying.value = false
  }
}

const seekTo = (event) => {
  const rect = event.currentTarget.getBoundingClientRect()
  const x = event.clientX - rect.left
  const percentage = Math.max(0, Math.min(1, x / rect.width))
  currentTime.value = Math.floor(audioDuration.value * percentage)
  ensureVisibleCurrentTime()
}

const seekToPercentage = (percentage) => {
  currentTime.value = Math.floor(audioDuration.value * percentage)
  ensureVisibleCurrentTime()
}

const skipForward = (seconds) => {
  currentTime.value = Math.min(audioDuration.value, currentTime.value + seconds)
  ensureVisibleCurrentTime()
}

const skipBackward = (seconds) => {
  currentTime.value = Math.max(0, currentTime.value - seconds)
  ensureVisibleCurrentTime()
}

// 文本中出现的口癖列表（去重）
const getFillerWordsInText = (text) => {
  if (!text) return []
  return fillerWords.filter(word => text.includes(word))
}

// 从当前片段文本中删除指定口癖
const removeFiller = (segment, word) => {
  if (!segment || !segment.text) return
  segment.text = segment.text.split(word).join('')
}

// 脚本优化按钮交互：对当前页面数据做「可见」的示例性修改
const applyScriptOptimization = (type) => {
  // 去口语冗余：自动删除所有片段里的口癖
  if (type === 'filler') {
    let hasChanges = false
    const newTranscript = mockTranscript.value.map(seg => {
      const originalText = seg.text || ''
      const newText = fillerWords.reduce((txt, w) => txt.split(w).join(''), originalText)
      if (originalText !== newText) hasChanges = true
      return { ...seg, text: newText }
    })

    if (hasChanges) {
      mockTranscript.value = newTranscript
      // 同时给剪辑建议里追加一条说明
      cutSuggestions.value.unshift({
        id: Date.now(),
        label: '已应用口癖清理建议',
        preview: '自动删除常见语气词（嗯、然后、就是等），可以在文字稿中查看效果。',
        tag: '口癖优化'
      })
      scriptOptimizeMessage.value = '已清理文字稿中的常见口癖，可在上方文字稿查看高亮与删除效果。'
    } else {
      scriptOptimizeMessage.value = '未检测到明显的口语冗余，文稿保持原样。'
    }
    return
  }

  // 逻辑纠错：在剪辑建议中插入一条「建议补充过渡句」
  if (type === 'logic') {
    cutSuggestions.value.unshift({
      id: Date.now(),
      label: '建议补充过渡句',
      preview: '在 00:32 前后语义跳跃明显，建议补一句过渡说明，增强逻辑连贯性。',
      tag: '逻辑优化'
    })
    scriptOptimizeMessage.value = '已在剪辑建议中添加逻辑优化提示，建议补充过渡句。'
    return
  }

  // 一键精华提取：直接复用已有 samplePreview 中「高光合集」分组
  if (type === 'highlights') {
    // 确保已有示例预览数据
    if (!samplePreview.value.length) {
      buildSamplePreview()
    }
    // 将高光相关分组移动到最前面，方便用户查看
    samplePreview.value = [...samplePreview.value].sort((a, b) => {
      if (a.label.includes('高光') || a.tag === '高光') return -1
      if (b.label.includes('高光') || b.tag === '高光') return 1
      return 0
    })
    scriptOptimizeMessage.value = '已优先展示高光合集，便于快速查看精华片段。'
    return
  }

  // BGM 智能匹配：在示例预览下方追加一组背景音乐推荐
  if (type === 'bgm') {
    const bgmGroup = {
      id: `g-bgm-${Date.now()}`,
      strategy: 'bgm',
      label: 'BGM 智能匹配',
      description: '根据当前节目节奏和情绪，推荐 3 条可用的背景音乐素材。',
      entries: [
        { id: 'bgm1', speaker: 'BGM · LoFi Chill', time: '全程可用', type: '配乐', content: '适合知识类播客的低侵入度 LoFi 背景音乐。', tags: [{ text: '低干扰', type: '配乐' }] },
        { id: 'bgm2', speaker: 'BGM · Ambient Soft', time: '开头 & 结尾', type: '配乐', content: '柔和氛围音乐，适合作为片头片尾。', tags: [{ text: '片头片尾', type: '配乐' }] },
        { id: 'bgm3', speaker: 'BGM · Conversation Bed', time: '对话段落', type: '配乐', content: '专为对话段落设计的背景床音乐。', tags: [{ text: '对话段落', type: '配乐' }] }
      ]
    }
    // 如果之前已经有 BGM 分组，先移除，再插入最新的一组在最前面
    samplePreview.value = [
      bgmGroup,
      ...samplePreview.value.filter(g => g.strategy !== 'bgm')
    ]
    scriptOptimizeMessage.value = '已生成 BGM 推荐结果（LoFi、Ambient 等），可在预览列表中查看。'
  }
}

// 最近语音生成任务（用于在面板中展示）
const voiceTasks = ref([])

// 语音生成按钮交互：生成一条任务记录
const handleVoiceTool = (type) => {
  const label = type === 'clone' ? '声线克隆' : '多角色生成'
  const id = Date.now()
  voiceTasks.value.unshift({
    id,
    type,
    label,
    status: '排队中',
    createdAt: new Date().toLocaleTimeString('zh-CN', { hour12: false }),
    note: type === 'clone'
      ? '会根据当前项目的一段语音生成新的声线配置。'
      : '会为当前文稿生成多角色朗读方案。',
    ttsText: '这是一段示例的 AI 合成语音文稿，可在“查看”中修改后插入到文字稿。'
  })
  // 简单模拟：2 秒后把任务标记为“已完成”
  setTimeout(() => {
    const task = voiceTasks.value.find(t => t.id === id)
    if (task) {
      task.status = '已完成'
    }
  }, 2000)
}

// 音频增强开关
const toggleVoiceEnhance = () => {
  voiceEnhanceEnabled.value = !voiceEnhanceEnabled.value
}

const toggleEchoRemoval = () => {
  echoRemovalEnabled.value = !echoRemovalEnabled.value
}

// TTS 预览与插入
const showTTSModal = ref(false)
const currentTTSTask = ref(null)
const ttsDraftText = ref('')
const openTTSPreview = (task) => {
  currentTTSTask.value = task
  ttsDraftText.value = task.ttsText || '请输入合成文稿...'
  showTTSModal.value = true
}
const getCurrentSegmentIndex = () => {
  return mockTranscript.value.findIndex(seg => currentTime.value >= seg.startTime && currentTime.value <= seg.endTime)
}
const confirmTTSInsertToTranscript = () => {
  const text = ttsDraftText.value?.trim()
  if (!text) return
  const idx = getCurrentSegmentIndex()
  const baseEnd = idx >= 0 ? mockTranscript.value[idx].endTime : (mockTranscript.value[mockTranscript.value.length - 1]?.endTime || 0)
  const newSeg = {
    startTime: baseEnd,
    endTime: baseEnd + Math.max(3, Math.min(15, Math.ceil(text.length / 8))), // 简单估时
    speaker: 'AI',
    text: '[TTS]' + text,
    confirmed: true
  }
  if (idx >= 0) {
    mockTranscript.value.splice(idx + 1, 0, newSeg)
  } else {
    mockTranscript.value.push(newSeg)
  }
  if (currentTTSTask.value) {
    currentTTSTask.value.inserted = true
  }
  showTTSModal.value = false
}

// 导出成功弹窗
const showExportSuccess = ref(false)
const doExport = async () => {
  showExportSuccess.value = false
  await new Promise(r => setTimeout(r, 500))
  showExportSuccess.value = true
}

// 脚本优化反馈提示
const scriptOptimizeMessage = ref('')
const onProgressHover = (event) => {
  const rect = event.currentTarget.getBoundingClientRect()
  const x = event.clientX - rect.left
  hoverTime.value = Math.max(0, Math.min(100, (x / rect.width) * 100))
}

// 标记点功能
const addMarker = () => {
  markers.value.push({
    id: Date.now(),
    time: currentTime.value,
    label: `标记 ${markers.value.length + 1}`
  })
}

const deleteMarker = (markerId) => {
  markers.value = markers.value.filter(m => m.id !== markerId)
}

// 时间跳转
const jumpToTime = () => {
  const timeStr = timeInputValue.value.trim()
  if (!timeStr) return
  
  // 解析时间格式 (HH:MM:SS 或 MM:SS)
  const parts = timeStr.split(':').map(Number)
  let totalSeconds = 0
  
  if (parts.length === 2) {
    // MM:SS
    totalSeconds = parts[0] * 60 + parts[1]
  } else if (parts.length === 3) {
    // HH:MM:SS
    totalSeconds = parts[0] * 3600 + parts[1] * 60 + parts[2]
  }
  
  if (totalSeconds >= 0 && totalSeconds <= audioDuration.value) {
    currentTime.value = totalSeconds
    showTimeInput.value = false
    timeInputValue.value = ''
  }
}

// 选择区域功能
const startSelection = (event) => {
  if (event.shiftKey) {
    isSelecting.value = true
    const rect = event.currentTarget.getBoundingClientRect()
    const x = event.clientX - rect.left
    const percentage = Math.max(0, Math.min(1, x / rect.width))
    selectionStart.value = Math.floor(audioDuration.value * percentage)
    selectionEnd.value = selectionStart.value
  }
}

const startDraggingProgress = (event) => {
  isDraggingProgress.value = true
  const handleMouseMove = (e) => {
    const progressBar = event.target.closest('.relative')
    if (progressBar) {
      const rect = progressBar.getBoundingClientRect()
      const x = e.clientX - rect.left
      const percentage = Math.max(0, Math.min(1, x / rect.width))
      currentTime.value = Math.floor(audioDuration.value * percentage)
    }
  }
  const handleMouseUp = () => {
    isDraggingProgress.value = false
    document.removeEventListener('mousemove', handleMouseMove)
    document.removeEventListener('mouseup', handleMouseUp)
  }
  document.addEventListener('mousemove', handleMouseMove)
  document.addEventListener('mouseup', handleMouseUp)
}

// 轨道折叠和锁定
const toggleTrackCollapse = (trackId) => {
  const track = tracks.value.find(t => t.id === trackId)
  if (track) {
    track.collapsed = !track.collapsed
  }
}

const toggleTrackLock = (trackId) => {
  const track = tracks.value.find(t => t.id === trackId)
  if (track) {
    track.locked = !track.locked
  }
}

const deleteTrack = (trackId) => {
  const index = tracks.value.findIndex(t => t.id === trackId)
  if (index !== -1) {
    tracks.value.splice(index, 1)
  }
}

const toggleRecord = (trackId) => {
  const track = tracks.value.find(t => t.id === trackId)
  if (track) {
    track.recording = !track.recording
  }
}

const showTrackColorPicker = (trackId) => {
  // 简单的颜色选择，实际可以打开颜色选择器
  const colors = ['bg-blue-500', 'bg-green-500', 'bg-purple-500', 'bg-pink-500', 'bg-indigo-500', 'bg-orange-500', 'bg-yellow-500', 'bg-red-500']
  const track = tracks.value.find(t => t.id === trackId)
  if (track) {
    const currentIndex = colors.indexOf(track.color)
    track.color = colors[(currentIndex + 1) % colors.length]
  }
}

// 时间轴计算 - 优化显示逻辑，确保时间标记清晰可见
const timeTicks = computed(() => {
  const ticks = []
  // 根据缩放级别和总时长动态调整间隔
  let interval = 1 // 默认1秒
  if (audioDuration.value > 3600) {
    // 超过1小时，使用更大的间隔
    interval = zoomLevel.value >= 2 ? 5 : zoomLevel.value >= 1 ? 10 : zoomLevel.value >= 0.5 ? 30 : 60
  } else if (audioDuration.value > 1800) {
    // 30分钟到1小时
    interval = zoomLevel.value >= 2 ? 1 : zoomLevel.value >= 1 ? 5 : zoomLevel.value >= 0.5 ? 10 : 30
  } else {
    // 小于30分钟
    interval = zoomLevel.value >= 2 ? 1 : zoomLevel.value >= 1 ? 5 : zoomLevel.value >= 0.5 ? 10 : 15
  }
  
  // 确保主刻度间隔合理（每5个或10个间隔一个主刻度）
  const majorInterval = interval >= 30 ? interval * 2 : interval * 5
  
  for (let time = 0; time <= audioDuration.value; time += interval) {
    ticks.push({
      time,
      isMajor: time % majorInterval === 0 || time === 0 || time === audioDuration.value
    })
  }
  return ticks
})

// 缩放功能
const zoomIn = () => {
  if (zoomLevel.value < 4) {
    zoomLevel.value = Math.min(4, zoomLevel.value * 1.5)
    updateTimelineWidth()
  }
}

const zoomOut = () => {
  if (zoomLevel.value > 0.25) {
    zoomLevel.value = Math.max(0.25, zoomLevel.value / 1.5)
    updateTimelineWidth()
  }
}

const updateTimelineWidth = () => {
  timelineWidth.value = Math.max(10000, audioDuration.value * zoomLevel.value * 10)
}

// 轨道操作
const addTrack = () => {
  const colors = ['bg-green-500', 'bg-purple-500', 'bg-pink-500', 'bg-indigo-500']
  const colorIndex = tracks.value.length % colors.length
  tracks.value.push({
    id: Date.now(),
    name: `轨道 ${tracks.value.length + 1}`,
    type: '音频',
    color: colors[colorIndex],
    muted: false,
    solo: false,
    volume: 100,
    pan: 0,
    collapsed: false,
    locked: false,
    recording: false,
    clips: []
  })
}

const selectTrack = (trackId) => {
  selectedTrackId.value = trackId
  selectedClipId.value = null
  
  // 查找该轨道对应的所有说话人片段
  const track = tracks.value.find(t => t.id === trackId)
  if (!track) {
    highlightedTranscriptIndices.value = []
    return
  }

  const range = []
  // 根据轨道名称映射说话人
  let speaker = ''
  if (track.name.includes('A')) speaker = 'A'
  else if (track.name.includes('B')) speaker = 'B'
  else if (track.name.includes('AI')) speaker = 'AI'

  if (speaker) {
    mockTranscript.value.forEach((seg, idx) => {
      if (seg.speaker === speaker) {
        range.push(idx)
      }
    })
  }
  highlightedTranscriptIndices.value = range
  
  // 滚动到该轨道的第一条文字稿
  if (range.length > 0) {
    scrollToSegment(range[0])
  }
}

const highlightedTranscriptIndices = ref([])

const isSegmentHighlighted = (index) => {
  return highlightedTranscriptIndices.value.includes(index)
}

const scrollToSegment = (index) => {
  const el = segmentRefs.value[index]
  if (el) {
    el.scrollIntoView({ behavior: 'smooth', block: 'center' })
  }
}

const selectClip = (clip) => {
  selectedClipId.value = clip.id
  // 查找该片段对应的文字稿索引范围
  const range = []
  mockTranscript.value.forEach((seg, idx) => {
    // 如果文字稿的时间段与片段的时间段有交集，则视为相关
    if (seg.startTime < clip.end && seg.endTime > clip.start) {
      range.push(idx)
    }
  })
  highlightedTranscriptIndices.value = range
  
  // 如果有高亮内容，自动滚动到第一条
  if (range.length > 0) {
    scrollToSegment(range[0])
  }
}

const toggleMute = (trackId) => {
  const track = tracks.value.find(t => t.id === trackId)
  if (track) {
    track.muted = !track.muted
  }
}

const toggleSolo = (trackId) => {
  const track = tracks.value.find(t => t.id === trackId)
  if (track) {
    track.solo = !track.solo
    // 如果独奏，其他轨道静音
    if (track.solo) {
      tracks.value.forEach(t => {
        if (t.id !== trackId) {
          t.muted = true
        }
      })
    } else {
      // 取消独奏，恢复其他轨道
      tracks.value.forEach(t => {
        if (t.id !== trackId) {
          t.muted = false
        }
      })
    }
  }
}

// 剪辑操作
const splitAtCurrentTime = () => {
  if (!selectedTrackId.value) return
  
  const track = tracks.value.find(t => t.id === selectedTrackId.value)
  if (!track) return
  
  const clip = track.clips.find(c => c.start <= currentTime.value && c.end >= currentTime.value)
  if (!clip) return
  
  // 分割剪辑
  const newClip = {
    id: Date.now(),
    name: clip.name + ' (2)',
    start: currentTime.value,
    end: clip.end,
    color: clip.color,
    fadeIn: false,
    fadeOut: clip.fadeOut
  }
  clip.end = currentTime.value
  clip.fadeOut = false
  
  track.clips.push(newClip)
  track.clips.sort((a, b) => a.start - b.start)
}

const deleteSelected = () => {
  if (selectedClipId.value) {
    tracks.value.forEach(track => {
      track.clips = track.clips.filter(c => c.id !== selectedClipId.value)
    })
    selectedClipId.value = null
  }
}

const addFadeIn = () => {
  if (selectedClipId.value) {
    tracks.value.forEach(track => {
      const clip = track.clips.find(c => c.id === selectedClipId.value)
      if (clip) {
        clip.fadeIn = true
      }
    })
  }
}

const addFadeOut = () => {
  if (selectedClipId.value) {
    tracks.value.forEach(track => {
      const clip = track.clips.find(c => c.id === selectedClipId.value)
      if (clip) {
        clip.fadeOut = true
      }
    })
  }
}

// 拖拽和调整大小
const startDragClip = (clip, event) => {
  selectClip(clip)
  const startX = event.clientX
  const startLeft = (clip.start / audioDuration.value * timelineWidth.value)
  
  const handleMouseMove = (e) => {
    const deltaX = e.clientX - startX
    const deltaTime = (deltaX / timelineWidth.value) * audioDuration.value
    const newStart = Math.max(0, Math.min(audioDuration.value - (clip.end - clip.start), startLeft / timelineWidth.value * audioDuration.value + deltaTime))
    
    if (snapToGrid.value) {
      const snapInterval = 1 // 1秒对齐
      clip.start = Math.round(newStart / snapInterval) * snapInterval
    } else {
      clip.start = newStart
    }
    clip.end = clip.start + (clip.end - clip.start)
  }
  
  const handleMouseUp = () => {
    document.removeEventListener('mousemove', handleMouseMove)
    document.removeEventListener('mouseup', handleMouseUp)
  }
  
  document.addEventListener('mousemove', handleMouseMove)
  document.addEventListener('mouseup', handleMouseUp)
}

const startResizeClip = (clip, side, event) => {
  selectedClipId.value = clip.id
  const startX = event.clientX
  const startTime = side === 'start' ? clip.start : clip.end
  
  const handleMouseMove = (e) => {
    const deltaX = e.clientX - startX
    const deltaTime = (deltaX / timelineWidth.value) * audioDuration.value
    let newTime = startTime + deltaTime
    
    if (snapToGrid.value) {
      const snapInterval = 1
      newTime = Math.round(newTime / snapInterval) * snapInterval
    }
    
    if (side === 'start') {
      clip.start = Math.max(0, Math.min(newTime, clip.end - 1))
    } else {
      clip.end = Math.max(clip.start + 1, Math.min(audioDuration.value, newTime))
    }
  }
  
  const handleMouseUp = () => {
    document.removeEventListener('mousemove', handleMouseMove)
    document.removeEventListener('mouseup', handleMouseUp)
  }
  
  document.addEventListener('mousemove', handleMouseMove)
  document.addEventListener('mouseup', handleMouseUp)
}

// 编辑片段
const editClip = (clip) => {
  selectedClipId.value = clip.id
  console.log('编辑片段:', clip)
}

// 分割片段
const splitClip = (clip) => {
  if (!selectedTrackId.value) return
  const track = tracks.value.find(t => t.id === selectedTrackId.value)
  if (!track) return
  
  const clipIndex = track.clips.findIndex(c => c.id === clip.id)
  if (clipIndex === -1) return
  
  const splitTime = currentTime.value
  if (splitTime <= clip.start || splitTime >= clip.end) return
  
  const newClip = {
    id: Date.now(),
    name: clip.name + ' (2)',
    start: splitTime,
    end: clip.end,
    color: clip.color,
    fadeIn: false,
    fadeOut: clip.fadeOut
  }
  
  clip.end = splitTime
  clip.fadeOut = false
  
  track.clips.splice(clipIndex + 1, 0, newClip)
  track.clips.sort((a, b) => a.start - b.start)
}

// 删除片段
const deleteClip = (clipId) => {
  tracks.value.forEach(track => {
    track.clips = track.clips.filter(c => c.id !== clipId)
  })
  if (selectedClipId.value === clipId) {
    selectedClipId.value = null
  }
}

// 撤销/重做
const undo = () => {
  console.log('撤销')
}

const redo = () => {
  console.log('重做')
}

const onTimelineScroll = (event) => {
  if (!event || !event.target) return
  const scrollLeft = event.target.scrollLeft
  if (event.target === timelineContainer.value) {
    if (timelineRuler.value) timelineRuler.value.scrollLeft = scrollLeft
  } else if (event.target === timelineRuler.value) {
    if (timelineContainer.value) timelineContainer.value.scrollLeft = scrollLeft
  } else {
    if (timelineRuler.value) timelineRuler.value.scrollLeft = scrollLeft
    if (timelineContainer.value) timelineContainer.value.scrollLeft = scrollLeft
  }
}

const triggerFileUpload = () => {
  fileInput.value?.click()
}

const generateCutSuggestions = async () => {
  if (isGenerating.value) return
  
  isGenerating.value = true
  
  // 模拟API调用延迟
  await new Promise(resolve => setTimeout(resolve, 800))
  
  const suggestions = []
  mockTranscript.value.forEach((segment, segmentIndex) => {
    const tokens = parseSegmentText(segment.text)
    
    // 找出该片段中的口癖与口吃
    const targetTokens = tokens.filter(t => {
      if (cuttingStrategy.value === 'filler' && t.type === 'filler') return true
      if (cuttingStrategy.value === 'stutter' && t.type === 'stutter') return true
      if (cuttingStrategy.value === 'both' && (t.type === 'filler' || t.type === 'stutter')) return true
      if (cuttingStrategy.value === 'all' && (t.type === 'filler' || t.type === 'stutter')) return true
      return false
    })

    if (targetTokens.length > 0) {
      // 生成预览文本：标注出要删除的部分
      const previewHtml = tokens.map(t => {
        const isTarget = targetTokens.some(target => target === t)
        if (isTarget) {
          return `<span class="text-red-400 line-through mx-0.5">${t.text}</span>`
        }
        return `<span>${t.text}</span>`
      }).join('')

      suggestions.push({
        id: `sug-${segmentIndex}-${Date.now()}`,
        segmentIndex,
        label: `建议优化片段 ${formatTime(segment.startTime)}`,
        previewHtml,
        tag: targetTokens.some(t => t.type === 'stutter') ? '口吃' : '口癖',
        targetTokenTexts: targetTokens.map(t => t.text)
      })
    }
  })
  
  cutSuggestions.value = suggestions
  isGenerating.value = false
}

// 应用剪辑建议
const applyCutSuggestion = (suggestion) => {
  const segment = mockTranscript.value[suggestion.segmentIndex]
  if (!segment) return

  // 对文字稿进行处理：将建议删除的 token 包装在 ~~ 中（留痕模式）
  const tokens = parseSegmentText(segment.text)
  const updatedText = tokens.map(t => {
    // 简单的文本匹配，在实际项目中可能需要更精确的索引匹配
    if (suggestion.targetTokenTexts.includes(t.text) && (t.type === 'filler' || t.type === 'stutter')) {
      return `~~${t.text}~~`
    }
    if (t.type === 'deleted') return `~~${t.text}~~`
    return t.text
  }).join('')

  segment.text = (segment.text.startsWith('[TTS]') ? '[TTS]' : '') + updatedText
  
  // 从建议列表中移除
  cutSuggestions.value = cutSuggestions.value.filter(s => s.id !== suggestion.id)
}

const buildSamplePreview = () => {
  const groups = [
    {
      id: 'g-filler',
      strategy: 'filler',
      label: 'AI 口癖剪辑',
      description: '自动识别并标记无意义语气词（如：嗯、呃、这个、那个）',
      entries: [
        { id: 'e1', speaker: '说话人 1', time: '00:08-00:14', type: '口癖', content: '嗯...所以这个研究的路径吧，它聚焦在技术窗口... -> 所以这个研究的路径吧，它聚焦在技术窗口... (已删除“嗯”)', tags: [{ text: '嗯', type: '口癖' }, { text: '这个', type: '口癖' }] },
        { id: 'e2', speaker: '说话人 2', time: '00:36-00:41', type: '口癖', content: '然后呢...这个第四点呢... -> 第四点是... (已精简冗余“然后呢/这个”)', tags: [{ text: '然后呢', type: '口癖' }] },
        { id: 'e2b', speaker: '说话人 1', time: '01:15-01:18', type: '口癖', content: '就是那个...怎么说呢...我觉得 -> 我觉得 (已移除无意义连接词)', tags: [{ text: '就是那个', type: '口癖' }, { text: '怎么说呢', type: '口癖' }] },
        { id: 'e2c', speaker: '说话人 2', time: '01:45-01:50', type: '口癖', content: '基本上...呃...你知道吧... -> (已完全删除无效片段)', tags: [{ text: '基本上', type: '口癖' }, { text: '你知道吧', type: '口癖' }] }
      ]
    },
    {
      id: 'g-stutter',
      strategy: 'stutter',
      label: 'AI 口吃剪辑',
      description: '智能修复重复字词与结巴现象',
      entries: [
        { id: 'e3', speaker: '说话人 3', time: '01:02-01:07', type: '口吃', content: '我我我...觉得这个方向... -> 我觉得这个方向... (已合并重复字)', tags: [{ text: '我我我', type: '口吃' }] },
        { id: 'e4', speaker: '说话人 1', time: '01:20-01:24', type: '口吃', content: '那那...那个问题... -> 那个问题... (已修复口吃)', tags: [{ text: '那那 那个', type: '口吃' }] }
      ]
    },
    {
      id: 'g-both',
      strategy: 'both',
      label: 'AI 口癖&口吃剪辑',
      description: '综合处理口癖与口吃，保留自然说话风格',
      entries: [
        { id: 'e5', speaker: '说话人 2', time: '02:10-02:16', type: '口癖', content: '就是说...我们可能需要补充的是，嗯... -> 我们可能需要补充的是... (已删除连词)', tags: [{ text: '就是说', type: '口癖' }, { text: '嗯', type: '口癖' }] },
        { id: 'e6', speaker: '说话人 1', time: '02:40-02:45', type: '口吃', content: '所以所以...我们从这个角度... -> 所以我们从这个角度... (已合并重复)', tags: [{ text: '所以所以', type: '口吃' }] }
      ]
    },
    {
      id: 'g-all',
      strategy: 'all',
      label: 'AI 全剪辑',
      description: '一键深度清理，最大程度提升信息密度',
      entries: [
        { id: 'e7', speaker: '说话人 1', time: '03:03-03:10', type: '口癖', content: '其实就是那个...嗯...核心观点 -> 核心观点 (已删除严重冗余)', tags: [{ text: '那个', type: '口癖' }, { text: '嗯', type: '口癖' }] },
        { id: 'e7b', speaker: '说话人 2', time: '04:15-04:20', type: '口癖', content: '怎么说呢...某种意义上...是吧 -> (已优化：删除无效废话)', tags: [{ text: '怎么说呢', type: '口癖' }] },
        { id: 'e8', speaker: '说话人 3', time: '03:25-03:31', type: '口吃', content: '我我...我们这期就到这里 -> 我们这期就到这里 (已修复)', tags: [{ text: '我我', type: '口吃' }] }
      ]
    }
  ]
  
  // 根据选择的策略过滤并显示对应的示例预览
  switch (cuttingStrategy.value) {
    case 'filler':
      samplePreview.value = groups.filter(g => g.strategy === 'filler')
      break
    case 'stutter':
      samplePreview.value = groups.filter(g => g.strategy === 'stutter')
      break
    case 'both':
      samplePreview.value = groups.filter(g => g.strategy === 'both')
      break
    case 'all':
    default:
      samplePreview.value = groups.filter(g => g.strategy === 'all')
      break
  }
}

const handleFileSelect = (event) => {
  const file = event.target.files[0]
  if (file) {
    assets.value.unshift({
      id: Date.now(),
      name: file.name,
      type: file.type.startsWith('video') ? 'video' : 'audio',
      duration: '00:00', // Mock duration
      format: file.name.split('.').pop().toUpperCase()
    })
  }
}

const selectAsset = (asset) => {
  console.log('Selected asset:', asset)
  // 可以在这里添加将素材添加到轨道的逻辑
}

const showAssetMenu = (asset) => {
  console.log('Show menu for:', asset)
  // 可以在这里显示右键菜单
}

// 深度语义搜索
const performSemanticSearch = async () => {
  if (!semanticSearchQuery.value.trim() || isSearching.value) return
  
  isSearching.value = true
  
  // 模拟 TS-RAG 搜索
  await new Promise(resolve => setTimeout(resolve, 1200))
  
  // 模拟搜索结果
  searchResults.value = [
    {
      id: 1,
      title: '关于职场焦虑的讨论',
      preview: '我觉得职场焦虑主要来源于对未来的不确定性，以及工作压力...',
      startTime: 1250,
      endTime: 1890,
      relevance: 92
    },
    {
      id: 2,
      title: '职场焦虑的应对方法',
      preview: '应对职场焦虑，我建议可以从几个方面入手：首先是时间管理...',
      startTime: 3420,
      endTime: 4100,
      relevance: 88
    },
    {
      id: 3,
      title: '职场焦虑的根源分析',
      preview: '职场焦虑的根源其实很复杂，既有外部环境因素，也有个人心理因素...',
      startTime: 5670,
      endTime: 6320,
      relevance: 85
    }
  ]
  
  // 生成话题热度图
  topicHeatmap.value = [
    { id: 1, name: '职场焦虑', intensity: 85 },
    { id: 2, name: '工作压力', intensity: 72 },
    { id: 3, name: '时间管理', intensity: 65 },
    { id: 4, name: '职业规划', intensity: 58 },
    { id: 5, name: '心理健康', intensity: 45 }
  ]
  
  isSearching.value = false
}

// 提取金句
const extractGoldenSentences = async () => {
  if (isExtracting.value) return
  
  isExtracting.value = true
  await new Promise(resolve => setTimeout(resolve, 1500))
  
  // 模拟 AI 分析逻辑：从文字稿中筛选出具有“金句”特质的句子
  // 这里我们根据句子长度和一些关键词（如“本质”、“未来”、“关键”、“灵魂”）进行简单模拟
  const keywords = ['本质', '未来', '关键', '灵魂', '解放', '核心', '流动']
  const results = []
  
  mockTranscript.value.forEach((segment, index) => {
    // 排除包含过多口癖或口吃的片段
    const tokens = parseSegmentText(segment.text)
    const hasTooManyFillers = tokens.filter(t => t.type === 'filler' || t.type === 'stutter').length > 2
    
    if (!hasTooManyFillers && segment.text.length > 20) {
      const hasKeyword = keywords.some(k => segment.text.includes(k))
      if (hasKeyword) {
        results.push({
          id: `golden-${index}-${Date.now()}`,
          content: segment.text.replace(/~~.*?~~/g, '').replace(/\[TTS\]/g, ''), // 移除标注和 TTS 前缀
          startTime: segment.startTime,
          endTime: segment.endTime,
          viralPotential: Math.floor(Math.random() * 15) + 80, // 80-95
          logicScore: Math.floor(Math.random() * 10) + 85 // 85-95
        })
      }
    }
  })
  
  goldenSentences.value = results.slice(0, 5) // 最多展示 5 条
  isExtracting.value = false
}

// 视频化转化状态
const aspectRatio = ref('9:16')
const isAddingTemplate = ref(false)

// 添加可视化模板
const addVisualTemplate = async () => {
  if (isAddingTemplate.value) return
  isAddingTemplate.value = true
  await new Promise(resolve => setTimeout(resolve, 1000))
  
  // 模拟添加效果，这里可以根据实际需求添加逻辑，比如在 timeline 上添加一个视频轨道
  // 这里暂时仅做状态反馈
  isAddingTemplate.value = false
}

// 跳转到指定时间
const seekToTime = (timeInSeconds) => {
  currentTime.value = timeInSeconds
  // 这里可以添加实际的音频跳转逻辑
  console.log('跳转到时间:', formatTime(timeInSeconds))
  ensureVisibleCurrentTime()
}

// 判断当前播放时间是否在某个文字片段内
const isCurrentSegment = (segment) => {
  return currentTime.value >= segment.startTime && currentTime.value <= segment.endTime
}

onMounted(async () => {
  if (route.params.id) {
    // 加载项目数据
    await projectStore.fetchProject(route.params.id)
    if (projectStore.currentProject) {
      currentProject.value = projectStore.currentProject
    }
  } else {
    // 如果没有项目 ID，尝试使用第一个项目
    if (projectStore.projects.length === 0) {
      await projectStore.fetchProjects()
    }
    if (projectStore.projects.length > 0) {
      const firstProject = projectStore.projects[0]
      currentProject.value = firstProject
    }
  }
  updateTimelineWidth()
  // 载入示例金句，便于选择
  loadSampleGoldenSentences()
  // 同步右侧面板高度与中间剪辑区可视高度
  const measureCenter = () => {
    centerPanelHeight.value = timelineContentHeightPx.value
  }
  setTimeout(measureCenter, 0)
  window.addEventListener('resize', measureCenter)
  const ro = new ResizeObserver(() => measureCenter())
  if (editorColumn.value) ro.observe(editorColumn.value)
  
  // 键盘快捷键
  document.addEventListener('keydown', (e) => {
    if (e.ctrlKey || e.metaKey) {
      if (e.key === 'z' && !e.shiftKey) {
        e.preventDefault()
        undo()
      } else if (e.key === 'y' || (e.key === 'z' && e.shiftKey)) {
        e.preventDefault()
        redo()
      }
    } else if (e.key === 'Delete' || e.key === 'Backspace') {
      if (selectedClipId.value) {
        e.preventDefault()
        deleteSelected()
      }
    } else if (e.key === 's' || e.key === 'S') {
      if (e.target.tagName !== 'INPUT' && e.target.tagName !== 'TEXTAREA') {
        e.preventDefault()
        splitAtCurrentTime()
      }
    }
  })
})
</script>

<style scoped>
.animate-fadeIn {
  animation: fadeIn 0.3s ease-out;
}
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(5px); }
  to { opacity: 1; transform: translateY(0); }
}

/* 滚动条美化 */
::-webkit-scrollbar {
  width: 4px;
  height: 4px;
}
::-webkit-scrollbar-track {
  background: transparent;
}
::-webkit-scrollbar-thumb {
  background: #FF6B9D;
  border-radius: 2px;
}
::-webkit-scrollbar-thumb:hover {
  background: #C084FC;
}

/* 波形动画 */
@keyframes wave {
  0%, 100% {
    transform: scaleY(0.5);
  }
  50% {
    transform: scaleY(1);
  }
}

/* 音量滑块样式 - 防止溢出 */
input[type="range"] {
  position: relative;
  z-index: 0;
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

input[type="range"]::-webkit-slider-thumb {
  position: relative;
  z-index: 1;
}

input[type="range"]::-moz-range-thumb {
  position: relative;
  z-index: 1;
}

/* 确保轨道内容不被遮挡 */
.track-content-area {
  position: relative;
  z-index: 0;
}
</style>
