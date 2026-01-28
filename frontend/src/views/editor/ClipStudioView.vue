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
          <button class="w-8 h-8 rounded-full bg-white flex items-center justify-center text-gray-600 border-2 border-dashed border-pink-200 hover:text-pink-600 hover:border-pink-400 transition">+</button>
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
      <!-- 2. 左侧：素材与资产管理 (Feature 2) -->
      <aside class="w-80 bg-gradient-to-b from-pink-50 to-purple-50 border-r border-pink-200 flex flex-col">
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
      <main class="flex-1 flex flex-col bg-white overflow-hidden relative">
        <!-- 播放器预览 -->
        <div class="h-1/3 border-b border-pink-200 p-6 flex flex-col relative bg-gradient-to-b from-white via-pink-50/30 to-white">
          <!-- 波形可视化区域 -->
          <div class="flex-1 flex items-center justify-center mb-4">
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
                class="relative h-4 bg-pink-100 rounded-full overflow-visible cursor-pointer group" 
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
                  <div class="absolute -top-1 left-1/2 -translate-x-1/2 w-2.5 h-2.5 bg-yellow-400 rounded-full border border-yellow-600"></div>
                </div>
                <!-- 播放指示器 -->
                <div 
                  class="absolute top-1/2 -translate-y-1/2 w-6 h-6 bg-white rounded-full shadow-lg border-2 border-pink-500 opacity-0 group-hover:opacity-100 transition-opacity z-20 cursor-grab active:cursor-grabbing"
                  :style="{ left: `calc(${currentTime / audioDuration * 100}% - 12px)` }"
                  @mousedown.stop="startDraggingProgress"
                >
                  <div class="absolute inset-0 flex items-center justify-center">
                    <div class="w-2 h-2 bg-pink-500 rounded-full"></div>
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
        <div class="flex-1 bg-white flex flex-col border-t border-pink-200 overflow-hidden">
          <!-- 工具栏 -->
          <div class="flex items-center justify-between p-3 border-b border-pink-200 bg-pink-50/50 flex-shrink-0">
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
          <div class="flex-1 flex flex-col overflow-hidden">
            <!-- 时间轴标尺（固定在顶部） -->
            <div class="h-14 border-b-2 border-pink-300 bg-gradient-to-b from-pink-50 to-white flex-shrink-0 relative overflow-x-auto" ref="timelineRuler" @scroll="onTimelineScroll">
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
                    class="absolute -top-9 left-0 transform -translate-x-1/2 whitespace-nowrap z-20"
                  >
                    <span class="text-xs font-mono text-gray-800 font-bold bg-white px-2 py-1 rounded border border-pink-300 shadow-sm">
                      {{ formatTime(tick.time) }}
                    </span>
                  </div>
                  <!-- 时间标签 - 次要刻度（放大时显示） -->
                  <div 
                    v-else-if="zoomLevel >= 1.5 && tick.time % 5 === 0"
                    class="absolute -top-8 left-0 transform -translate-x-1/2 z-20"
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
            
            <!-- 轨道区域（可滚动） -->
            <div class="flex-1 overflow-auto relative" ref="timelineContainer" @scroll="onTimelineScroll">
              <div class="flex h-full">
                <!-- 固定左侧轨道控制栏 -->
                <div class="sticky left-0 z-10 bg-white border-r-2 border-pink-300 flex-shrink-0" style="width: 240px;">
                  <!-- 轨道列表 -->
                  <div class="space-y-0">
                    <div 
                      v-for="(track, index) in tracks" 
                      :key="track.id"
                      class="h-24 bg-white border-b border-pink-200 flex flex-col overflow-hidden relative isolate"
                      :class="{ 'bg-pink-50/30': selectedTrackId === track.id }"
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
                        class="h-24 border-b border-pink-200 bg-white relative"
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
      </main>

      <!-- 4. 右侧：AI 智能工具箱 (Feature 3, 4, 5) -->
      <aside class="w-96 bg-gradient-to-b from-pink-50 to-purple-50 border-l border-pink-200 flex flex-col">
        <!-- 工具导航 Tabs -->
        <div class="flex border-b border-pink-200">
          <button 
            v-for="tab in toolTabs" 
            :key="tab.id"
            @click="activeToolTab = tab.id"
            class="flex-1 py-3 text-sm font-medium transition relative"
            :class="activeToolTab === tab.id ? 'text-gray-900 font-bold' : 'text-gray-600 hover:text-pink-600'"
          >
            {{ tab.name }}
            <div v-if="activeToolTab === tab.id" class="absolute bottom-0 left-0 right-0 h-0.5 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC]"></div>
          </button>
        </div>

        <div class="flex-1 overflow-y-auto p-6 space-y-8">
          
          <!-- Tab 1: 智能剪辑 (Feature 3) -->
          <div v-if="activeToolTab === 'edit'" class="space-y-6 animate-fadeIn">
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
                <button class="w-full py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] hover:shadow-lg hover:scale-105 text-sm text-white rounded transition">开始转写</button>
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
                  <div v-for="s in cutSuggestions" :key="s.id" class="p-3 bg-white border border-pink-200 rounded text-xs text-gray-700 flex items-center justify-between">
                    <div class="flex-1 min-w-0">
                      <div class="font-medium text-gray-900">{{ s.label }}</div>
                      <div class="text-[10px] text-gray-600 truncate">{{ s.preview }}</div>
                    </div>
                    <span class="ml-3 px-2 py-0.5 rounded bg-pink-100 text-pink-700 border border-pink-200 text-[10px]">{{ s.tag }}</span>
                  </div>
                </div>
                <div v-if="samplePreview.length" class="space-y-3 pt-2 border-t border-pink-100">
                  <div class="text-xs font-bold text-gray-900">示例预览</div>
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
                  <label class="text-xs font-medium text-gray-900">TS-RAG 语义搜索</label>
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

            <!-- 脚本优化 -->
            <section>
              <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-blue-500 rounded-full"></span>
                脚本优化
              </h3>
              <div class="grid grid-cols-2 gap-2">
                <button class="p-2 bg-white border border-pink-200 rounded text-xs text-gray-900 hover:border-pink-400 hover:text-pink-600 transition" title="自动修正错别字、剔除口语化冗余">去口语冗余</button>
                <button class="p-2 bg-white border border-pink-200 rounded text-xs text-gray-900 hover:border-pink-400 hover:text-pink-600 transition" title="检测逻辑断层，推荐衔接句">逻辑纠错</button>
                <button class="p-2 bg-white border border-pink-200 rounded text-xs text-gray-900 hover:border-pink-400 hover:text-pink-600 transition" title="提取核心片段生成精华版">一键精华提取</button>
                <button class="p-2 bg-white border border-pink-200 rounded text-xs text-gray-900 hover:border-pink-400 hover:text-pink-600 transition" title="根据内容推荐背景音乐">BGM智能匹配</button>
              </div>
            </section>

             <!-- TTS 生成 (Feature 3.5) -->
             <section>
              <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-pink-500 rounded-full"></span>
                TTS 语音生成
              </h3>
               <div class="space-y-3">
                 <div class="grid grid-cols-2 gap-2">
                    <button class="p-2 bg-white border border-pink-200 rounded text-xs text-gray-900 hover:border-pink-400 hover:text-pink-600 transition flex items-center justify-center gap-1">
                      <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" /></svg>
                      声线克隆
                    </button>
                     <button class="p-2 bg-white border border-pink-200 rounded text-xs text-gray-900 hover:border-pink-400 hover:text-pink-600 transition">多角色生成</button>
                 </div>
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
                  <div class="h-1 bg-pink-100 rounded-full overflow-hidden"><div class="w-[80%] h-full bg-green-500"></div></div>
                </div>
                <div class="space-y-1">
                  <div class="flex justify-between text-xs text-gray-600"><span>音量均衡</span><span>On</span></div>
                   <div class="flex items-center gap-2">
                      <button class="text-[10px] px-2 py-0.5 rounded bg-white border border-pink-200 text-gray-900 hover:bg-pink-50">人声增强</button>
                      <button class="text-[10px] px-2 py-0.5 rounded bg-white border border-pink-200 text-gray-900 hover:bg-pink-50">去回声</button>
                   </div>
                </div>
              </div>
            </section>
          </div>

          <!-- Tab 2: 内容增值 (Feature 4) -->
          <div v-if="activeToolTab === 'enhance'" class="space-y-6 animate-fadeIn">
            <!-- 场景自适应设置 -->
            <section>
              <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-violet-500 rounded-full"></span>
                场景自适应设置
              </h3>
              <div class="p-4 bg-white border border-pink-200 rounded-lg space-y-3">
                <div class="text-xs font-medium text-gray-900 mb-2">播客类型</div>
                <div class="space-y-2">
                  <label class="flex items-start gap-2.5 text-sm text-gray-700 cursor-pointer hover:text-pink-600 transition p-2 rounded hover:bg-pink-50">
                    <input type="radio" name="podcastType" class="w-4 h-4 mt-0.5 border-2 border-pink-300 text-pink-600 focus:ring-2 focus:ring-pink-300" v-model="podcastType" value="knowledge">
                    <div class="flex-1">
                      <div class="font-medium">知识分享类</div>
                      <div class="text-xs text-gray-500 mt-0.5">追求极致信息效率，精准剔除冗余</div>
                    </div>
                  </label>
                  <label class="flex items-start gap-2.5 text-sm text-gray-700 cursor-pointer hover:text-pink-600 transition p-2 rounded hover:bg-pink-50">
                    <input type="radio" name="podcastType" class="w-4 h-4 mt-0.5 border-2 border-pink-300 text-pink-600 focus:ring-2 focus:ring-pink-300" v-model="podcastType" value="companion">
                    <div class="flex-1">
                      <div class="font-medium">情感陪伴类</div>
                      <div class="text-xs text-gray-500 mt-0.5">保留真实呼吸感与松弛感</div>
                    </div>
                  </label>
                </div>
                <div class="pt-2 border-t border-pink-100">
                  <div class="text-xs text-gray-600 mb-2">当前算法权重</div>
                  <div class="space-y-2">
                    <div>
                      <div class="flex justify-between text-xs text-gray-600 mb-1">
                        <span>语义逻辑权重</span>
                        <span>{{ podcastType === 'knowledge' ? '80%' : '50%' }}</span>
                      </div>
                      <div class="h-1.5 bg-pink-100 rounded-full overflow-hidden">
                        <div class="h-full bg-gradient-to-r from-blue-500 to-indigo-500 rounded-full transition-all" 
                          :style="{ width: podcastType === 'knowledge' ? '80%' : '50%' }"></div>
                      </div>
                    </div>
                    <div>
                      <div class="flex justify-between text-xs text-gray-600 mb-1">
                        <span>情感保留权重</span>
                        <span>{{ podcastType === 'knowledge' ? '20%' : '50%' }}</span>
                      </div>
                      <div class="h-1.5 bg-pink-100 rounded-full overflow-hidden">
                        <div class="h-full bg-gradient-to-r from-pink-500 to-purple-500 rounded-full transition-all" 
                          :style="{ width: podcastType === 'knowledge' ? '20%' : '50%' }"></div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </section>

            <!-- Shownotes 与章节生成 -->
            <section>
              <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-amber-500 rounded-full"></span>
                Shownotes 与章节生成
              </h3>
              <div class="p-4 bg-white border border-pink-200 rounded-lg space-y-3">
                <button 
                  @click="generateShownotes"
                  :disabled="isGeneratingShownotes"
                  class="w-full py-2.5 bg-gradient-to-r from-amber-500 to-orange-500 text-white text-sm font-medium rounded-lg hover:shadow-lg transition disabled:opacity-50 flex items-center justify-center gap-2"
                >
                  <svg v-if="isGeneratingShownotes" class="animate-spin h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  <span>{{ isGeneratingShownotes ? '生成中...' : '生成结构化 Shownotes' }}</span>
                </button>
                <div v-if="shownotesData" class="space-y-3 pt-2 border-t border-pink-100">
                  <div class="text-xs font-bold text-gray-900 mb-2">章节时间轴</div>
                  <div class="space-y-2 max-h-60 overflow-y-auto">
                    <div v-for="chapter in shownotesData.chapters" :key="chapter.id" 
                      class="p-2 bg-pink-50 border border-pink-200 rounded cursor-pointer hover:bg-pink-100 transition"
                      @click="seekToTime(chapter.startTime)"
                    >
                      <div class="flex items-center justify-between mb-1">
                        <span class="text-xs font-medium text-gray-900">{{ chapter.title }}</span>
                        <span class="text-[10px] text-pink-600">{{ formatTime(chapter.startTime) }}</span>
                      </div>
                      <div class="text-[10px] text-gray-600 line-clamp-2">{{ chapter.summary }}</div>
                    </div>
                  </div>
                  <button 
                    @click="showMindMap = !showMindMap"
                    class="w-full py-2 bg-white border border-pink-200 text-gray-700 text-xs rounded-lg hover:bg-pink-50 transition flex items-center justify-center gap-2"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" />
                    </svg>
                    <span>{{ showMindMap ? '隐藏' : '显示' }}思维导图</span>
                  </button>
                  <div v-if="showMindMap && shownotesData.mindMap" class="p-3 bg-gradient-to-br from-purple-50 to-pink-50 border border-purple-200 rounded-lg">
                    <div class="text-xs font-medium text-gray-900 mb-2">思维导图预览</div>
                    <div class="text-[10px] text-gray-600 whitespace-pre-line">{{ shownotesData.mindMap }}</div>
                  </div>
                </div>
              </div>
            </section>

            <!-- 视频播客自动生成 -->
            <section>
              <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-rose-500 rounded-full"></span>
                视频播客自动生成
              </h3>
              <div class="p-4 bg-white border border-pink-200 rounded-lg space-y-3">
                <div class="space-y-2">
                  <label class="text-xs font-medium text-gray-900">选择金句片段</label>
                  <div v-if="goldenSentences.length" class="space-y-2 max-h-40 overflow-y-auto">
                    <label v-for="sentence in goldenSentences" :key="sentence.id" 
                      class="flex items-start gap-2 p-2 bg-pink-50 border border-pink-200 rounded cursor-pointer hover:bg-pink-100 transition"
                    >
                      <input type="checkbox" :value="sentence.id" v-model="selectedSentences" class="mt-0.5">
                      <div class="flex-1">
                        <div class="text-xs text-gray-900">{{ sentence.content.substring(0, 50) }}...</div>
                        <div class="text-[10px] text-gray-600 mt-1">{{ formatTime(sentence.startTime) }} - {{ formatTime(sentence.endTime) }}</div>
                      </div>
                    </label>
                  </div>
                  <div v-else class="text-xs text-gray-500 text-center py-4">请先提取金句</div>
                </div>
                <div class="space-y-2">
                  <label class="text-xs font-medium text-gray-900">视频模板</label>
                  <select v-model="videoTemplate" class="w-full px-3 py-2 text-xs border border-pink-200 rounded-lg focus:ring-2 focus:ring-pink-300">
                    <option value="digital-human">数字人播客</option>
                    <option value="waveform">波形可视化</option>
                    <option value="subtitle">字幕卡片</option>
                    <option value="hybrid">混合模式</option>
                  </select>
                </div>
                <button 
                  @click="generateVideoPodcast"
                  :disabled="selectedSentences.length === 0 || isGeneratingVideo"
                  class="w-full py-2.5 bg-gradient-to-r from-rose-500 to-pink-500 text-white text-sm font-medium rounded-lg hover:shadow-lg transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                >
                  <svg v-if="isGeneratingVideo" class="animate-spin h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  <span>{{ isGeneratingVideo ? '生成中...' : '生成视频播客' }}</span>
                </button>
                <div v-if="generatedVideos.length" class="space-y-2 pt-2 border-t border-pink-100">
                  <div class="text-xs font-medium text-gray-900">已生成视频</div>
                  <div v-for="video in generatedVideos" :key="video.id" class="p-2 bg-gradient-to-r from-rose-50 to-pink-50 border border-rose-200 rounded">
                    <div class="flex items-center justify-between mb-1">
                      <span class="text-xs font-medium text-gray-900">{{ video.title }}</span>
                      <span class="text-[10px] text-gray-600">{{ video.duration }}</span>
                    </div>
                    <div class="flex items-center gap-2 mt-2">
                      <button class="text-[10px] px-2 py-1 bg-rose-500 text-white rounded hover:bg-rose-600 transition">预览</button>
                      <button class="text-[10px] px-2 py-1 bg-white border border-rose-300 text-rose-600 rounded hover:bg-rose-50 transition">下载</button>
                    </div>
                  </div>
                </div>
              </div>
            </section>

            <div class="p-4 bg-white border border-pink-200 rounded-lg">
              <h4 class="text-sm font-bold text-gray-900 mb-2">AI 文案生成</h4>
               <div class="grid grid-cols-2 gap-2 mb-3">
                  <label class="flex items-center gap-2 text-xs text-gray-700 cursor-pointer">
                    <input type="checkbox" checked class="rounded bg-white border border-pink-200 text-pink-600 focus:ring-pink-300">
                    Show Notes
                  </label>
                  <label class="flex items-center gap-2 text-xs text-gray-700 cursor-pointer">
                    <input type="checkbox" class="rounded bg-white border border-pink-200 text-pink-600 focus:ring-pink-300">
                    小红书文案
                  </label>
                  <label class="flex items-center gap-2 text-xs text-gray-700 cursor-pointer">
                    <input type="checkbox" class="rounded bg-white border border-pink-200 text-pink-600 focus:ring-pink-300">
                    公众号文章
                  </label>
                  <label class="flex items-center gap-2 text-xs text-gray-700 cursor-pointer">
                    <input type="checkbox" class="rounded bg-white border border-pink-200 text-pink-600 focus:ring-pink-300">
                    视频字幕
                  </label>
               </div>
              <button class="w-full py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white text-xs rounded transition shadow-lg">一键生成</button>
            </div>

            <!-- 交互式播客 (Feature 4.3) -->
            <section>
              <h4 class="text-sm font-bold text-gray-900 mb-2">交互式播客生成</h4>
              <div class="space-y-2">
                 <button class="w-full p-3 bg-white border border-pink-200 rounded text-left hover:bg-pink-50 transition group">
                    <div class="text-xs text-gray-900 group-hover:text-pink-700 font-medium mb-1">实时问答配置</div>
                    <div class="text-[10px] text-gray-600">集成大模型API，设置互动节点</div>
                 </button>
                 <button class="w-full p-3 bg-white border border-pink-200 rounded text-left hover:bg-pink-50 transition group">
                    <div class="text-xs text-gray-900 group-hover:text-pink-700 font-medium mb-1">分支剧情设计</div>
                    <div class="text-[10px] text-gray-600">预设2-3个主题分支，听众选择后无缝衔接</div>
                 </button>
              </div>
           </section>

            <div class="space-y-2">
              <h4 class="text-sm font-bold text-gray-900">视频化转化</h4>
              <div class="grid grid-cols-3 gap-2">
                 <div class="aspect-[9/16] bg-white rounded border border-pink-200 hover:border-pink-300 cursor-pointer flex items-center justify-center text-xs text-gray-600 flex-col gap-1">
                    <span>9:16</span>
                    <span class="text-[8px] text-gray-500">抖音/Shorts</span>
                 </div>
                 <div class="aspect-[16/9] bg-white rounded border border-pink-200 hover:border-pink-300 cursor-pointer flex items-center justify-center text-xs text-gray-600 flex-col gap-1">
                    <span>16:9</span>
                    <span class="text-[8px] text-gray-500">B站/YT</span>
                 </div>
                 <div class="aspect-square bg-white rounded border border-pink-200 hover:border-pink-300 cursor-pointer flex items-center justify-center text-xs text-gray-600">1:1</div>
              </div>
              <button class="w-full py-2 mt-2 bg-white border border-pink-200 hover:bg-pink-50 text-gray-700 text-xs rounded transition">添加可视化波形/字幕模板</button>
            </div>
          </div>

          <!-- Tab 3: 导出分发 (Feature 5) -->
          <div v-if="activeToolTab === 'export'" class="space-y-6 animate-fadeIn">
            <div class="space-y-3">
              <label class="block text-sm text-gray-700">导出格式</label>
              <select class="w-full bg-white border border-pink-200 text-gray-900 text-sm rounded p-2 focus:ring-2 focus:ring-pink-300 outline-none">
                <option>MP3 (320kbps)</option>
                <option>WAV (无损)</option>
                <option>MP4 (1080P)</option>
              </select>
            </div>
            <div class="space-y-3">
              <label class="block text-sm text-gray-700">分发平台</label>
              <div class="grid grid-cols-4 gap-2">
                <div class="w-10 h-10 rounded-full cursor-pointer transition opacity-90 hover:opacity-100" title="微信">
                  <img :src="weixinIcon" alt="微信" class="w-full h-full object-contain" />
                </div>
                <div class="w-10 h-10 rounded-full cursor-pointer transition opacity-90 hover:opacity-100" title="抖音">
                  <img :src="douyinIcon" alt="抖音" class="w-full h-full object-contain" />
                </div>
                <div class="w-10 h-10 rounded-full cursor-pointer transition opacity-90 hover:opacity-100" title="QQ">
                  <img :src="qqIcon" alt="QQ" class="w-full h-full object-contain" />
                </div>
                <div class="w-10 h-10 rounded-full cursor-pointer transition opacity-90 hover:opacity-100" title="小红书">
                  <img :src="xiaohongshuIcon" alt="小红书" class="w-full h-full object-contain" />
                </div>
              </div>
            </div>
            <button class="w-full py-3 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white font-bold rounded-lg shadow-lg transition transform hover:-translate-y-0.5">
              导出并分发
            </button>
          </div>

        </div>
      </aside>
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

// 播放器增强功能
const playbackSpeed = ref(1)
const loopMode = ref(false)
const markers = ref([])
const hoverTime = ref(null)
const showTimeInput = ref(false)
const timeInputValue = ref('')
const showMarkersPanel = ref(false)
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

// 轨道数据
const tracks = ref([
  {
    id: 1,
    name: '主人声 A',
    type: '音频',
    color: 'bg-blue-500',
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
        name: '片段 1',
        start: 0,
        end: 1200,
        color: 'bg-gradient-to-r from-blue-500/80 to-blue-400/80 border-blue-400',
        fadeIn: true,
        fadeOut: false
      },
      {
        id: 2,
        name: '片段 2',
        start: 1212,
        end: 3600,
        color: 'bg-gradient-to-r from-blue-500/80 to-blue-400/80 border-blue-400',
        fadeIn: false,
        fadeOut: false
      }
    ]
  },
  {
    id: 2,
    name: '背景音乐',
    type: '音频',
    color: 'bg-orange-500',
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
        end: 3600,
        color: 'bg-gradient-to-r from-orange-500/80 to-orange-400/80 border-orange-400',
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

// 素材库 Mock Data (Feature 2)
const assets = ref([
  { id: 1, name: '原始录音_Track1.wav', type: 'audio', duration: '45:20', format: 'WAV' },
  { id: 2, name: '背景音乐_Jazz.mp3', type: 'audio', duration: '03:15', format: 'MP3' },
  { id: 3, name: 'Intro_Video.mp4', type: 'video', duration: '00:15', format: 'MP4' },
])

// 工具栏 Tabs
const activeToolTab = ref('edit')
const toolTabs = [
  { id: 'edit', name: '智能剪辑' },
  { id: 'enhance', name: '内容增值' },
  { id: 'export', name: '导出分发' }
]

const showLinkModal = ref(false)
const fileInput = ref(null)

// Methods
const formatTime = (seconds) => {
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
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
}

const seekToPercentage = (percentage) => {
  currentTime.value = Math.floor(audioDuration.value * percentage)
}

const skipForward = (seconds) => {
  currentTime.value = Math.min(audioDuration.value, currentTime.value + seconds)
}

const skipBackward = (seconds) => {
  currentTime.value = Math.max(0, currentTime.value - seconds)
}

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
  selectedClipId.value = clip.id
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
  // 同步时间轴标尺和轨道内容的滚动
  if (event && event.target) {
    const scrollLeft = event.target.scrollLeft
    if (timelineRuler.value) {
      timelineRuler.value.scrollLeft = scrollLeft
    }
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
  
  // 模拟数据：根据选择的策略返回不同的剪辑建议
  const allSamples = [
    { id: 1, t: '00:12-00:14', type: 'filler', preview: '嗯…这个…', tag: '口癖' },
    { id: 2, t: '01:03-01:05', type: 'stutter', preview: '我我我 觉得…', tag: '口吃' },
    { id: 3, t: '03:20-03:23', type: 'filler', preview: '就是说…然后…', tag: '口癖' },
    { id: 4, t: '05:41-05:44', type: 'stutter', preview: '那那 那个…', tag: '口吃' },
    { id: 5, t: '07:15-07:18', type: 'filler', preview: '呃…那个…', tag: '口癖' },
    { id: 6, t: '09:30-09:33', type: 'stutter', preview: '这这 这个…', tag: '口吃' }
  ]
  
  let filtered = []
  switch (cuttingStrategy.value) {
    case 'filler':
      // 只剪口癖
      filtered = allSamples.filter(s => s.type === 'filler')
      break
    case 'stutter':
      // 只剪口吃
      filtered = allSamples.filter(s => s.type === 'stutter')
      break
    case 'both':
      // 两者都剪
      filtered = allSamples.filter(s => s.type === 'filler' || s.type === 'stutter')
      break
    case 'all':
    default:
      // 一键全剪（包含所有类型）
      filtered = allSamples
      break
  }
  
  cutSuggestions.value = filtered.map(s => ({ 
    id: s.id, 
    label: `建议移除片段 ${s.t}`, 
    preview: s.preview, 
    tag: s.tag 
  }))
  
  buildSamplePreview()
  isGenerating.value = false
}

const buildSamplePreview = () => {
  const groups = [
    {
      id: 'g-filler',
      strategy: 'filler',
      label: 'AI 口癖剪辑',
      description: '只处理口癖（如：嗯、呃、这个、那个等语气词）',
      entries: [
        { id: 'e1', speaker: '说话人 1', time: '00:08-00:14', type: '口癖', content: '嗯，所以这个研究的路径吧，它聚焦在技术窗口、商业模式、竞争格局。', tags: [{ text: '嗯', type: '口癖' }, { text: '这个', type: '口癖' }] },
        { id: 'e2', speaker: '说话人 2', time: '00:36-00:41', type: '口癖', content: '然后呢，这个第四点呢就是说这个公司有独特的企业文化。', tags: [{ text: '然后呢', type: '口癖' }] }
      ]
    },
    {
      id: 'g-stutter',
      strategy: 'stutter',
      label: 'AI 口吃剪辑',
      description: '只处理口吃（如：重复字词、结巴等）',
      entries: [
        { id: 'e3', speaker: '说话人 3', time: '01:02-01:07', type: '口吃', content: '我我我觉得这个方向基本上就是，得先讲这四点。', tags: [{ text: '我我我', type: '口吃' }] },
        { id: 'e4', speaker: '说话人 1', time: '01:20-01:24', type: '口吃', content: '那那 那个问题，我们之后会统一说明。', tags: [{ text: '那那 那个', type: '口吃' }] }
      ]
    },
    {
      id: 'g-both',
      strategy: 'both',
      label: 'AI 口癖&口吃剪辑',
      description: '同时处理口癖和口吃，保留说话风格',
      entries: [
        { id: 'e5', speaker: '说话人 2', time: '02:10-02:16', type: '口癖', content: '就是说，我们可能需要补充的是，嗯，为什么产业更快发展。', tags: [{ text: '就是说', type: '口癖' }, { text: '嗯', type: '口癖' }] },
        { id: 'e6', speaker: '说话人 1', time: '02:40-02:45', type: '口吃', content: '所以所以 我们从这个角度再看一下整体逻辑。', tags: [{ text: '所以所以', type: '口吃' }] }
      ]
    },
    {
      id: 'g-all',
      strategy: 'all',
      label: 'AI 全剪辑',
      description: '一键全剪，处理所有冗余内容',
      entries: [
        { id: 'e7', speaker: '说话人 1', time: '03:03-03:10', type: '口癖', content: '其实就是那个，嗯，核心观点我们总结过几次。', tags: [{ text: '那个', type: '口癖' }, { text: '嗯', type: '口癖' }] },
        { id: 'e8', speaker: '说话人 3', time: '03:25-03:31', type: '口吃', content: '我我 我们这期就到这里，后面再展开。', tags: [{ text: '我我', type: '口吃' }] }
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
  
  goldenSentences.value = [
    {
      id: 1,
      content: '职场焦虑主要来源于对未来的不确定性，以及工作压力带来的心理负担。',
      startTime: 1250,
      endTime: 1350,
      viralPotential: 92,
      logicScore: 95
    },
    {
      id: 2,
      content: '应对职场焦虑，我建议可以从时间管理、心理调节和职业规划三个方面入手。',
      startTime: 3420,
      endTime: 3520,
      viralPotential: 88,
      logicScore: 90
    },
    {
      id: 3,
      content: '职场焦虑的根源其实很复杂，既有外部环境因素，也有个人心理因素，需要综合看待。',
      startTime: 5670,
      endTime: 5780,
      viralPotential: 85,
      logicScore: 88
    }
  ]
  
  isExtracting.value = false
}

// 生成 Shownotes
const generateShownotes = async () => {
  if (isGeneratingShownotes.value) return
  
  isGeneratingShownotes.value = true
  await new Promise(resolve => setTimeout(resolve, 2000))
  
  shownotesData.value = {
    chapters: [
      {
        id: 1,
        title: '开场：职场焦虑的普遍现象',
        summary: '讨论职场焦虑在当代社会中的普遍性，以及它对个人工作和生活的影响。',
        startTime: 0,
        endTime: 1200
      },
      {
        id: 2,
        title: '职场焦虑的根源分析',
        summary: '深入分析职场焦虑产生的内外因素，包括工作压力、未来不确定性等。',
        startTime: 1200,
        endTime: 3600
      },
      {
        id: 3,
        title: '应对策略：时间管理与心理调节',
        summary: '提供实用的应对方法，包括时间管理技巧和心理调节策略。',
        startTime: 3600,
        endTime: 5400
      },
      {
        id: 4,
        title: '职业规划与长期发展',
        summary: '探讨如何通过职业规划来减少焦虑，实现长期职业发展目标。',
        startTime: 5400,
        endTime: 7200
      }
    ],
    mindMap: `职场焦虑应对
├── 问题识别
│   ├── 普遍现象
│   └── 影响分析
├── 根源分析
│   ├── 外部因素
│   │   ├── 工作压力
│   │   └── 环境变化
│   └── 内部因素
│       ├── 心理状态
│       └── 认知模式
└── 解决方案
    ├── 时间管理
    ├── 心理调节
    └── 职业规划`
  }
  
  isGeneratingShownotes.value = false
}

// 生成视频播客
const generateVideoPodcast = async () => {
  if (selectedSentences.length === 0 || isGeneratingVideo.value) return
  
  isGeneratingVideo.value = true
  await new Promise(resolve => setTimeout(resolve, 3000))
  
  const selected = goldenSentences.value.filter(s => selectedSentences.value.includes(s.id))
  
  generatedVideos.value = selected.map((sentence, index) => ({
    id: index + 1,
    title: `金句片段 ${index + 1}: ${sentence.content.substring(0, 20)}...`,
    duration: `${Math.floor((sentence.endTime - sentence.startTime) / 60)}:${String((sentence.endTime - sentence.startTime) % 60).padStart(2, '0')}`,
    template: videoTemplate.value,
    sentenceId: sentence.id
  }))
  
  isGeneratingVideo.value = false
}

// 跳转到指定时间
const seekToTime = (timeInSeconds) => {
  currentTime.value = timeInSeconds
  // 这里可以添加实际的音频跳转逻辑
  console.log('跳转到时间:', formatTime(timeInSeconds))
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
  width: 6px;
  height: 6px;
}
::-webkit-scrollbar-track {
  background: transparent;
}
::-webkit-scrollbar-thumb {
  background: #FF6B9D;
  border-radius: 3px;
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

