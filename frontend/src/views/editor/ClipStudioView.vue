<template>
  <div class="h-screen bg-white flex flex-col overflow-hidden">
    <!-- 1. 顶部导航 & 用户管理 (Feature 1, 6) -->
    <header class="h-16 border-b border-pink-200 bg-gradient-to-r from-pink-50 to-purple-50 px-6 flex items-center justify-between sticky top-0 z-50">
      <div class="flex items-center gap-4">
        <h1 class="text-xl font-bold bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent tracking-tight">PodPal Studio</h1>
        <div class="h-6 w-px bg-pink-200 mx-2"></div>
        <div class="flex items-center gap-2 text-sm text-gray-600 hover:text-pink-600 cursor-pointer transition">
          <span>{{ currentProject.name || '未命名项目' }}</span>
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" /></svg>
        </div>
        <span
          v-if="activeToolTab === 'edit'"
          class="text-xs px-2 py-0.5 rounded bg-blue-100 text-blue-700 border border-blue-300 inline-flex items-center gap-1.5"
        >
          <span class="w-1.5 h-1.5 rounded-full bg-blue-500"></span>
          {{ autoSaveStatus }}
        </span>
      </div>
      
      <div class="flex items-center gap-6">
        <!-- 删除顶部“+”按钮 -->
        
        <!-- 用户菜单 (Feature 1) -->
        <div class="flex items-center gap-3 pl-6 border-l border-pink-200">
          <div class="text-right hidden md:block">
            <div class="text-sm text-gray-900">Podpal</div>
            <div class="text-xs text-gray-600">个人账号</div>
          </div>
          <div class="w-9 h-9 rounded-full bg-gradient-to-br from-blue-500 to-cyan-500 flex items-center justify-center text-white font-semibold">P</div>
        </div>
      </div>
    </header>

    <div class="flex-1 flex overflow-hidden">
      <!-- 垂直流程导航栏 -->
      <nav ref="stepNavRef" class="w-20 flex-none bg-white border-r border-pink-100 flex flex-col items-center py-8 gap-10 relative">
        <!-- 进度背景线（置于图标下方且不响应事件） -->
        <div class="absolute left-1/2 w-0.5 bg-pink-50 -translate-x-1/2 z-0 pointer-events-none" :style="navProgressTrackStyle">
          <div
            class="absolute top-0 w-full bg-gradient-to-b from-[#FF6B9D] to-[#C084FC] rounded-full"
            :style="navProgressFillStyle"
          ></div>
        </div>

        <!-- 步骤节点 -->
        <div 
          v-for="(tab, i) in toolTabs" 
          :key="tab.id"
          :ref="el => setStepNodeRef(el, i)"
          @click="handleTabClick(tab)"
          class="relative z-20 flex flex-col items-center gap-2 cursor-pointer group"
          :class="{ 'opacity-40 cursor-not-allowed pointer-events-none': tab.id !== 'upload' && !hasUploaded }"
        >
          <!-- 图标容器 -->
          <div class="relative">
            <div 
              class="w-12 h-12 rounded-2xl flex items-center justify-center transition-all duration-300 border-2 relative z-30"
              :class="[
                i < stepIndex ? 'bg-gradient-to-br from-[#F7C6DA] to-[#E4C5FA] border-transparent text-white shadow-sm shadow-pink-100' : i === stepIndex ? 'bg-gradient-to-br from-[#FF6B9D] to-[#C084FC] border-transparent text-white shadow-lg shadow-pink-100' : 'bg-white border-pink-100 text-pink-300 group-hover:border-pink-300',
                activeToolTab === tab.id ? 'scale-110' : 'hover:scale-105'
              ]"
            >
              <div v-html="tab.icon"></div>
            </div>
            <div
              v-if="tab.id !== 'upload' && !hasUploaded"
              class="absolute -right-1 -bottom-1 flex h-5 w-5 items-center justify-center rounded-full border border-pink-200 bg-white text-pink-500 shadow-sm"
              title="请先上传素材解锁"
            >
              <svg class="h-3 w-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 11V7a4 4 0 10-8 0v4m-.5 0h9a1 1 0 011 1v8a1 1 0 01-1 1h-9a1 1 0 01-1-1v-8a1 1 0 011-1z" />
              </svg>
            </div>
          </div>
          <!-- 标签 -->
          <span 
            class="text-[10px] font-bold tracking-tighter transition-colors text-center px-1"
            :class="i <= stepIndex ? 'text-pink-600' : 'text-gray-400'"
          >
            {{ tab.name }}
          </span>
        </div>
      </nav>

      <!-- 2. 左侧：根据当前标签页显示不同内容 -->
      <aside
        class="relative border-r border-pink-200 flex flex-col overflow-hidden transition-all duration-300"
        :class="((activeToolTab === 'edit' && isAssetSidebarCollapsed) || ((activeToolTab === 'enhance' || activeToolTab === 'export') && isWorkSidebarCollapsed)) ? 'w-16 flex-none' : 'w-80 flex-none'"
      >
        <button
          v-if="activeToolTab === 'edit'"
          class="absolute top-4 right-1 z-20 flex h-8 w-8 items-center justify-center rounded-full border border-pink-200 bg-white/95 text-pink-600 shadow-sm transition hover:bg-pink-50 hover:text-pink-700"
          :title="isAssetSidebarCollapsed ? '展开素材库' : '收起素材库'"
          @click="toggleAssetSidebar"
        >
          <svg class="h-4 w-4 transition-transform duration-300" :class="isAssetSidebarCollapsed ? 'rotate-180' : ''" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </button>
        <!-- 素材库 (上传素材和智能剪辑标签页显示) -->
        <div
          v-show="activeToolTab === 'upload' || activeToolTab === 'edit'"
          class="h-full bg-gradient-to-b from-pink-50 to-purple-50 flex flex-col overflow-hidden transition-opacity duration-300"
          :class="activeToolTab === 'edit' && isAssetSidebarCollapsed ? 'opacity-0 pointer-events-none select-none' : 'opacity-100'"
        >
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

          <!-- 分类标签筛选 -->
          <div class="px-4 py-3 border-b border-pink-200 bg-white/50">
            <div class="flex items-center justify-between mb-2">
              <span class="text-xs font-semibold text-gray-600">分类筛选</span>
              <button @click="showAddCategoryModal = true" class="text-xs text-pink-600 hover:text-pink-700 flex items-center gap-1">
                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" /></svg>
                自定义
              </button>
            </div>
            <div class="flex flex-wrap gap-2">
              <button
                v-for="cat in assetCategories"
                :key="cat"
                @click="selectedCategory = cat"
                class="px-3 py-1.5 text-xs rounded-full transition"
                :class="selectedCategory === cat ? 'bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white shadow-md' : 'bg-white text-gray-600 border border-pink-200 hover:border-pink-300'"
              >
                {{ cat }}
              </button>
            </div>
          </div>

          <!-- 素材列表 -->
          <div class="flex-1 overflow-y-auto p-4 space-y-2">
            <div 
              v-for="asset in filteredAssets" 
              :key="asset.id" 
              class="relative p-3 bg-white rounded-lg border border-pink-200 hover:border-pink-300 hover:bg-pink-50 cursor-pointer group transition-all duration-200"
              @click="selectAsset(asset)"
              draggable="true"
              @dragstart="handleAssetDragStart($event, asset)"
            >
              <!-- 多选复选框 -->
              <label class="absolute top-2 left-2 w-4 h-4 flex items-center justify-center rounded-sm border border-pink-300 bg-white shadow-sm">
                <input type="checkbox" class="appearance-none w-3 h-3 rounded-sm bg-white border border-pink-300 checked:bg-pink-500 checked:border-pink-500"
                       :checked="selectedAssetIds.includes(asset.id)"
                       @click.stop="toggleAssetSelect(asset)" />
              </label>
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
                    <div class="text-xs text-gray-600 mt-0.5">
                      {{ asset.duration }}
                      <span v-if="asset.category" class="ml-2 px-1.5 py-0.5 text-[10px] rounded border bg-gray-50 text-gray-600 border-gray-200">{{ asset.category }}</span>
                    </div>
                  </div>
                </div>
                <button 
                  class="p-1.5 text-gray-600 hover:text-blue-600 hover:bg-blue-50 rounded opacity-0 group-hover:opacity-100 transition"
                  @click.stop="playAsset(asset)"
                  :title="asset.playing ? '暂停预听' : '预听'"
                >
                  <svg v-if="!asset.playing" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-8.197-4.905A1 1 0 005 7.105v9.79a1 1 0 001.555.832l8.197-4.905a1 1 0 000-1.664z" />
                  </svg>
                  <svg v-else class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 9v6m4-6v6" />
                  </svg>
                </button>
                <button 
                  class="p-1.5 text-gray-600 hover:text-pink-600 hover:bg-pink-100 rounded opacity-0 group-hover:opacity-100 transition"
                  @click.stop="showAssetMenu(asset)"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
                  </svg>
                </button>
              </div>
              <!-- AI 摘要与关键词 -->
              <div class="mt-2 space-y-1">
                <div class="flex items-center justify-between">
                  <span class="text-[10px] text-gray-500">AI 摘要</span>
                  <div class="flex items-center gap-1">
                    <button class="text-[10px] px-1.5 py-0.5 rounded border border-yellow-300 bg-yellow-50 text-yellow-700 hover:bg-yellow-100"
                            @click.stop="generateAssetMeta(asset)">AI 生成</button>
                    <button class="text-[10px] px-1.5 py-0.5 rounded border border-gray-200 bg-white text-gray-600 hover:bg-gray-50"
                            @click.stop="asset.editingSummary = !asset.editingSummary">{{ asset.editingSummary ? '收起' : '编辑' }}</button>
                  </div>
                </div>
                <div v-if="!asset.editingSummary" class="text-[11px] text-gray-800 leading-snug">
                  {{ asset.summary || '（暂无摘要）' }}
                </div>
                <div v-else class="flex items-center gap-2">
                  <input v-model="asset.summary" class="flex-1 text-[11px] border border-pink-200 rounded px-2 py-1" placeholder="编辑摘要..." />
                  <button class="text-[10px] px-2 py-0.5 rounded bg-pink-500 text-white" @click.stop="asset.editingSummary=false">保存</button>
                </div>
                <div class="flex flex-wrap gap-1">
                  <span v-for="t in asset.tags" :key="t" class="text-[10px] px-1.5 py-0.5 rounded border bg-pink-50 text-pink-700 border-pink-200">#{{ t }}</span>
                </div>
              </div>
              <div v-if="asset.type === 'audio' && asset.url" class="mt-2" @click.stop>
                <!-- 自定义播放器（按素材显示固定总时长） -->
                <div v-if="asset.id === 1 || asset.id === 2" class="bg-gray-100/70 rounded-full px-3 py-2 flex items-center gap-3">
                  <button
                    class="w-8 h-8 rounded-full bg-white flex items-center justify-center shadow-sm hover:shadow transition"
                    @click.stop="toggleInlineAssetAudio(asset)"
                    :title="asset.playing ? '暂停' : '播放'"
                  >
                    <svg v-if="!asset.playing" class="w-4 h-4 text-gray-800 ml-0.5" fill="currentColor" viewBox="0 0 20 20">
                      <path d="M6.3 2.841A1.5 1.5 0 004 4.11V15.89a1.5 1.5 0 002.3 1.269l9.344-5.89a1.5 1.5 0 000-2.538L6.3 2.84z" />
                    </svg>
                    <svg v-else class="w-4 h-4 text-gray-800" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zM7 8a1 1 0 012 0v4a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v4a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
                    </svg>
                  </button>

                  <div class="flex-1 min-w-0">
                    <input
                      type="range"
                      class="w-full accent-pink-500"
                      :min="0"
                      :max="Math.max(0.01, (assetAudioMeta[asset.id]?.duration || 0.01))"
                      :step="0.01"
                      :value="assetAudioMeta[asset.id]?.currentTime || 0"
                      @input="(e) => seekInlineAssetAudio(asset, Number(e.target.value))"
                    />
                    <div class="flex justify-between text-[10px] text-gray-600 mt-1 font-mono">
                      <span>{{ formatTime(getScaledAssetTime(asset.id, assetAudioMeta[asset.id]?.currentTime || 0)) }}</span>
                      <span>{{ formatTime(getFixedAssetTotalSeconds(asset.id)) }}</span>
                    </div>
                  </div>

                  <audio
                    :ref="el => setAssetAudioRef(el, asset.id)"
                    :src="asset.url"
                    preload="metadata"
                    class="hidden"
                    @loadedmetadata="handleAssetAudioMetadata(asset)"
                    @timeupdate="handleAssetAudioTimeUpdate(asset)"
                    @play="handleAssetAudioPlay(asset)"
                    @pause="handleAssetAudioPause(asset)"
                    @ended="handleAssetAudioEnded(asset)"
                    @error="handleAssetAudioError(asset)"
                  ></audio>
                </div>

                <!-- 其他素材：保留原生控件 -->
                <audio
                  v-else
                  :ref="el => setAssetAudioRef(el, asset.id)"
                  :src="asset.url"
                  controls
                  preload="metadata"
                  class="w-full h-8"
                  @play="handleAssetAudioPlay(asset)"
                  @pause="handleAssetAudioPause(asset)"
                  @ended="handleAssetAudioEnded(asset)"
                  @error="handleAssetAudioError(asset)"
                ></audio>
              </div>
              <div class="flex items-center justify-between text-xs mt-2 pt-2 border-t border-pink-100">
                <div class="flex items-center gap-2">
                  <span class="text-gray-600">{{ asset.duration }}</span>
                  <span v-if="asset.used" class="px-1.5 py-0.5 rounded bg-emerald-100 text-emerald-700 border border-emerald-200">已使用</span>
                </div>
                <span class="bg-pink-100 px-2 py-0.5 rounded text-pink-700 border border-pink-200">{{ asset.format }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 作品仓库 (内容增值和导出分发标签页显示) -->
        <div
          v-show="activeToolTab === 'enhance' || activeToolTab === 'export'"
          class="relative h-full bg-white flex flex-col overflow-hidden transition-all duration-300"
          :class="isWorkSidebarCollapsed ? 'w-16 flex-none' : 'w-80 flex-none'"
        >
          <button
            class="absolute top-4 right-1 z-20 flex h-8 w-8 items-center justify-center rounded-full border border-pink-200 bg-white/95 text-pink-600 shadow-sm transition hover:bg-pink-50 hover:text-pink-700"
            :title="isWorkSidebarCollapsed ? '展开作品仓库' : '收起作品仓库'"
            @click="toggleWorkSidebar"
          >
            <svg class="h-4 w-4 transition-transform duration-300" :class="isWorkSidebarCollapsed ? 'rotate-180' : ''" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          <div class="p-4 border-b border-pink-200 bg-gradient-to-r from-pink-50 to-purple-50 transition-opacity duration-300" :class="isWorkSidebarCollapsed ? 'opacity-0 pointer-events-none select-none' : 'opacity-100'">
            <h2 class="text-sm font-semibold text-gray-700 uppercase tracking-wider flex items-center gap-2">
              <svg class="w-4 h-4 text-pink-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
              </svg>
              作品仓库
            </h2>
            <p class="text-xs text-gray-500 mt-1">剪辑工作台导出的成品音频</p>
          </div>
          
          <!-- 作品列表 -->
          <div class="flex-1 overflow-y-auto p-4 space-y-3 transition-opacity duration-300" :class="isWorkSidebarCollapsed ? 'opacity-0 pointer-events-none select-none' : 'opacity-100'">
            <!-- 当前项目成品 -->
            <div v-if="currentProjectExport" class="p-3 bg-gradient-to-r from-pink-50 to-purple-50 rounded-lg border-2 border-pink-300 cursor-pointer hover:shadow-md transition"
                 @click="selectWork(currentProjectExport)"
                 :class="{ 'ring-2 ring-pink-500': selectedWork?.id === currentProjectExport.id }">
              <div class="flex items-start gap-3">
                <div class="w-10 h-10 rounded-lg bg-gradient-to-br from-[#FF6B9D] to-[#C084FC] flex items-center justify-center flex-shrink-0">
                  <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" />
                  </svg>
                </div>
                <div class="flex-1 min-w-0">
                  <div class="text-sm font-medium text-gray-900 truncate">{{ currentProjectExport.name }}</div>
                  <div class="text-xs text-gray-500 mt-0.5">{{ PROJECT_DURATION_TEXT }}</div>
                  <div class="flex items-center gap-2 mt-1">
                    <span class="text-[10px] px-1.5 py-0.5 bg-pink-100 text-pink-600 rounded">当前项目</span>
                    <span class="text-[10px] text-gray-400">{{ currentProjectExport.exportTime }}</span>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 历史作品 -->
            <div class="text-xs font-semibold text-gray-500 uppercase tracking-wider mt-4 mb-2">历史作品</div>
            <div v-for="work in workRepository" :key="work.id" 
                 class="p-3 bg-gray-50 rounded-lg border border-gray-200 cursor-pointer hover:border-pink-300 hover:bg-pink-50 transition"
                 @click="selectWork(work)"
                 :class="{ 'ring-2 ring-pink-400 bg-pink-50 border-pink-300': selectedWork?.id === work.id }">
              <div class="flex items-start gap-3">
                <div class="w-10 h-10 rounded-lg bg-gray-200 flex items-center justify-center flex-shrink-0">
                  <svg class="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" />
                  </svg>
                </div>
                <div class="flex-1 min-w-0">
                  <div class="text-sm font-medium text-gray-900 truncate">{{ work.name }}</div>
                  <div class="text-xs text-gray-500 mt-0.5">{{ work.duration }}</div>
                  <div class="text-[10px] text-gray-400 mt-1">{{ work.exportTime }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </aside>

      <!-- 自定义分类弹窗 -->
      <div v-if="showAddCategoryModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
        <div class="bg-white rounded-xl shadow-2xl w-[400px] p-6 border border-pink-200">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-bold text-gray-900">添加自定义分类</h3>
            <button class="text-gray-400 hover:text-gray-600" @click="showAddCategoryModal = false">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
          </div>
          <div class="space-y-3">
            <input 
              v-model="newCategoryName" 
              @keyup.enter="addCustomCategory"
              type="text" 
              placeholder="请输入分类名称"
              class="w-full px-3 py-2 text-sm border border-pink-200 rounded-lg focus:ring-2 focus:ring-pink-300 outline-none"
            />
            <div class="space-y-2">
              <div class="text-xs text-gray-500">现有自定义分类（可删除）：</div>
              <div class="flex flex-wrap gap-2">
                <button
                  v-for="cat in assetCategories.filter(c => !['全部', '人声', '背景音', '效果音'].includes(c))"
                  :key="cat"
                  class="px-2 py-1 text-xs rounded-full bg-pink-100 text-pink-700 border border-pink-200 flex items-center gap-1"
                >
                  {{ cat }}
                  <svg @click.stop="deleteCategory(cat)" class="w-3 h-3 cursor-pointer hover:text-pink-900" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                  </svg>
                </button>
              </div>
            </div>
          </div>
          <div class="flex justify-end gap-2 mt-4">
            <button class="px-4 py-2 text-sm rounded-lg border border-gray-200 hover:bg-gray-50 text-gray-700" @click="showAddCategoryModal = false">取消</button>
            <button 
              @click="addCustomCategory"
              class="px-4 py-2 text-sm rounded-lg bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white hover:shadow-lg"
              :disabled="!newCategoryName.trim()"
              :class="{ 'opacity-50 cursor-not-allowed': !newCategoryName.trim() }"
            >
              添加
            </button>
          </div>
        </div>
      </div>

      <!-- 3. 中间：工作区 (Feature 3, 9) -->
      <main class="flex-1 min-w-0 flex flex-col bg-white overflow-hidden relative transition-all duration-300">
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
                    <div class="text-sm text-gray-900 mb-2">点击选择文件，或将左侧素材拖拽到此处</div>
                    <div class="text-xs text-gray-500">支持: mp3, wav, m4a, mp4, mov</div>
                  </div>
                  <input ref="inlineFileInput" type="file" accept="audio/*,video/*" class="hidden" @change="handleInlineSelect">
                  <div class="flex items-center justify-between">
                    <button
                      class="px-3 py-1.5 text-xs text-white rounded transition"
                      :class="(inlinePendingFile || selectedAssetIds.length > 0) ? 'bg-blue-500 hover:bg-blue-600' : 'bg-gray-300 cursor-not-allowed'"
                      :disabled="!inlinePendingFile && selectedAssetIds.length === 0"
                      @click="confirmInlineUpload"
                    >
                      确认上传素材<span v-if="!inlinePendingFile && selectedAssetIds.length > 0">（已选{{ selectedAssetIds.length }}）</span>
                    </button>
                    <span class="text-xs text-gray-500">
                      {{ inlinePendingFile ? `已选择: ${inlinePendingFile.name}` : (selectedAssetIds.length > 0 ? `已勾选素材: ${selectedAssetIds.length} 个` : '完成后将自动进入智能剪辑') }}
                    </span>
                  </div>
                  <div v-if="selectedUploadAssets.length" class="space-y-2 rounded-lg border border-pink-100 bg-white/80 p-3">
                    <div class="flex items-center justify-between">
                      <span class="text-xs font-semibold text-gray-700">上传列表</span>
                      <span class="text-[11px] text-gray-500">拖入的素材会出现在这里</span>
                    </div>
                    <div class="space-y-2 max-h-40 overflow-y-auto pr-1">
                      <div
                        v-for="asset in selectedUploadAssets"
                        :key="asset.id"
                        class="flex items-center justify-between gap-3 rounded-lg border border-pink-100 bg-pink-50/40 px-3 py-2"
                      >
                        <div class="min-w-0">
                          <div class="truncate text-sm font-medium text-gray-900">{{ asset.name }}</div>
                          <div class="text-[11px] text-gray-500">{{ asset.duration }} · {{ asset.category || '未分类' }}</div>
                        </div>
                        <button
                          class="shrink-0 rounded-full border border-pink-200 bg-white px-2 py-1 text-[11px] text-pink-600 hover:bg-pink-50"
                          @click="removeQueuedUploadAsset(asset.id)"
                        >
                          移除
                        </button>
                      </div>
                    </div>
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
              
              <section v-if="isTranscribing" class="bg-white rounded-xl border border-pink-200 shadow-sm overflow-hidden p-6">
                <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                  <span class="w-1 h-4 bg-pink-500 rounded-full"></span>
                  前置预处理进度
                </h3>
                <div class="space-y-2">
                  <div class="flex items-center justify-between text-xs">
                    <span class="text-pink-700 font-medium">{{ transcriptionStatus }}</span>
                    <span class="text-pink-500 font-mono">{{ Math.round(transcriptionProgress) }}%</span>
                  </div>
                  <div class="h-2 w-full bg-pink-100 rounded-full overflow-hidden">
                    <div
                      class="h-full bg-gradient-to-r from-pink-500 to-purple-500 transition-all duration-300"
                      :style="{ width: transcriptionProgress + '%' }"
                    ></div>
                  </div>
                  <p class="text-[11px] text-gray-500">正在进行素材前置处理，请稍候...</p>
                </div>
              </section>
           </div>
           
           <!-- 预处理小弹窗 -->
           <div v-if="showPreprocessModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
             <div class="bg-white rounded-xl shadow-2xl w-[560px] p-6 border border-pink-200">
               <div class="flex items-center justify-between mb-3">
                 <h3 class="text-lg font-bold text-gray-900">{{ preprocessRunning ? '前置处理进行中' : '上传完成 · 前置预处理' }}</h3>
                 <button class="text-gray-400 hover:text-gray-600" @click="cancelPreprocessAndClose" :disabled="preprocessRunning">
                   <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
                 </button>
               </div>
               <div v-if="!preprocessRunning" class="space-y-3">
                 <label class="flex items-center gap-3 p-3 border border-pink-200 rounded-lg bg-pink-50/30">
                   <input type="checkbox" v-model="preTranscribe" class="rounded border-pink-300 text-pink-600 focus:ring-pink-500">
                   <div class="flex-1">
                     <div class="text-sm text-gray-900 font-medium">语音转写</div>
                     <div class="text-[11px] text-gray-600">说话人分离、情绪提取、关键词</div>
                   </div>
                 </label>
                 <div class="p-3 border border-pink-200 rounded-lg bg-pink-50/30">
                   <div class="text-sm text-gray-900 font-medium mb-2">音质增强</div>
                   <div class="flex items-center gap-2">
                     <label class="flex items-center gap-2 text-xs text-gray-700">
                       <input type="checkbox" v-model="preVoiceEnhance" class="rounded border-pink-300 text-pink-600 focus:ring-pink-500"> 人声增强
                     </label>
                     <label class="flex items-center gap-2 text-xs text-gray-700">
                       <input type="checkbox" v-model="preEchoRemoval" class="rounded border-pink-300 text-pink-600 focus:ring-pink-500"> 去回声
                     </label>
                   </div>
                 </div>
               </div>
               <div class="flex justify-end gap-2 mt-4">
                 <button class="px-3 py-1.5 text-sm rounded border border-gray-200 hover:bg-gray-50 text-gray-700" @click="runFastPreprocessProgress" :disabled="preprocessRunning">跳过</button>
                 <button class="px-4 py-1.5 text-sm rounded bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white hover:shadow-lg" @click="startPreprocess">开始处理</button>
               </div>
             </div>
           </div>
        </div>
        <!-- Editor View -->
        <div v-show="activeToolTab === 'edit'" class="flex-1 min-h-0 flex flex-col overflow-hidden relative" ref="editorColumn">
        <!-- 播放器预览 -->
        <div class="flex-1 min-h-0 p-6 flex flex-col relative bg-gradient-to-b from-white via-pink-50/30 to-white" :class="transcriptRepairing ? 'blur-sm' : ''">
          <!-- 视图切换按钮 -->
          <div class="flex items-center justify-between mb-4">
            <div class="flex items-center gap-2">
              <button
                class="px-3 py-1.5 text-sm rounded-lg transition bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white"
              >
                📝 文字稿
              </button>

            </div>

          </div>

          <!-- 波形可视化区域 -->


          <!-- 文字稿区域（可编辑 & 口癖高亮） -->
          <div ref="transcriptContainer" class="transcript-scroll flex-1 bg-white rounded-lg border border-pink-200 p-4 overflow-y-auto relative"
               @mouseup="handleTextSelection">
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
                <span class="w-2 h-2 rounded bg-rose-100 border border-rose-200"></span>
                异常停顿
              </span>
              <span class="flex items-center gap-1">
                <span class="w-2 h-2 rounded bg-blue-100 border border-blue-200"></span>
                正常停顿
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
                  :key="segment.uid"
                  :ref="el => setSegmentRef(el, index)"
                  class="group relative"
                >

                <!-- AI 总结卡片 -->
                <div v-if="isSummaryStart(index)" class="mb-4 rounded-xl bg-white border-2 border-blue-200 shadow-[0_8px_24px_-12px_rgba(59,130,246,0.55)] overflow-hidden ring-1 ring-blue-100">
                  <div class="h-1 bg-gradient-to-r from-blue-500 via-cyan-400 to-sky-300"></div>
                  <div class="px-3 py-2 border-b border-blue-100 bg-gradient-to-r from-blue-50/70 to-cyan-50/60">
                    <div class="flex items-center gap-3">
                      <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-500 to-cyan-400 flex items-center justify-center flex-shrink-0 shadow-md shadow-blue-200">
                        <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
                        </svg>
                      </div>
                      <div class="flex items-center gap-2 flex-wrap">
                        <span class="text-xs font-bold text-blue-700 bg-white border border-blue-200 px-2 py-0.5 rounded-full shadow-sm">AI 总结</span>
                        <span class="text-xs text-gray-600">第 {{ getAISummaryForSegment(index).sectionNumber }} 部分</span>
                        <span class="text-xs text-gray-400 font-mono">{{ formatTime(getAISummaryForSegment(index).timestamp) }}</span>
                      </div>
                    </div>
                  </div>
                  <div class="p-3 bg-white">
                    <div class="text-sm text-gray-800 leading-relaxed">
                      {{ getAISummaryForSegment(index).summary }}
                    </div>
                  </div>
                </div>
                
                <div 
                  class="p-3 rounded-lg cursor-pointer transition-all duration-200"
                  :class="[
                    isCurrentSegment(segment) ? 'bg-gradient-to-r from-pink-100 to-purple-100 border-l-4 border-pink-500' : getSpeakerBgColor(segment.speaker),
                    isSegmentHighlighted(index) ? 'ring-2 ring-pink-400 ring-inset' : '',
                    segment.isGolden ? 'bg-gradient-to-r from-yellow-50 to-orange-50 border-l-4 border-yellow-500' : '',
                    segment.text.startsWith('[TTS]') && !segment.confirmed ? 'border border-dashed border-blue-300' : '',
                    segment.text.startsWith('[TTS]') && segment.confirmed ? 'border border-blue-200' : '',
                    segment.isNew ? 'animate-highlightNew' : ''
                  ]"
                  @click="seekToTime(segment.startTime)"
                >
                
                <div class="flex items-center justify-between mb-1">
                  <div class="flex items-center gap-2">
                    <span class="text-xs text-gray-500 font-mono">{{ formatTime(segment.startTime) }} - {{ formatTime(segment.endTime) }}</span>
                    <span v-if="segment.text.startsWith('[TTS]')" class="text-[10px] bg-blue-500 text-white px-1.5 rounded">TTS</span>
                    <span v-if="segment.voiceLabGenerated" class="text-[10px] bg-purple-500 text-white px-1.5 rounded">声演生成</span>
                    <span v-if="segment.isGolden" class="text-[10px] bg-yellow-200 text-yellow-800 px-1.5 rounded">已收藏</span>
                    <span v-if="deletedCount(segment.text) > 0" class="text-[10px] bg-red-100 text-red-700 px-1.5 rounded">已留痕</span>
                    <!-- AI 建议图标 -->
                    <button 
                      v-if="hasAIRecommendations(segment)"
                      @click.stop="showAIRecommendations(segment, $event)"
                      class="relative text-amber-500 hover:text-amber-600 transition"
                      title="AI 优化建议"
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                      </svg>
                    </button>
                  </div>
                  <div class="flex items-center gap-2">
                    <button
                      @click.stop="toggleGoldenSentence(segment, index)"
                      class="p-1 rounded transition"
                      :class="segment.isGolden ? 'text-yellow-600 hover:bg-yellow-100' : 'text-gray-400 hover:text-yellow-600 hover:bg-yellow-50'"
                      :title="segment.isGolden ? '取消收藏' : '收藏为金句'"
                    >
                      <svg class="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M12 17.27l5.18 3.04-1.64-5.81L20 9.24l-5.9-.5L12 3.5 9.9 8.74 4 9.24l4.46 5.26-1.64 5.81L12 17.27z" />
                      </svg>
                    </button>
                    <button 
                      @click.stop="insertTTS(index)"
                      class="hidden group-hover:flex text-[10px] text-pink-500 hover:text-pink-700 font-medium"
                    >+ 插入补录</button>
                    <button 
                      v-if="segment.text.startsWith('[TTS]')"
                      @click.stop="deleteTTSSegment(index)"
                      class="hidden group-hover:flex text-[10px] text-red-500 hover:text-red-700 font-medium"
                    >删除补录</button>
                    <!-- 说话人编辑 -->
                    <div class="relative">
                      <span 
                        v-if="!segment.editingSpeaker" 
                        class="text-xs px-2 py-0.5 rounded-full cursor-pointer hover:opacity-80" 
                        :class="getSpeakerColorClass(segment.speaker)"
                        @click="segment.editingSpeaker = true"
                      >
                        {{ segment.speaker === 'AI' ? 'AI 合成' : segment.speaker || '说话人' }}
                      </span>
                      <div v-else class="flex items-center gap-1">
                        <input 
                          v-model="segment.speaker" 
                          class="text-xs px-2 py-0.5 rounded border border-gray-300 focus:outline-none focus:ring-1 focus:ring-pink-500 w-24"
                          @blur="segment.editingSpeaker = false"
                          @keyup.enter="segment.editingSpeaker = false"
                          @keyup.esc="segment.editingSpeaker = false"
                        />
                        <button 
                          class="text-[10px] text-green-600 hover:text-green-800"
                          @click="segment.editingSpeaker = false"
                        >
                          <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                          </svg>
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
                
                <!-- 增强的文本编辑模式 (仅针对 TTS) -->
                <div 
                  v-if="editingSegmentId === index && segment.text.startsWith('[TTS]') && !segment.isEditing"
                  class="mt-1"
                >
                  <textarea
                    v-model="segment.text"
                    v-focus
                    class="w-full text-sm text-gray-900 leading-relaxed bg-white border border-blue-300 rounded-md px-2 py-1 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
                    rows="3"
                    @click.stop
                    @blur="confirmTTS(index)"
                  />
                  <div v-if="segment.warning" class="mt-2">
                    <div v-if="segment.warning" class="mr-auto text-[10px] text-amber-600 flex items-center gap-1">
                      <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                      </svg>
                      {{ segment.warning }}
                    </div>
                  </div>
                </div>

                <!-- 精准编辑模式（支持键盘增删改） -->
                <div 
                  v-else-if="editingSegmentId === index && !segment.isEditing"
                  class="mt-1"
                >
                  <textarea
                    v-model="editingSegmentDraft"
                    v-focus
                    class="w-full text-sm text-gray-900 leading-relaxed bg-white border border-pink-300 rounded-md px-2 py-1 focus:outline-none focus:ring-2 focus:ring-pink-300 resize-none"
                    rows="3"
                    @click.stop
                    @blur="saveSegmentEditing(index)"
                    @keydown="onSegmentEditorKeydown($event, index)"
                  />
                </div>

                <!-- 新插入的文字稿编辑模式 -->
                <div 
                  v-else-if="editingSegmentId === index && segment.isEditing"
                  class="mt-1"
                >
                  <textarea
                    v-model="segment.text"
                    v-focus
                    class="w-full text-sm text-gray-900 leading-relaxed bg-white border border-blue-300 rounded-md px-2 py-1 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
                    rows="3"
                    @click.stop
                    @blur="confirmNewInlineEdit(index)"
                  />
                  <div class="mt-2 flex justify-end gap-2">
                    <button 
                      @click.stop="deleteNewSegment(index)"
                      class="px-3 py-1.5 text-xs text-red-500 hover:bg-red-100 rounded"
                    >删除</button>
                  </div>
                </div>

                <!-- 预览模式（点击进入删除模式；口癖/已删除仍可单点切换） -->
                <div 
                  v-else
                  class="mt-1 text-sm leading-relaxed min-h-[1.5rem] whitespace-pre-wrap"
                  :class="segment.speaker === 'AI' ? 'text-blue-800 italic' : 'text-gray-900'"
                >
                  <!-- 克隆语音标识 -->
                  <div v-if="segment.isCloned" class="flex items-center gap-2 mb-1">
                    <span class="text-[10px] px-1.5 py-0.5 rounded bg-gradient-to-r from-pink-100 to-purple-100 text-pink-700 border border-pink-200">
                      {{ segment.voiceName || 'AI语音' }}
                    </span>
                    <button 
                      @click.stop="editClonedSegment(index)"
                      class="text-[10px] text-orange-500 hover:text-orange-700 hover:bg-orange-50 px-1.5 py-0.5 rounded transition"
                    >
                      编辑
                    </button>
                  </div>
                  <template v-for="(token, tIndex) in parseSegmentText(segment.text)" :key="tIndex">
                    <!-- 口癖 Token -->
                    <span 
                      v-if="token.type === 'filler'" 
                      @click="toggleTokenDelete(segment, tIndex)"
                      :data-token-index="tIndex"
                      class="inline-flex items-center mx-0.5 px-1 py-0.5 rounded bg-yellow-100 text-yellow-800 border border-yellow-200 cursor-pointer hover:bg-yellow-200 transition"
                    >
                      {{ token.text }}
                    </span>
                    <!-- 口吃 Token -->
                    <span 
                      v-else-if="token.type === 'stutter'"
                      @click="toggleTokenDelete(segment, tIndex)"
                      :data-token-index="tIndex"
                      class="inline-flex items-center mx-0.5 px-1 py-0.5 rounded bg-purple-100 text-purple-800 border border-purple-200 cursor-pointer hover:bg-purple-200 transition"
                    >
                      {{ token.text }}
                    </span>
                    <!-- 停顿 Token -->
                    <span
                      v-else-if="token.type === 'pause'"
                      @click="toggleTokenDelete(segment, tIndex)"
                      :data-token-index="tIndex"
                      class="inline-flex items-center mx-0.5 px-1.5 py-0.5 rounded border cursor-pointer transition gap-1"
                      :class="getPauseTokenMeta(segment, tIndex)?.isAbnormal
                        ? 'bg-rose-100 text-rose-800 border-rose-200 hover:bg-rose-200'
                        : 'bg-blue-100 text-blue-900 border-blue-200 hover:bg-blue-200'"
                      :title="getPauseTokenMeta(segment, tIndex)?.title"
                    >
                      <span class="text-[10px] font-semibold">{{ getPauseTokenMeta(segment, tIndex)?.label }}</span>
                      <span class="text-[10px] font-mono opacity-80">{{ getPauseTokenMeta(segment, tIndex)?.durationText }}</span>
                    </span>
                    <!-- 已删除 Token -->
                    <span 
                      v-else-if="token.type === 'deleted'"
                      :data-token-index="tIndex"
                      class="mx-0.5 text-gray-400 transition"
                    >
                      <span
                        v-for="(deletedChar, cIndex) in Array.from(token.text)"
                        :key="`${tIndex}-${cIndex}`"
                        class="inline-block cursor-pointer line-through decoration-red-400 decoration-2 hover:text-gray-600 rounded px-0.5"
                        :class="getDeletionHighlightClass(index)"
                        @click.stop="restoreDeletedChar(segment, tIndex, cIndex)"
                      >
                        {{ deletedChar }}
                      </span>
                    </span>
                    <!-- 修正后的 Token -->
                    <span 
                      v-else-if="token.type === 'corrected'"
                      @click="toggleTokenDelete(segment, tIndex)"
                      :data-token-index="tIndex"
                      class="inline-flex items-center mx-0.5 px-1 py-0.5 rounded bg-green-100 text-green-800 border border-green-200 cursor-pointer hover:bg-green-200 transition"
                      title="点击撤回此项逻辑优化建议"
                    >
                      <svg class="w-3 h-3 mr-1 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                      {{ token.text }}
                    </span>
                    <!-- 空白 Token -->
                    <span 
                      v-else-if="token.type === 'space'"
                      :data-token-index="tIndex"
                      @click="startSegmentEditing(index)"
                    >{{ token.text }}</span>
                    <!-- 普通文本 Token -->
                    <span 
                      v-else
                      :data-token-index="tIndex"
                      @click="startSegmentEditing(index)"
                      class="cursor-pointer hover:bg-pink-100/50 rounded px-0.5 transition"
                    >
                      {{ token.text }}
                    </span>
                  </template>
                </div>
              </div>
              </div>
            </div>
          </div>
          <div
            v-if="transcriptRepairing"
            class="absolute inset-0 z-20 flex items-center justify-center pointer-events-none"
          >
            <div class="px-4 py-2 text-sm text-white bg-black/50 rounded-lg backdrop-blur-sm">后期大师正在修复中...</div>
          </div>
          
        </div>

        <!-- 底部控制区（恢复） -->
        <div class="flex-none border-t border-pink-200 bg-white px-6 py-4">
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
              <span class="text-xs text-gray-500 px-2 py-1 bg-pink-50 rounded">
                剩余: {{ formatTime(audioDuration - currentTime) }}
              </span>
            </div>
            <div class="flex items-center gap-3">
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
              <button
                @click="loopMode = !loopMode"
                class="p-1.5 text-gray-600 hover:text-pink-600 hover:bg-pink-100 rounded transition"
                :class="{ 'text-pink-600 bg-pink-100': loopMode }"
                title="循环播放"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                </svg>
              </button>
              <div class="relative">
                <button
                  @click="toggleBookmarkForCurrentSegment"
                  class="p-1.5 text-gray-600 hover:text-pink-600 hover:bg-pink-100 rounded transition"
                  title="为当前对话添加/取消书签"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
                  </svg>
                </button>
                <button
                  @click="showMarkersPanel = !showMarkersPanel"
                  class="ml-1 px-2 py-1 text-[10px] border border-pink-200 rounded text-gray-600 hover:bg-pink-50"
                  :class="markers.length ? 'bg-pink-50 text-pink-700' : ''"
                  title="查看书签列表"
                >
                  书签{{ markers.length ? `(${markers.length})` : '' }}
                </button>
                <div
                  v-if="showMarkersPanel"
                  class="absolute right-0 top-full mt-2 w-72 max-h-64 overflow-y-auto bg-white border border-pink-200 rounded-lg shadow-xl z-30 p-2"
                >
                  <div v-if="!markers.length" class="text-xs text-gray-500 p-2">暂无书签</div>
                  <button
                    v-for="marker in markers"
                    :key="marker.id"
                    @click="jumpToBookmark(marker)"
                    class="w-full text-left p-2 rounded hover:bg-pink-50 flex items-start justify-between gap-2"
                  >
                    <span class="text-xs text-gray-700">
                      <span class="font-mono text-pink-600 mr-2">{{ formatTime(marker.time) }}</span>
                      {{ marker.label }}
                    </span>
                    <span class="text-[10px] text-gray-400">跳转</span>
                  </button>
                </div>
              </div>
              <button
                @click="saveAndGoToContentEnhance"
                :disabled="isSavingToEnhance"
                class="px-3 py-1.5 text-xs rounded-lg text-white bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] hover:shadow-lg transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-1.5"
                title="保存并前往内容增值工作台"
              >
                <svg v-if="isSavingToEnhance" class="w-3.5 h-3.5 animate-spin" viewBox="0 0 24 24" fill="none">
                  <circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="2" class="opacity-30"></circle>
                  <path d="M21 12a9 9 0 0 0-9-9" stroke="currentColor" stroke-width="2" stroke-linecap="round"></path>
                </svg>
                <span>{{ isSavingToEnhance ? '保存中...' : '保存并去内容增值' }}</span>
              </button>
            </div>
          </div>

          <div class="relative mb-4">
            <div
              class="relative h-[3px] bg-pink-100 rounded-full overflow-visible cursor-pointer group flex items-center"
              @click="seekTo"
              @mousemove="onProgressHover"
              @mouseleave="hoverTime = null"
              @mousedown="startSelection"
            >
              <div
                class="absolute inset-y-0 left-0 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] rounded-full transition-all duration-100"
                :style="{ width: (currentTime / audioDuration * 100) + '%' }"
              ></div>
              <div
                v-for="marker in markers"
                :key="marker.id"
                class="absolute top-0 bottom-0 w-0.5 bg-yellow-400 z-10 cursor-pointer hover:bg-yellow-500 transition shadow-sm"
                :style="{ left: (marker.time / audioDuration * 100) + '%' }"
                :title="marker.label || formatTime(marker.time)"
                @click.stop="seekToTime(marker.time)"
              ></div>
            </div>
            <div class="flex items-center justify-between mt-1 text-[10px] text-gray-500">
              <span>开始</span>
              <span>结束</span>
            </div>
          </div>

          <div class="flex items-center justify-center gap-6">
            <button
              @click="skipBackward(5)"
              class="p-2.5 text-gray-600 hover:text-pink-600 hover:bg-pink-100 rounded-lg transition"
              title="后退5秒"
            >
              <span class="text-[10px] text-gray-500 block">-5s</span>
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
              <span class="text-[10px] text-gray-500 block">+5s</span>
            </button>
          </div>
        </div>

        </div>

        <!-- Content Enhancement View -->
        <div v-if="activeToolTab === 'enhance'" class="flex-1 bg-gray-50 flex flex-col">
          <!-- 右侧：内容增值工作台 -->
          <div class="flex-1 p-3">
            <div class="w-full max-w-6xl mx-auto space-y-3">
               <div class="flex items-center justify-between">
                  <div>
                    <h2 class="text-xl font-bold text-gray-900">内容增值工作台</h2>
                    <p class="text-xs text-gray-500 mt-0.5">利用 AI 为您的播客创造更多价值</p>
                  </div>
                  <button @click="showPublishPreview = true" class="px-3 py-1.5 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg transition flex items-center gap-2 text-sm">
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                    </svg>
                    模拟发布预览
                  </button>
               </div>
               
               <!-- 标签页导航 -->
               <div class="flex items-center gap-1 bg-white/60 p-1 rounded-lg border border-pink-200 sticky top-0 z-10">
                 <button 
                     class="flex-1 px-3 py-1.5 text-sm font-medium rounded border transition"
                   :class="openEnhancePanel==='shownotes' ? 'bg-white border-pink-300 text-pink-600 shadow-sm' : 'border-transparent text-gray-600 hover:bg-pink-50'"
                   @click="openEnhancePanel='shownotes'"
                 >
                   智能 Shownotes
                 </button>
                 <button 
                     class="flex-1 px-3 py-1.5 text-sm font-medium rounded border transition"
                   :class="openEnhancePanel==='video' ? 'bg-white border-pink-300 text-pink-600 shadow-sm' : 'border-transparent text-gray-600 hover:bg-pink-50'"
                   @click="openEnhancePanel='video'"
                 >
                   视频播客生成
                 </button>
                 <button 
                     class="flex-1 px-3 py-1.5 text-sm font-medium rounded border transition"
                   :class="openEnhancePanel==='social' ? 'bg-white border-pink-300 text-pink-600 shadow-sm' : 'border-transparent text-gray-600 hover:bg-pink-50'"
                   @click="openEnhancePanel='social'"
                 >
                   多平台文案
                 </button>
               </div>
               
               <!-- 1. Shownotes 生成 -->
               <section v-show="openEnhancePanel==='shownotes'" class="bg-white rounded-xl border border-pink-200 shadow-sm p-2">
                  <div class="flex items-center gap-2 mb-2">
                    <div class="w-6 h-6 rounded-full bg-purple-100 flex items-center justify-center text-purple-600">
                      <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" /></svg>
                    </div>
                    <div>
                      <h3 class="text-base font-bold text-gray-900">智能 Shownotes</h3>
                      <p class="text-xs text-gray-500">一键生成标题、摘要、时间戳和思维导图</p>
                    </div>
                  </div>
                  
                  <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                     <!-- 生成选项 -->
                     <div class="space-y-2">
                        <div>
                          <label class="block text-sm font-medium text-gray-700 mb-1">播客类型</label>
                          <select v-model="podcastType" class="w-full rounded-lg border-gray-300 border p-2 text-sm focus:ring-2 focus:ring-pink-300 focus:border-pink-300">
                            <option value="interview">访谈对话</option>
                            <option value="knowledge">知识分享</option>
                            <option value="companion">情感陪伴</option>
                            <option value="story">故事叙述</option>
                          </select>
                          <p class="mt-1 text-[11px] text-gray-500">AI 已自动识别并提取为「访谈对话」，可按需手动调整。</p>
                        </div>
                        
                        <div>
                           <label class="block text-sm font-medium text-gray-700 mb-1">包含内容</label>
                           <div class="space-y-1.5">
                             <label class="flex items-center gap-2 text-sm text-gray-600">
                               <input type="checkbox" checked class="rounded border-gray-300 text-pink-600 focus:ring-pink-500">
                               SEO 优化标题 (5个备选)
                             </label>
                             <label class="flex items-center gap-2 text-sm text-gray-600">
                               <input type="checkbox" checked class="rounded border-gray-300 text-pink-600 focus:ring-pink-500">
                              内容摘要
                             </label>
                             <label class="flex items-center gap-2 text-sm text-gray-600">
                               <input type="checkbox" checked class="rounded border-gray-300 text-pink-600 focus:ring-pink-500">
                              时间戳
                             </label>
                           </div>
                        </div>

                        <button 
                          @click="generateShownotes"
                          :disabled="isGeneratingShownotes"
                          class="w-full py-2 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-lg hover:shadow-lg transition font-medium disabled:opacity-50 flex items-center justify-center gap-2 text-sm"
                        >
                           <svg v-if="isGeneratingShownotes" class="animate-spin h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                             <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                             <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                           </svg>
                           {{ isGeneratingShownotes ? 'AI 正在生成...' : '立即生成 Shownotes' }}
                        </button>
                     </div>

                     <!-- 结果预览（可滚动，确保完整显示） -->
                     <div class="bg-gray-50 rounded-lg border border-gray-200 p-2 min-h-[350px] max-h-[520px] overflow-y-auto">
                        <div v-if="!shownotesData" class="h-full flex flex-col items-center justify-center text-gray-400">
                           <svg class="w-10 h-10 mb-2 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" /></svg>
                           <span class="text-sm">点击生成查看结果</span>
                        </div>
                        <div v-else class="space-y-3 animate-fadeIn">
                           <!-- 音频播放器 -->
                           <div class="bg-white rounded-lg border border-gray-200 p-2">
                             <div class="flex items-center gap-2">
                               <button @click="toggleAudioPlay" class="w-7 h-7 rounded-full bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white flex items-center justify-center hover:shadow-md transition">
                                 <svg v-if="!isAudioPlaying" class="w-3.5 h-3.5 ml-0.5" fill="currentColor" viewBox="0 0 20 20">
                                   <path d="M6.3 2.841A1.5 1.5 0 004 4.11V15.89a1.5 1.5 0 002.3 1.269l9.344-5.89a1.5 1.5 0 000-2.538L6.3 2.84z" />
                                 </svg>
                                 <svg v-else class="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 20 20">
                                   <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zM7 8a1 1 0 012 0v4a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v4a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
                                 </svg>
                               </button>
                               <div class="flex-1">
                                 <div class="h-1.5 bg-gray-200 rounded-full overflow-hidden cursor-pointer" @click="seekAudioProgress">
                                   <div class="h-full bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] rounded-full transition-all" :style="{ width: audioProgress + '%' }"></div>
                                 </div>
                                 <div class="flex justify-between text-[10px] text-gray-500 mt-1">
                                   <span>{{ formatTime(currentAudioTime) }}</span>
                                   <span>{{ PROJECT_DURATION_TEXT }}</span>
                                 </div>
                               </div>
                             </div>
                           </div>
                           
                           <div class="space-y-2">
                              <h4 class="text-xs font-bold text-gray-500 uppercase flex items-center justify-between">
                                 推荐标题
                                 <button @click="addNewTitle" class="text-xs text-pink-600 hover:text-pink-800 flex items-center gap-1">
                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" /></svg>
                                    添加
                                 </button>
                              </h4>
                              <div class="space-y-1">
                                 <div v-for="(title, idx) in shownotesData.titles" :key="idx" class="p-2 bg-white border border-gray-200 rounded text-sm text-gray-800 hover:border-pink-300 transition flex items-center justify-between group">
                                    <input 
                                       v-if="editingTitleIndex === idx"
                                       v-model="shownotesData.titles[idx]"
                                       @blur="editingTitleIndex = -1"
                                       @keydown.enter="editingTitleIndex = -1"
                                       class="flex-1 text-sm border-none outline-none bg-transparent"
                                       v-focus
                                    />
                                    <span v-else @click="editingTitleIndex = idx" class="flex-1 cursor-text">{{ title }}</span>
                                    <div class="flex items-center gap-1">
                                       <button @click="editingTitleIndex = idx" class="text-xs text-gray-400 hover:text-pink-600 opacity-0 group-hover:opacity-100">
                                          <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" /></svg>
                                       </button>
                                       <button @click="copyText(title)" class="text-xs text-pink-600 opacity-0 group-hover:opacity-100">复制</button>
                                       <button @click="deleteTitle(idx)" class="text-xs text-red-400 hover:text-red-600 opacity-0 group-hover:opacity-100">
                                          <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
                                       </button>
                                    </div>
                                 </div>
                              </div>
                           </div>
                           <div class="space-y-2">
                              <h4 class="text-xs font-bold text-gray-500 uppercase">摘要</h4>
                              <textarea 
                                 v-if="editingSummary"
                                 v-model="shownotesData.summary"
                                 @blur="editingSummary = false"
                                 class="w-full text-sm text-gray-700 bg-white p-3 rounded border border-pink-300 leading-relaxed resize-none"
                                 rows="4"
                              ></textarea>
                              <p 
                                 v-else 
                                 @click="editingSummary = true"
                                 class="text-sm text-gray-700 bg-white p-3 rounded border border-gray-200 leading-relaxed cursor-text hover:border-pink-300 transition"
                              >{{ shownotesData.summary }}</p>
                           </div>
                           <div v-if="shownotesData.timeline && shownotesData.timeline.length > 0" class="space-y-2">
                              <h4 class="text-xs font-bold text-gray-500 uppercase flex items-center justify-between">
                                 节目时间轴
                                 <button @click="addNewTimelineItem" class="text-xs text-pink-600 hover:text-pink-800 flex items-center gap-1">
                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" /></svg>
                                    添加
                                 </button>
                              </h4>
                              <div class="space-y-2">
                                 <div v-for="(item, idx) in shownotesData.timeline" :key="idx" 
                                    class="flex gap-3 group hover:bg-white p-2 rounded transition-colors border border-transparent hover:border-pink-100"
                                 >
                                    <div 
                                       class="flex-none font-mono text-xs text-pink-600 font-bold bg-pink-50 px-2 py-0.5 rounded h-fit group-hover:bg-pink-100 cursor-pointer"
                                       @click="seekToTime(item.seconds)"
                                       title="点击跳转到对应位置"
                                    >
                                       {{ item.timestamp }}
                                    </div>
                                    <div class="flex-1 space-y-0.5">
                                       <input 
                                          v-if="editingTimelineIndex === idx"
                                          v-model="shownotesData.timeline[idx].topic"
                                          @blur="editingTimelineIndex = -1"
                                          @keydown.enter="editingTimelineIndex = -1"
                                          class="w-full text-xs font-bold text-gray-800 border-none outline-none bg-transparent"
                                          v-focus
                                       />
                                       <div v-else @click="editingTimelineIndex = idx" class="text-xs font-bold text-gray-800 cursor-text">{{ item.topic }}</div>
                                       <input 
                                          v-if="editingTimelineDescIndex === idx"
                                          v-model="shownotesData.timeline[idx].description"
                                          @blur="editingTimelineDescIndex = -1"
                                          @keydown.enter="editingTimelineDescIndex = -1"
                                          class="w-full text-[10px] text-gray-500 leading-relaxed border-none outline-none bg-transparent"
                                          v-focus
                                       />
                                       <div v-else @click="editingTimelineDescIndex = idx" class="text-[10px] text-gray-500 leading-relaxed cursor-text">{{ item.description }}</div>
                                    </div>
                                    <div class="flex items-center gap-1 opacity-0 group-hover:opacity-100">
                                       <button @click="editingTimelineIndex = idx" class="text-xs text-gray-400 hover:text-pink-600">
                                          <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" /></svg>
                                       </button>
                                       <button @click="deleteTimelineItem(idx)" class="text-xs text-red-400 hover:text-red-600">
                                          <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
                                       </button>
                                    </div>
                                 </div>
                              </div>
                           </div>
                           <div class="pt-2 flex items-center justify-between border-t border-gray-100 mt-4">
                              <button @click="showMindMap = true" class="text-sm text-purple-600 hover:text-purple-800 flex items-center gap-1">
                                 <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0121 18.382V7.618a1 1 0 01-.553-.894L15 7m0 13V7" /></svg>
                                 查看思维导图
                              </button>
                              <button @click="copyFullShownotes" class="text-xs bg-gray-100 text-gray-600 hover:bg-pink-50 hover:text-pink-600 px-3 py-1.5 rounded-lg transition flex items-center gap-1.5">
                                 <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3" /></svg>
                                 复制完整 Shownotes
                              </button>
                           </div>
                        </div>
                     </div>
                  </div>
               </section>

             <!-- 2. 视频化与分发 -->
             <div class="grid grid-cols-1 md:grid-cols-2 gap-2">
                <!-- 视频播客生成 -->
                <section v-show="openEnhancePanel==='video'" class="bg-white rounded-xl border border-pink-200 shadow-sm p-2">
                   <div class="flex items-center gap-2 mb-1.5">
                      <div class="w-6 h-6 rounded-full bg-blue-100 flex items-center justify-center text-blue-600">
                         <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" /></svg>
                      </div>
                      <div>
                         <h3 class="text-base font-bold text-gray-900">视频播客生成</h3>
                         <p class="text-xs text-gray-500">将音频转化为短视频，抢占视频平台流量</p>
                      </div>
                   </div>
                   
                   <div class="space-y-2">
                      <div class="grid grid-cols-2 gap-2">
                         <div 
                           class="p-2 border rounded-lg cursor-pointer transition hover:border-pink-400"
                           :class="videoTemplate === 'digital-human' ? 'border-pink-500 bg-pink-50' : 'border-gray-200'"
                           @click="videoTemplate = 'digital-human'"
                         >
                            <div class="text-sm font-medium text-gray-900 mb-1">AI 数字人口播</div>
                            <div class="text-xs text-gray-500">根据音频口型驱动数字人</div>
                         </div>

                      </div>
                      
                      <div class="bg-gray-50 p-2 rounded border border-gray-200">
                         <div class="flex items-center justify-between mb-1.5">
                           <div class="text-xs text-gray-500">选择金句片段</div>
                           <div class="text-[10px] text-pink-500">来自前面剪辑的金句池</div>
                         </div>
                         <div v-if="videoSentenceCandidates.length" class="space-y-2">
                           <button
                             v-for="(s, index) in videoSentenceCandidates"
                             :key="s.id ?? index"
                             @click="toggleSelectedSentence(s)"
                             class="w-full rounded-lg border p-2 text-left transition"
                             :class="selectedSentences.includes(s.id) ? 'bg-blue-500 text-white border-blue-600 shadow-sm' : 'bg-white text-gray-700 border-gray-200 hover:border-pink-300 hover:bg-pink-50'"
                           >
                             <div class="flex items-start justify-between gap-2">
                               <div class="min-w-0 flex-1">
                                 <div class="text-[11px] font-medium leading-snug line-clamp-2">{{ s.content }}</div>
                                 <div class="mt-1 flex items-center gap-2 text-[10px]" :class="selectedSentences.includes(s.id) ? 'text-blue-50' : 'text-gray-500'">
                                   <span>{{ s.sourceLabel }}</span>
                                   <span>·</span>
                                   <span>{{ s.durationLabel }}</span>
                                 </div>
                               </div>
                               <span class="flex-none rounded-full px-1.5 py-0.5 text-[10px] font-medium" :class="selectedSentences.includes(s.id) ? 'bg-white/20 text-white' : 'bg-gray-100 text-gray-600'">
                                 {{ index + 1 }}
                               </span>
                             </div>
                           </button>
                         </div>
                         <div v-else class="rounded-lg border border-dashed border-gray-200 bg-white px-3 py-4 text-xs text-gray-500">
                           先在前面的剪辑区收藏金句，视频播客会自动在这里引用。
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
                      <div v-if="generatedVideos.length" class="space-y-1.5 pt-2 border-t border-gray-100">
                        <div class="text-xs font-medium text-gray-900">已生成视频</div>
                        <div v-for="(video, idx) in generatedVideos" :key="video.id" class="flex gap-2 p-2 bg-gray-50 rounded border border-gray-200 hover:border-pink-200 transition group">
                            <div class="w-16 h-12 rounded overflow-hidden flex-shrink-0 relative cursor-pointer" @click="previewVideo(video)">
                              <!-- 这里变成真正的视频！-->
                          <video 
                            src="/src/assets/show.mp4"  class="w-full h-full object-cover" muted>
                          </video>
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
                   <!-- 视频预览弹窗（真视频，已替换） -->
<div v-if="showVideoPreview" class="fixed inset-0 z-50 flex items-center justify-center bg-black/70">
  <div class="bg-white rounded-lg w-full max-w-2xl overflow-hidden">
    <div class="p-4 flex justify-between items-center border-b">
      <h3 class="font-bold text-gray-800">视频预览</h3>
      <button @click="showVideoPreview = false" class="text-gray-500 text-xl">×</button>
    </div>

    <!-- ✅ 这里是真视频！！！ -->
    <video 
      src="/src/assets/show.mp4" 
      controls 
      class="w-full h-auto"
      autoplay
      muted
    ></video>

    <div class="p-3 flex justify-end gap-2">
      <button @click="showVideoPreview = false" class="px-4 py-2 bg-gray-100 rounded">关闭</button>
    </div>
  </div>
</div>
                </section>

                <!-- 社交媒体文案 -->
                <section v-show="openEnhancePanel==='social'" class="bg-white rounded-xl border border-pink-200 shadow-sm p-2">
                   <div class="flex items-center gap-2 mb-1.5">
                      <div class="w-6 h-6 rounded-full bg-green-100 flex items-center justify-center text-green-600">
                         <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" /></svg>
                      </div>
                      <div>
                         <h3 class="text-base font-bold text-gray-900">多平台文案</h3>
                         <p class="text-xs text-gray-500">针对不同平台调性生成推广文案</p>
                      </div>
                   </div>
                   
                   <div class="space-y-2">
                      <div class="flex gap-1.5 border-b border-gray-100 pb-2">
                         <button 
                           @click="socialPlatform = 'wechat'"
                           class="px-2.5 py-1 text-xs rounded-full transition"
                           :class="socialPlatform === 'wechat' ? 'bg-green-100 text-green-700' : 'text-gray-600 hover:bg-gray-50'"
                         >公众号</button>
                         <button 
                           @click="socialPlatform = 'xiaohongshu'"
                           class="px-2.5 py-1 text-xs rounded-full transition"
                           :class="socialPlatform === 'xiaohongshu' ? 'bg-red-100 text-red-700' : 'text-gray-600 hover:bg-gray-50'"
                         >小红书</button>
                         <button 
                           @click="socialPlatform = 'weibo'"
                           class="px-2.5 py-1 text-xs rounded-full transition"
                           :class="socialPlatform === 'weibo' ? 'bg-blue-100 text-blue-700' : 'text-gray-600 hover:bg-gray-50'"
                         >微博</button>
                      </div>
                      <div class="relative">
                        <textarea 
                          v-model="currentSocialCopy"
                          class="w-full h-64 p-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-green-200 focus:border-green-400 resize-none" 
                          :placeholder="isGeneratingCopy ? 'AI 正在思考中...' : 'AI 将在此生成适配该平台的推广文案...'"
                          :disabled="isGeneratingCopy"
                        ></textarea>
                        <div v-if="isGeneratingCopy" class="absolute inset-0 bg-white/50 flex items-center justify-center">
                          <svg class="animate-spin h-5 w-5 text-green-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
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
                          {{ currentSocialCopy ? '重新生成' : '立即生成' }}
                         </button>
                         <button 
                           @click="copySocialCopy"
                          :disabled="!currentSocialCopy"
                           class="px-3 py-1.5 text-xs bg-green-500 text-white rounded hover:bg-green-600 disabled:opacity-50 disabled:bg-gray-300"
                         >
                           复制文案
                         </button>
                         <button 
                          @click="openPublishPreviewForCurrentPlatform"
                          :disabled="!hasAnySocialCopy"
                           class="px-3 py-1.5 text-xs bg-gradient-to-r from-pink-500 to-purple-500 text-white rounded hover:shadow-md transition disabled:opacity-50 disabled:bg-gray-300"
                         >
                           预览效果
                         </button>
                      </div>
                   </div>
                </section>
             </div>

               <!-- MindMap Modal -->
               <div v-if="showMindMap" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm" @click.self="showMindMap = false">
                  <div class="bg-white rounded-xl shadow-2xl w-[900px] h-[700px] flex flex-col overflow-hidden animate-scaleIn">
                     <div class="flex items-center justify-between p-4 border-b border-gray-100">
                        <h3 class="text-lg font-bold text-gray-900">思维导图编辑</h3>
                        <div class="flex items-center gap-2">
                           <button @click="addMindMapNode" class="text-xs text-pink-600 hover:text-pink-800 flex items-center gap-1 px-3 py-1.5 rounded-lg hover:bg-pink-50 transition">
                              <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" /></svg>
                              添加节点
                           </button>
                           <button @click="showMindMap = false" class="text-gray-400 hover:text-gray-600">
                              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
                           </button>
                        </div>
                     </div>
                     <div class="flex-1 bg-gray-50 p-6 overflow-auto flex items-center justify-center">
                        <!-- Simple CSS Mindmap Visualization with Edit -->
                        <div class="flex flex-col items-center gap-8">
                           <!-- Root Node -->
                           <div 
                              class="bg-pink-100 text-pink-700 px-6 py-3 rounded-lg font-bold border border-pink-200 shadow-sm cursor-text hover:border-pink-400 transition"
                              @click="editingMindMapRoot = true"
                           >
                              <input 
                                 v-if="editingMindMapRoot"
                                 v-model="shownotesData.mindmap.root"
                                 @blur="editingMindMapRoot = false"
                                 @keydown.enter="editingMindMapRoot = false"
                                 class="bg-transparent border-none outline-none text-center text-pink-700 font-bold"
                                 v-focus
                              />
                              <span v-else>{{ shownotesData.mindmap?.root || 'AI 播客创作' }}</span>
                           </div>
                           <div class="flex gap-12 relative">
                              <!-- Connector Lines (Simplified) -->
                              <div class="absolute top-[-2rem] left-1/2 -translate-x-1/2 w-[80%] h-8 border-t-2 border-l-2 border-r-2 border-gray-300 rounded-t-xl"></div>
                              
                              <div v-for="(node, idx) in shownotesData.mindmap?.children" :key="idx" class="flex flex-col items-center gap-4 relative group">
                                  <div class="w-0.5 h-4 bg-gray-300 absolute -top-4"></div>
                                  <div class="bg-white border border-gray-200 px-4 py-2 rounded-lg font-medium shadow-sm text-sm text-center min-w-[100px] hover:border-pink-300 transition">
                                     <input 
                                        v-if="editingMindMapNode === idx"
                                        v-model="shownotesData.mindmap.children[idx].label"
                                        @blur="editingMindMapNode = -1"
                                        @keydown.enter="editingMindMapNode = -1"
                                        class="w-full text-center border-none outline-none bg-transparent font-medium"
                                        v-focus
                                     />
                                     <div v-else @click="editingMindMapNode = idx" class="cursor-text">{{ node.label }}</div>
                                     <div v-if="node.time" class="text-xs text-gray-400 mt-0.5 cursor-pointer hover:text-pink-600" @click="seekToTime(parseTimeToSeconds(node.time))">
                                        {{ node.time }}
                                     </div>
                                  </div>
                                  <button 
                                     @click="deleteMindMapNode(idx)"
                                     class="absolute -top-2 -right-2 w-5 h-5 bg-red-100 text-red-500 rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition hover:bg-red-200"
                                  >
                                     <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
                                  </button>
                                  <div v-if="node.children" class="flex flex-col gap-2 relative pt-4">
                                     <div class="w-0.5 h-4 bg-gray-300 absolute top-0 left-1/2 -translate-x-1/2"></div>
                                     <div v-for="(child, cIdx) in node.children" :key="cIdx" class="bg-gray-50 border border-gray-100 px-3 py-1.5 rounded text-xs text-gray-600 flex flex-col items-center gap-0.5 min-w-[80px] hover:border-pink-200 transition group/child">
                                        <input 
                                           v-if="editingMindMapChild === `${idx}-${cIdx}`"
                                           v-model="shownotesData.mindmap.children[idx].children[cIdx].label"
                                           @blur="editingMindMapChild = ''"
                                           @keydown.enter="editingMindMapChild = ''"
                                           class="w-full text-center border-none outline-none bg-transparent text-xs"
                                           v-focus
                                        />
                                        <span v-else @click="editingMindMapChild = `${idx}-${cIdx}`" class="cursor-text">{{ child.label }}</span>
                                        <span v-if="child.time" class="text-[10px] text-gray-400 cursor-pointer hover:text-pink-600" @click="seekToTime(parseTimeToSeconds(child.time))">{{ child.time }}</span>
                                        <button 
                                           @click="deleteMindMapChild(idx, cIdx)"
                                           class="absolute -top-1 -right-1 w-4 h-4 bg-red-100 text-red-500 rounded-full flex items-center justify-center opacity-0 group-hover/child:opacity-100 transition hover:bg-red-200"
                                        >
                                           <svg class="w-2 h-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
                                        </button>
                                     </div>
                                     <button 
                                        @click="addMindMapChild(idx)"
                                        class="text-[10px] text-pink-600 hover:text-pink-800 flex items-center justify-center gap-0.5 py-1"
                                     >
                                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" /></svg>
                                        添加子节点
                                     </button>
                                  </div>
                               </div>
                           </div>
                        </div>
                     </div>
                     <div class="p-4 border-t border-gray-100 flex justify-end gap-2 bg-gray-50">
                        <button @click="exportMindMapImage" class="px-4 py-2 text-sm text-gray-600 hover:bg-gray-200 rounded-lg">导出图片</button>
                        <button @click="exportMindMapPDF" class="px-4 py-2 text-sm bg-pink-500 text-white rounded-lg hover:bg-pink-600 shadow-sm">导出 PDF</button>
                     </div>
                  </div>
               </div>

               <!-- Video Preview Modal - 真视频版本（缩小版） -->
<div v-if="showVideoPreview" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm" @click.self="showVideoPreview = false">
  <div class="bg-white rounded-xl shadow-2xl w-[480px] flex flex-col overflow-hidden animate-scaleIn">
    <div class="flex items-center justify-between p-3 border-b border-gray-100">
      <h3 class="text-base font-bold text-gray-900">视频预览</h3>
      <button @click="showVideoPreview = false" class="text-gray-400 hover:text-gray-600">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
      </button>
    </div>

    <!-- 真视频区域 -->
    <div class="aspect-video bg-black">
      <video 
        src="/src/assets/show.mp4" 
        controls 
        class="w-full h-full object-cover"
        autoplay
        muted
      ></video>
    </div>

    <div class="p-3 border-t border-gray-100 flex justify-end gap-2 bg-gray-50">
      <button class="px-3 py-1.5 text-sm text-gray-600 hover:bg-gray-200 rounded-lg">下载视频</button>
      <button class="px-3 py-1.5 text-sm bg-pink-500 text-white rounded-lg hover:bg-pink-600 shadow-sm">分享</button>
    </div>
  </div>
</div>

               <!-- 模拟发布预览 Modal -->
               <div v-if="showPublishPreview" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm" @click.self="showPublishPreview = false">
                  <div class="bg-white rounded-xl shadow-2xl w-[900px] h-[700px] flex flex-col overflow-hidden animate-scaleIn">
                     <div class="flex items-center justify-between p-4 border-b border-gray-100 bg-gradient-to-r from-pink-50 to-purple-50">
                        <div class="flex items-center gap-3">
                           <h3 class="text-lg font-bold text-gray-900">模拟发布预览</h3>
                           <span class="text-xs text-gray-500">预览各平台真实发布效果</span>
                        </div>
                        <div class="flex items-center gap-2">
                           <button @click="generateShareLink" class="px-3 py-1.5 text-xs bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-md transition flex items-center gap-1">
                              <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                 <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" />
                              </svg>
                              生成分享链接
                           </button>
                           <button @click="showPublishPreview = false" class="text-gray-400 hover:text-gray-600">
                              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
                           </button>
                        </div>
                     </div>
                     
                     <!-- 平台切换标签 -->
                     <div class="flex items-center gap-1 p-3 border-b border-gray-100 bg-gray-50">
                        <button 
                          v-for="platform in previewPlatforms" 
                          :key="platform.id"
                          @click="currentPreviewPlatform = platform.id"
                          class="px-4 py-2 text-sm rounded-lg transition flex items-center gap-2"
                          :class="currentPreviewPlatform === platform.id ? 'bg-white text-pink-600 shadow-sm border border-pink-200' : 'text-gray-600 hover:bg-white/50'"
                        >
                           <img :src="platform.icon" class="w-4 h-4" />
                           {{ platform.name }}
                        </button>
                     </div>
                     
                     <!-- 预览内容区域 -->
                     <div class="flex-1 overflow-y-auto p-6 bg-gray-100">
                        <!-- 小宇宙预览 -->
                        <div v-if="currentPreviewPlatform === 'xiaoyuzhou'" class="max-w-md mx-auto bg-white rounded-xl shadow-md overflow-hidden">
                           <!-- 封面图 -->
                          <div class="w-full h-full relative bg-gray-100 rounded-lg overflow-hidden">
                            <video
                              ref="exportPreviewVideo"
                              :src="(generatedVideos[0] && generatedVideos[0].url) || (assets.find(a=>a.type==='video') && assets.find(a=>a.type==='video').url) || '/src/assets/show.mp4'"
                              :poster="xiaoyuzhouCoverImage"
                              class="w-full h-full object-cover"
                              preload="metadata"
                              @click="handleExportPreviewVideoClick"
                              playsinline
                              webkit-playsinline
                            ></video>

                            <!-- 中间播放按钮 -->
                            <button v-if="showExportPreviewControl" @click.stop="toggleExportPreviewPlay"
                              class="absolute inset-0 m-auto w-16 h-16 rounded-full bg-white/90 flex items-center justify-center shadow-lg transform transition hover:scale-105"
                              style="left: 50%; top: 50%; transform: translate(-50%, -50%);">
                              <svg v-if="!exportPreviewPlaying" class="w-8 h-8 text-pink-500" fill="currentColor" viewBox="0 0 20 20"><path d="M6.3 2.841A1.5 1.5 0 004 4.11V15.89a1.5 1.5 0 002.3 1.269l9.344-5.89a1.5 1.5 0 000-2.538L6.3 2.84z"/></svg>
                              <svg v-else class="w-6 h-6 text-pink-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M6 4h3v12H6V4zm5 0h3v12h-3V4z" clip-rule="evenodd"/></svg>
                            </button>
                          </div>
                           
                           <div class="p-4">
                              <!-- 节目信息 -->
                              <div class="flex items-center gap-3 mb-3">
                                 <img :src="xiaoyuzhouCoverImage" alt="小宇宙封面" class="w-10 h-10 object-cover rounded-full flex-shrink-0" />
                                 <div class="flex-1">
                                    <p class="text-sm font-medium text-gray-900">PodPal Studio</p>
                                    <div class="flex items-center gap-2 text-xs text-gray-500">
                                       <span>{{ PROJECT_DURATION_TEXT }}</span>
                                       <span>·</span>
                                       <span>2026-03-24</span>
                                       <span>·</span>
                                       <span>第 12 期</span>
                                    </div>
                                 </div>
                                 <button class="px-3 py-1 bg-pink-500 text-white text-xs rounded-full hover:bg-pink-600 transition">
                                    订阅
                                 </button>
                              </div>
                              
                              <!-- 节目简介 -->
                              <div class="mb-4">
                                 <div class="text-sm text-gray-700 leading-relaxed mb-3 whitespace-pre-line break-words">
                                    {{ getPreviewCopy('xiaoyuzhou') }}
                                 </div>
                                 
                                 <!-- 标签 -->
                                 <div class="flex flex-wrap gap-1.5">
                                    <span class="px-2 py-0.5 bg-gray-100 text-gray-600 text-xs rounded-full">#播客</span>
                                    <span class="px-2 py-0.5 bg-gray-100 text-gray-600 text-xs rounded-full">#AI</span>
                                    <span class="px-2 py-0.5 bg-gray-100 text-gray-600 text-xs rounded-full">#内容创作</span>
                                    <span class="px-2 py-0.5 bg-gray-100 text-gray-600 text-xs rounded-full">#技术</span>
                                 </div>
                              </div>
                              
                              <!-- 时间戳 -->
                              <div class="mb-4">
                                 <h5 class="text-xs font-medium text-gray-900 mb-2">节目时间轴</h5>
                                 <div class="space-y-2">
                                    <div v-for="(item, idx) in buildUnifiedTimelineItems(10)" :key="`${item.timestamp}-${idx}`" class="flex items-start gap-2">
                                       <span class="text-xs text-gray-500 tabular-nums min-w-[64px]">{{ item.timestamp }}</span>
                                       <span class="text-xs text-gray-700 break-words">{{ item.topic }}</span>
                                    </div>
                                 </div>
                              </div>
                              
                              <!-- 互动数据 -->
                              <div class="flex items-center justify-between mb-4 pt-3 border-t border-gray-100">
                                 <div class="flex items-center gap-4">
                                    <div class="flex items-center gap-1 text-xs text-gray-500">
                                       <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" /></svg>
                                       <span>1.2k</span>
                                    </div>
                                    <div class="flex items-center gap-1 text-xs text-gray-500">
                                       <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" /></svg>
                                       <span>89</span>
                                    </div>
                                    <div class="flex items-center gap-1 text-xs text-gray-500">
                                       <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" /></svg>
                                       <span>156</span>
                                    </div>
                                 </div>
                                 <button class="px-3 py-1 bg-gradient-to-r from-pink-500 to-purple-500 text-white text-xs rounded-full hover:shadow-md transition">
                                    播放
                                 </button>
                              </div>
                              
                              <!-- 精选评论 -->
                              <div>
                                 <h5 class="text-xs font-medium text-gray-900 mb-2">精选评论</h5>
                                 <div class="space-y-3">
                                    <div class="flex gap-2">
                                       <div class="w-6 h-6 rounded-full bg-blue-500 flex-shrink-0"></div>
                                       <div class="flex-1">
                                          <div class="flex items-center gap-2 mb-1">
                                             <span class="text-xs font-medium text-gray-900">科技爱好者</span>
                                             <span class="text-xs text-gray-400">2小时前</span>
                                          </div>
                                          <p class="text-xs text-gray-700">内容非常实用，学到了很多AI工具的使用方法，期待下一期！</p>
                                          <div class="flex items-center gap-3 mt-1">
                                             <button class="text-xs text-gray-500 hover:text-pink-500">👍 23</button>
                                             <button class="text-xs text-gray-500 hover:text-pink-500">回复</button>
                                          </div>
                                       </div>
                                    </div>
                                    <div class="flex gap-2">
                                       <div class="w-6 h-6 rounded-full bg-green-500 flex-shrink-0"></div>
                                       <div class="flex-1">
                                          <div class="flex items-center gap-2 mb-1">
                                             <span class="text-xs font-medium text-gray-900">播客新手</span>
                                             <span class="text-xs text-gray-400">4小时前</span>
                                          </div>
                                          <p class="text-xs text-gray-700">作为刚入门的播客创作者，这一期给了我很多启发，感谢分享！</p>
                                          <div class="flex items-center gap-3 mt-1">
                                             <button class="text-xs text-gray-500 hover:text-pink-500">👍 15</button>
                                             <button class="text-xs text-gray-500 hover:text-pink-500">回复</button>
                                          </div>
                                       </div>
                                    </div>
                                 </div>
                              </div>
                           </div>
                        </div>
                        
                        <!-- 微信公众号预览 -->
                        <div v-if="currentPreviewPlatform === 'wechat'" class="max-w-md mx-auto bg-white shadow-md rounded-xl overflow-hidden">
                           <!-- 头部 -->
                           <div class="p-4 border-b border-gray-100">
                              <div class="flex items-center gap-2">
                                 <div class="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center text-white font-bold">P</div>
                                 <div>
                                    <p class="text-sm font-medium text-gray-900">PodPal Studio</p>
                                    <p class="text-xs text-gray-500">科技 · 内容创作 · AI</p>
                                 </div>
                                 <button class="ml-auto px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded-full">
                                    关注
                                 </button>
                              </div>
                           </div>
                           
                           <div class="p-4">
                              <!-- 标题 -->
                              <h4 class="text-xl font-bold text-gray-900 mb-4">{{ shownotesData?.titles?.[0] || 'AI 时代的播客创作：从灵感到分发的全流程解析' }}</h4>
                              
                              <!-- 封面图 -->
                              <img
                                :src="wechatImage"
                                alt="微信公众号封面"
                                class="w-full h-48 object-cover rounded-lg mb-4"
                              />
                              
                              <!-- 内容 -->
                              <div class="prose prose-sm text-gray-700 mb-4">
                                 <div class="mb-3 whitespace-pre-line break-words">
                                    {{ getFormattedPreviewCopy('wechat') }}
                                 </div>
                                 <p class="mb-3">
                                    我们邀请了资深播客制作人，分享他们使用 PodPal 提升效率的实战经验，并展望了未来播客行业的发展趋势。无论你是刚入门的新手，还是经验丰富的创作者，本期内容都将为你带来全新的启发。
                                 </p>
                                 <h5 class="font-bold text-gray-900 mt-4 mb-2">🎧 本期节目亮点</h5>
                                 <ul class="list-disc pl-5 space-y-1">
                                    <li>AI 如何 revolution 播客创作流程</li>
                                    <li>智能剪辑工具的实际应用案例</li>
                                    <li>多平台分发的最佳实践</li>
                                    <li>未来播客行业的发展趋势</li>
                                 </ul>
                              </div>
                              
                              <!-- 收听卡片 -->
                              <div class="mt-4 p-3 bg-green-50 rounded-lg border border-green-200">
                                 <div class="flex items-center gap-3">
                                    <div class="w-12 h-12 bg-gradient-to-br from-green-400 to-green-600 rounded-lg flex items-center justify-center">
                                       <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
                                       </svg>
                                    </div>
                                    <div class="flex-1">
                                       <p class="text-sm font-medium text-gray-900">点击收听完整播客</p>
                                       <p class="text-xs text-gray-500">时长：{{ PROJECT_DURATION_TEXT }}</p>
                                    </div>
                                    <button class="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center text-white">
                                       <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
                                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                       </svg>
                                    </button>
                                 </div>
                              </div>
                              
                              <!-- 标签 -->
                              <div class="flex flex-wrap gap-1.5 mt-4">
                                 <span class="px-2 py-0.5 bg-gray-100 text-gray-600 text-xs rounded-full">#播客</span>
                                 <span class="px-2 py-0.5 bg-gray-100 text-gray-600 text-xs rounded-full">#AI</span>
                                 <span class="px-2 py-0.5 bg-gray-100 text-gray-600 text-xs rounded-full">#内容创作</span>
                                 <span class="px-2 py-0.5 bg-gray-100 text-gray-600 text-xs rounded-full">#技术</span>
                              </div>
                              
                              <!-- 互动数据 -->
                              <div class="flex items-center justify-between mt-4 pt-4 border-t border-gray-100 text-sm text-gray-500">
                                 <span>2026-03-24</span>
                                 <div class="flex items-center gap-4">
                                    <span>阅读 1.2k</span>
                                    <span>点赞 89</span>
                                    <span>在看 45</span>
                                 </div>
                              </div>
                              
                              <!-- 推荐阅读 -->
                              <div class="mt-4 pt-4 border-t border-gray-100">
                                 <h5 class="text-sm font-medium text-gray-900 mb-3">推荐阅读</h5>
                                 <div class="space-y-3">
                                    <div class="flex gap-3 items-center">
                                       <div class="w-16 h-16 bg-gradient-to-br from-blue-400 to-blue-600 rounded flex-shrink-0"></div>
                                       <div class="flex-1">
                                          <p class="text-sm font-medium text-gray-900 line-clamp-2">如何用 AI 快速生成播客脚本</p>
                                          <p class="text-xs text-gray-500 mt-1">2026-03-10 · 阅读 856</p>
                                       </div>
                                    </div>
                                    <div class="flex gap-3 items-center">
                                       <div class="w-16 h-16 bg-gradient-to-br from-purple-400 to-purple-600 rounded flex-shrink-0"></div>
                                       <div class="flex-1">
                                          <p class="text-sm font-medium text-gray-900 line-clamp-2">播客变现的 5 种有效方法</p>
                                          <p class="text-xs text-gray-500 mt-1">2026-03-05 · 阅读 1.5k</p>
                                       </div>
                                    </div>
                                 </div>
                              </div>
                           </div>
                        </div>
                        
                        <!-- 小红书预览 -->
                        <div v-if="currentPreviewPlatform === 'xiaohongshu'" class="max-w-sm mx-auto bg-white rounded-xl shadow-md overflow-hidden">
                           <!-- 封面图 -->
                           <div class="aspect-square relative">
                              <img :src="xiaohongshuImage" alt="小红书封面" class="w-full h-full object-cover" />
                              <div class="absolute top-3 left-3 px-2 py-1 bg-black/50 rounded-full text-white text-xs">播客</div>
                              <div class="absolute bottom-4 left-4 right-4">
                                 <h4 class="text-white text-sm font-bold drop-shadow-md line-clamp-2">{{ shownotesData?.titles?.[0] || 'AI 时代的播客创作：从灵感到分发的全流程解析' }}</h4>
                              </div>
                           </div>
                           
                           <div class="p-4">
                              <!-- 作者信息 -->
                              <div class="flex items-center gap-3 mb-3">
                                 <div class="w-10 h-10 rounded-full bg-gradient-to-br from-[#FF6B9D] to-[#C084FC] flex items-center justify-center text-white font-bold">P</div>
                                 <div class="flex-1">
                                    <p class="text-sm font-medium text-gray-900">PodPal Studio</p>
                                    <p class="text-xs text-gray-500">科技内容创作者</p>
                                 </div>
                                 <button class="px-3 py-1 bg-black text-white text-xs rounded-full hover:bg-gray-800 transition">
                                    关注
                                 </button>
                              </div>
                              
                              <!-- 内容 -->
                              <div class="mb-4">
                                 <div class="text-sm text-gray-800 leading-relaxed mb-3 whitespace-pre-line break-words">
                                    {{ getFormattedPreviewCopy('xiaohongshu') }}
                                 </div>
                                 <p class="text-sm text-gray-800 leading-relaxed mb-3">
                                    本期节目邀请了资深播客制作人，分享他们使用 AI 工具提升效率的实战经验，真的学到了很多！无论是刚入门的新手还是经验丰富的创作者，都能从中获得启发～
                                 </p>
                              </div>
                              
                              <!-- 标签 -->
                              <div class="flex flex-wrap gap-1.5 mb-4">
                                 <span class="px-2 py-0.5 bg-gray-100 text-gray-600 text-xs rounded-full">#播客</span>
                                 <span class="px-2 py-0.5 bg-gray-100 text-gray-600 text-xs rounded-full">#AI工具</span>
                                 <span class="px-2 py-0.5 bg-gray-100 text-gray-600 text-xs rounded-full">#内容创作</span>
                                 <span class="px-2 py-0.5 bg-gray-100 text-gray-600 text-xs rounded-full">#效率工具</span>
                                 <span class="px-2 py-0.5 bg-gray-100 text-gray-600 text-xs rounded-full">#新手必备</span>
                              </div>
                              
                              <!-- 互动数据 -->
                              <div class="flex items-center gap-4 mb-3 pt-3 border-t border-gray-100">
                                 <div class="flex items-center gap-1 text-sm text-gray-600">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" /></svg>
                                    <span>328</span>
                                 </div>
                                 <div class="flex items-center gap-1 text-sm text-gray-600">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" /></svg>
                                    <span>56</span>
                                 </div>
                                 <div class="flex items-center gap-1 text-sm text-gray-600">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" /></svg>
                                    <span>128</span>
                                 </div>
                              </div>
                              
                              <!-- 评论区 -->
                              <div class="space-y-3">
                                 <div class="flex gap-2">
                                    <div class="w-6 h-6 rounded-full bg-pink-500 flex-shrink-0"></div>
                                    <div class="flex-1">
                                       <div class="flex items-center gap-2 mb-1">
                                          <span class="text-xs font-medium text-gray-900">粉色控</span>
                                          <span class="text-xs text-gray-400">2小时前</span>
                                       </div>
                                       <p class="text-xs text-gray-700">太感谢分享了！一直想做播客但不知道从何开始，这个工具看起来真的很有用！</p>
                                       <div class="flex items-center gap-3 mt-1">
                                          <button class="text-xs text-gray-500 hover:text-pink-500">👍 23</button>
                                          <button class="text-xs text-gray-500 hover:text-pink-500">回复</button>
                                       </div>
                                    </div>
                                 </div>
                                 <div class="flex gap-2">
                                    <div class="w-6 h-6 rounded-full bg-blue-500 flex-shrink-0"></div>
                                    <div class="flex-1">
                                       <div class="flex items-center gap-2 mb-1">
                                          <span class="text-xs font-medium text-gray-900">科技达人</span>
                                          <span class="text-xs text-gray-400">4小时前</span>
                                       </div>
                                       <p class="text-xs text-gray-700">PodPal 我用过，确实很强大！AI 剪辑功能太香了，节省了我大量时间。</p>
                                       <div class="flex items-center gap-3 mt-1">
                                          <button class="text-xs text-gray-500 hover:text-pink-500">👍 15</button>
                                          <button class="text-xs text-gray-500 hover:text-pink-500">回复</button>
                                       </div>
                                    </div>
                                 </div>
                                 <div class="text-center mt-3">
                                    <button class="text-xs text-gray-500 hover:text-pink-500">查看全部 12 条评论</button>
                                 </div>
                              </div>
                           </div>
                        </div>
                        
                        <!-- 微博预览 -->
                        <div v-if="currentPreviewPlatform === 'weibo'" class="max-w-md mx-auto bg-white rounded-xl shadow-md overflow-hidden">
                           <div class="p-4">
                              <!-- 作者信息 -->
                              <div class="flex items-start gap-3">
                                 <div class="w-10 h-10 rounded-full bg-gradient-to-br from-[#FF6B9D] to-[#C084FC] flex items-center justify-center text-white font-bold">P</div>
                                 <div class="flex-1">
                                    <div class="flex items-center gap-2">
                                       <span class="font-bold text-sm text-gray-900">PodPal Studio</span>
                                       <svg class="w-4 h-4 text-yellow-500" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                                       <span class="text-xs text-gray-400">认证用户</span>
                                    </div>
                                    <p class="text-xs text-gray-500">刚刚 来自 PodPal Studio</p>
                                 </div>
                                 <button class="text-gray-400 hover:text-gray-600">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5v14m-7-7h14"/></svg>
                                 </button>
                              </div>
                              
                              <!-- 内容 -->
                              <div class="mt-3">
                                 <div class="text-sm text-gray-800 leading-relaxed mb-3 whitespace-pre-line break-words">
                                    {{ getFormattedPreviewCopy('weibo') }}
                                    \n\n点击链接收听完整内容 👇
                                 </div>
                                 
                                 <!-- 卡片 -->
                                 <div class="mt-3 rounded-lg overflow-hidden border border-gray-200">
                                    <img :src="weiboImage" alt="微博封面" class="w-full h-32 object-cover" />
                                    <div class="p-3 bg-gray-50">
                                       <div class="text-sm font-medium text-gray-900 mb-1">{{ shownotesData?.titles?.[0] || 'AI 时代的播客创作：从灵感到分发的全流程解析' }}</div>
                                       <div class="text-xs text-gray-500 flex items-center gap-2">
                                          <span>PodPal Studio</span>
                                          <span>·</span>
                                          <span>{{ PROJECT_DURATION_TEXT }}</span>
                                       </div>
                                    </div>
                                 </div>
                              </div>
                              
                              <!-- 话题标签 -->
                              <div class="flex flex-wrap gap-1.5 mt-3">
                                 <a href="#" class="text-xs text-blue-500 hover:underline">#播客</a>
                                 <a href="#" class="text-xs text-blue-500 hover:underline">#AI</a>
                                 <a href="#" class="text-xs text-blue-500 hover:underline">#内容创作</a>
                                 <a href="#" class="text-xs text-blue-500 hover:underline">#技术</a>
                              </div>
                              
                              <!-- 互动数据 -->
                              <div class="flex items-center justify-between mt-3 pt-3 border-t border-gray-100 text-sm text-gray-500">
                                 <div class="flex items-center gap-4">
                                    <button class="flex items-center gap-1 hover:text-pink-600 transition">
                                       <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" /></svg>
                                       <span>128</span>
                                    </button>
                                    <button class="flex items-center gap-1 hover:text-pink-600 transition">
                                       <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" /></svg>
                                       <span>56</span>
                                    </button>
                                    <button class="flex items-center gap-1 hover:text-pink-600 transition">
                                       <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" /></svg>
                                       <span>234</span>
                                    </button>
                                    <button class="flex items-center gap-1 hover:text-pink-600 transition">
                                       <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" /></svg>
                                       <span>89</span>
                                    </button>
                                 </div>
                              </div>
                              
                              <!-- 评论区 -->
                              <div class="mt-4 space-y-3">
                                 <div class="flex gap-2">
                                    <div class="w-6 h-6 rounded-full bg-red-500 flex-shrink-0"></div>
                                    <div class="flex-1">
                                       <div class="flex items-center gap-2 mb-1">
                                          <span class="text-xs font-medium text-gray-900">微博用户</span>
                                          <span class="text-xs text-gray-400">1小时前</span>
                                       </div>
                                       <p class="text-xs text-gray-700">期待已久的播客终于更新了！AI 工具确实改变了内容创作的方式，学习了！</p>
                                       <div class="flex items-center gap-3 mt-1">
                                          <button class="text-xs text-gray-500 hover:text-pink-500">👍 15</button>
                                          <button class="text-xs text-gray-500 hover:text-pink-500">回复</button>
                                       </div>
                                    </div>
                                 </div>
                                 <div class="flex gap-2">
                                    <div class="w-6 h-6 rounded-full bg-blue-500 flex-shrink-0"></div>
                                    <div class="flex-1">
                                       <div class="flex items-center gap-2 mb-1">
                                          <span class="text-xs font-medium text-gray-900">科技前沿</span>
                                          <span class="text-xs text-gray-400">2小时前</span>
                                       </div>
                                       <p class="text-xs text-gray-700">PodPal 的 AI 功能真的很强大，已经在用了，强烈推荐给所有内容创作者！</p>
                                       <div class="flex items-center gap-3 mt-1">
                                          <button class="text-xs text-gray-500 hover:text-pink-500">👍 23</button>
                                          <button class="text-xs text-gray-500 hover:text-pink-500">回复</button>
                                       </div>
                                    </div>
                                 </div>
                              </div>
                           </div>
                        </div>
                     </div>
                  </div>
               </div>

               <!-- 分享链接弹窗 -->
               <div v-if="showShareLinkModal" class="fixed inset-0 z-[60] flex items-center justify-center bg-black/50 backdrop-blur-sm" @click.self="showShareLinkModal = false">
                  <div class="bg-white rounded-xl shadow-2xl w-[500px] flex flex-col overflow-hidden animate-scaleIn">
                     <div class="flex items-center justify-between p-4 border-b border-gray-100">
                        <h3 class="text-lg font-bold text-gray-900">生成分享链接</h3>
                        <button @click="showShareLinkModal = false" class="text-gray-400 hover:text-gray-600">
                           <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
                        </button>
                     </div>
                     <div class="p-6 space-y-4">
                        <p class="text-sm text-gray-600">生成一个只读链接，发送给嘉宾或合作伙伴，他们可以在线试听并留下文字评论。</p>
                        
                        <div class="bg-gray-50 p-4 rounded-lg border border-gray-200">
                           <div class="text-xs text-gray-500 mb-2">链接设置</div>
                           <div class="space-y-2">
                              <label class="flex items-center gap-2 text-sm text-gray-700">
                                 <input type="checkbox" v-model="shareLinkOptions.allowComments" class="rounded border-gray-300 text-pink-600 focus:ring-pink-500" />
                                 允许评论
                              </label>
                              <label class="flex items-center gap-2 text-sm text-gray-700">
                                 <input type="checkbox" v-model="shareLinkOptions.allowDownload" class="rounded border-gray-300 text-pink-600 focus:ring-pink-500" />
                                 允许下载
                              </label>
                              <label class="flex items-center gap-2 text-sm text-gray-700">
                                 <input type="checkbox" v-model="shareLinkOptions.expireEnabled" class="rounded border-gray-300 text-pink-600 focus:ring-pink-500" />
                                 设置有效期
                              </label>
                              <select v-if="shareLinkOptions.expireEnabled" v-model="shareLinkOptions.expireDays" class="w-full mt-1 rounded border-gray-300 text-sm">
                                 <option :value="1">1天</option>
                                 <option :value="7">7天</option>
                                 <option :value="30">30天</option>
                              </select>
                           </div>
                        </div>
                        
                        <div v-if="generatedShareLink" class="bg-pink-50 p-3 rounded-lg border border-pink-200">
                           <div class="text-xs text-gray-500 mb-1">生成的链接</div>
                           <div class="flex items-center gap-2">
                              <input :value="generatedShareLink" readonly class="flex-1 text-xs bg-white border border-gray-200 rounded px-2 py-1.5" />
                              <button @click="copyShareLink" class="px-3 py-1.5 text-xs bg-pink-500 text-white rounded hover:bg-pink-600 transition">复制</button>
                           </div>
                        </div>
                     </div>
                     <div class="p-4 border-t border-gray-100 flex justify-end gap-2 bg-gray-50">
                        <button @click="showShareLinkModal = false" class="px-4 py-2 text-sm text-gray-600 hover:bg-gray-200 rounded-lg">取消</button>
                        <button @click="createShareLink" :disabled="isGeneratingLink" class="px-4 py-2 text-sm bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-md transition disabled:opacity-50 flex items-center gap-2">
                           <svg v-if="isGeneratingLink" class="animate-spin h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                           </svg>
                           {{ isGeneratingLink ? '生成中...' : '生成链接' }}
                        </button>
                     </div>
                  </div>
               </div>
            </div>
          </div>
        </div>

        <!-- Export Distribution View -->
        <div v-if="activeToolTab === 'export'" class="flex-1 min-w-0 overflow-hidden bg-gray-50 flex">
          <!-- 中间：预览界面 -->
          <div class="flex-[3] min-w-0 overflow-y-auto p-6">
            <div class="space-y-6 max-w-3xl mx-auto">
              <!-- 顶部标题栏 -->
              <div class="flex items-center justify-between">
                <div>
                  <h2 class="text-2xl font-bold text-gray-900">导出预览</h2>
                  <p class="text-sm text-gray-500 mt-1">检查所有内容，准备分发</p>
                </div>
                <button @click="doExport" class="px-6 py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg shadow-lg hover:shadow-xl hover:scale-105 transition font-bold flex items-center gap-2">
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                  </svg>
                  立即导出
                </button>
              </div>
              
              <!-- 预览卡片 -->
              <div class="bg-white rounded-xl border border-pink-200 shadow-sm overflow-hidden">
                <!-- 封面区域 -->
                <div class="h-96 relative overflow-hidden rounded-lg">
  <!-- 封面视频 -->
  <video
    ref="exportPreviewVideo"
    :src="(generatedVideos[0] && generatedVideos[0].url) || (assets.find(a=>a.type==='video') && assets.find(a=>a.type==='video').url) || '/src/assets/show.mp4'"
    poster="/src/assets/fengmian.png"
    class="absolute inset-0 w-full h-full object-cover"
    preload="metadata"
    @click="handleExportPreviewVideoClick"
    playsinline
    webkit-playsinline
  ></video>

  <!-- 黑色半透明遮罩（让文字更清晰） -->
  <div class="absolute inset-0 bg-black/30"></div>

  <!-- 中间文字 -->
  <div class="absolute inset-0 flex items-center justify-center">
    <div class="text-center text-white">
      <div class="text-3xl font-bold mb-2">{{ shownotesData?.titles?.[0] || currentProject.name || '播客封面' }}</div>
      <div class="text-sm opacity-80">PodPal Studio</div>
    </div>
  </div>

  <!-- 中心播放按钮 -->
  <button v-if="showExportPreviewControl" @click.stop="toggleExportPreviewPlay"
    class="absolute z-30 left-1/2 top-1/2 transform -translate-x-1/2 -translate-y-1/2 w-20 h-20 rounded-full bg-white/90 flex items-center justify-center shadow-lg hover:scale-105 transition"
    :title="exportPreviewPlaying ? '暂停' : '播放'">
    <svg v-if="!exportPreviewPlaying" class="w-10 h-10 text-pink-500" fill="currentColor" viewBox="0 0 20 20"><path d="M6.3 2.841A1.5 1.5 0 004 4.11V15.89a1.5 1.5 0 002.3 1.269l9.344-5.89a1.5 1.5 0 000-2.538L6.3 2.84z"/></svg>
    <svg v-else class="w-7 h-7 text-pink-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M6 4h3v12H6V4zm5 0h3v12h-3V4z" clip-rule="evenodd"/></svg>
  </button>

  <!-- 时长 -->
  <div class="absolute bottom-3 right-3 px-3 py-1 bg-black/30 rounded-full text-white text-xs backdrop-blur-sm">
    {{ PROJECT_DURATION_TEXT }}
  </div>

  <!-- 进度条与播放控制 -->
  <div class="absolute bottom-0 left-0 right-0 p-4">
    <div class="flex items-center gap-3">
      <button
        @click.stop="toggleExportPreviewPlay"
        class="w-8 h-8 rounded-full bg-black/45 text-white flex items-center justify-center hover:bg-black/60 transition"
        :title="exportPreviewPlaying ? '暂停' : '播放'"
      >
        <svg v-if="!exportPreviewPlaying" class="w-4 h-4 ml-0.5" fill="currentColor" viewBox="0 0 20 20"><path d="M6.3 2.841A1.5 1.5 0 004 4.11V15.89a1.5 1.5 0 002.3 1.269l9.344-5.89a1.5 1.5 0 000-2.538L6.3 2.84z"/></svg>
        <svg v-else class="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M6 4h3v12H6V4zm5 0h3v12h-3V4z" clip-rule="evenodd"/></svg>
      </button>
      <input 
        type="range" 
        ref="progressBar" 
        min="0" 
        max="100" 
        value="0" 
        class="flex-1 h-2 bg-white/30 rounded-lg appearance-none cursor-pointer"
        @input="updateVideoProgress"
      />
    </div>
  </div>
</div>

                <!-- ID3v2 标签元数据检查器 -->
                <div class="bg-gradient-to-br from-slate-800 to-slate-900 p-4">
                  <div class="flex items-center gap-2 mb-3">
                    <div class="w-6 h-6 rounded bg-emerald-500/20 flex items-center justify-center">
                      <svg class="w-3.5 h-3.5 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                      </svg>
                    </div>
                    <div>
                      <h3 class="text-xs font-semibold text-emerald-400">ID3v2 标签元数据检查器</h3>
                      <p class="text-[10px] text-slate-400">Meta-Tag Inspector</p>
                    </div>
                  </div>
                  <div class="grid grid-cols-1 gap-2">
                    <div class="flex items-center gap-2 text-xs">
                      <span class="w-2 h-2 rounded-full bg-emerald-400"></span>
                      <span class="text-slate-300">ID3v2.4 容器状态：</span>
                      <span class="text-emerald-400 font-medium">已就绪 (Successfully Encapsulated)</span>
                    </div>
                    <div class="flex items-center gap-2 text-xs">
                      <span class="w-2 h-2 rounded-full bg-amber-400"></span>
                      <span class="text-slate-300">TIT2 (标题帧)：</span>
                      <span class="text-white font-medium">{{ shownotesData?.titles?.[0] || '未设置标题' }}</span>
                    </div>
                    <div class="flex items-center gap-2 text-xs">
                      <span class="w-2 h-2 rounded-full bg-blue-400"></span>
                      <span class="text-slate-300">TPE1 (作者帧)：</span>
                      <span class="text-white font-medium">PodPal 主播</span>
                    </div>
                    <div class="flex items-center gap-2 text-xs">
                      <span class="w-2 h-2 rounded-full bg-purple-400"></span>
                      <span class="text-slate-300">APIC (封面帧)：</span>
                      <span class="text-white font-medium">cover.jpg (240KB 二进制流已嵌入音频头部)</span>
                    </div>
                  </div>
                </div>
                
                <!-- 内容预览 -->
                <div class="p-6 space-y-6">
                  <!-- RSS-Ready 文本与时间戳章节 -->
                  <div v-if="shownotesData">
                    <div class="flex items-center justify-between mb-3">
                      <h3 class="text-sm font-bold text-gray-900 flex items-center gap-2">
                        <span class="w-1 h-4 bg-purple-500 rounded-full"></span>
                        RSS-Ready 章节标记
                      </h3>
                      <button @click="copyFullShownotes" class="text-xs bg-pink-500 text-white px-3 py-1 rounded-lg hover:bg-pink-600 transition flex items-center gap-1">
                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                        </svg>
                        一键复制
                      </button>
                    </div>
                    <div class="bg-gray-50 rounded-lg p-4 max-h-[420px] overflow-y-auto">
                      <div class="font-mono text-xs text-gray-600 whitespace-pre-wrap">
# 📌 节目章节（自动同步至 RSS 规范标签）

{{ shownotesData.titles?.[0] || '播客标题' }}

{{ shownotesData.summary || '节目摘要' }}

## ⏱️ 时间轴章节
<span v-for="(item, idx) in shownotesData.timeline" :key="idx">[{{ item.timestamp }}] {{ item.topic }}
{{ item.description }}

</span>
                      </div>
                    </div>
                  </div>
                  
                  <!-- 多模态矩阵引流视频 -->
<div v-if="generatedVideos.length > 0">
  <div class="flex items-center justify-between mb-3">
    <h3 class="text-sm font-bold text-gray-900 flex items-center gap-2">
      <span class="w-1 h-4 bg-blue-500 rounded-full"></span>
      多模态矩阵引流视频
    </h3>
    <span class="text-xs text-gray-500">{{ generatedVideos.length }} 个宣发短片</span>
  </div>
  <div class="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-lg p-4 border border-blue-200">
    <div class="grid grid-cols-3 gap-3 mb-3">
      <div v-for="video in generatedVideos.slice(0, 3)" :key="video.id" class="aspect-video bg-gray-200 rounded-lg overflow-hidden relative cursor-pointer group">
        <video 
          src="/src/assets/show.mp4" 
          class="w-full h-full object-cover"
          muted
          loop
          autoplay
        ></video>
        <div class="absolute bottom-1 right-1 px-1.5 py-0.5 bg-black/60 text-white text-[10px] rounded">{{ video.duration }}</div>
        <div class="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition flex items-center justify-center opacity-0 group-hover:opacity-100">
          <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 20 20"><path d="M6.3 2.841A1.5 1.5 0 004 4.11V15.89a1.5 1.5 0 002.3 1.269l9.344-5.89a1.5 1.5 0 000-2.538L6.3 2.84z"/></svg>
        </div>
      </div>
    </div>
    <div class="space-y-1.5 text-xs text-gray-600">
      <div class="flex items-center gap-2">
        <span class="w-1.5 h-1.5 rounded-full bg-blue-400"></span>
        <span><span class="font-semibold text-gray-800">文件格式：</span>H.264 / 1080P / 60fps MP4</span>
      </div>
      <div class="flex items-center gap-2">
        <span class="w-1.5 h-1.5 rounded-full bg-indigo-400"></span>
        <span><span class="font-semibold text-gray-800">画面特征：</span>AI 亚像素级口型对齐宣发短视频（自适应抖音/小红书 9:16 画幅）</span>
      </div>
    </div>
  </div>
</div>
                  
                  <!-- 社交媒体文案预览 -->
                  <div v-if="hasAnySocialCopy">
                    <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                      <span class="w-1 h-4 bg-green-500 rounded-full"></span>
                      {{ socialPlatformLabel }} 推广文案
                    </h3>
                    <div class="bg-green-50 rounded-lg p-4 border border-green-100">
                      <div class="text-sm text-gray-700 whitespace-pre-line">{{ currentSocialCopy }}</div>
                    </div>
                  </div>
                  
                  <!-- 导出设置 -->
                  <div class="pt-4 border-t border-gray-100">
                    <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                      <span class="w-1 h-4 bg-purple-500 rounded-full"></span>
                      音频导出设置
                    </h3>
                    
                    <!-- 格式选择 -->
                    <div class="space-y-4">
                      <div class="flex items-center justify-between">
                        <span class="text-xs text-gray-500">格式</span>
                        <div class="flex items-center gap-2">
                          <label class="flex items-center gap-2 cursor-pointer">
                            <input type="radio" v-model="exportSettings.format" value="mp3" class="text-purple-600 focus:ring-purple-500" />
                            <span class="text-xs text-gray-700">MP3</span>
                          </label>
                          <label class="flex items-center gap-2 cursor-pointer">
                            <input type="radio" v-model="exportSettings.format" value="wav" class="text-purple-600 focus:ring-purple-500" />
                            <span class="text-xs text-gray-700">WAV (无损)</span>
                          </label>
                        </div>
                      </div>
                      
                      <!-- 比特率选择 -->
                      <div class="flex items-center justify-between">
                        <span class="text-xs text-gray-500">比特率</span>
                        <select v-model="exportSettings.bitrate" class="text-xs bg-gray-100 rounded-lg px-3 py-1.5 border-none focus:ring-2 focus:ring-purple-500">
                          <option value="192">192 kbps</option>
                          <option value="256">256 kbps</option>
                          <option value="320">320 kbps</option>
                        </select>
                      </div>
                      
                      <!-- 采样率选择 -->
                      <div class="flex items-center justify-between">
                        <span class="text-xs text-gray-500">采样率</span>
                        <select v-model="exportSettings.samplerate" class="text-xs bg-gray-100 rounded-lg px-3 py-1.5 border-none focus:ring-2 focus:ring-purple-500">
                          <option value="44100">44100 Hz</option>
                          <option value="48000">48000 Hz</option>
                        </select>
                      </div>
                      
                      <!-- 音量优化 -->
                      <div class="pt-3 border-t border-gray-100">
                        <div class="flex items-center justify-between mb-3">
                          <div>
                            <div class="text-xs font-medium text-gray-800">优化节目音量大小</div>
                            <div class="text-[10px] text-gray-500">选择上传的平台，会自动优化对应的音量</div>
                          </div>
                          <button 
                            @click="exportSettings.volumeOptimization = !exportSettings.volumeOptimization"
                            class="w-10 h-5 rounded-full transition-colors"
                            :class="exportSettings.volumeOptimization ? 'bg-purple-500' : 'bg-gray-300'"
                          >
                            <span 
                              class="block w-4 h-4 bg-white rounded-full shadow transition-transform"
                              :class="exportSettings.volumeOptimization ? 'translate-x-5' : 'translate-x-0.5'"
                            ></span>
                          </button>
                        </div>
                        <select 
                          v-model="exportSettings.lufs" 
                          :disabled="!exportSettings.volumeOptimization"
                          class="w-full text-xs bg-gray-100 rounded-lg px-3 py-2 border-none focus:ring-2 focus:ring-purple-500 disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          <option value="-14">-14 LUFS（视频音轨推荐响度）</option>
                          <option value="-16">-16 LUFS（播客音频推荐响度）</option>
                          <option value="-23">-23 LUFS（传统广播电视标准响度）</option>
                        </select>
                      </div>
                    </div>
                  </div>

                  <!-- 资产包一键下载 / 投递区 -->
                  <div class="pt-4 border-t border-gray-100">
                    <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                      <span class="w-1 h-4 bg-rose-500 rounded-full"></span>
                      资产包投递区
                    </h3>
                    <div class="space-y-3">
                      <button @click="exportAssetPack" class="w-full py-3 bg-gradient-to-r from-rose-500 to-pink-500 text-white rounded-lg hover:from-rose-600 hover:to-pink-600 transition flex items-center justify-center gap-2 text-sm font-medium">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                        </svg>
                        <span>📦 导出标准 RSS-Ready 资产包 (.zip)</span>
                      </button>
                      <p class="text-[11px] text-gray-500 text-center">
                        内含内嵌 ID3v2 标签音频、Shownotes.md、章节时间戳、短视频
                      </p>
                    </div>
                  </div>
                </div>
              </div>
              
            </div>
          </div>
          
          <!-- 右侧：AI 发布时间分析 + RSS 模板 -->
          <aside class="flex-[2] min-w-0 bg-white border-l border-pink-200 flex flex-col overflow-hidden">
            <div class="p-4 border-b border-pink-200 bg-gradient-to-r from-pink-50 to-purple-50">
              <h2 class="text-sm font-semibold text-gray-700 uppercase tracking-wider flex items-center gap-2">
                <svg class="w-4 h-4 text-pink-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                AI 发布分析
              </h2>
              <p class="text-xs text-gray-500 mt-1">强调听众听到时间，倒推审核提交时间</p>
            </div>
            
            <div class="flex-1 overflow-y-auto p-4 space-y-4">
              <div class="bg-gradient-to-br from-pink-50 to-purple-50 rounded-lg p-4 border border-pink-200">
                <div class="flex items-center justify-between mb-3">
                  <div class="text-sm font-semibold text-gray-900">发布时间策略（定时发布）</div>
                  <button @click="generatePropagationForecast" :disabled="isGeneratingForecast" class="text-xs text-pink-600 hover:text-pink-700 flex items-center gap-1">
                    <svg v-if="isGeneratingForecast" class="animate-spin h-3.5 w-3.5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    </svg>
                    <span>{{ isGeneratingForecast ? '分析中...' : '重新分析' }}</span>
                  </button>
                </div>

                <div v-if="propagationForecast" class="space-y-3">
                  <div class="grid grid-cols-1 gap-2">
                    <div class="p-3 rounded-lg bg-white border border-pink-100">
                      <div class="text-[11px] text-gray-500">建议听众听到时间（定时上线）</div>
                      <div class="text-lg font-bold text-pink-600">{{ propagationForecast.listenerGoLiveAt }}</div>
                    </div>
                    <div class="p-3 rounded-lg bg-white border border-pink-100">
                      <div class="text-[11px] text-gray-500">预计审核耗时（小宇宙）</div>
                      <div class="text-sm font-semibold text-gray-900">{{ propagationForecast.reviewEstimate }}</div>
                    </div>
                    <div class="p-3 rounded-lg bg-white border border-pink-100">
                      <div class="text-[11px] text-gray-500">建议最晚送审时间</div>
                      <div class="text-sm font-semibold text-rose-600">{{ propagationForecast.submitBefore }}</div>
                    </div>
                  </div>

                  <div class="bg-white rounded-lg p-3 border border-pink-100">
                    <div class="text-xs font-semibold text-gray-800 mb-2">各平台黄金发布时段</div>
                    <div class="space-y-2">
                      <div v-for="slot in propagationForecast.platformWindows" :key="slot.platform" class="text-xs text-gray-700">
                        <span class="font-semibold text-gray-900">{{ slot.platform }}：</span>{{ slot.window }}
                      </div>
                    </div>
                  </div>

                  <div class="bg-white rounded-lg p-3 border border-pink-100">
                    <div class="text-xs font-semibold text-gray-800 mb-2">实操时间搭配（定档 {{ propagationForecast.listenerGoLiveAt }}）</div>
                    <ol class="space-y-1.5 text-xs text-gray-700 list-decimal ml-4">
                      <li v-for="step in propagationForecast.executionPlan" :key="step">{{ step }}</li>
                    </ol>
                  </div>

                  <div class="bg-white rounded-lg p-3 border border-pink-100">
                    <div class="text-xs font-semibold text-gray-800 mb-2">AI 小贴士</div>
                    <ul class="space-y-1 text-xs text-gray-700">
                      <li v-for="tip in propagationForecast.tips" :key="tip">• {{ tip }}</li>
                    </ul>
                  </div>
                </div>

                <div v-else class="text-xs text-gray-500">{{ isGeneratingForecast ? 'AI 正在分析发布节奏…' : '点击“重新分析”生成发布建议。' }}</div>
              </div>

              <!-- AI 封面生成器 -->
              <div class="bg-white rounded-lg border border-gray-200 p-4">
                <div class="flex items-center justify-between mb-3">
                  <div class="text-sm font-semibold text-gray-900 flex items-center gap-2">
                    <svg class="w-4 h-4 text-purple-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                    AI 封面生成器
                  </div>
                </div>
                <div class="space-y-3">
                  <!-- 当前封面预览 -->
                  <div class="relative aspect-square bg-gradient-to-br from-purple-100 to-pink-100 rounded-lg overflow-hidden mb-3">
                    <img 
                      :src="currentCoverImage || '/src/assets/fengmian.png'" 
                      alt="播客封面" 
                      class="w-full h-full object-cover"
                    />
                    <div v-if="!currentCoverImage" class="absolute inset-0 flex items-center justify-center">
                      <span class="text-xs text-gray-400">暂无封面</span>
                    </div>
                  </div>
                  
                  <!-- 操作按钮 -->
                  <div class="flex gap-2">
                    <label class="flex-1 py-2 px-3 bg-gray-100 hover:bg-gray-200 rounded-lg cursor-pointer text-xs text-gray-700 flex items-center justify-center gap-2 transition">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                      </svg>
                      上传封面
                      <input type="file" accept="image/*" class="hidden" @change="handleCoverUpload" />
                    </label>
                    <button 
                      @click="generateCover" 
                      :disabled="isGeneratingCover"
                      class="flex-1 py-2 px-3 bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 disabled:opacity-50 disabled:cursor-not-allowed text-white rounded-lg text-xs flex items-center justify-center gap-2 transition"
                    >
                      <svg v-if="isGeneratingCover" class="animate-spin w-3.5 h-3.5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      </svg>
                      <svg v-else class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                      </svg>
                      {{ isGeneratingCover ? '生成中...' : 'AI生成' }}
                    </button>
                  </div>
                  
                  <!-- 生成提示 -->
                  <p v-if="coverGenerationTip" class="text-[11px] text-purple-600 bg-purple-50 p-2 rounded-lg">
                    {{ coverGenerationTip }}
                  </p>
                </div>
              </div>

              <div class="bg-white rounded-lg border border-gray-200 p-4">
                <div class="flex items-center justify-between mb-3">
                  <div class="text-sm font-semibold text-gray-900 flex items-center gap-2">
                    <svg class="w-4 h-4 text-orange-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                    </svg>
                    通用 RSS 模板
                  </div>
                  <button @click="copyRssTemplate" class="text-xs bg-orange-100 text-orange-600 px-2 py-1 rounded hover:bg-orange-200 transition">
                    📋 复制 XML
                  </button>
                </div>
                <p class="text-[11px] text-gray-500 mb-4">无需选择导出平台，RSS 为通用格式，可直接用于播客托管平台。</p>
                
                <!-- RSS 模板字段展示 -->
                <div class="space-y-4">
                  <!-- 播客基础信息 -->
                  <div class="border-l-2 border-blue-500 pl-3">
                    <div class="text-xs font-semibold text-blue-600 mb-2">📻 播客基础信息</div>
                    <div class="space-y-2 text-xs">
                      <div class="flex justify-between">
                        <span class="text-gray-500">标题</span>
                        <span class="text-gray-800 font-medium">{{ currentProject?.name || '播客名称' }}</span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-500">主页网址</span>
                        <span class="text-gray-800 font-medium">{{ windowLocationOrigin || 'https://example.com' }}</span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-500">简介</span>
                        <span class="text-gray-800 font-medium max-w-[150px] truncate">{{ shownotesData?.summary || '节目简介' }}</span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-500">语言</span>
                        <span class="text-gray-800 font-medium">zh-CN</span>
                      </div>
                    </div>
                  </div>
                  
                  <!-- iTunes 信息 -->
                  <div class="border-l-2 border-green-500 pl-3">
                    <div class="text-xs font-semibold text-green-600 mb-2">🎵 iTunes 必填信息</div>
                    <div class="space-y-2 text-xs">
                      <div class="flex justify-between">
                        <span class="text-gray-500">主播名</span>
                        <span class="text-gray-800 font-medium">PodPal 主播</span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-500">联系邮箱</span>
                        <span class="text-gray-800 font-medium">hello@podpal.ai</span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-500">分类</span>
                        <span class="text-gray-800 font-medium">Society & Culture</span>
                      </div>
                    </div>
                  </div>
                  
                  <!-- 单期节目 -->
                  <div class="border-l-2 border-purple-500 pl-3">
                    <div class="text-xs font-semibold text-purple-600 mb-2">🎙️ 单期节目</div>
                    <div class="space-y-2 text-xs">
                      <div class="flex justify-between">
                        <span class="text-gray-500">标题</span>
                        <span class="text-gray-800 font-medium max-w-[150px] truncate">{{ shownotesData?.titles?.[0] || '单集标题' }}</span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-500">时长</span>
                        <span class="text-gray-800 font-medium">{{ PROJECT_DURATION_TEXT }}</span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-500">发布日期</span>
                        <span class="text-gray-800 font-medium">{{ buildPodcastPubDate() }}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </aside>
        </div>

      </main>

      <!-- 4. 右侧：AI 智能工具箱 (Feature 3, 4, 5) -->
      <aside
        v-show="activeToolTab === 'edit'"
        class="right-toolbox-scale bg-gradient-to-b from-pink-50 to-purple-50 border-l border-pink-200 flex flex-col overflow-hidden transition-all duration-300 min-h-0 h-full self-stretch text-sm"
        :class="isAssetSidebarCollapsed ? 'flex-1 min-w-0' : 'w-96 flex-none'"
      >
        <div class="flex-1 min-h-0 p-6 space-y-8 overflow-y-auto">
          
          <!-- Tab 1: 智能剪辑 (Feature 3) -->
          <div v-if="activeToolTab === 'edit'" class="space-y-6 animate-fadeIn">
            <div class="flex items-center gap-2 bg-white/60 p-2 rounded-lg border border-pink-200 sticky top-0 z-10">
              <button 
                class="flex-1 px-3 py-1.5 text-xs rounded border transition"
                :class="openRightPanel==='content_post' ? 'bg-white border-pink-300 text-pink-600 shadow-sm' : 'border-transparent text-gray-600 hover:bg-pink-50'"
                @click="openRightPanel='content_post'"
              >
                内容润色 & 后期大师
              </button>
              <button 
                class="flex-1 px-3 py-1.5 text-xs rounded border transition"
                :class="openRightPanel==='voice' ? 'bg-white border-pink-300 text-pink-600 shadow-sm' : 'border-transparent text-gray-600 hover:bg-pink-50'"
                @click="openRightPanel='voice'"
              >
                声演实验室
              </button>
              <button 
                class="flex-1 px-3 py-1.5 text-xs rounded border transition"
                :class="openRightPanel==='highlights' ? 'bg-white border-pink-300 text-pink-600 shadow-sm' : 'border-transparent text-gray-600 hover:bg-pink-50'"
                @click="openRightPanel='highlights'"
              >
                高光金句库
              </button>
            </div>
            <!-- 脚本优化 -->
            <section v-show="openRightPanel==='content_post'">
              <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-blue-500 rounded-full"></span>
                内容润色 / 脚本精修
              </h3>
              <div class="grid grid-cols-2 gap-2">
                <button
                  class="p-2 rounded text-xs transition border"
                  :class="lastScriptOptimizationType === 'filler'
                    ? 'bg-gradient-to-r from-pink-500 to-purple-500 text-white border-transparent shadow-md'
                    : 'bg-white border-pink-200 text-gray-900 hover:border-pink-400 hover:text-pink-600'"
                  title="只删除语气词、口癖类文字稿内容"
                  @click="applyScriptOptimization('filler')"
                >
                  {{ lastScriptOptimizationType === 'filler' ? '已清理语气词' : '去语气词' }}
                </button>
                <button
                  class="p-2 rounded text-xs transition border"
                  :class="lastScriptOptimizationType === 'stutter'
                    ? 'bg-gradient-to-r from-fuchsia-500 to-pink-500 text-white border-transparent shadow-md'
                    : 'bg-white border-pink-200 text-gray-900 hover:border-pink-400 hover:text-pink-600'"
                  title="只删除重复口吃类文字稿内容"
                  @click="applyScriptOptimization('stutter')"
                >
                  {{ lastScriptOptimizationType === 'stutter' ? '已清理口吃' : '去口吃' }}
                </button>
                <button
                  class="p-2 rounded text-xs transition border"
                  :class="lastScriptOptimizationType === 'pause-abnormal'
                    ? 'bg-gradient-to-r from-rose-500 to-orange-500 text-white border-transparent shadow-md'
                    : 'bg-white border-pink-200 text-gray-900 hover:border-pink-400 hover:text-pink-600'"
                  title="只删除异常停顿的文字稿内容"
                  @click="applyScriptOptimization('pause-abnormal')"
                >
                  {{ lastScriptOptimizationType === 'pause-abnormal' ? '已清理异常停顿' : '去异常停顿' }}
                </button>
                <button
                  class="p-2 rounded text-xs transition border"
                  :class="lastScriptOptimizationType === 'logic'
                    ? 'bg-gradient-to-r from-blue-500 to-indigo-500 text-white border-transparent shadow-md'
                    : 'bg-white border-pink-200 text-gray-900 hover:border-pink-400 hover:text-pink-600'"
                  title="检测逻辑断层，推荐衔接句"
                  @click="applyScriptOptimization('logic')"
                >
                  {{ lastScriptOptimizationType === 'logic' ? '已应用逻辑优化' : '逻辑纠错' }}
                </button>
              </div>
              <!-- 脚本优化建议列表 -->
              <div v-if="scriptSuggestions.length" class="mt-4 space-y-2">
                <div v-for="s in scriptSuggestions" :key="s.id" class="p-3 bg-white border border-blue-200 rounded text-xs text-gray-700 flex flex-col gap-2 shadow-sm">
                  <div class="flex items-center justify-between">
                    <div class="font-medium text-gray-900 flex items-center gap-1">
                      <svg class="w-3 h-3 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
                      {{ s.label }}
                    </div>
                    <span class="px-2 py-0.5 rounded bg-blue-50 text-blue-600 border border-blue-100 text-[10px]">{{ s.tag }}</span>
                  </div>
                  <div class="text-[10px] text-gray-500 leading-relaxed italic">{{ s.preview }}</div>
                  <div class="flex justify-end gap-2 mt-1">
                    <button 
                      @click="applyScriptSuggestion(s)"
                      class="px-3 py-1 bg-blue-500 text-white rounded-full text-[10px] hover:bg-blue-600 transition shadow-sm"
                    >确认</button>
                    <button 
                      v-if="s.type && appliedOptimizations && appliedOptimizations[s.type]"
                      @click="undoScriptSuggestion(s)"
                      class="px-3 py-1 bg-white text-emerald-600 border border-emerald-100 rounded-full text-[10px] hover:bg-emerald-50 transition"
                    >撤销</button>
                    <button 
                      @click="scriptSuggestions = scriptSuggestions.filter(item => item.id !== s.id)"
                      class="px-3 py-1 bg-white text-gray-400 border border-gray-100 rounded-full text-[10px] hover:bg-gray-50 transition"
                    >忽略</button>
                  </div>
                </div>
              </div>

              <!-- 脚本预览展示 -->
              <div v-if="scriptPreview.length" class="mt-4 space-y-3 pt-3 border-t border-blue-100">
                <div class="text-xs font-bold text-gray-900 flex items-center gap-1">
                  <svg class="w-3 h-3 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                  文稿优化预览
                </div>
                <div v-for="group in scriptPreview" :key="group.id" class="space-y-2">
                  <div class="text-[10px] px-2 py-0.5 rounded bg-blue-50 border border-blue-100 text-blue-600 inline-block font-medium">{{ group.label }}</div>
                  <div v-for="entry in group.entries" :key="entry.id" class="p-2.5 bg-white border border-blue-50 rounded-lg shadow-sm">
                    <div class="flex items-center justify-between mb-1">
                      <div class="text-[10px] text-gray-400">{{ entry.speaker }} · {{ entry.time }}</div>
                      <span class="text-[9px] px-1.5 py-0.5 rounded border bg-indigo-50 text-indigo-600 border-indigo-100">{{ entry.type }}</span>
                    </div>
                    <div class="text-[11px] text-gray-800 leading-snug">{{ entry.content }}</div>
                    <div class="mt-1.5 flex flex-wrap gap-1">
                      <span v-for="tag in entry.tags" :key="tag.text" class="text-[9px] px-1.5 py-0.5 rounded border bg-blue-50 text-blue-500 border-blue-100">{{ tag.text }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </section>

             <!-- 语音生成（简化版 - 你要的功能） -->
<section v-show="openRightPanel==='voice'">
  <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
    <span class="w-1 h-4 bg-pink-500 rounded-full"></span>
    声演实验室
  </h3>
  <div class="space-y-3">
                 <!-- 语音内容输入区域 -->
                 <div class="p-3 bg-gradient-to-r from-pink-50 to-purple-50 border border-pink-200 rounded-lg">
                   <div class="text-xs font-medium text-gray-700 mb-2">输入语音内容</div>
                   <textarea
                     v-model="voicePrompt"
                     placeholder="请输入您想要生成的语音内容..."
                     class="w-full text-xs text-gray-700 bg-white border border-pink-200 rounded p-2 focus:outline-none focus:ring-2 focus:ring-pink-300 resize-none"
                     rows="3"
                   ></textarea>
                   <button
                     @click="generateVoiceFromPrompt"
                     :disabled="!voicePrompt.trim() || isGeneratingVoice"
                     class="w-full mt-2 py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white text-xs font-medium rounded-lg transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                   >
                     <svg v-if="isGeneratingVoice" class="animate-spin h-3 w-3 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                       <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                       <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                     </svg>
                     <svg v-else class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                       <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" />
                     </svg>
                     {{ isGeneratingVoice ? '生成中...' : '生成语音' }}
                   </button>
                 </div>

                 <div v-if="ttsInsertIndex !== null" class="p-3 bg-white border border-pink-200 rounded-lg space-y-2">
                   <div class="text-xs font-medium text-gray-800">补录插入位置</div>
                   <div class="flex items-center gap-2 text-xs">
                     <label class="flex items-center gap-1.5 px-2 py-1 rounded border border-pink-200 bg-pink-50/60">
                       <input type="radio" v-model="ttsInsertPosition" value="before" class="text-pink-600 focus:ring-pink-500"> 句子前
                     </label>
                     <label class="flex items-center gap-1.5 px-2 py-1 rounded border border-pink-200 bg-pink-50/60">
                       <input type="radio" v-model="ttsInsertPosition" value="after" class="text-pink-600 focus:ring-pink-500"> 句子后
                     </label>
                     <label class="flex items-center gap-1.5 px-2 py-1 rounded border border-pink-200 bg-pink-50/60">
                       <input type="radio" v-model="ttsInsertPosition" value="middle" class="text-pink-600 focus:ring-pink-500"> 句中
                     </label>
                   </div>
                   <div class="text-[11px] text-gray-500 truncate">
                     当前目标句：{{ getCurrentTTSBaseText() || '未选择' }}
                   </div>
                   <div v-if="ttsInsertPosition === 'middle'" class="space-y-1">
                     <div class="text-[11px] text-gray-600">句中补录内容（已复制原句，可直接编辑）</div>
                     <textarea
                       v-model="ttsMiddleDraftText"
                       rows="2"
                       class="w-full text-xs text-gray-700 bg-pink-50 border border-pink-200 rounded p-2 focus:outline-none focus:ring-2 focus:ring-pink-300 resize-none"
                     ></textarea>
                     <div v-if="isMiddleSupplementing" class="space-y-1.5 p-2 bg-pink-50 border border-pink-200 rounded">
                       <div class="flex items-center justify-between text-[11px] text-pink-700">
                         <span>语音补录处理中...</span>
                         <span>{{ middleSupplementProgress }}%</span>
                       </div>
                       <div class="h-1.5 w-full bg-pink-100 rounded-full overflow-hidden">
                         <div
                           class="h-full bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] transition-all duration-200"
                           :style="{ width: middleSupplementProgress + '%' }"
                         ></div>
                       </div>
                     </div>
                     <div class="flex justify-end">
                       <button
                         @click="insertMiddleDraftToTranscript"
                         :disabled="!ttsMiddleDraftText.trim() || isMiddleSupplementing"
                         class="px-3 py-1.5 text-xs rounded bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white hover:shadow-md transition disabled:opacity-50 disabled:cursor-not-allowed"
                       >
                         {{ isMiddleSupplementing ? '补录中...' : '插入到文字稿' }}
                       </button>
                     </div>
                   </div>
                 </div>

                 <!-- 生成的句子预览 -->
                 <div v-if="generatedVoiceSentences.length > 0" class="space-y-2">
                   <div class="text-xs font-medium text-gray-900 flex items-center justify-between">
                     <span>生成的内容</span>
                     <span class="text-[10px] text-gray-500">{{ generatedVoiceSentences.length }} 条</span>
                   </div>
                   <div
                     v-for="(sentence, idx) in generatedVoiceSentences"
                     :key="sentence.id"
                     class="p-3 bg-white border border-pink-200 rounded-lg hover:border-pink-400 transition group shadow-sm"
                   >
                     <div class="flex items-start gap-2">
                       <div class="w-5 h-5 rounded-full bg-gradient-to-br from-pink-400 to-purple-400 flex items-center justify-center text-[10px] text-white flex-shrink-0">
                         {{ idx + 1 }}
                       </div>
                       <div class="flex-1 min-w-0">
                         <div 
                           contenteditable="true"
                           @blur="updateSentenceText(sentence, $event)"
                           class="text-xs text-gray-800 leading-relaxed outline-none focus:ring-2 focus:ring-pink-300 rounded p-1"
                         >{{ sentence.text }}</div>
                         <div class="flex items-center gap-2 mt-2">
                           <span class="text-[10px] text-gray-500">{{ sentence.duration }}秒</span>
                           <span class="text-[10px] px-1.5 py-0.5 rounded bg-pink-100 text-pink-700">{{ sentence.style }}</span>
                         </div>
                       </div>
                       <div class="flex flex-col gap-1">
                         <button
                           @click.stop="previewVoiceSentence(sentence)"
                           class="p-1.5 text-pink-500 hover:bg-pink-100 rounded transition"
                           title="预览"
                         >
                           <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                             <path d="M6.3 2.841A1.5 1.5 0 004 4.11V15.89a1.5 1.5 0 002.3 1.269l9.344-5.89a1.5 1.5 0 000-2.538L6.3 2.84z" />
                           </svg>
                         </button>
                         <button
                           @click.stop="insertGeneratedVoiceSentence(sentence)"
                           class="p-1.5 text-green-500 hover:bg-green-100 rounded transition"
                           title="插入到文字稿"
                         >
                           <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                             <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                           </svg>
                         </button>
                         <button
                           @click.stop="deleteGeneratedVoiceSentence(sentence.id)"
                           class="p-1.5 text-red-500 hover:bg-red-100 rounded transition"
                           title="删除"
                         >
                           <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                             <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                           </svg>
                         </button>
                       </div>
                     </div>
                   </div>
                 </div>
  </div>
</section>

            <section v-show="openRightPanel==='content_post'">
              <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-indigo-500 rounded-full"></span>
                后期大师 · 智能降噪与剪裁
              </h3>
              <div class="p-4 bg-white border border-pink-200 rounded-lg space-y-4">
                <div class="text-xs font-medium text-gray-900 mb-2">请选择 AI 音频剪辑方案</div>
                <div class="space-y-2.5">
                  <label class="flex items-start gap-2.5 text-sm text-gray-700 cursor-pointer hover:text-pink-600 transition p-2 rounded hover:bg-pink-50 group">
                    <input type="radio" name="cuttingStrategy" class="w-4 h-4 mt-0.5 border-2 border-pink-300 text-pink-600 focus:ring-2 focus:ring-pink-300 focus:ring-offset-0" v-model="cuttingStrategy" value="silence">
                    <div class="flex-1">
                      <div class="font-medium">静音自动切除</div>
                      <div class="text-xs text-gray-500 mt-0.5">自动识别并剔除超过 3s 的无效静音片段</div>
                    </div>
                  </label>
                  <label class="flex items-start gap-2.5 text-sm text-gray-700 cursor-pointer hover:text-pink-600 transition p-2 rounded hover:bg-pink-50 group">
                    <input type="radio" name="cuttingStrategy" class="w-4 h-4 mt-0.5 border-2 border-pink-300 text-pink-600 focus:ring-2 focus:ring-pink-300 focus:ring-offset-0" v-model="cuttingStrategy" value="pause">
                    <div class="flex-1">
                      <div class="font-medium">长停顿缩减</div>
                      <div class="text-xs text-gray-500 mt-0.5">将语气间的长停顿缩减至自然停顿（约 0.5s）</div>
                    </div>
                  </label>
                  <label class="flex items-start gap-2.5 text-sm text-gray-700 cursor-pointer hover:text-pink-600 transition p-2 rounded hover:bg-pink-50 group">
                    <input type="radio" name="cuttingStrategy" class="w-4 h-4 mt-0.5 border-2 border-pink-300 text-pink-600 focus:ring-2 focus:ring-pink-300 focus:ring-offset-0" v-model="cuttingStrategy" value="noise">
                    <div class="flex-1">
                      <div class="font-medium">噪音/呼吸音清理</div>
                      <div class="text-xs text-gray-500 mt-0.5">一键识别并清除底噪、喷麦音或明显的呼吸音</div>
                    </div>
                  </label>
                  <label class="flex items-start gap-2.5 text-sm text-gray-700 cursor-pointer hover:text-pink-600 transition p-2 rounded hover:bg-pink-50 group">
                    <input type="radio" name="cuttingStrategy" class="w-4 h-4 mt-0.5 border-2 border-pink-300 text-pink-600 focus:ring-2 focus:ring-pink-300 focus:ring-offset-0" v-model="cuttingStrategy" value="normalize">
                    <div class="flex-1">
                      <div class="font-medium">人声响度均衡</div>
                      <div class="text-xs text-gray-500 mt-0.5">自动平衡不同嘉宾音量，统一导出标准响度</div>
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
                  <div v-if="audioOptimizeMessage" class="mt-2 text-[11px] text-pink-600 text-center bg-pink-50 py-1 rounded border border-pink-100 animate-pulse">{{ audioOptimizeMessage }}</div>
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
                  <div class="text-xs font-bold text-gray-900 flex items-center gap-1">
                    <svg class="w-3 h-3 text-pink-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" /></svg>
                    音频优化预览
                  </div>
                  <div v-for="group in samplePreview" :key="group.id" class="space-y-2">
                    <div class="text-[11px] px-2 py-1 rounded bg-pink-50 border border-pink-200 text-pink-700 inline-block">{{ group.label }}</div>
                    <div v-for="entry in group.entries" :key="entry.id" class="p-3 bg-white border border-pink-200 rounded">
                      <div class="flex items-center justify-between">
                        <div class="text-[11px] text-gray-600">{{ entry.speaker }} · {{ entry.time }}</div>
                        <span class="text-[10px] px-2 py-0.5 rounded border"
                          :class="{
                            'bg-pink-100 text-pink-800 border-pink-200': entry.type === '静音',
                              'bg-rose-100 text-rose-800 border-rose-200': entry.type === '异常停顿',
                              'bg-blue-100 text-blue-800 border-blue-200': entry.type === '正常停顿',
                            'bg-amber-100 text-amber-800 border-amber-200': entry.type === '噪音',
                              'bg-cyan-100 text-cyan-800 border-cyan-200': entry.type !== '静音' && entry.type !== '异常停顿' && entry.type !== '正常停顿' && entry.type !== '噪音'
                          }">{{ entry.type }}</span>
                      </div>
                      <div class="mt-1 text-xs text-gray-900">{{ entry.content }}</div>
                      <div class="mt-1 flex flex-wrap gap-1">
                        <span v-for="tag in entry.tags" :key="tag.text" class="text-[10px] px-2 py-0.5 rounded border"
                          :class="{
                            'bg-pink-50 text-pink-700 border-pink-100': tag.type === '静音',
                            'bg-rose-50 text-rose-700 border-rose-100': tag.type === '异常停顿',
                            'bg-blue-50 text-blue-700 border-blue-100': tag.type === '正常停顿',
                            'bg-amber-50 text-amber-700 border-amber-100': tag.type === '噪音',
                            'bg-cyan-50 text-cyan-700 border-cyan-100': tag.type !== '静音' && tag.type !== '异常停顿' && tag.type !== '正常停顿' && tag.type !== '噪音'
                          }">{{ tag.text }}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </section>

            <!-- 深度语义搜索与金句定位 -->
            <section v-show="openRightPanel==='highlights'">
              <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-emerald-500 rounded-full"></span>
                高光提取 / 智能金句库
              </h3>
              <div class="p-4 bg-white border border-pink-200 rounded-lg space-y-3">
                <!-- 手动选中的高光金句预览 -->
                <div v-if="showHighlightPreview && selectedText" class="space-y-2 pt-2 border-t border-pink-100">
                  <div class="text-xs font-medium text-gray-900">手动选中的高光金句</div>
                  <div class="p-3 bg-gradient-to-r from-blue-50 to-cyan-50 border border-blue-200 rounded-lg">
                    <div class="text-xs text-gray-900 font-medium mb-2">{{ selectedText }}</div>
                    <div class="flex justify-end gap-2">
                      <button class="text-[10px] px-3 py-1 rounded bg-blue-500 text-white hover:bg-blue-600 transition" @click="addSelectedTextToGoldenSentences">
                        添加到金句库
                      </button>
                    </div>
                  </div>
                </div>
                
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
                    <div v-if="result.recognitionFeature" class="mt-2 rounded-md border border-cyan-200 bg-cyan-50 px-2 py-1 text-[10px] text-cyan-800 leading-snug">
                      <span class="font-semibold">🔍 [TS-RAG 识别特征]：</span>{{ result.recognitionFeature }}
                    </div>
                    <div class="flex items-center justify-between mt-1">
                      <span class="text-[10px] text-pink-600">{{ formatTime(result.startTime) }} - {{ formatTime(result.endTime) }}</span>
                      <span class="px-2 py-0.5 bg-purple-100 text-purple-700 rounded text-[10px]">相关度: {{ result.relevance }}%</span>
                    </div>
                  </div>
                </div>
                <div v-if="topicHeatmap.length" class="pt-2 border-t border-pink-100">
                  <div class="text-xs font-medium text-gray-900 mb-2">话题热度分布</div>
                    <div class="space-y-3">
                      <div v-for="(topic, idx) in topicHeatmap" :key="topic.id" class="flex items-start gap-2">
                        <span class="text-[10px] text-gray-400 w-4 text-right pt-0.5">{{ idx + 1 }}</span>
                        <div class="flex-1 min-w-0">
                          <div class="h-2 mt-1 bg-pink-100 rounded-full overflow-hidden">
                            <div class="h-full bg-gradient-to-r from-pink-400 to-purple-400 rounded-full transition-all"
                              :style="{ width: topic.intensity + '%' }"></div>
                          </div>
                          <div class="mt-1 text-[10px] text-gray-600 whitespace-normal break-words leading-tight">{{ topic.name }}</div>
                        </div>
                        <span class="text-[10px] font-medium text-gray-500 w-9 text-right flex-none pt-0.5">{{ topic.intensity }}%</span>
                    </div>
                  </div>
                </div>
                <div class="pt-2 border-t border-pink-100">
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
                </div>
                <div v-if="goldenSentences.length" class="space-y-2 pt-2">
                  <div class="text-xs font-medium text-gray-900">推荐金句</div>
                  <div v-for="sentence in goldenSentences" :key="sentence.id" class="p-3 bg-gradient-to-r from-yellow-50 to-orange-50 border border-yellow-200 rounded-lg transition">
                    <div class="flex items-start justify-between mb-1">
                      <div class="flex items-center gap-2">
                        <span class="text-[10px] text-gray-600">{{ formatTime(sentence.startTime) }} - {{ formatTime(sentence.endTime) }}</span>
                        <span class="px-2 py-0.5 bg-yellow-200 text-yellow-800 rounded text-[10px] font-medium">金句</span>
                      </div>
                      <div class="flex items-center gap-1">
                        <button class="p-1 rounded hover:bg-yellow-200 text-gray-600" @click.stop="sentence.editing = !sentence.editing" title="编辑">
                          <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 4H7a2 2 0 00-2 2v4m0 0h4m-4 0l9 9m4-13a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"/></svg>
                        </button>
                        <button class="p-1 rounded hover:bg-red-100 text-red-600" @click.stop="deleteGoldenSentence(sentence.id)" title="删除">
                          <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
                        </button>
                      </div>
                    </div>
                    <div v-if="!sentence.editing" class="text-xs text-gray-900 font-medium cursor-pointer mb-2" @click="scrollToGoldenSentence(sentence)">{{ sentence.content }}</div>
                    <div v-else class="flex items-center gap-2 mb-2">
                      <input v-model="sentence.content" class="flex-1 text-xs border border-yellow-300 rounded px-2 py-1" />
                      <button class="text-[10px] px-2 py-0.5 bg-yellow-400 text-white rounded" @click="sentence.editing=false">保存</button>
                      <button class="text-[10px] px-2 py-0.5 bg-white border border-gray-200 rounded" @click="sentence.editing=false">取消</button>
                    </div>
                    <div class="mt-3 space-y-2">
                      <div class="flex items-center justify-between">
                        <div class="flex items-center gap-1.5 text-[11px] text-orange-600">
                          <span>★</span>
                          <span>热度</span>
                        </div>
                        <span class="text-[11px] font-semibold text-gray-700">{{ sentence.viralPotential ?? 0 }}%</span>
                      </div>
                      <div class="h-2 bg-gray-200/80 rounded-full overflow-hidden">
                        <div
                          class="h-full bg-gradient-to-r from-orange-400 to-rose-400 rounded-full transition-all"
                          :style="{ width: `${sentence.viralPotential ?? 0}%` }"
                        ></div>
                      </div>
                      <div class="flex items-center justify-between">
                        <div class="flex items-center gap-1.5 text-[11px] text-blue-600">
                          <span>●</span>
                          <span>逻辑完整度</span>
                        </div>
                        <span class="text-[11px] font-semibold text-gray-700">{{ sentence.logicScore ?? 0 }}%</span>
                      </div>
                      <div class="h-2 bg-gray-200/80 rounded-full overflow-hidden">
                        <div
                          class="h-full bg-gradient-to-r from-blue-400 to-purple-400 rounded-full transition-all"
                          :style="{ width: `${sentence.logicScore ?? 0}%` }"
                        ></div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </section>
            


            <!-- 语音分析 -->
            <section v-if="false">
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

                <!-- 侧边栏：语音转写状态栏 -->
                <div v-if="isTranscribing" class="mt-4 p-3 bg-pink-50 rounded-lg border border-pink-100 animate-pulse">
                  <div class="flex items-center justify-between mb-2">
                    <div class="flex items-center gap-2">
                      <div class="w-4 h-4 border-2 border-pink-500 border-t-transparent rounded-full animate-spin"></div>
                      <span class="text-[11px] font-medium text-pink-700 truncate w-32">{{ transcriptionStatus }}</span>
                    </div>
                    <span class="text-[10px] font-mono text-pink-500">{{ Math.round(transcriptionProgress) }}%</span>
                  </div>
                  <div class="h-1 w-full bg-pink-100 rounded-full overflow-hidden">
                    <div 
                      class="h-full bg-gradient-to-r from-pink-500 to-purple-500 transition-all duration-300"
                      :style="{ width: transcriptionProgress + '%' }"
                    ></div>
                  </div>
                </div>

                <!-- 侧边栏：智能转写分析面板 -->
                <div v-if="showAnalysisPanel && !isTranscribing" class="mt-4 p-4 bg-gradient-to-br from-indigo-50 to-purple-50 rounded-xl border border-indigo-100 shadow-sm animate-fadeIn">
                  <div class="flex items-center justify-between mb-3">
                    <h4 class="text-xs font-bold text-gray-800 flex items-center gap-2">
                      <div class="w-6 h-6 rounded bg-indigo-500 flex items-center justify-center text-white">
                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" /></svg>
                      </div>
                      AI 分析报告
                    </h4>
                    <button @click="showAnalysisPanel = false" class="text-gray-400 hover:text-gray-600">
                      <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
                    </button>
                  </div>
                  
                  <div class="space-y-3">
                    <div>
                      <div class="text-[9px] font-bold text-indigo-400 uppercase tracking-wider mb-1">核心摘要</div>
                      <p class="text-[10px] text-gray-700 leading-relaxed">{{ transcriptionAnalysis.summary }}</p>
                    </div>
                    
                    <div class="flex flex-wrap gap-1">
                      <span v-for="tag in transcriptionAnalysis.keywords" :key="tag" class="px-1.5 py-0.5 bg-white border border-indigo-100 text-indigo-600 text-[9px] rounded-full">
                        #{{ tag }}
                      </span>
                    </div>

                    <div class="pt-2 border-t border-indigo-100/50 space-y-2">
                      <div class="bg-white/50 p-2 rounded-lg">
                        <div class="text-[9px] text-gray-500 mb-1">情感基调</div>
                        <div class="flex items-center gap-2">
                          <span class="text-[10px] font-bold text-gray-800">{{ transcriptionAnalysis.sentiment.label }}</span>
                          <div class="flex-1 h-0.5 bg-gray-100 rounded-full overflow-hidden">
                            <div class="h-full bg-green-400" :style="{ width: (transcriptionAnalysis.sentiment.score * 100) + '%' }"></div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- 侧边栏：转写结果列表 -->
                <div v-if="transcriptionResultSegments.length > 0 && !isTranscribing" class="mt-4 space-y-2">
                  <div class="text-xs font-bold text-gray-900 flex items-center justify-between">
                    <span>转写结果预览</span>
                    <button @click="transcriptionResultSegments = []" class="text-[10px] font-normal text-gray-400 hover:text-gray-600">清空</button>
                  </div>
                  <div class="max-h-[300px] overflow-y-auto pr-1 space-y-2 custom-scrollbar">
                    <div 
                      v-for="(seg, sIdx) in transcriptionResultSegments" 
                      :key="sIdx"
                      class="p-2 bg-gray-50 rounded border border-gray-100 hover:border-pink-200 transition"
                    >
                      <div class="flex items-center justify-between mb-1">
                        <span class="text-[9px] font-mono text-gray-400">{{ formatTime(seg.startTime) }}</span>
                        <span class="px-1 py-0.5 bg-pink-100 text-pink-700 rounded text-[9px]">{{ seg.speaker === 'A' ? '主持人' : '嘉宾' }}</span>
                      </div>
                      <p class="text-[11px] text-gray-700 leading-snug">{{ seg.text }}</p>
                    </div>
                  </div>
                </div>
              </div>
            </section>
            
            <!-- 音频优化 -->
             <section v-if="false">
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
          <div class="text-xs text-gray-500">已同步生成通用 RSS 模板，可直接复制到托管平台发布。</div>
        </div>
        <div class="p-4 border-t border-gray-100 flex justify-end gap-2 bg-gray-50">
          <button @click="showExportSuccess = false" class="px-4 py-2 text-sm bg-pink-500 text-white rounded hover:bg-pink-600">好的</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted, computed, watch, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useProjectStore } from '../../stores/project'
import { useMaterialStore } from '../../stores/material'
import weixinIcon from '../../static/weixin.png'
import douyinIcon from '../../static/douyin.png'
import qqIcon from '../../static/QQ.png'
import xiaohongshuIcon from '../../static/xiaohongshu.png'
import appleIcon from '../../static/Apple播客.png'
import xiaoyuzhouIcon from '../../static/小宇宙.png'
import weiboIcon from '../../static/weibo.png'
import xiaoyuzhouCoverImage from '../../assets/xiaoyuzhou.png'
import wechatImage from '../../assets/wechat.png'
import xiaohongshuImage from '../../assets/xiaohongshu.png'
import weiboImage from '../../assets/weibo.png'
import uneditedAudio from '../../assets/未剪辑版.m4a'
import editedAudio from '../../assets/剪辑版.m4a'
import supplementAudio from '../../assets/补录.m4a'

const route = useRoute()
const router = useRouter()
const projectStore = useProjectStore()
const materialStore = useMaterialStore()

// 状态管理
const currentProject = ref({ name: '未命名项目', id: null })
const PROJECT_DURATION_TEXT = '32:15'
const autoSaveStatus = ref('自动保存 · --:--:--')
const isAssetSidebarCollapsed = ref(false)
const isWorkSidebarCollapsed = ref(false)
const transcriptRepairing = ref(false)
const isPlaying = ref(false)
const currentTime = ref(45)
const audioDuration = ref(1935)
const cuttingStrategy = ref('all')
const cutSuggestions = ref([])
const samplePreview = ref([])
const scriptSuggestions = ref([])
const scriptPreview = ref([])
const isGenerating = ref(false)
const openRightPanel = ref('content_post')
const openEnhancePanel = ref('shownotes')

// 视频预览相关
const exportPreviewVideo = ref(null)
const progressBar = ref(null)

// 文本编辑与同步相关状态
const editingSegmentId = ref(null)
const editingSegmentDraft = ref('')
const editingSegmentOriginalText = ref('')

// AI 总结相关状态
const aiSummaries = ref([])
const isGeneratingAiSummary = ref(false)

// Shownotes 编辑相关状态
const editingTitleIndex = ref(-1)
const editingSummary = ref(false)
const editingTimelineIndex = ref(-1)
const editingTimelineDescIndex = ref(-1)

// 思维导图编辑相关状态
const editingMindMapRoot = ref(false)
const editingMindMapNode = ref(-1)
const editingMindMapChild = ref('')

// 视频预览播放相关状态
const isVideoPlaying = ref(false)
const videoCurrentTime = ref(0)
const videoDuration = ref(30) // 默认30秒
const videoWaveformBars = ref(Array(50).fill(0).map(() => 0.3 + Math.random() * 0.7))
let videoPlayInterval = null
let autoSaveInterval = null
let transcriptRepairTimer = null
let aiSummaryRefreshTimer = null
let aiSummaryRefreshPending = false
let scriptOptimizationHighlightTimer = null

// 导出预览播放相关状态
const exportAudioRef = ref(null)
const exportAudioPlaying = ref(false)
const exportAudioCurrentTime = ref(0)

const toggleExportPlay = () => {
  const el = exportAudioRef.value
  if (!el) return
  if (el.paused) {
    const p = el.play()
    if (p && typeof p.catch === 'function') p.catch(() => {})
  } else {
    el.pause()
  }
}

const onExportAudioPlay = () => { exportAudioPlaying.value = true }
const onExportAudioPause = () => { exportAudioPlaying.value = false }
const onExportAudioTimeUpdate = (e) => { exportAudioCurrentTime.value = Math.floor(e.target.currentTime || 0) }

// 导出预览视频播放状态
const exportPreviewPlaying = ref(false)
const showExportPreviewControl = ref(true)

const toggleExportPreviewPlay = () => {
  const el = exportPreviewVideo.value
  if (!el) return
  if (el.paused) {
    const p = el.play()
    if (p && typeof p.catch === 'function') p.catch(() => {})
    showExportPreviewControl.value = false
  } else {
    el.pause()
    showExportPreviewControl.value = true
  }
}

const handleExportPreviewVideoClick = () => {
  if (exportPreviewPlaying.value) {
    showExportPreviewControl.value = true
  }
}

const onExportVideoPlay = () => {
  exportPreviewPlaying.value = true
  showExportPreviewControl.value = false
}
const onExportVideoPause = () => {
  exportPreviewPlaying.value = false
  showExportPreviewControl.value = true
}

const refreshAutoSaveStatus = () => {
  const currentRefreshTime = new Date().toLocaleTimeString('zh-CN', { hour12: false })
  autoSaveStatus.value = `自动保存 · ${currentRefreshTime}`
}

const stepNavRef = ref(null)
const stepNodeRefs = ref([])
const navProgressTop = ref(56)
const navProgressHeight = ref(220)
const navProgressFillHeight = ref(0)

const setStepNodeRef = (el, index) => {
  if (el) stepNodeRefs.value[index] = el
}

const navProgressTrackStyle = computed(() => ({
  top: `${Math.max(0, navProgressTop.value)}px`,
  height: `${Math.max(0, navProgressHeight.value)}px`
}))

const navProgressFillStyle = computed(() => ({
  height: `${Math.max(0, Math.min(navProgressFillHeight.value, navProgressHeight.value))}px`
}))

const syncStepNavProgress = () => {
  const navEl = stepNavRef.value
  const nodes = stepNodeRefs.value.filter(Boolean)
  if (!navEl || nodes.length === 0) return

  const navRect = navEl.getBoundingClientRect()
  const centers = nodes.map((node) => {
    const rect = node.getBoundingClientRect()
    return rect.top - navRect.top + rect.height / 2
  })

  const firstCenter = centers[0]
  const lastCenter = centers[centers.length - 1]
  navProgressTop.value = firstCenter
  navProgressHeight.value = Math.max(0, lastCenter - firstCenter)

  const active = Math.max(0, Math.min(stepIndex.value, centers.length - 1))
  const currentCenter = centers[active] ?? firstCenter
  navProgressFillHeight.value = Math.max(0, currentCenter - firstCenter)
}

const toggleAssetSidebar = () => {
  isAssetSidebarCollapsed.value = !isAssetSidebarCollapsed.value
}

const toggleWorkSidebar = () => {
  isWorkSidebarCollapsed.value = !isWorkSidebarCollapsed.value
}

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

watch(editingSegmentId, (index) => {
  if (index === null || index === undefined) {
    editingSegmentDraft.value = ''
    editingSegmentOriginalText.value = ''
    return
  }
  const segment = mockTranscript.value[index]
  if (!segment) return
  if (!segment.isEditing && !segment.text.startsWith('[TTS]')) {
    ensureSegmentOriginalText(segment)
    const editable = getEditableSegmentText(segment.text || '')
    editingSegmentOriginalText.value = segment.originalText || editable
    editingSegmentDraft.value = editable
  }
})

// (moved) export forecast auto-trigger watch is defined after activeToolTab

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
  // 把连续省略号也纳入口癖冗余，便于统一高亮与清理
  const mainRegex = new RegExp(`(~~.*?~~|\\+\\+.*?\\+\\+|\\.{3,}|…+|${fillerRegex})`, 'g')
  const parts = processText.split(mainRegex)
  parts.forEach(part => {
    if (!part) return
    if (part.startsWith('~~') && part.endsWith('~~')) {
      tokens.push({ type: 'deleted', text: part.substring(2, part.length - 2), isTTS })
      return
    }
    if (part.startsWith('++') && part.endsWith('++')) {
      tokens.push({ type: 'corrected', text: part.substring(2, part.length - 2), isTTS })
      return
    }
    if (new RegExp(`^(${fillerRegex})$`).test(part)) {
      tokens.push({ type: 'filler', text: part, isTTS })
      return
    }
    if (/^(\.{3,}|…+)$/.test(part)) {
      tokens.push({ type: 'pause', text: part, isTTS })
      return
    }
    const wordRegex = /(\s+|[，。！？、；：,.!?…—-])/g
                const subs = part.split(wordRegex)
                // 口吃匹配：仅识别 3 连及以上重复字，避免把“聊聊”等正常叠词误判为口癖
                const stutterPattern = /([\u4e00-\u9fa5A-Za-z])\1{2,}/g
                
                subs.forEach(sub => {
                  if (!sub) return
                  if (wordRegex.test(sub)) {
                    tokens.push({ type: 'space', text: sub, isTTS })
                  } else {
                    // 对每一个子段落，进一步拆分出口吃部分
                    let lastIndex = 0
                    let match
                    const subText = sub
                    
                    while ((match = stutterPattern.exec(subText)) !== null) {
                      // 匹配前的正常文本
                      if (match.index > lastIndex) {
                        tokens.push({ 
                          type: 'text', 
                          text: subText.substring(lastIndex, match.index), 
                          isTTS 
                        })
                      }
                      // 口吃部分
                      tokens.push({ 
                        type: 'stutter', 
                        text: match[0], 
                        isTTS 
                      })
                      lastIndex = stutterPattern.lastIndex
                    }
                    
                    // 剩余的正常文本
                    if (lastIndex < subText.length) {
                      tokens.push({ 
                        type: 'text', 
                        text: subText.substring(lastIndex), 
                        isTTS 
                      })
                    }
                  }
                })
  })
  return tokens
}

const isPauseContextToken = (token) => {
  if (!token || token.type === 'space') return false
  if (token.type !== 'deleted') return true
  return ['呃', '嗯', '啊', '诶', '额', '那个', '怎么说呢', '你知道', '对吧'].some(word => token.text.includes(word)) || /[，,：:；;]$/.test(token.text)
}

const getStableRandomInRange = (seedText, min, max) => {
  const seed = Array.from(String(seedText || '')).reduce((acc, char) => {
    return ((acc * 31) + char.codePointAt(0)) >>> 0
  }, 0)
  const normalized = (seed % 1000) / 999
  return Number((min + (max - min) * normalized).toFixed(1))
}

const getPauseTokenMeta = (segment, tokenIndex) => {
  const tokens = parseSegmentText(segment?.text || '')
  const token = tokens[tokenIndex]
  if (!token || token.type !== 'pause') return null

  let prevToken = null
  for (let i = tokenIndex - 1; i >= 0; i--) {
    if (isPauseContextToken(tokens[i])) {
      prevToken = tokens[i]
      break
    }
  }

  let nextToken = null
  for (let i = tokenIndex + 1; i < tokens.length; i++) {
    if (isPauseContextToken(tokens[i])) {
      nextToken = tokens[i]
      break
    }
  }

  const pauseText = token.text || ''
  const rawLength = Array.from(pauseText).length
  const prevText = prevToken?.text || ''
  const nextText = nextToken?.text || ''
  const hesitationHints = ['呃', '嗯', '啊', '诶', '额', '那个', '怎么说呢', '你知道', '对吧']
  const looksAbnormal = hesitationHints.some(word => prevText.includes(word) || nextText.includes(word)) || /[，,：:；;]$/.test(prevText)
  const durationSeed = [segment?.speaker || '', segment?.startTime ?? '', tokenIndex, pauseText, prevText, nextText, rawLength].join('|')
  const seconds = looksAbnormal
    ? getStableRandomInRange(durationSeed, 0.5, 1.5)
    : getStableRandomInRange(durationSeed, 0.0, 0.5)

  return {
    isAbnormal: looksAbnormal,
    label: looksAbnormal ? '异常停顿' : '正常停顿',
    durationText: `${seconds.toFixed(1)}s`,
    title: looksAbnormal
      ? `异常停顿 · ${seconds.toFixed(1)}s，建议删除`
      : `正常停顿 · ${seconds.toFixed(1)}s，建议保留`
  }
}

// 切换文本的删除状态（留痕模式，跳过空白）
const toggleTokenDelete = (segment, tokenIndex) => {
  const tokens = parseSegmentText(segment.text)
  const token = tokens[tokenIndex]
  if (!token || token.type === 'space') return
  
  if (token.type === 'corrected') {
    // 撤回逻辑纠错：移除 ++ 标记，恢复原文
    const rawText = segment.text.replace(/\+\+([^+]+)\+\+/g, '$1')
    segment.text = rawText
    return
  }

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
  recalculateTranscriptDurationsFromText()
}

const restoreDeletedChar = (segment, tokenIndex, charIndex) => {
  if (!segment) return
  const tokens = parseSegmentText(segment.text)
  const token = tokens[tokenIndex]
  if (!token || token.type !== 'deleted') return

  const chars = Array.from(token.text)
  if (charIndex < 0 || charIndex >= chars.length) return

  const before = chars.slice(0, charIndex).join('')
  const restoredChar = chars[charIndex]
  const after = chars.slice(charIndex + 1).join('')
  const replacement = []

  if (before) replacement.push({ ...token, text: before, type: 'deleted' })
  replacement.push({ ...token, text: restoredChar, type: 'text' })
  if (after) replacement.push({ ...token, text: after, type: 'deleted' })

  tokens.splice(tokenIndex, 1, ...replacement)
  rebuildSegmentText(segment, tokens)
  recalculateTranscriptDurationsFromText()
}

const rebuildSegmentText = (segment, tokens) => {
  const prefix = segment.text.startsWith('[TTS]') ? '[TTS]' : ''
  const contentText = tokens.map(t => (t.type === 'deleted' ? `~~${t.text}~~` : t.text)).join('')
  segment.text = prefix + contentText
}

const getSelectionOffsetsInContainer = (selection, container) => {
  if (!selection || selection.rangeCount === 0 || !container) return null
  const range = selection.getRangeAt(0)
  const startRange = range.cloneRange()
  startRange.selectNodeContents(container)
  startRange.setEnd(range.startContainer, range.startOffset)

  const endRange = range.cloneRange()
  endRange.selectNodeContents(container)
  endRange.setEnd(range.endContainer, range.endOffset)

  const start = startRange.toString().length
  const end = endRange.toString().length
  return { start: Math.min(start, end), end: Math.max(start, end) }
}

const deleteBySelectionRange = (segment, start, end) => {
  if (end <= start) return
  const tokens = parseSegmentText(segment.text)
  let cursor = 0

  tokens.forEach(token => {
    const tokenStart = cursor
    const tokenEnd = cursor + token.text.length
    cursor = tokenEnd

    if (token.type === 'space' || token.type === 'deleted') return
    const hasOverlap = tokenStart < end && tokenEnd > start
    if (hasOverlap) {
      token.type = 'deleted'
    }
  })

  rebuildSegmentText(segment, tokens)
}

const deleteSingleCharAtCaret = (segment, caretOffset, isBackspace) => {
  const targetOffset = isBackspace ? caretOffset - 1 : caretOffset
  if (targetOffset < 0) return false

  const tokens = parseSegmentText(segment.text)
  let cursor = 0

  for (let i = 0; i < tokens.length; i++) {
    const token = tokens[i]
    const tokenStart = cursor
    const tokenEnd = cursor + token.text.length
    cursor = tokenEnd

    if (targetOffset < tokenStart || targetOffset >= tokenEnd) continue
    if (token.type === 'deleted' || token.type === 'space') return false

    const localIndex = targetOffset - tokenStart
    const chars = Array.from(token.text)
    if (localIndex < 0 || localIndex >= chars.length) return false

    const before = chars.slice(0, localIndex).join('')
    const deletedChar = chars[localIndex]
    const after = chars.slice(localIndex + 1).join('')

    const replacement = []
    if (before) replacement.push({ ...token, text: before })
    replacement.push({ type: 'deleted', text: deletedChar, isTTS: token.isTTS })
    if (after) replacement.push({ ...token, text: after })

    tokens.splice(i, 1, ...replacement)
    rebuildSegmentText(segment, tokens)
    return true
  }

  return false
}

// 处理文本选择事件
const handleTextSelection = () => {
  // 文字稿删除编辑态下，选区仅用于删除，不联动高光库
  if (editingSegmentId.value !== null) {
    selectedText.value = ''
    showHighlightPreview.value = false
    return
  }
  const selection = window.getSelection()
  const text = selection.toString().trim()
  if (text) {
    selectedText.value = text
    showHighlightPreview.value = true
    // 检查是否在编辑TTS内容，如果是则不自动切换到高光金句面板
    const activeElement = document.activeElement
    const isEditingTTS = activeElement && activeElement.getAttribute('contenteditable') === 'true'
    if (!isEditingTTS) {
      
    }
  } else {
    showHighlightPreview.value = false
  }
}

const startSegmentEditing = (index) => {
  const segment = mockTranscript.value[index]
  if (!segment) return
  editingSegmentId.value = index
  ensureSegmentOriginalText(segment)
  const originalText = getEditableSegmentText(segment.text || '')
  editingSegmentOriginalText.value = segment.originalText || originalText
  editingSegmentDraft.value = originalText
}

const getEditableSegmentText = (text = '') => {
  return (text || '')
    .replace(/^\[TTS\]/, '')
    .replace(/~~[^~]+~~/g, '')
    .replace(/\+\+([^+]+)\+\+/g, '$1')
}

const ensureSegmentOriginalText = (segment) => {
  if (!segment) return ''
  if (!segment.originalText) {
    segment.originalText = getEditableSegmentText(segment.text || '')
  }
  return segment.originalText
}

const buildTextWithDeletionMarks = (originalText = '', editedText = '') => {
  const oldChars = Array.from(originalText)
  const newChars = Array.from(editedText)
  const m = oldChars.length
  const n = newChars.length

  const dp = Array.from({ length: m + 1 }, () => Array(n + 1).fill(0))
  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      if (oldChars[i - 1] === newChars[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1] + 1
      } else {
        dp[i][j] = Math.max(dp[i - 1][j], dp[i][j - 1])
      }
    }
  }

  const chunks = []
  let i = m
  let j = n
  while (i > 0 || j > 0) {
    if (i > 0 && j > 0 && oldChars[i - 1] === newChars[j - 1]) {
      chunks.push({ type: 'text', value: oldChars[i - 1] })
      i--
      j--
      continue
    }
    if (i > 0 && (j === 0 || dp[i - 1][j] >= dp[i][j - 1])) {
      chunks.push({ type: 'deleted', value: oldChars[i - 1] })
      i--
      continue
    }
    if (j > 0) {
      chunks.push({ type: 'inserted', value: newChars[j - 1] })
      j--
    }
  }

  chunks.reverse()
  const merged = []
  chunks.forEach((chunk) => {
    const prev = merged[merged.length - 1]
    if (prev && prev.type === chunk.type) {
      prev.value += chunk.value
    } else {
      merged.push({ ...chunk })
    }
  })

  return merged.map((chunk) => {
    if (chunk.type === 'deleted') return `~~${chunk.value}~~`
    if (chunk.type === 'inserted') return `++${chunk.value}++`
    return chunk.value
  }).join('')
}

const saveSegmentEditing = (index) => {
  const segment = mockTranscript.value[index]
  if (!segment) return
  const originalText = ensureSegmentOriginalText(segment) || editingSegmentOriginalText.value || ''
  segment.text = buildTextWithDeletionMarks(
    originalText,
    editingSegmentDraft.value || ''
  )
  recalculateTranscriptDurationsFromText()
  editingSegmentId.value = null
  editingSegmentDraft.value = ''
  editingSegmentOriginalText.value = ''
}

const cancelSegmentEditing = () => {
  editingSegmentId.value = null
  editingSegmentDraft.value = ''
  editingSegmentOriginalText.value = ''
}

const onSegmentEditorKeydown = (event, index) => {
  if ((event.ctrlKey || event.metaKey) && event.key === 'Enter') {
    event.preventDefault()
    event.target?.blur()
    saveSegmentEditing(index)
  }
}

const confirmNewInlineEdit = (index) => {
  const segment = mockTranscript.value[index]
  if (!segment) return
  segment.isEditing = false
  editingSegmentId.value = null
  recalculateTranscriptDurationsFromText()
}

// 声演实验室补录状态
const ttsInsertIndex = ref(null)
const generatedSentence = ref('')
const ttsInsertPosition = ref('after') // before | after | middle
const ttsMiddleDraftText = ref('')
const isMiddleSupplementing = ref(false)
const middleSupplementProgress = ref(0)

// 插入 TTS 片段（待确认）
const insertTTS = (index) => {
  // 记录插入位置
  ttsInsertIndex.value = index
  ttsInsertPosition.value = 'after'
  ttsMiddleDraftText.value = ''
  // 打开声演实验室
  openRightPanel.value = 'voice' // 切换到声演实验室面板
}

const getCleanSegmentText = (text = '') => {
  return text
    .replace(/^\[TTS\]/, '')
    // 已留痕删除的口癖在后续模块中应视为“已删除”
    .replace(/~~[^~]+~~/g, '')
    .replace(/\+\+([^+]+)\+\+/g, '$1')
    .replace(/\s+/g, ' ')
    .trim()
}

const segmentTextLengthSnapshot = ref([])
const SEGMENT_MIN_DURATION_SECONDS = 1
// 时长微调系数：每新增/删除 1 个字，约 ±1 秒
const SEGMENT_SECONDS_PER_CHAR_DELTA = 1

const getSegmentEffectiveTextLength = (text = '') => {
  const cleanText = getCleanSegmentText(text).replace(/\s+/g, '')
  return Array.from(cleanText).length
}

const syncSegmentTextLengthSnapshot = () => {
  segmentTextLengthSnapshot.value = (mockTranscript.value || []).map((seg) =>
    getSegmentEffectiveTextLength(seg.text || '')
  )
}

const recalculateTranscriptDurationsFromText = () => {
  if (!mockTranscript.value?.length) return
  if (segmentTextLengthSnapshot.value.length !== mockTranscript.value.length) {
    syncSegmentTextLengthSnapshot()
  }

  const nextLengths = mockTranscript.value.map((segment) => getSegmentEffectiveTextLength(segment.text || ''))
  let cursor = 0
  mockTranscript.value.forEach((segment, index) => {
    const previousLength = segmentTextLengthSnapshot.value[index] ?? nextLengths[index]
    const deltaChars = nextLengths[index] - previousLength
    const previousDuration = Math.max(
      SEGMENT_MIN_DURATION_SECONDS,
      (Number(segment.endTime) || 0) - (Number(segment.startTime) || 0)
    )
    const nextDuration = Math.max(
      SEGMENT_MIN_DURATION_SECONDS,
      previousDuration + deltaChars * SEGMENT_SECONDS_PER_CHAR_DELTA
    )

    segment.startTime = Number(cursor.toFixed(2))
    cursor += nextDuration
    segment.endTime = Number(cursor.toFixed(2))
  })

  segmentTextLengthSnapshot.value = nextLengths
  audioDuration.value = Math.max(1, Number(cursor.toFixed(2)))
  totalAudioDuration.value = audioDuration.value
  currentProjectExport.value.duration = formatDurationMMSS(Math.round(audioDuration.value))
  if (currentTime.value > audioDuration.value) {
    currentTime.value = audioDuration.value
  }

  scheduleAISummaryRefresh()
}

const scheduleAISummaryRefresh = () => {
  if (aiSummaryRefreshTimer) {
    clearTimeout(aiSummaryRefreshTimer)
  }
  aiSummaryRefreshTimer = setTimeout(() => {
    aiSummaryRefreshTimer = null
    if (mockTranscript.value.length === 0) {
      aiSummaries.value = []
      return
    }
    if (isGeneratingAiSummary.value) {
      aiSummaryRefreshPending = true
      return
    }
    generateAISummaries()
  }, 250)
}

const getCurrentTTSBaseText = () => {
  if (ttsInsertIndex.value === null) return ''
  const seg = mockTranscript.value[ttsInsertIndex.value]
  return getCleanSegmentText(seg?.text || '')
}

watch(ttsInsertPosition, (pos) => {
  if (pos !== 'middle') return
  const baseText = getCurrentTTSBaseText()
  if (baseText) {
    ttsMiddleDraftText.value = baseText
  }
})

// 确认 TTS 片段内容
const confirmTTS = async (index) => {
  const seg = mockTranscript.value[index]
  if (!seg || !seg.text.startsWith('[TTS]')) return

  // ========== 【开始：假装生成进度条】 ==========
  isGeneratingTTS.value = true
  generateProgress.value = 0

  await new Promise((resolve) => {
    const timer = setInterval(() => {
      generateProgress.value += 6
      if (generateProgress.value >= 100) {
        clearInterval(timer)
        resolve()
      }
    }, 100)
  })
  // ========== 【结束：假装生成进度条】 ==========

  // 下面是你原来的逻辑，完全不动
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

  // 关闭加载状态
  isGeneratingTTS.value = false
}

// 删除 TTS 片段
const deleteTTSSegment = (index) => {
  const seg = mockTranscript.value[index]
  if (!seg || !seg.text.startsWith('[TTS]')) return
  mockTranscript.value.splice(index, 1)
  recalculateTranscriptDurationsFromText()
}



// 插入生成的句子
const insertGeneratedSentence = () => {
  if (!generatedSentence.value || ttsInsertIndex.value === null) return
  
  const baseSeg = mockTranscript.value[ttsInsertIndex.value]
  const baseEnd = baseSeg?.endTime ?? 0
  const newSeg = createTranscriptSegment({
    startTime: baseEnd,
    endTime: baseEnd + 5,
    speaker: 'AI',
    text: generatedSentence.value,
    originalText: getCleanSegmentText(baseSeg?.text || ''),
    confirmed: true
  })
  
  mockTranscript.value.splice(ttsInsertIndex.value + 1, 0, newSeg)
  recalculateTranscriptDurationsFromText()
  
  // 重置状态
  ttsInsertIndex.value = null
}

// 从声演实验室插入生成的句子
const insertGeneratedVoiceSentence = (sentence) => {
  if (!sentence || ttsInsertIndex.value === null) return
  
  const baseIdx = ttsInsertIndex.value
  const baseSeg = mockTranscript.value[baseIdx]
  if (!baseSeg) return

  const ttsDuration = sentence.duration || 5
  const ttsText = ttsInsertPosition.value === 'middle'
    ? (ttsMiddleDraftText.value?.trim() || sentence.text)
    : sentence.text
  const newSeg = createTranscriptSegment({
    startTime: baseSeg.endTime,
    endTime: baseSeg.endTime + ttsDuration,
    speaker: 'AI',
    text: ttsInsertPosition.value === 'middle' ? '[TTS]' + ttsText : ttsText,
    originalText: getCleanSegmentText(baseSeg?.text || ''),
    confirmed: true,
    voiceLabGenerated: true
  })

  const sentenceAudioUrl = sentence.audioUrl || supplementAudio
  newSeg.audioUrl = sentenceAudioUrl

  if (ttsInsertPosition.value === 'before') {
    newSeg.startTime = baseSeg.startTime
    newSeg.endTime = baseSeg.startTime + ttsDuration
    mockTranscript.value.splice(baseIdx, 0, newSeg)
    recalculateTranscriptDurationsFromText()
  } else if (ttsInsertPosition.value === 'middle') {
    // 句中补录：改写原句本身，不新增文字稿行
    const updatedText = ttsMiddleDraftText.value?.trim() || ttsText
    baseSeg.originalText = getCleanSegmentText(baseSeg.text)
    baseSeg.text = updatedText
    baseSeg.confirmed = true
    baseSeg.voiceLabGenerated = true
    recalculateTranscriptDurationsFromText()
  } else {
    mockTranscript.value.splice(baseIdx + 1, 0, newSeg)
    recalculateTranscriptDurationsFromText()
  }
  
  // 重置状态
  ttsInsertIndex.value = null
  // 为补录结果落一条时间轴 clip，便于播放与导出
  let aiTrack = tracks.value.find(t => t.name.includes('AI'))
  if (!aiTrack) {
    aiTrack = {
      id: Date.now() + 10,
      name: 'AI 合成',
      type: '音频',
      color: 'bg-[#8B5CF6]',
      muted: false,
      solo: false,
      volume: 80,
      pan: 0,
      collapsed: false,
      locked: false,
      recording: false,
      clips: []
    }
    tracks.value.push(aiTrack)
  }
  const clip = {
    id: Date.now() + 11,
    name: '声演补录',
    start: newSeg.startTime,
    end: newSeg.endTime,
    audioUrl: sentenceAudioUrl,
    color: 'bg-gradient-to-r from-[#8B5CF6]/80 to-[#A78BFA]/80 border-[#A78BFA]',
    fadeIn: false,
    fadeOut: false
  }
  aiTrack.clips.push(clip)
  ttsInsertPosition.value = 'after'
  ttsMiddleDraftText.value = ''
  
  // 显示成功提示
  audioOptimizeMessage.value = '已插入到文字稿'
  setTimeout(() => {
    audioOptimizeMessage.value = ''
  }, 2000)
}

const insertMiddleDraftToTranscript = async () => {
  if (ttsInsertIndex.value === null) return
  const text = ttsMiddleDraftText.value?.trim()
  if (!text || isMiddleSupplementing.value) return

  isMiddleSupplementing.value = true
  middleSupplementProgress.value = 0

  try {
    await new Promise((resolve) => {
      const timer = setInterval(() => {
        middleSupplementProgress.value = Math.min(96, middleSupplementProgress.value + 8)
        if (middleSupplementProgress.value >= 96) {
          clearInterval(timer)
          resolve()
        }
      }, 120)
    })

    await new Promise((resolve) => setTimeout(resolve, 220))
    middleSupplementProgress.value = 100

    insertGeneratedVoiceSentence({
      id: `middle-${Date.now()}`,
      text,
      duration: Math.max(3, Math.min(15, Math.ceil(text.length / 8))),
      style: '句中补录'
    })
  } finally {
    isMiddleSupplementing.value = false
    middleSupplementProgress.value = 0
  }

}

// 跳转到内容增值页面
const goToContentEnhance = () => {
  console.log('goToContentEnhance called')
  console.log('router:', router)
  // 立即切换本地视图，确保按钮点击后有反馈
  activeToolTab.value = 'enhance'
  openEnhancePanel.value = 'shownotes'
  podcastType.value = 'interview'
  // 同步路由状态（便于刷新/分享链接）
  router.push({ path: '/clip-studio', query: { ...route.query, tab: 'enhance' } })
}

const isSavingToEnhance = ref(false)
const saveAndGoToContentEnhance = async () => {
  if (isSavingToEnhance.value) return
  isSavingToEnhance.value = true
  try {
    // 模拟“保存/导出草稿”动作，便于首次进入剪辑后的流程闭环
    await new Promise(resolve => setTimeout(resolve, 700))
    const draftWork = {
      id: 'enhance-ready-' + Date.now(),
      title: currentProject.value?.name ? `${currentProject.value.name} · 剪辑稿` : '剪辑稿',
      createdAt: new Date().toISOString(),
      description: '来自剪辑工作台的一键保存稿，可继续内容增值处理',
      tags: ['剪辑稿', '待增值'],
      audioUrl: editedAudio
    }
    localStorage.setItem('lastExportedWork', JSON.stringify(draftWork))
    goToContentEnhance()
  } catch (e) {
    console.warn('保存并跳转失败', e)
  } finally {
    isSavingToEnhance.value = false
  }
}

// 将选中的文本添加到金句库
const addSelectedTextToGoldenSentences = () => {
  if (!selectedText.value) return
  
  const newGoldenSentence = {
    id: Date.now(),
    content: selectedText.value,
    startTime: 0,
    endTime: 0,
    segmentIndex: 0,
    ...buildGoldenMetrics(selectedText.value, { hasEnding: /[。！？!?]$/.test(selectedText.value) }),
    editing: false,
    highlight: true
  }
  
  goldenSentences.value.unshift(newGoldenSentence)
  
  // 重置状态
  selectedText.value = ''
  showHighlightPreview.value = false
  
  // 显示成功提示
  alert('已添加到金句库')
}

// 标记或取消标记金句
const toggleGoldenSentence = (segment, index) => {
  segment.isGolden = !segment.isGolden
  
  if (segment.isGolden) {
    // 已存在则不重复添加
    if (goldenSentences.value.some(s => s.segmentIndex === index)) {
      alert('已标记为金句')
      return
    }
    // 添加到金句库
    const newGoldenSentence = {
      id: Date.now(),
      content: getCleanSegmentText(segment.text),
      startTime: segment.startTime,
      endTime: segment.endTime,
      segmentIndex: index,
      ...buildGoldenMetrics(getCleanSegmentText(segment.text), { hasEnding: /[。！？!?]$/.test(getCleanSegmentText(segment.text)) }),
      editing: false,
      highlight: true
    }
    goldenSentences.value.unshift(newGoldenSentence)
   
  } else {
    // 从金句库中移除
    goldenSentences.value = goldenSentences.value.filter(sentence => sentence.segmentIndex !== index)

  }
  openRightPanel.value = 'highlights'  // ✅ 100% 正确

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
const isGeneratingTTS = ref(false)       // 生成中状态


const cleanSummarySourceText = (text = '') => {
  return (text || '')
    .replace(/\[TTS\]/g, '')
    .replace(/~~[^~]+~~/g, '')
    .replace(/\+\+([^+]+)\+\+/g, '$1')
    .replace(/\s+/g, ' ')
    .trim()
}

const splitSummarySentences = (text = '') => {
  return (text || '')
    .split(/[。！？!?]/)
    .map(line => line.trim())
    .filter(line => line.length >= 6)
}

const normalizeSummaryClause = (text = '') => {
  return (text || '')
    .replace(/[，,、；;]{2,}/g, '，')
    .replace(/([，,、；;])\1+/g, '$1')
    .replace(/\s+/g, '')
    .replace(/^[，,、；;:.。！？!?]+/, '')
    .replace(/[，,、；;:.。！？!?]+$/, '')
    .trim()
}

const trimClauseLength = (text = '', maxLength = 26) => {
  const normalized = normalizeSummaryClause(text)
  if (!normalized) return ''
  if (normalized.length <= maxLength) return normalized
  return `${normalized.slice(0, maxLength - 1)}…`
}

const buildAISummarySections = (segments = []) => {
  if (!segments.length) return []
  if (segments.length <= 3) {
    return [{
      startIndex: 0,
      endIndex: segments.length - 1,
      segments
    }]
  }

  const preferredCount = Math.max(2, Math.min(6, Math.round(Math.sqrt(segments.length))))
  const desiredBoundaryCount = preferredCount - 1
  const transitionStarts = ['然后', '接下来', '另外', '最后', '回到', '总结', '所以', '但是', '不过', '此外']
  const questionStarts = ['为什么', '怎么', '如何', '是否', '能否', '要不要']

  const boundaries = []
  for (let i = 0; i < segments.length - 1; i++) {
    const current = segments[i]
    const next = segments[i + 1]
    const currentText = cleanSummarySourceText(current.text)
    const nextText = cleanSummarySourceText(next.text)
    const gapSeconds = Math.max(0, (next.startTime ?? 0) - (current.endTime ?? 0))

    let score = 0
    if ((current.speaker || '') !== (next.speaker || '')) score += 2
    if (/[。！？!?]$/.test(currentText)) score += 1
    if (transitionStarts.some(token => nextText.startsWith(token))) score += 2
    if (questionStarts.some(token => nextText.startsWith(token))) score += 1
    if (gapSeconds >= 6) score += 1
    if (Math.abs(nextText.length - currentText.length) >= 24) score += 1

    boundaries.push({ index: i, score })
  }

  const chosenBoundaryIndexes = boundaries
    .filter(item => item.score >= 2)
    .sort((a, b) => b.score - a.score)
    .slice(0, desiredBoundaryCount)
    .map(item => item.index)
    .sort((a, b) => a - b)

  const sections = []
  let start = 0
  chosenBoundaryIndexes.forEach(boundaryIndex => {
    sections.push({
      startIndex: start,
      endIndex: boundaryIndex,
      segments: segments.slice(start, boundaryIndex + 1)
    })
    start = boundaryIndex + 1
  })
  if (start <= segments.length - 1) {
    sections.push({
      startIndex: start,
      endIndex: segments.length - 1,
      segments: segments.slice(start)
    })
  }

  // 兜底：如果切分太碎，按邻近段落合并到每段至少 2 句
  const merged = []
  sections.forEach(section => {
    const prev = merged[merged.length - 1]
    if (prev && section.segments.length < 2) {
      prev.endIndex = section.endIndex
      prev.segments = segments.slice(prev.startIndex, section.endIndex + 1)
      return
    }
    merged.push({ ...section })
  })

  return merged
}

const composeAISummaryText = (section) => {
  const textContent = section.segments.map(s => cleanSummarySourceText(s.text)).join(' ')
  const sentenceCandidates = splitSummarySentences(textContent)

  if (!sentenceCandidates.length) return '这段主要是围绕同一话题的延展讨论。'

  const keywords = extractKeywords(textContent)
    .filter(word => word.length >= 2 && !/^[0-9]+$/.test(word))
    .slice(0, 6)

  const themeWords = keywords.slice(0, 2)
  const detailWords = keywords.slice(2, 5)

  const viewpointSentences = sentenceCandidates
    .map((sentence, index) => {
      let score = 0
      if (sentence.length >= 10 && sentence.length <= 42) score += 6
      else if (sentence.length >= 7 && sentence.length <= 56) score += 4
      else score += 1
      if (/(认为|指出|提到|强调|讨论|分享|解释|建议|担心|关注|希望)/.test(sentence)) score += 4
      if (/(关键|核心|本质|结论|重点|价值|方法|策略|方向|问题|方案)/.test(sentence)) score += 3
      if (/(因为|所以|因此|导致|背后|原因|结果)/.test(sentence)) score += 2
      score += Math.max(0, 3 - index)
      return { sentence, score }
    })
    .sort((a, b) => b.score - a.score)
    .map(item => trimClauseLength(item.sentence, 36))
    .filter(Boolean)

  const topViewpoints = viewpointSentences
    .filter((item, index, arr) => arr.indexOf(item) === index)
    .slice(0, 2)

  const themePart = themeWords.length
    ? `这段对话主要在聊${themeWords.join('和')}`
    : '这段对话主要围绕核心话题展开'

  const detailPart = detailWords.length ? `也提到了${detailWords.join('、')}` : ''

  const viewpointPart = topViewpoints.length
    ? `核心意思是：${topViewpoints.join('；')}`
    : ''

  const summary = [themePart, detailPart, viewpointPart].filter(Boolean).join('，')

  const normalized = `${normalizeSummaryClause(summary)}。`
  if (normalized.length <= 100) return normalized
  return `${normalized.slice(0, 99)}…`
}

// AI 总结生成函数
const generateAISummaries = async () => {
  if (isGeneratingAiSummary.value) {
    aiSummaryRefreshPending = true
    return
  }
  if (mockTranscript.value.length === 0) return

  isGeneratingAiSummary.value = true
  try {
    const sections = buildAISummarySections(mockTranscript.value)
    const presetSummaries = [
      'Claire 问候王老师并开场，点明访谈主题：创作者圈热议的 AI 介入创作；王老师回应并表示持续关注 PodPal 项目进展。',
      '两人讨论 AI 剪辑痛点：担心内容“冰冷”。王老师认为停顿承载情绪与思考，智能剪辑应做逻辑筛选；AI 是延伸感知，不替代创作。',
      '谈到“文稿式剪辑”的意义：降低剪辑门槛，让普通人聚焦观点与故事。双方认同 PodPal 让技术交给算法，把直觉与灵魂留给创作者。'
    ]
    const summaries = await Promise.all(sections.map(async (section, index) => {
      await new Promise(resolve => setTimeout(resolve, 220))
      return {
        id: `summary_${index + 1}`,
        sectionNumber: index + 1,
        startIndex: section.startIndex,
        endIndex: section.endIndex,
        summary: presetSummaries[index] || composeAISummaryText(section),
        timestamp: section.segments[0].startTime,
        duration: section.segments[section.segments.length - 1].endTime - section.segments[0].startTime
      }
    }))
    aiSummaries.value = summaries
  } catch (error) {
    console.error('生成AI总结失败:', error)
  } finally {
    isGeneratingAiSummary.value = false
    if (aiSummaryRefreshPending) {
      aiSummaryRefreshPending = false
      scheduleAISummaryRefresh()
    }
  }
}

// 检查段落是否有AI总结
const getAISummaryForSegment = (segmentIndex) => {
  return aiSummaries.value.find(summary => 
    segmentIndex >= summary.startIndex && segmentIndex <= summary.endIndex
  )
}

// 检查段落是否是总结的开始
const isSummaryStart = (segmentIndex) => {
  return aiSummaries.value.some(summary => summary.startIndex === segmentIndex)
}

// 提取关键词函数
const extractKeywords = (text) => {
  // 过滤掉常见虚词和标点
  const stopWords = new Set([
    '的', '了', '在', '是', '我', '有', '和', '就', '不', '人', '都', '一', '一个', '上', '也', '很', '到', '说', '要', '去', '你', '会', '着', '没有', '看', '好', '自己', '这', '那', '这些', '那些', '这个', '那个', '之', '与', '及', '等', '或', '但是', '然而', '因此', '所以', '因为', '如果', '虽然', '但是', '可以', '需要', '进行', '通过', '对于', '关于', '根据', '以及', '还有', '而且', '并且', '然后', '接着', '最后', '首先', '其次', '再次', '第一', '第二', '第三'
  ])
  
  // 提取中文词汇（简单实现：提取2-6个字的词组）
  const words = []
  const seen = new Set()
  
  // 提取2-4字词组
  for (let len = 4; len >= 2; len--) {
    for (let i = 0; i <= text.length - len; i++) {
      const word = text.substring(i, i + len)
      // 过滤条件：不包含标点、不是纯数字、不是停用词、没有重复
      if (!/[，。！？、；：,.!?…—-\s]/.test(word) && 
          !/^\d+$/.test(word) && 
          !stopWords.has(word) &&
          !seen.has(word)) {
        words.push(word)
        seen.add(word)
      }
    }
  }
  
  // 返回前3个关键词
  return words.slice(0, 3)
}

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

// 时间轴区域的高度（标尺 + 实际轨道数量 + 底部预留空间）
const fixedTimelineHeightPx = computed(() => {
  const trackCount = tracks.value.length
  return TIMELINE_RULER_HEIGHT + (trackCount * TRACK_ROW_HEIGHT) + 30
})

// 整个编辑器区域的总高度（播放器 + 时间轴区域）
const totalEditorHeightPx = computed(() => {
  return PLAYER_HEIGHT + fixedTimelineHeightPx.value
})

const rightPanelStyle = computed(() => ({
  height: 'calc(100vh - 100px)',
  minHeight: '0'
}))

// 轨道数据
const tracks = ref([
  {
    id: 1,
    name: '主人声 A',
    type: 'voice',
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
    type: 'bgm',
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
    type: 'voice',
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
        fadeIn: false,
        fadeOut: false
      },
      {
        id: 302,
        name: '而且现在有了 AI 技术的辅助',
        start: 24,
        end: 32.5,
        color: 'bg-gradient-to-r from-[#10B981]/80 to-[#34D399]/80 border-[#34D399]',
        fadeIn: false,
        fadeOut: false
      },
      {
        id: 303,
        name: '对，尤其是在内容创作方面',
        start: 40,
        end: 47.5,
        color: 'bg-gradient-to-r from-[#10B981]/80 to-[#34D399]/80 border-[#34D399]',
        fadeIn: false,
        fadeOut: false
      },
      {
        id: 304,
        name: '没错，技术只是工具',
        start: 55,
        end: 62.5,
        color: 'bg-gradient-to-r from-[#10B981]/80 to-[#34D399]/80 border-[#34D399]',
        fadeIn: false,
        fadeOut: false
      }
    ]
  }
])

// 轨道排序 - 按类型归类
const sortedTracks = computed(() => {
  return [...tracks.value].sort((a, b) => {
    const typeOrder = { voice: 0, bgm: 1, sound: 2 }
    return (typeOrder[a.type] || 999) - (typeOrder[b.type] || 999)
  })
})

// 深度语义搜索与金句定位
const semanticSearchQuery = ref('')
const searchResults = ref([])
const isSearching = ref(false)
const topicHeatmap = ref([])
const goldenSentences = ref([])
const isExtracting = ref(false)

// 文本选择和高光金句
const selectedText = ref('')
const showHighlightPreview = ref(false)
// 获取说话人颜色类
const getSpeakerColorClass = (speaker) => {
  const colors = {
    'A': 'bg-blue-100 text-blue-700 border border-blue-200',
    'B': 'bg-green-100 text-green-700 border border-green-200',
    'C': 'bg-purple-100 text-purple-700 border border-purple-200',
    'D': 'bg-orange-100 text-orange-700 border border-orange-200',
    'AI': 'bg-indigo-100 text-indigo-700 border border-indigo-200'
  }
  
  // 为自定义说话人分配颜色
  if (colors[speaker]) {
    return colors[speaker]
  } else {
    // 根据说话人名称生成哈希值来分配颜色
    let hash = 0
    for (let i = 0; i < speaker.length; i++) {
      hash = speaker.charCodeAt(i) + ((hash << 5) - hash)
    }
    const colorIndex = Math.abs(hash) % 5
    const customColors = [
      'bg-pink-100 text-pink-700 border border-pink-200',
      'bg-teal-100 text-teal-700 border border-teal-200',
      'bg-yellow-100 text-yellow-700 border border-yellow-200',
      'bg-rose-100 text-rose-700 border border-rose-200',
      'bg-violet-100 text-violet-700 border border-violet-200'
    ]
    return customColors[colorIndex]
  }
}

// 获取说话人背景色
const getSpeakerBgColor = (speaker) => {
  const bgColors = {
    'A': 'bg-blue-50',
    'B': 'bg-green-50',
    'C': 'bg-purple-50',
    'D': 'bg-orange-50',
    'AI': 'bg-indigo-50'
  }
  
  // 为自定义说话人分配背景颜色
  if (bgColors[speaker]) {
    return bgColors[speaker]
  } else {
    // 根据说话人名称生成哈希值来分配颜色
    let hash = 0
    for (let i = 0; i < speaker.length; i++) {
      hash = speaker.charCodeAt(i) + ((hash << 5) - hash)
    }
    const colorIndex = Math.abs(hash) % 5
    const customBgColors = [
      'bg-pink-50',
      'bg-teal-50',
      'bg-yellow-50',
      'bg-rose-50',
      'bg-violet-50'
    ]
    return customBgColors[colorIndex]
  }
}

const scrollToGoldenSentence = (sentence) => {
  // 跳转音频时间
  seekToTime(sentence.startTime)
  
  // 滚动文字稿到对应片段
  const index = sentence.segmentIndex !== undefined && sentence.segmentIndex !== null && sentence.segmentIndex >= 0
    ? sentence.segmentIndex
    : mockTranscript.value.findIndex(s => s.startTime <= sentence.startTime && s.endTime >= sentence.startTime)
  if (index !== -1) {
    scrollToSegment(index)
    highlightedTranscriptIndices.value = [index]
    setTimeout(() => {
      highlightedTranscriptIndices.value = []
    }, 1500)
  }
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
    timeline: [
      { timestamp: '00:00:00', seconds: 0, topic: '开场：AI 播客创作时代的到来', description: '介绍本期话题及背景，为什么每个创作者都该关注 AI。' },
      { timestamp: '03:15:00', seconds: 195, topic: '前期策划：如何用 AI 找灵感', description: '分享使用 LLM 进行选题策划和脚本大纲撰写的实操技巧。' },
      { timestamp: '12:30:00', seconds: 750, topic: '中期制作：智能录音与剪辑', description: '演示 PodPal 的 AI 降噪、自动剪辑口癖等黑科技功能。' },
      { timestamp: '25:45:00', seconds: 1545, topic: '后期分发：Shownotes 与视频化', description: '探讨如何利用 AI 快速生成多平台分发文案，抢占流量。' },
      { timestamp: '32:10:00', seconds: 1930, topic: 'Q&A：听众最关心的 AI 创作问题', description: '解答关于版权、原创性以及技术门槛的常见疑惑。' }
    ],
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

// 视频生成相关 - 接入 Seedance API
const parseVideoDurationToSeconds = (value) => {
  if (typeof value === 'number' && Number.isFinite(value) && value > 0) {
    return Math.round(value)
  }

  if (typeof value !== 'string') return null
  const durationText = value.trim()
  if (!durationText) return null

  if (durationText.includes(':')) {
    const parts = durationText.split(':').map(part => Number(part))
    if (parts.some(part => Number.isNaN(part))) return null
    if (parts.length === 2) return parts[0] * 60 + parts[1]
    if (parts.length === 3) return parts[0] * 3600 + parts[1] * 60 + parts[2]
    return null
  }

  const seconds = Number(durationText)
  return Number.isFinite(seconds) && seconds > 0 ? Math.round(seconds) : null
}

const generateVideoPreview = async () => {
  if (isGeneratingVideo.value) return
  const selectedGoldenSentences = getSelectedVideoSentences()
  if (selectedGoldenSentences.length === 0) {
    alert('请至少选择一个金句片段')
    return
  }
  
  isGeneratingVideo.value = true
  
  try {
    // 获取选中的金句内容
    const videoPrompt = selectedGoldenSentences.map(s => s.content || s.text || '').join(' ')
    const estimatedDuration = selectedGoldenSentences.reduce((total, sentence) => {
      const duration = Number(sentence.durationSeconds ?? sentence.duration)
      if (Number.isFinite(duration) && duration > 0) {
        return total + duration
      }
      const fallbackDuration = Math.max(3, Math.min(20, Math.ceil((sentence.content?.length || sentence.text?.length || 0) / 8)))
      return total + fallbackDuration
    }, 0)
    const estimatedDurationSeconds = Math.max(6, Math.min(120, Math.round(estimatedDuration || 15)))
    
    // 调用 Seedance API 生成视频
    const response = await fetch('https://api.seedance.io/v1/generate', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_SEEDANCE_API_KEY' // 需要替换为实际的 API Key
      },
      body: JSON.stringify({
        prompt: videoPrompt,
        template: videoTemplate.value, // 'digital-human' 或 'waveform'
        duration: estimatedDurationSeconds,
        aspect_ratio: '9:16', // 竖屏视频
        style: 'professional',
        audio_source: 'podcast', // 使用播客音频
        subtitles: true,
        watermark: false
      })
    })
    
    if (!response.ok) {
      throw new Error('Seedance API 调用失败')
    }
    
    const result = await response.json()
    const apiDurationSeconds = parseVideoDurationToSeconds(result.duration)
    const finalDurationText = formatTime(apiDurationSeconds || estimatedDurationSeconds)
    
    // 模拟：实际项目中使用 API 返回的数据
    // 这里使用模拟数据展示效果
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    generatedVideos.value.push({
      id: Date.now(),
      url: result.video_url || '#',
      thumbnail: result.thumbnail_url || `https://placehold.co/320x180/FF6B9D/ffffff?text=${encodeURIComponent((selectedGoldenSentences[0]?.content || selectedGoldenSentences[0]?.text || '').substring(0, 20) || 'Video')}`,
      duration: finalDurationText,
      template: videoTemplate.value,
      sentences: selectedGoldenSentences.map(sentence => ({
        id: sentence.id,
        content: sentence.content,
        startTime: sentence.startTime,
        endTime: sentence.endTime
      })),
      seedance_id: result.id // 保存 Seedance 视频 ID
    })
    
    alert('视频生成成功！')
  } catch (error) {
    console.error('视频生成失败:', error)
    // 降级处理：使用模拟数据
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    const fallbackDuration = selectedGoldenSentences.reduce((total, sentence) => {
      const duration = Number(sentence.durationSeconds ?? sentence.duration)
      if (Number.isFinite(duration) && duration > 0) {
        return total + duration
      }
      const fallbackSeconds = Math.max(3, Math.min(20, Math.ceil((sentence.content?.length || sentence.text?.length || 0) / 8)))
      return total + fallbackSeconds
    }, 0)
    const fallbackDurationText = formatTime(Math.max(6, Math.min(120, Math.round(fallbackDuration || 15))))
    generatedVideos.value.push({
      id: Date.now(),
      url: '#',
      thumbnail: `https://placehold.co/320x180/FF6B9D/ffffff?text=${encodeURIComponent((selectedGoldenSentences[0]?.content || selectedGoldenSentences[0]?.text || '').substring(0, 15) || 'Video')}`,
      duration: fallbackDurationText,
      template: videoTemplate.value,
      sentences: selectedGoldenSentences.map(sentence => ({
        id: sentence.id,
        content: sentence.content,
        startTime: sentence.startTime,
        endTime: sentence.endTime
      }))
    })
    
    alert('视频已生成（演示模式）')
  } finally {
    isGeneratingVideo.value = false
  }
}

const showVideoPreview = ref(false)
const currentVideo = ref(null)

const previewVideo = (video) => {
  currentVideo.value = video
  showVideoPreview.value = true
}

// 模拟方法实现
const handleRemoveRedundancy = async () => {
  console.log('执行去口癖处理')
  await new Promise(resolve => setTimeout(resolve, 500))
}

const handleAutoClip = async () => {
  console.log('执行智能分段')
  await new Promise(resolve => setTimeout(resolve, 500))
}

// 社交文案相关
const socialPlatform = ref('wechat') // 'wechat' | 'xiaohongshu' | 'weibo'
const socialCopies = ref({
  wechat: '',
  xiaohongshu: '',
  weibo: ''
})
const socialPlatformLabel = computed(() => {
  const map = {
    wechat: '视频号',
    xiaohongshu: '小红书',
    weibo: '微博'
  }
  return map[socialPlatform.value] || '社交平台'
})
const isGeneratingCopy = ref(false)
const currentSocialCopy = computed({
  get: () => socialCopies.value[socialPlatform.value] || '',
  set: (value) => {
    socialCopies.value[socialPlatform.value] = value
  }
})
const hasAnySocialCopy = computed(() => {
  return Object.values(socialCopies.value).some(copy => !!copy?.trim())
})

// AI 传播预测
const propagationForecast = ref(null)
const isGeneratingForecast = ref(false)

// AI 封面相关状态
const currentCoverImage = ref(null)
const isGeneratingCover = ref(false)
const coverGenerationTip = ref('')

// 导出设置
const exportSettings = reactive({
  format: 'mp3',
  bitrate: '192',
  samplerate: '44100',
  volumeOptimization: true,
  lufs: '-16'
})

// 全局 location 封装，避免模板中直接访问
const windowLocationOrigin = typeof window !== 'undefined' ? window.location.origin : 'https://example.com'

const buildPodcastPubDate = () => {
  return new Date().toUTCString()
}

const rssTemplateXml = computed(() => {
  const podcastTitle = currentProject.value?.name || '播客名称'
  const episodeTitle = shownotesData.value?.titles?.[0] || `${podcastTitle} - 最新一期`
  const episodeSummary = shownotesData.value?.summary || '单集简介（由 AI 生成）'
  const author = 'PodPal 主播'
  const contactEmail = 'hello@podpal.ai'
  const website = location?.origin || 'https://example.com'
  const imageUrl = `${website}/src/assets/fengmian.png`
  const audioUrl = editedAudio || `${website}/audio/latest.mp3`
  const duration = PROJECT_DURATION_TEXT?.length >= 4 ? `00:${PROJECT_DURATION_TEXT}` : '00:25:30'

  return `<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
     xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
     xmlns:content="http://purl.org/rss/1.0/modules/content/">
<channel>
    <title>${podcastTitle}</title>
    <link>${website}</link>
    <description>${episodeSummary}</description>
    <language>zh-CN</language>
    <copyright>${new Date().getFullYear()} ${podcastTitle}</copyright>

    <itunes:author>${author}</itunes:author>
    <itunes:email>${contactEmail}</itunes:email>
    <itunes:image href="${imageUrl}"/>
    <itunes:category text="Society &amp; Culture"/>
    <itunes:explicit>no</itunes:explicit>

    <item>
        <title>${episodeTitle}</title>
        <description>${episodeSummary}</description>
        <pubDate>${buildPodcastPubDate()}</pubDate>
        <guid>${audioUrl}</guid>
        <enclosure url="${audioUrl}" length="0" type="audio/mpeg"/>
        <itunes:duration>${duration}</itunes:duration>
        <itunes:episode>1</itunes:episode>
    </item>
</channel>
</rss>`
})

const copyRssTemplate = async () => {
  try {
    await navigator.clipboard.writeText(rssTemplateXml.value)
    alert('RSS 模板已复制')
  } catch (error) {
    console.error('复制 RSS 模板失败:', error)
    alert('复制失败，请重试')
  }
}

// AI 封面上传处理
const handleCoverUpload = (event) => {
  const file = event.target.files?.[0]
  if (!file) return
  
  const reader = new FileReader()
  reader.onload = (e) => {
    currentCoverImage.value = e.target?.result
    coverGenerationTip.value = '封面上传成功！'
    setTimeout(() => {
      coverGenerationTip.value = ''
    }, 3000)
  }
  reader.readAsDataURL(file)
}

// AI 封面生成
const generateCover = async () => {
  if (isGeneratingCover.value) return
  isGeneratingCover.value = true
  coverGenerationTip.value = 'AI 正在生成封面，请稍候...'
  
  await new Promise(resolve => setTimeout(resolve, 2000))
  
  // 模拟生成封面（实际项目中调用AI图像生成API）
  currentCoverImage.value = '/src/assets/fengmian.png'
  coverGenerationTip.value = '封面生成成功！点击上传可更换其他图片。'
  isGeneratingCover.value = false
  
  setTimeout(() => {
    coverGenerationTip.value = ''
  }, 4000)
}

// 导出资产包
const exportAssetPack = async () => {
  // 创建资产包内容
  const assetPack = {
    podcast: {
      title: currentProject.value?.name || '播客名称',
      author: 'PodPal 主播',
      email: 'hello@podpal.ai',
      description: shownotesData.value?.summary || '节目简介',
      duration: PROJECT_DURATION_TEXT,
      pubDate: new Date().toISOString(),
      rssTemplate: rssTemplateXml.value
    },
    shownotes: {
      title: shownotesData.value?.titles?.[0] || '单集标题',
      summary: shownotesData.value?.summary || '节目摘要',
      chapters: shownotesData.value?.timeline?.map(item => ({
        timestamp: item.timestamp,
        seconds: item.seconds,
        topic: item.topic,
        description: item.description
      })) || []
    },
    metadata: {
      id3Version: 'ID3v2.4',
      frames: {
        TIT2: shownotesData.value?.titles?.[0] || '未设置标题',
        TPE1: 'PodPal 主播',
        APIC: 'cover.jpg (240KB 二进制流已嵌入音频头部)',
        TLEN: `${PROJECT_DURATION_TEXT}`
      }
    },
    videos: generatedVideos.value?.map(video => ({
      id: video.id,
      duration: video.duration,
      thumbnail: video.thumbnail
    })) || []
  }

  // 创建 JSON 文件并下载
  const blob = new Blob([JSON.stringify(assetPack, null, 2)], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `podcast-asset-pack-${Date.now()}.json`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

const generateSocialCopy = async () => {
  if (isGeneratingCopy.value) return
  isGeneratingCopy.value = true
  
  await new Promise(resolve => setTimeout(resolve, 1500))
  
  const title = shownotesData.value?.titles?.[0] || 'AI 时代的播客创作：从灵感到分发的全流程解析'
  const summary = shownotesData.value?.summary || '本期围绕 AI 如何改变播客制作展开，覆盖前期选题、录制剪辑到多平台分发的实战经验。'
  const timelinePreview = buildUnifiedTimelineItems(8)
  const shortSummary = summary.length > 120 ? `${summary.substring(0, 120)}...` : summary
  const tinySummary = summary.length > 78 ? `${summary.substring(0, 78)}...` : summary

  socialCopies.value = {
    wechat: `【${title}】\n\n${shortSummary}\n\n🎧 本期亮点：\n${timelinePreview.map(item => `${item.timestamp} ${item.topic}`).join('\n')}\n\n#播客 #AI #内容创作 #效率工具`,
    xiaohongshu: `宝藏播客推荐！✨ ${title}\n\n宝子们，最近听到一期超有料的播客：\n${shortSummary}\n\n时间轴速览：\n${timelinePreview.slice(0, 6).map(item => `- ${item.timestamp} ${item.topic}`).join('\n')}\n\n真的干货满满，做内容的朋友一定要听！\n\n#播客 #AI工具 #内容创作 #知识分享`,
    weibo: `🎙️ 新一期播客上线：${title}\n\n${tinySummary}\n\n时间轴：\n${timelinePreview.slice(0, 6).map(item => `${item.timestamp} ${item.topic}`).join('\n')}\n\n#播客 #科技 #AI`
  }

  isGeneratingCopy.value = false
}

const copySocialCopy = () => {
  if (!currentSocialCopy.value) return
  navigator.clipboard.writeText(currentSocialCopy.value)
  // 实际项目中可以加一个 Toast 提示
  alert('文案已复制到剪贴板')
}

const getPreviewCopy = (platform) => {
  if (platform === 'xiaoyuzhou') {
    return socialCopies.value.wechat || shownotesData.value?.summary || '本期节目聚焦 AI 播客创作实战，欢迎点击收听完整内容。'
  }
  return socialCopies.value[platform] || shownotesData.value?.summary || '本期节目聚焦 AI 播客创作实战，欢迎点击收听完整内容。'
}

const getFormattedPreviewCopy = (platform) => {
  const title = shownotesData.value?.titles?.[0] || 'AI 时代的播客创作：从灵感到分发的全流程解析'
  const summary = shownotesData.value?.summary || (socialCopies.value.wechat || '').split('\n').slice(0, 2).join(' ').trim() || '本期节目聚焦 AI 播客创作实战，欢迎点击收听完整内容。'
  const timelineItems = buildUnifiedTimelineItems(12)
  const deepDive = `我们把本期讨论拆解为“选题定位、结构组织、录制提效、后期剪辑、分发复盘”五个层次，尽量避免只讲工具而忽略方法论。你会看到不仅是功能演示，还包括每一步背后的决策依据：为什么这一步要先做、怎样判断是否有效、如何在不同内容类型下做取舍。`
  const audience = `如果你是刚开始做播客的新手，这期可以帮助你快速建立完整流程认知；如果你已经在稳定更新，也可以把它当作一次工作流体检，看看哪些环节还能进一步提速。尤其是当你同时运营多个平台时，这套“统一内容骨架 + 平台差异化表达”的思路会更实用。`
  const action = `建议你边听边对照自己的制作链路，先挑 1-2 个最痛的环节做小步优化，连续执行一周，再看播放完成率、互动率和复用效率的变化。这样比一次性大改流程更稳，也更容易看到正反馈。`

  // 针对不同平台做轻微口吻差异，但保持结构统一
  if (platform === 'wechat') {
    return `【${title}】\n\n${summary}\n\n${deepDive}\n\n${audience}\n\n🎧 本期时间轴：\n${timelineItems.map(i => `${i.timestamp} ${i.topic}`).join('\n')}\n\n${action}\n\n#播客 #AI #内容创作 #效率工具`
  }
  if (platform === 'xiaohongshu') {
    return `宝藏播客推荐！✨ ${title}\n\n${summary}\n\n${deepDive}\n\n${audience}\n\n时间轴速览：\n${timelineItems.slice(0, 10).map(i => `- ${i.timestamp} ${i.topic}`).join('\n')}\n\n${action}\n\n#播客 #AI工具 #内容创作 #效率工具`
  }
  if (platform === 'weibo') {
    return `🎧 新一期播客上线：${title}\n\n${summary}\n\n${deepDive}\n\n时间轴：\n${timelineItems.slice(0, 10).map(i => `${i.timestamp} ${i.topic}`).join('\n')}\n\n${action}\n\n#播客 #科技 #AI`
  }
  if (platform === 'xiaoyuzhou') {
    return `${summary}\n\n${deepDive}\n\n${audience}\n\n节目时间轴：\n${timelineItems.map(i => `${i.timestamp} ${i.topic}`).join('\n')}\n\n${action}`
  }
  return summary
}

const openPublishPreviewForCurrentPlatform = () => {
  const previewPlatformMap = {
    wechat: 'wechat',
    xiaohongshu: 'xiaohongshu',
    weibo: 'weibo'
  }
  currentPreviewPlatform.value = previewPlatformMap[socialPlatform.value] || 'wechat'
  showPublishPreview.value = true
}

// AI 传播预测生成
const generatePropagationForecast = async () => {
  if (isGeneratingForecast.value) return
  isGeneratingForecast.value = true
  
  await new Promise(resolve => setTimeout(resolve, 2000))
  
  propagationForecast.value = {
    listenerGoLiveAt: '20:00',
    reviewEstimate: '约 2-6 小时（波动区间 10 分钟 - 1 天）',
    submitBefore: '14:00 - 16:00 提交审核更稳妥',
    platformWindows: [
      { platform: '抖音', window: '12:00-13:30、18:30-22:00（晚高峰最高）' },
      { platform: '小红书', window: '11:30-13:00、19:00-23:00（休闲刷帖活跃）' },
      { platform: '视频号', window: '12:00、20:00（社交传阅强）' },
      { platform: '小宇宙播客', window: '19:30-21:00（正式上线优选）' }
    ],
    executionPlan: [
      '14:00-16:00：上传播客并提交审核，预留充足审核时长',
      '17:00-18:00：发布抖音/小红书/视频号宣发短片并引导收听入口',
      '20:00：播客定时正式上线，短视频评论区同步引导收听'
    ],
    tips: [
      '“发布时间”是听众听到内容的时间，不是提交审核时间。',
      '短视频平台先预热，再在播客上线时集中导流，转化更高。',
      '如果内容敏感度高，建议再提前 2-4 小时提交审核。',
      'AI 分析建议分开提：先算播客上线窗口，再算短视频各平台宣发时点。'
    ]
  }
  
  isGeneratingForecast.value = false
}

const copyFullShownotes = () => {
  if (!shownotesData.value) return
  
  let content = `【${shownotesData.value.titles[0]}】\n\n`
  content += `摘要：\n${shownotesData.value.summary}\n\n`
  content += `节目时间轴：\n`
  shownotesData.value.timeline.forEach(item => {
    content += `${item.timestamp} ${item.topic}\n`
    content += `${item.description}\n\n`
  })
  
  navigator.clipboard.writeText(content)
  alert('完整 Shownotes 已复制到剪贴板')
}

// Shownotes 编辑相关方法
const addNewTitle = () => {
  if (!shownotesData.value) return
  shownotesData.value.titles.push('新标题')
  editingTitleIndex.value = shownotesData.value.titles.length - 1
}

const deleteTitle = (idx) => {
  if (!shownotesData.value) return
  shownotesData.value.titles.splice(idx, 1)
}

const copyText = (text) => {
  navigator.clipboard.writeText(text)
  alert('已复制到剪贴板')
}

const addNewTimelineItem = () => {
  if (!shownotesData.value) return
  const newItem = {
    timestamp: '00:00:00',
    seconds: 0,
    topic: '新话题',
    description: '话题描述'
  }
  shownotesData.value.timeline.push(newItem)
}

const deleteTimelineItem = (idx) => {
  if (!shownotesData.value) return
  shownotesData.value.timeline.splice(idx, 1)
}

// 思维导图编辑相关方法
const addMindMapNode = () => {
  if (!shownotesData.value || !shownotesData.value.mindmap) return
  if (!shownotesData.value.mindmap.children) {
    shownotesData.value.mindmap.children = []
  }
  shownotesData.value.mindmap.children.push({
    label: '新节点',
    time: '00:00',
    children: []
  })
}

const deleteMindMapNode = (idx) => {
  if (!shownotesData.value || !shownotesData.value.mindmap) return
  shownotesData.value.mindmap.children.splice(idx, 1)
}

const addMindMapChild = (parentIdx) => {
  if (!shownotesData.value || !shownotesData.value.mindmap) return
  const parent = shownotesData.value.mindmap.children[parentIdx]
  if (!parent.children) {
    parent.children = []
  }
  parent.children.push({
    label: '子节点',
    time: '00:00'
  })
}

const deleteMindMapChild = (parentIdx, childIdx) => {
  if (!shownotesData.value || !shownotesData.value.mindmap) return
  const parent = shownotesData.value.mindmap.children[parentIdx]
  if (parent.children) {
    parent.children.splice(childIdx, 1)
  }
}

const parseTimeToSeconds = (timeStr) => {
  if (!timeStr) return 0
  const parts = timeStr.split(':')
  if (parts.length === 2) {
    return parseInt(parts[0]) * 60 + parseInt(parts[1])
  }
  return 0
}

const exportMindMapImage = () => {
  alert('导出图片功能开发中...')
}

const exportMindMapPDF = () => {
  alert('导出 PDF 功能开发中...')
}

// 视频预览播放相关方法
const toggleVideoPlay = () => {
  isVideoPlaying.value = !isVideoPlaying.value
  if (isVideoPlaying.value) {
    startVideoPlay()
  } else {
    stopVideoPlay()
  }
}

const startVideoPlay = () => {
  videoPlayInterval = setInterval(() => {
    videoCurrentTime.value += 0.1
    if (videoCurrentTime.value >= videoDuration.value) {
      videoCurrentTime.value = 0
      isVideoPlaying.value = false
      stopVideoPlay()
    }
    // 更新波形动画
    videoWaveformBars.value = videoWaveformBars.value.map(() => 0.2 + Math.random() * 0.8)
  }, 100)
}

const stopVideoPlay = () => {
  if (videoPlayInterval) {
    clearInterval(videoPlayInterval)
    videoPlayInterval = null
  }
}

const videoProgressPercent = computed(() => {
  return (videoCurrentTime.value / videoDuration.value) * 100
})

const formatVideoTime = (seconds) => {
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
}

const seekVideoProgress = (event) => {
  const rect = event.currentTarget.getBoundingClientRect()
  const percent = (event.clientX - rect.left) / rect.width
  videoCurrentTime.value = Math.max(0, Math.min(videoDuration.value, percent * videoDuration.value))
}

// 口癖 / 语气词列表，用于高亮和一键删除
const fillerWords = [
  '然后', '那个', '这个',
  '嗯', '嗯嗯', '啊', '啊啊', '呃', '呃呃', '诶', '诶诶', '额', '额额',
  '你知道', '对吧', '可以说', '怎么说呢'
]

// 音频增强开关
const voiceEnhanceEnabled = ref(false)
const echoRemovalEnabled = ref(false)

// 模拟转写文本数据
const createTranscriptSegment = (segment) => ({
  uid: `seg-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
  ...segment
})

const mockTranscript = ref([
  {
    startTime: 0,
    endTime: 15,
    speaker: 'A',
    text: '王老师，好久不见。今天咱们请您来，是想聊聊那个……最近创作者圈子里讨论特别多的"AI 介入创作"的问题。'
  },
  {
    startTime: 15,
    endTime: 30,
    speaker: 'B', 
    text: '诶，你好 Claire。我我我一直有在关注你们这个 PodPal 的进展。'
  },
  {
    startTime: 30,
    endTime: 45,
    speaker: 'A',
    text: '真的吗？那咱们直奔主题。现在 AI 剪辑挺火的，但很多人担心……呃，就是说，AI 剪出来的东西太冷冰冰了，没那个……人情味。对对对，这就是大家最在意的点。'
  },
  {
    startTime: 45,
    endTime: 60,
    speaker: 'B',
    text: '嗯，其实这确实是个普遍的……那个，误区。传统的 AI 剪辑逻辑比较机械，它只会盯着波形看，哪里没声音了它就直接剪掉。改改改稿的时候也容易把节奏弄硬。'
  },
  {
    startTime: 60,
    endTime: 75,
    speaker: 'B',
    text: '但我们要知道，人类聊天时的"停顿"是有灵魂的。有些沉默是因为思考……有些沉默是因为情绪到了。'
  },
  {
    startTime: 75,
    endTime: 90,
    speaker: 'A',
    text: '没错！有时候那个……就是说，沉默反而比说话更有力量。我之前用传统软件剪辑，最怕的就是把嘉宾这种有温度的瞬间给切碎了。好好好的留白其实很重要。'
  },
  {
    startTime: 90,
    endTime: 105,
    speaker: 'B',
    text: '对。所以真正的智能不该只做物理意义上的"减法"……而是要做逻辑上的"筛选"。'
  },
  {
    startTime: 105,
    endTime: 120,
    speaker: 'B',
    text: '好的工具不应该替代人的思考……而应该延长人的感官。'
  },
  {
    startTime: 120,
    endTime: 135,
    speaker: 'A',
    text: '这句话说得太好了，我得记下来。那您觉得，像 PodPal 这种"文稿式剪辑"的操作逻辑，对普通人意味着什么？'
  },
  {
    startTime: 135,
    endTime: 150,
    speaker: 'B',
    text: '意味着……呃，创作权力的下放吧。以前你得学三个月软件才能剪出一档像样的播客，把时间都花在对齐音轨这种机械劳动上。就就是就是这样。'
  },
  {
    startTime: 150,
    endTime: 165,
    speaker: 'B',
    text: '现在只要你会改作文，你就能当主编。你可以把所有精力都放在打磨你的观点和故事上。'
  },
  {
    startTime: 165,
    endTime: 180,
    speaker: 'B',
    text: '当技术退居幕后，表达的欲望才会真正走向台前。'
  },
  {
    startTime: 180,
    endTime: 195,
    speaker: 'A',
    text: '明白了。就像 PodPal 做的，把复杂留给算法……把直觉留给作者。'
  },
  {
    startTime: 195,
    endTime: 210,
    speaker: 'A',
    text: '其实这种理念非常契合我们产品的初衷。我们希望通过 AI 的辅助，让每一个有思想的人都能无障碍地发声。'
  },
  {
    startTime: 210,
    endTime: 225,
    speaker: 'B',
    text: '总结得非常到位。技术的进步不应该是为了取代人，而是为了让人更有尊严地去创造。'
  }
].map(createTranscriptSegment))

// 语音转写状态与新增计数
const isTranscribing = ref(false)
const transcriptionProgress = ref(0)
const transcriptionStatus = ref('')
const transcribeNewCount = ref(0)
const transcriptionResultSegments = ref([]) // 侧边栏展示的转写结果片段
const transcriptionOptions = ref({
  language: 'zh-CN',
  diarization: true,
  punctuation: true
})

// 语音转写与分析结果 Mock 数据
const transcriptionAnalysis = ref({
  summary: '',
  keywords: [],
  sentiment: { label: '', score: 0 },
  speakers: []
})
const showAnalysisPanel = ref(false)

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

// 开始语音转写（增强版：包含状态流转与进度反馈）
const startTranscription = async () => {
  if (isTranscribing.value) return
  isTranscribing.value = true
  transcribeNewCount.value = 0
  transcriptionProgress.value = 0
  
  const stages = [
    { name: '素材预处理（降噪/特征提取）...', duration: 3200, progress: 20 },
    { name: '上传音频指纹...', duration: 1800, progress: 35 },
    { name: 'AI 引擎初始化...', duration: 1400, progress: 50 },
    { name: '正在识别说话人 (Diarization)...', duration: 2600, progress: 75 },
    { name: '文本转写与标点纠偏...', duration: 3200, progress: 95 },
    { name: '结果最终校对中...', duration: 1500, progress: 100 }
  ]

  for (const stage of stages) {
    transcriptionStatus.value = stage.name
    const step = (stage.progress - transcriptionProgress.value) / 10
    for (let i = 0; i < 10; i++) {
      await new Promise(resolve => setTimeout(resolve, stage.duration / 10))
      transcriptionProgress.value += step
    }
    transcriptionProgress.value = stage.progress
  }

  const lastEnd = mockTranscript.value.length
    ? mockTranscript.value[mockTranscript.value.length - 1].endTime
    : 0

  const newSegments = [
    {
      startTime: lastEnd + 120,
      endTime: lastEnd + 135,
      speaker: 'A',
      text: '继续刚才的话题，我们结合一个实际的剪辑案例，看看如何提升听感。',
      isNew: true
    },
    {
      startTime: lastEnd + 240,
      endTime: lastEnd + 265,
      speaker: 'B',
      text: '首先，去除口癖会让信息更凝练，比如把“就是说、然后呢”等冗余词汇清理掉。',
      isNew: true
    },
    {
      startTime: lastEnd + 400,
      endTime: lastEnd + 425,
      speaker: 'A',
      text: '其次，补充过渡句可以减少语义跳跃，让听众更容易跟上思路。',
      isNew: true
    }
  ]

  transcriptionResultSegments.value = newSegments
  transcribeNewCount.value = newSegments.length

  transcriptionStatus.value = '转写完成'
  
  // 模拟 AI 内容分析
  transcriptionAnalysis.value = {
    summary: '本段对话主要围绕 AI 技术在播客剪辑中的应用展开。嘉宾讨论了如何通过去除口癖、增加过渡句等方式提升音频内容的听感，并强调了 PodPal 平台在智能化剪辑方面的核心优势。',
    keywords: ['AI 剪辑', '口癖清理', '内容连贯性', 'PodPal', '听感提升'],
    sentiment: { label: '积极/专业', score: 0.85 },
    speakers: [
      { id: 'A', name: '主持人', turnCount: 2, totalTime: '40s' },
      { id: 'B', name: '技术专家', turnCount: 1, totalTime: '25s' }
    ]
  }
  showAnalysisPanel.value = true

  await new Promise(resolve => setTimeout(resolve, 1000))
  isTranscribing.value = false
  // 转写结果现在侧边栏展示，主区域滚动逻辑移除
}

// 场景自适应设置
const podcastType = ref('interview') // 'knowledge' | 'companion' | 'interview' | 'story'

// Shownotes 生成
const shownotesData = ref(null)
const isGeneratingShownotes = ref(false)
const showMindMap = ref(false)

// 作品仓库
const workRepository = ref([
  { id: 'work-1', name: 'AI播客创作指南_最终版.mp3', duration: '32:15', exportTime: '2024-03-08 14:30', audioUrl: editedAudio },
  { id: 'work-2', name: '职场焦虑与应对_剪辑版.mp3', duration: '28:45', exportTime: '2024-03-07 09:15', audioUrl: editedAudio },
  { id: 'work-3', name: '科技趋势解读_第15期.mp3', duration: '45:20', exportTime: '2024-03-05 16:45', audioUrl: editedAudio },
])
const currentProjectExport = ref({
  id: 'current',
  name: '当前项目_待导出.mp3',
  duration: PROJECT_DURATION_TEXT,
  exportTime: '刚刚',
  audioUrl: editedAudio
})
const selectedWork = ref(null)

// 音频播放器状态
const isAudioPlaying = ref(false)
const audioProgress = ref(0)
const currentAudioTime = ref(0)
const parseMediaDuration = (durationStr, fallback = 1800) => {
  if (!durationStr || typeof durationStr !== 'string') return fallback
  const parts = durationStr.split(':').map(Number)
  if (parts.some(part => Number.isNaN(part))) return fallback
  if (parts.length === 2) {
    return parts[0] * 60 + parts[1]
  }
  if (parts.length === 3) {
    return parts[0] * 3600 + parts[1] * 60 + parts[2]
  }
  return fallback
}
const totalAudioDuration = ref(parseMediaDuration(currentProjectExport.value.duration)) // 跟随当前作品时长
let audioPlayInterval = null

const formatDurationMMSS = (seconds = 0) => {
  const s = Math.max(0, Math.floor(seconds))
  const m = Math.floor(s / 60)
  const ss = s % 60
  if (m >= 60) {
    const h = Math.floor(m / 60)
    const mm = m % 60
    return `${h}:${mm.toString().padStart(2, '0')}:${ss.toString().padStart(2, '0')}`
  }
  return `${m.toString().padStart(2, '0')}:${ss.toString().padStart(2, '0')}`
}

const rescaleTranscriptToDuration = (newTotalSeconds) => {
  const total = Math.max(1, Math.floor(newTotalSeconds || 0))
  if (!mockTranscript.value?.length) {
    audioDuration.value = total
    return
  }
  const oldTotal = Math.max(
    1,
    Math.floor(
      mockTranscript.value.reduce((maxEnd, seg) => Math.max(maxEnd, seg.endTime || 0), 0)
    )
  )
  const scale = total / oldTotal
  mockTranscript.value.forEach((seg) => {
    seg.startTime = Math.max(0, Math.floor((seg.startTime || 0) * scale))
    seg.endTime = Math.max(seg.startTime + 1, Math.floor((seg.endTime || 0) * scale))
  })
  // 修正最后一个片段不超出总时长
  const last = mockTranscript.value[mockTranscript.value.length - 1]
  if (last && last.endTime > total) last.endTime = total
  audioDuration.value = total
  syncSegmentTextLengthSnapshot()
}

const setActiveMaterialDuration = (durationStr) => {
  const seconds = parseMediaDuration(durationStr, audioDuration.value || 1800)
  audioDuration.value = seconds
  totalAudioDuration.value = seconds
  currentProjectExport.value.duration = formatDurationMMSS(seconds)
  rescaleTranscriptToDuration(seconds)
}

const buildUnifiedTimelineItems = (maxItems = 8) => {
  const limit = Math.max(3, Math.min(12, maxItems))
  const timeline = shownotesData.value?.timeline
  if (Array.isArray(timeline) && timeline.length) {
    return timeline.slice(0, limit).map((t) => ({
      timestamp: t.timestamp,
      seconds: typeof t.seconds === 'number' ? t.seconds : parseMediaDuration(t.timestamp, 0),
      topic: t.topic
    }))
  }

  const total = Math.max(1, Math.floor(totalAudioDuration.value || audioDuration.value || 1800))
  const step = Math.max(1, Math.floor(total / (limit + 1)))
  const items = []
  for (let i = 0; i < limit; i++) {
    const target = step * i
    let seg = mockTranscript.value?.[0]
    if (mockTranscript.value?.length) {
      seg = mockTranscript.value.reduce((best, cur) => {
        const bd = Math.abs((best?.startTime ?? 0) - target)
        const cd = Math.abs((cur?.startTime ?? 0) - target)
        return cd < bd ? cur : best
      }, mockTranscript.value[0])
    }
    const seconds = Math.max(0, Math.floor(seg?.startTime ?? target))
    const text = getCleanSegmentText(seg?.text || '')
    items.push({
      timestamp: formatTime(seconds),
      seconds,
      topic: (text || '片段').slice(0, 22)
    })
  }
  // 去重 timestamp
  const seen = new Set()
  return items.filter((it) => {
    if (seen.has(it.timestamp)) return false
    seen.add(it.timestamp)
    return true
  })
}

// 模拟发布预览
const showPublishPreview = ref(false)
const currentPreviewPlatform = ref('xiaoyuzhou')
const previewPlatforms = [
  { id: 'xiaoyuzhou', name: '小宇宙', icon: xiaoyuzhouIcon },
  { id: 'wechat', name: '微信公众号', icon: weixinIcon },
  { id: 'xiaohongshu', name: '小红书', icon: xiaohongshuIcon },
  { id: 'weibo', name: '微博', icon: weiboIcon },
]

// 分享链接
const showShareLinkModal = ref(false)
const isGeneratingLink = ref(false)
const generatedShareLink = ref('')
const shareLinkOptions = ref({
  allowComments: true,
  allowDownload: false,
  expireEnabled: true,
  expireDays: 7
})

// 视频播客生成
const selectedSentences = ref([])
const videoTemplate = ref('digital-human')
const isGeneratingVideo = ref(false)
const generatedVideos = ref([])

// 记录已应用但未撤销的脚本优化（type -> snapshot），用于按钮「已使用」状态和保留上次处理结果
const appliedOptimizations = ref({})

const videoSentenceCandidates = computed(() => {
  const sourceSentences = (goldenSentences.value || []).length
    ? goldenSentences.value
    : (mockTranscript.value || [])
        .filter(segment => segment.isGolden)
        .map((segment, index) => ({
          id: `video-fallback-${index}-${segment.startTime ?? index}`,
          content: getCleanSegmentText(segment.text || ''),
          startTime: segment.startTime,
          endTime: segment.endTime,
          segmentIndex: index
        }))

  return sourceSentences
    .map((sentence, index) => {
      const content = getCleanSegmentText(sentence.content || sentence.text || '')
      const startTime = Number(sentence.startTime) || 0
      const rawEndTime = Number(sentence.endTime)
      const explicitDuration = Number(sentence.durationSeconds)
      const originalDurationSeconds = Number.isFinite(rawEndTime) && rawEndTime > startTime
        ? rawEndTime - startTime
        : Number.NaN
      const contentBasedDurationSeconds = Math.max(10, Math.min(24, Math.ceil((content.length || 0) / 12)))
      const indexOffsetSeconds = (index % 4) * 3
      const normalizedDurationSeconds = Math.max(10, Math.min(42, contentBasedDurationSeconds + indexOffsetSeconds))
      const durationSeconds = Number.isFinite(explicitDuration) && explicitDuration > 0 && explicitDuration <= 42
        ? explicitDuration
        : Number.isFinite(originalDurationSeconds) && originalDurationSeconds <= 42
          ? originalDurationSeconds
          : normalizedDurationSeconds

      return {
        id: sentence.id || `video-golden-${sentence.segmentIndex ?? index}-${startTime}`,
        content,
        startTime,
        endTime: startTime + durationSeconds,
        durationSeconds,
        sourceLabel: `来源 ${formatTime(startTime)}`,
        durationLabel: `${Math.max(3, Math.round(durationSeconds))}s`
      }
    })
    .filter(sentence => sentence.content)
    .sort((a, b) => a.startTime - b.startTime)
    .slice(0, 6)
})

const getSelectedVideoSentences = () => {
  const selected = videoSentenceCandidates.value.filter(sentence => selectedSentences.value.includes(sentence.id))
  if (selected.length) return selected
  return videoSentenceCandidates.value.slice(0, Math.min(4, videoSentenceCandidates.value.length))
}

watch(
  videoSentenceCandidates,
  (sentences) => {
    if (!sentences.length) {
      selectedSentences.value = []
      return
    }

    const availableIds = new Set(sentences.map(sentence => sentence.id))
    const filteredIds = selectedSentences.value.filter(id => availableIds.has(id))

    if (filteredIds.length !== selectedSentences.value.length) {
      selectedSentences.value = filteredIds
    }

    if (!selectedSentences.value.length) {
      selectedSentences.value = sentences.slice(0, Math.min(4, sentences.length)).map(sentence => sentence.id)
    }
  },
  { immediate: true }
)

const toggleSelectedSentence = (s) => {
  const idx = selectedSentences.value.indexOf(s.id)
  if (idx >= 0) {
    selectedSentences.value.splice(idx, 1)
  } else {
    selectedSentences.value.push(s.id)
  }
}

// 素材库 Mock Data (Feature 2)
const assets = ref([
  { id: 1, name: '原始录音_Track1.wav', url: uneditedAudio, type: 'audio', duration: '45:20', format: 'M4A', category: '人声', used: false, playing: false, summary: '嘉宾与主持围绕 AI 剪辑展开的长对话录音。', tags: ['现场', '录音', '人声'], editingSummary: false },
  { id: 2, name: '补录音频_最新.m4a', url: supplementAudio, type: 'audio', duration: '00:15', format: 'M4A', category: '人声', used: false, playing: false, summary: '用于补录试听与插入的最新补录音频。', tags: ['补录', '人声'], editingSummary: false },
  { id: 3, name: 'Intro_Video.mp4', type: 'video', duration: '00:15', format: 'MP4', category: '效果音', used: false, playing: false, summary: '片头视频短片，包含品牌开场动画与音乐。', tags: ['片头', '品牌'], editingSummary: false },
  { id: 4, name: '转场音效_Swoosh.wav', type: 'audio', duration: '00:03', format: 'WAV', category: '效果音', used: false, playing: false, summary: '平滑的转场音效，适用于章节切换。', tags: ['转场', '平滑'], editingSummary: false },
  { id: 5, name: '嘉宾采访_Alice.wav', type: 'audio', duration: '12:30', format: 'WAV', category: '人声', used: false, playing: false, summary: '嘉宾 Alice 关于 AI 技术发展的深度访谈。', tags: ['访谈', 'AI技术', '深度'], editingSummary: false },
  { id: 6, name: '氛围音乐_Chill.mp3', type: 'audio', duration: '05:45', format: 'MP3', category: '背景音', used: false, playing: false, summary: '轻松的氛围音乐，适合知识分享类播客。', tags: ['轻松', '氛围', '知识'], editingSummary: false },
])

// 素材分类筛选
const assetCategories = ref(['全部', '人声', '背景音', '效果音'])
const selectedCategory = ref('全部')
const showAddCategoryModal = ref(false)
const newCategoryName = ref('')

// 过滤后的素材列表
const filteredAssets = computed(() => {
  if (selectedCategory.value === '全部') {
    return assets.value
  }
  return assets.value.filter(asset => asset.category === selectedCategory.value)
})

// 添加自定义分类
const addCustomCategory = () => {
  if (newCategoryName.value.trim() && !assetCategories.value.includes(newCategoryName.value.trim())) {
    assetCategories.value.push(newCategoryName.value.trim())
    newCategoryName.value = ''
    showAddCategoryModal.value = false
  }
}

// 删除自定义分类
const deleteCategory = (category) => {
  if (['全部', '人声', '背景音', '效果音'].includes(category)) return
  const idx = assetCategories.value.indexOf(category)
  if (idx >= 0) {
    assetCategories.value.splice(idx, 1)
    if (selectedCategory.value === category) {
      selectedCategory.value = '全部'
    }
  }
}

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

watch(
  () => activeToolTab.value,
  async (tab) => {
    if (tab === 'export' && !propagationForecast.value && !isGeneratingForecast.value) {
      await generatePropagationForecast()
    }
  }
)

// 检查路由参数，设置初始标签页
if (route.query.tab && toolTabs.some(t => t.id === route.query.tab)) {
  const requestedTab = route.query.tab
  if (requestedTab === 'upload') {
    resetUploadUnlockState()
    activeToolTab.value = 'upload'
  } else if (!hasUploaded.value) {
    activeToolTab.value = 'upload'
  } else {
    activeToolTab.value = requestedTab
    if (requestedTab === 'enhance') {
      openEnhancePanel.value = 'shownotes'
      // 进入内容增值时默认展示“访谈对话”（模拟 AI 自动识别）
      podcastType.value = 'interview'
    }
  }
}

// 监听路由 tab 变化，同步工作台视图（避免 push 后 UI 不刷新）
watch(
  () => route.query.tab,
  (tab) => {
    if (tab && toolTabs.some(t => t.id === tab)) {
      if (tab === 'upload') {
        resetUploadUnlockState()
        activeToolTab.value = 'upload'
        return
      }
      if (!hasUploaded.value) {
        activeToolTab.value = 'upload'
        scriptOptimizeMessage.value = '请先上传素材以解锁该功能。'
        setTimeout(() => { scriptOptimizeMessage.value = '' }, 2500)
        return
      }
      activeToolTab.value = tab
      if (tab === 'enhance') {
        openEnhancePanel.value = 'shownotes'
        // 进入内容增值时默认展示“访谈对话”（模拟 AI 自动识别）
        podcastType.value = 'interview'
      }
    }
  }
)

const handleTabClick = (tab) => {
  if (tab.id === 'upload') {
    resetUploadUnlockState()
    activeToolTab.value = 'upload'
    return
  }
  if (tab.id !== 'upload' && !hasUploaded.value) {
    // 阻止切换并提示上传素材
    activeToolTab.value = 'upload'
    scriptOptimizeMessage.value = '请先上传素材以解锁该功能。'
    setTimeout(() => { scriptOptimizeMessage.value = '' }, 2500)
    return
  }
  activeToolTab.value = tab.id
}

// 顶部步骤进度
const stepIndex = computed(() => toolTabs.findIndex(t => t.id === activeToolTab.value))

watch(
  [stepIndex, () => toolTabs.length, hasUploaded],
  async () => {
    await nextTick()
    syncStepNavProgress()
  },
  { immediate: true }
)

const showLinkModal = ref(false)
const fileInput = ref(null)
const inlineFileInput = ref(null)
const inlineUploading = ref(false)
const inlineProgress = ref(0)
const inlineFilename = ref('')
const inlinePendingFile = ref(null)
const triggerInlineUpload = () => inlineFileInput.value?.click()
const SUPPORTED_UPLOAD_EXTENSIONS = ['mp3', 'wav', 'm4a', 'flac', 'aac', 'ogg', 'mp4', 'mov', 'mkv', 'webm']
const isSupportedUploadFile = (file) => {
  if (!file) return false
  const ext = (file.name?.split('.').pop() || '').toLowerCase()
  const isMimeSupported = file.type?.startsWith('audio/') || file.type?.startsWith('video/')
  const isExtensionSupported = SUPPORTED_UPLOAD_EXTENSIONS.includes(ext)
  return (isMimeSupported || isExtensionSupported) && file.size <= 300 * 1024 * 1024
}
// 上传后预处理弹窗
const showPreprocessModal = ref(false)
const preTranscribe = ref(true)
const preVoiceEnhance = ref(true)
const preEchoRemoval = ref(false)
const preprocessRunning = ref(false)
const preprocessProgress = ref(0)
const preprocessStatus = ref('')
const resetUploadUnlockState = () => {
  hasUploaded.value = false
  showPreprocessModal.value = false
  inlineUploading.value = false
  preprocessRunning.value = false
  preprocessProgress.value = 0
  preprocessStatus.value = ''
  inlinePendingFile.value = null
  inlineFilename.value = ''
  inlineProgress.value = 0
  selectedAssetIds.value = []
}
// 素材多选
const selectedAssetIds = ref([])
const selectedUploadAssets = computed(() => {
  return assets.value.filter(asset => selectedAssetIds.value.includes(asset.id))
})
const toggleAssetSelect = (asset) => {
  const idx = selectedAssetIds.value.indexOf(asset.id)
  if (idx >= 0) selectedAssetIds.value.splice(idx, 1)
  else selectedAssetIds.value.push(asset.id)
}

const queueAssetForUpload = (asset) => {
  if (!asset) return
  inlinePendingFile.value = null
  inlineFilename.value = ''
  inlineProgress.value = 0
  if (!selectedAssetIds.value.includes(asset.id)) {
    selectedAssetIds.value.push(asset.id)
  }
}

const removeQueuedUploadAsset = (assetId) => {
  const index = selectedAssetIds.value.indexOf(assetId)
  if (index >= 0) selectedAssetIds.value.splice(index, 1)
}

const useSelectedAssets = () => {
  if (selectedAssetIds.value.length === 0) return
  assets.value.forEach(asset => {
    if (selectedAssetIds.value.includes(asset.id)) {
      asset.used = true
    }
  })
  const firstSelected = assets.value.find(a => selectedAssetIds.value.includes(a.id))
  if (firstSelected?.duration) {
    setActiveMaterialDuration(firstSelected.duration)
  }
  hasUploaded.value = false
  showPreprocessModal.value = true
}

const cancelPreprocessAndClose = () => {
  if (preprocessRunning.value) return
  showPreprocessModal.value = false
}

const finishPreprocessAndEnterEdit = () => {
  preprocessRunning.value = false
  preprocessStatus.value = '已进入智能剪辑'
  hasUploaded.value = true
  showPreprocessModal.value = false
  activeToolTab.value = 'edit'
}

const runFastPreprocessProgress = async () => {
  if (preprocessRunning.value) return
  preprocessRunning.value = true
  preprocessProgress.value = 0
  preprocessStatus.value = '正在快速跳过前置处理...'

  const stages = [
    { name: '跳过降噪与特征提取...', progress: 35, duration: 180 },
    { name: '跳过说话人分析...', progress: 65, duration: 180 },
    { name: '跳过文本预校正...', progress: 100, duration: 220 }
  ]

  for (const stage of stages) {
    preprocessStatus.value = stage.name
    const start = preprocessProgress.value
    const step = (stage.progress - start) / 8
    for (let i = 0; i < 8; i++) {
      await new Promise(resolve => setTimeout(resolve, stage.duration / 8))
      preprocessProgress.value = Math.min(stage.progress, preprocessProgress.value + step)
    }
    preprocessProgress.value = stage.progress
  }

  await new Promise(resolve => setTimeout(resolve, 200))
  finishPreprocessAndEnterEdit()
}
// 生成素材 AI 摘要与标签（模拟）
const generateAssetMeta = (asset) => {
  if (!asset) return
  asset.summary = asset.summary || '围绕播客主题的核心内容片段，建议用于预告与社交片段。'
  if (!asset.tags || asset.tags.length === 0) {
    asset.tags = ['高光', '人声', '安静底噪']
  }
}

// 音频试听播放
const currentPlayingAsset = ref(null)
const previewAudio = ref(null)
const assetAudioRefs = ref({})
const assetAudioMeta = ref({})
const FIXED_ASSET_TOTAL_SECONDS = 45 * 60 + 20
const FIXED_BG_TOTAL_SECONDS = 3 * 60 + 15

const getFixedAssetTotalSeconds = (assetId) => {
  if (assetId === 2) return FIXED_BG_TOTAL_SECONDS
  return FIXED_ASSET_TOTAL_SECONDS
}

const setAssetAudioRef = (el, assetId) => {
  if (!assetId) return
  if (el) {
    assetAudioRefs.value[assetId] = el
  } else {
    delete assetAudioRefs.value[assetId]
  }
}

const handleAssetAudioMetadata = (asset) => {
  const el = assetAudioRefs.value[asset?.id]
  if (!asset?.id || !el) return
  assetAudioMeta.value[asset.id] = {
    ...(assetAudioMeta.value[asset.id] || {}),
    duration: Number.isFinite(el.duration) && el.duration > 0 ? el.duration : 0
  }
}

const handleAssetAudioTimeUpdate = (asset) => {
  const el = assetAudioRefs.value[asset?.id]
  if (!asset?.id || !el) return
  assetAudioMeta.value[asset.id] = {
    ...(assetAudioMeta.value[asset.id] || {}),
    currentTime: el.currentTime,
    duration: Number.isFinite(el.duration) && el.duration > 0 ? el.duration : (assetAudioMeta.value[asset.id]?.duration || 0)
  }
}

const getScaledAssetTime = (assetId, rawSeconds) => {
  const meta = assetAudioMeta.value[assetId]
  const duration = meta?.duration || 0
  if (!duration || duration <= 0) return 0
  const total = getFixedAssetTotalSeconds(assetId)
  const ratio = total / duration
  return Math.max(0, Math.min(total, rawSeconds * ratio))
}

const toggleInlineAssetAudio = (asset) => {
  const el = assetAudioRefs.value[asset?.id]
  if (!asset || !el) return
  if (!el.paused) {
    el.pause()
    return
  }
  const p = el.play()
  if (p && typeof p.catch === 'function') {
    p.catch(() => {
      asset.playing = false
      if (currentPlayingAsset.value === asset) currentPlayingAsset.value = null
    })
  }
}

const getAssetFallbackAudioUrl = (asset) => {
  if (asset?.name?.includes('补录')) return supplementAudio
  return editedAudio
}

const handleAssetAudioError = (asset) => {
  if (!asset) return
  const fallbackUrl = getAssetFallbackAudioUrl(asset)
  if (!fallbackUrl || asset.url === fallbackUrl) return
  asset.url = fallbackUrl
}

const seekInlineAssetAudio = (asset, rawSeconds) => {
  const el = assetAudioRefs.value[asset?.id]
  if (!asset || !el) return
  el.currentTime = Math.max(0, Math.min(el.duration || 0, rawSeconds))
}

const handleAssetAudioPlay = (asset) => {
  if (!asset) return

  if (previewAudio.value) {
    previewAudio.value.pause()
    previewAudio.value.currentTime = 0
  }

  if (currentPlayingAsset.value && currentPlayingAsset.value !== asset) {
    currentPlayingAsset.value.playing = false
  }
  currentPlayingAsset.value = asset
  asset.playing = true
}

const handleAssetAudioPause = (asset) => {
  if (!asset) return
  asset.playing = false
  if (currentPlayingAsset.value === asset) {
    currentPlayingAsset.value = null
  }
}

const handleAssetAudioEnded = (asset) => {
  if (!asset) return
  asset.playing = false
  if (currentPlayingAsset.value === asset) {
    currentPlayingAsset.value = null
  }
}

const playAsset = (asset) => {
  if (!asset || asset.type !== 'audio') return

  const inlineAudio = assetAudioRefs.value[asset.id]
  if (inlineAudio) {
    if (!inlineAudio.paused) {
      inlineAudio.pause()
      return
    }
    const p = inlineAudio.play()
    if (p && typeof p.catch === 'function') {
      p.catch(() => {
        asset.playing = false
        if (currentPlayingAsset.value === asset) {
          currentPlayingAsset.value = null
        }
      })
    }
    return
  }

  if (!previewAudio.value) {
    previewAudio.value = new Audio()
    previewAudio.value.addEventListener('ended', () => {
      if (currentPlayingAsset.value) {
        currentPlayingAsset.value.playing = false
      }
      currentPlayingAsset.value = null
    })
  }

  if (currentPlayingAsset.value === asset) {
    if (asset.playing) {
      previewAudio.value.pause()
      asset.playing = false
      currentPlayingAsset.value = null
      return
    }

    const p = previewAudio.value.play()
    asset.playing = true
    currentPlayingAsset.value = asset
    if (p && typeof p.catch === 'function') {
      p.catch(() => {
        asset.playing = false
        currentPlayingAsset.value = null
      })
    }
    return
  }

  if (currentPlayingAsset.value) {
    currentPlayingAsset.value.playing = false
  }

  previewAudio.value.pause()
  previewAudio.value.currentTime = 0
  previewAudio.value.src = asset.url || getAssetFallbackAudioUrl(asset)

  asset.playing = true
  currentPlayingAsset.value = asset

  const p = previewAudio.value.play()
  if (p && typeof p.catch === 'function') {
    p.catch(() => {
      asset.playing = false
      currentPlayingAsset.value = null
    })
  }
}
// 开始预处理
const startPreprocess = async () => {
  if (preprocessRunning.value) return
  voiceEnhanceEnabled.value = !!preVoiceEnhance.value
  echoRemovalEnabled.value = !!preEchoRemoval.value
  showPreprocessModal.value = false
  if (preTranscribe.value) {
    // 先让弹窗完成退场，再显示预处理进度；处理完成后再跳转下一页
    await nextTick()
    await new Promise(resolve => setTimeout(resolve, 250))
    await startTranscription()
  }
  hasUploaded.value = true
  activeToolTab.value = 'edit'
}

const handleInlineDrop = async (e) => {
  e.preventDefault()
  
  // 检查是否是从外部拖入的文件
  const files = e.dataTransfer.files
  if (files && files.length > 0) {
    const f = files[0]
    if (!isSupportedUploadFile(f)) {
      alert('仅支持 300MB 以内的音频/视频文件')
      return
    }
    inlinePendingFile.value = f
    inlineFilename.value = f.name
    return
  }
  
  // 检查是否是从左侧素材库拖入的素材
  const assetId = e.dataTransfer.getData('assetId') || e.dataTransfer.getData('text/plain')
  const draggedAssetFromSidebar = draggedAsset.value
  if (assetId || draggedAssetFromSidebar) {
    const asset = assets.value.find(a => a.id == assetId) || draggedAssetFromSidebar
    if (asset) {
      queueAssetForUpload(asset)
    }
  }
  draggedAsset.value = null
}

const handleInlineSelect = async (e) => {
  const f = e.target.files?.[0]
  if (!f) return
  if (!isSupportedUploadFile(f)) {
    alert('仅支持 300MB 以内的音频/视频文件')
    e.target.value = ''
    return
  }
  selectedAssetIds.value = []
  inlinePendingFile.value = f
  inlineFilename.value = f.name
  e.target.value = ''
}

const confirmInlineUpload = async () => {
  if (!inlinePendingFile.value && selectedAssetIds.value.length > 0) {
    useSelectedAssets()
    return
  }
  if (!inlinePendingFile.value) return
  const f = inlinePendingFile.value
  inlineUploading.value = true
  inlineProgress.value = 0
  const result = await materialStore.uploadMaterial(f, (progress) => {
    inlineProgress.value = progress
  })
  if (!result.success) {
    inlineUploading.value = false
    alert(result.error || '上传失败，请重试')
    return
  }
  assets.value.unshift({
    id: result.data?.id || Date.now(),
    name: f.name,
    type: f.type.startsWith('video') ? 'video' : 'audio',
    duration: result.data?.duration || '00:00',
    format: f.name.split('.').pop().toUpperCase(),
    category: f.type.startsWith('video') ? '效果音' : '人声',
    used: false,
    playing: false,
    summary: result.data?.summary || '',
    tags: result.data?.tags || [],
    editingSummary: false
  })
  setActiveMaterialDuration(result.data?.duration || '00:00')
  hasUploaded.value = false
  inlineUploading.value = false
  inlinePendingFile.value = null
  showPreprocessModal.value = true
}

// Methods
const formatTime = (seconds) => {
  const safeSeconds = Math.max(0, Number(seconds) || 0)
  const h = Math.floor(safeSeconds / 3600)
  const m = Math.floor((safeSeconds % 3600) / 60)
  const s = Math.floor(safeSeconds % 60)
  return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
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



const flashProcessedTranscriptIndices = (indices, optType) => {
  if (scriptOptimizationHighlightTimer) {
    clearTimeout(scriptOptimizationHighlightTimer)
    scriptOptimizationHighlightTimer = null
  }
  const uniqueIndices = Array.from(new Set((indices || []).filter(index => Number.isInteger(index) && index >= 0)))
  if (uniqueIndices.length === 0) return

  recentProcessedTranscriptIndices.value = uniqueIndices
  // 记录每个片段上一次处理的类型，供高亮配色使用
  uniqueIndices.forEach(i => {
    recentProcessedTranscriptMeta.value[i] = optType || 'generic'
  })
  scriptOptimizationHighlightTimer = setTimeout(() => {
    recentProcessedTranscriptIndices.value = []
    recentProcessedTranscriptMeta.value = {}
    scriptOptimizationHighlightTimer = null
  }, 2000)
}

const saveScriptOptimizationUndoSnapshot = () => {
  scriptOptimizationUndoSnapshot.value = {
    transcript: JSON.parse(JSON.stringify(mockTranscript.value)),
    suggestions: JSON.parse(JSON.stringify(scriptSuggestions.value)),
    lastType: lastScriptOptimizationType.value,
    message: scriptOptimizeMessage.value
  }
}

const undoLastScriptOptimization = () => {
  const snapshot = scriptOptimizationUndoSnapshot.value
  if (!snapshot) return

  // 清除对应已应用标记（如果有的话）
  if (snapshot.appliedType && appliedOptimizations.value && appliedOptimizations.value[snapshot.appliedType]) {
    delete appliedOptimizations.value[snapshot.appliedType]
  }

  mockTranscript.value = JSON.parse(JSON.stringify(snapshot.transcript))
  scriptSuggestions.value = JSON.parse(JSON.stringify(snapshot.suggestions))
  lastScriptOptimizationType.value = snapshot.lastType
  scriptOptimizeMessage.value = '已撤销刚刚的处理操作。'
  scriptOptimizationUndoSnapshot.value = null
  recalculateTranscriptDurationsFromText()
}

// 对应单条建议的撤销：使用 appliedOptimizations 中保存的 snapshot 恢复并清理标记
const undoScriptSuggestion = (suggestion) => {
  if (!suggestion || !suggestion.type) return
  const type = suggestion.type
  const applied = appliedOptimizations.value && appliedOptimizations.value[type]
  if (!applied || !applied.snapshot) {
    scriptOptimizeMessage.value = '未找到对应的应用记录，无法撤销。'
    return
  }

  const snap = applied.snapshot || {}
  if (snap.transcript) {
    mockTranscript.value = JSON.parse(JSON.stringify(snap.transcript))
  }
  if (snap.suggestions) {
    scriptSuggestions.value = JSON.parse(JSON.stringify(snap.suggestions))
  }
  lastScriptOptimizationType.value = snap.lastType || null
  scriptOptimizeMessage.value = `已撤销「${type}」的处理。`
  // 清理 applied 标记
  delete appliedOptimizations.value[type]
  // 重新计算时长/暂停等元信息
  recalculateTranscriptDurationsFromText()
}

// 从当前片段文本中删除指定口癖
const removeFiller = (segment, word) => {
  if (!segment || !segment.text) return
  segment.text = segment.text.split(word).join('')
}

// 脚本优化按钮交互：对当前页面数据做「可见」的示例性修改
const applyScriptOptimization = (type) => {
  // 如果该类型已经被应用（且未撤销），不重复执行，直接展示提示和高亮原处理结果
  if (appliedOptimizations.value && appliedOptimizations.value[type]) {
    scriptOptimizeMessage.value = appliedOptimizations.value[type].message || '此项已应用，保留上次处理结果。'
    if (Array.isArray(appliedOptimizations.value[type].processedIndices) && appliedOptimizations.value[type].processedIndices.length) {
      flashProcessedTranscriptIndices(appliedOptimizations.value[type].processedIndices, type)
    }
    return
  }

  saveScriptOptimizationUndoSnapshot()
  // 标记当前即将应用的类型，便于撤销时清理对应的已应用标记
  if (scriptOptimizationUndoSnapshot.value) {
    scriptOptimizationUndoSnapshot.value.appliedType = type
  }
  lastScriptOptimizationType.value = type

  // 保存一个用于精确撤销的快照到 appliedOptimizations（以便可以对单条记录进行撤销）
  appliedOptimizations.value = appliedOptimizations.value || {}
  appliedOptimizations.value[type] = {
    snapshot: JSON.parse(JSON.stringify(scriptOptimizationUndoSnapshot.value || {})),
    message: '',
    processedIndices: []
  }
  // 去口语冗余：自动删除所有片段里的口癖（留痕模式）
  if (type === 'filler' || type === 'stutter' || type === 'pause-abnormal') {
    let hasChanges = false
    const changedSegmentIndices = []
    mockTranscript.value.forEach((seg, segIndex) => {
      const tokens = parseSegmentText(seg.text)
      let changed = false
      const newTokens = tokens.flatMap(token => {
        const pauseMeta = token.type === 'pause' ? getPauseTokenMeta(seg, tokens.indexOf(token)) : null
        const shouldDelete =
          (type === 'filler' && token.type === 'filler') ||
          (type === 'stutter' && token.type === 'stutter') ||
          (type === 'pause-abnormal' && token.type === 'pause' && pauseMeta?.isAbnormal)

        // 针对当前选择的口癖类型进行留痕删除
        if (shouldDelete && token.type !== 'deleted') {
          changed = true
          hasChanges = true
          if (type === 'stutter') {
            const chars = Array.from(token.text || '')
            if (chars.length <= 1) {
              return [{ ...token, type: 'deleted' }]
            }
            return [
              { ...token, type: 'text', text: chars[0] },
              { ...token, type: 'deleted', text: chars.slice(1).join('') }
            ]
          }
          return [{ ...token, type: 'deleted' }]
        }
        return [token]
      })
      
      if (changed) {
        changedSegmentIndices.push(segIndex)
        let prefix = seg.text.startsWith('[TTS]') ? '[TTS]' : ''
        seg.text = prefix + newTokens.map(t => {
          if (t.type === 'deleted') return `~~${t.text}~~`
          return t.text
        }).join('')
      }
    })

    if (hasChanges) {
      // 同时给脚本优化建议里追加一条说明
      const optimizationMeta = {
        filler: {
          label: '已清理语气词',
          preview: '仅对语气词和常见口癖进行留痕删除，未处理口吃或停顿。',
          tag: '语气词'
        },
        stutter: {
          label: '已清理口吃',
          preview: '仅对重复口吃进行留痕删除，未处理语气词或停顿。',
          tag: '口吃'
        },
        'pause-abnormal': {
          label: '已清理异常停顿',
          preview: '仅对异常停顿进行留痕删除，保留正常停顿和其他口语内容。',
          tag: '异常停顿'
        }
      }
      scriptSuggestions.value.unshift({
        id: Date.now(),
        type: type,
        label: optimizationMeta[type]?.label || '已应用口语冗余清理',
        preview: optimizationMeta[type]?.preview || '自动识别并留痕删除了冗余口语内容。',
        tag: optimizationMeta[type]?.tag || '口癖优化'
      })
      scriptOptimizeMessage.value = optimizationMeta[type]?.preview || '已对文字稿中的冗余口语内容进行留痕删除，提升内容精炼度。'
      flashProcessedTranscriptIndices(changedSegmentIndices, type)
      // 记录为已应用，保留本次处理结果和被处理的片段索引
      appliedOptimizations.value = appliedOptimizations.value || {}
      appliedOptimizations.value[type] = appliedOptimizations.value[type] || {}
      appliedOptimizations.value[type].message = scriptOptimizeMessage.value
      appliedOptimizations.value[type].processedIndices = changedSegmentIndices.slice()
    } else {
      const emptyMessageMap = {
        filler: '未检测到可删除的语气词，文稿保持原样。',
        stutter: '未检测到可删除的口吃，文稿保持原样。',
        'pause-abnormal': '未检测到可删除的异常停顿，文稿保持原样。'
      }
      scriptOptimizeMessage.value = emptyMessageMap[type] || '未检测到明显的口语冗余或口吃，文稿保持原样。'
    }
    return
  }

  // 逻辑纠错：对文稿中的逻辑断层或病句进行修正（留痕模式）
  if (type === 'logic') {
    let hasChanges = false
    const changedSegmentIndices = []
    // 示例：修正第 3 个片段（索引为 2）的逻辑连贯性
    if (mockTranscript.value[2] && !mockTranscript.value[2].text.includes('++')) {
      const seg = mockTranscript.value[2]
      const originalText = seg.text
      // 模拟纠错 1：增加过渡词，使句子更连贯
      seg.text = originalText.replace('自动生成剪辑建议', '++极大提高了工作效率，并++自动生成剪辑建议')
      hasChanges = true
      changedSegmentIndices.push(2)
    }

    // 示例：修正第 6 个片段（索引为 5）的病句
    if (mockTranscript.value[5] && !mockTranscript.value[5].text.includes('++')) {
      const seg = mockTranscript.value[5]
      const originalText = seg.text
      // 模拟纠错 2：修正表达
      seg.text = originalText.replace('主要体现在哪些方面呢', '++具体的竞争优势++主要体现在哪些方面呢')
      hasChanges = true
      changedSegmentIndices.push(5)
    }

    if (hasChanges) {
      scriptSuggestions.value.unshift({
        id: Date.now(),
        type: 'logic',
        label: '已应用逻辑纠错建议',
        preview: '识别到话语逻辑较为生硬，已自动添加补位过渡词。如果不满意，可直接点击文字稿中的绿色高亮部分撤回。',
        tag: '逻辑优化'
      })
      scriptOptimizeMessage.value = '已在文稿中应用逻辑纠错建议，新增内容已用绿色高亮标注。点击高亮内容可一键撤回。'
      flashProcessedTranscriptIndices(changedSegmentIndices, 'logic')
      appliedOptimizations.value = appliedOptimizations.value || {}
      appliedOptimizations.value['logic'] = appliedOptimizations.value['logic'] || {}
      appliedOptimizations.value['logic'].message = scriptOptimizeMessage.value
      appliedOptimizations.value['logic'].processedIndices = changedSegmentIndices.slice()
    } else {
      scriptOptimizeMessage.value = '未检测到明显的逻辑断层，文稿逻辑基本通顺。'
    }
    return
  }

  // 一键精华提取：直接复用已有 scriptPreview 中「高光合集」分组
  if (type === 'highlights') {
    const entriesFromGolden = (goldenSentences.value || []).slice(0, 6).map((s, idx) => ({
      id: s.id || `h-${idx}-${Date.now()}`,
      speaker: '高光',
      time: formatTime(s.startTime ?? 0),
      type: '高光',
      content: s.content,
      tags: [{ text: '金句', type: '高光' }]
    }))
    const fallbackEntries = (mockTranscript.value || []).slice(0, 6).map((seg, idx) => ({
      id: `h-fb-${idx}`,
      speaker: seg.speaker || '片段',
      time: formatTime(seg.startTime ?? 0),
      type: '高光',
      content: getCleanSegmentText(seg.text || ''),
      tags: [{ text: '片段', type: '高光' }]
    }))
    scriptPreview.value = [
      {
        id: 'g-highlights',
        strategy: 'highlights',
        label: '高光合集提取',
        description: '从文字稿中提取出的金句与核心片段（与文字稿保持一致）。',
        entries: entriesFromGolden.length ? entriesFromGolden : fallbackEntries
      }
    ]
    scriptOptimizeMessage.value = '已生成高光精华预览，便于快速查看核心内容。'
    return
  }

  // BGM 智能匹配：在脚本预览下方追加一组背景音乐推荐
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
    scriptPreview.value = [
      bgmGroup,
      ...scriptPreview.value.filter(g => g.strategy !== 'bgm')
    ]
    scriptOptimizeMessage.value = '已生成 BGM 推荐结果，可在预览列表中查看。'
  }
}

// 最近语音生成任务（用于在面板中展示）
const voiceTasks = ref([])

// 提示词生成语音相关状态
const voicePrompt = ref('')
const isGeneratingVoice = ref(false)
const generatedVoiceSentences = ref([])

// 新的声演实验室状态
const lockedTTSSegment = ref(null)
const voiceOptions = ref([
  { id: 1, name: '温柔女声', style: '亲切自然' },
  { id: 2, name: '磁性男声', style: '深沉有力' },
  { id: 3, name: '活泼少女', style: '青春活力' },
  { id: 4, name: '成熟男声', style: '稳重专业' },
  { id: 5, name: '知性女声', style: '优雅知性' },
  { id: 6, name: '可爱童声', style: '天真可爱' }
])

const selectedVoice = ref(null)
const isCloningVoice = ref(false)
const generateProgress = ref(0)
const editSupplementText = ref('')
const clonedVoiceSentences = ref([])
const insertedVoiceRecords = ref([])

// 根据提示词生成语音内容
const generateVoiceFromPrompt = async () => {
  if (!voicePrompt.value.trim()) return
  
  isGeneratingVoice.value = true
  
  try {
    // 模拟AI生成过程
    await new Promise(resolve => setTimeout(resolve, 1500))
    
    // 直接使用用户输入的内容作为生成的句子
    const sentences = [
      { 
        id: Date.now(), 
        text: voicePrompt.value, 
        duration: Math.ceil(voicePrompt.value.length / 5), // 简单估算时长
        style: '自定义内容',
        audioUrl: supplementAudio
      }
    ]
    
    generatedVoiceSentences.value = sentences
    
    // 同时添加到任务列表
    sentences.forEach((sentence, idx) => {
      voiceTasks.value.unshift({
        id: sentence.id,
        type: 'prompt-generated',
        label: `AI生成语音 ${idx + 1}`,
        status: '已完成',
        createdAt: new Date().toLocaleTimeString('zh-CN', { hour12: false }),
        note: sentence.text.substring(0, 30) + '...',
        ttsText: sentence.text,
        duration: sentence.duration,
        style: sentence.style
      })
    })
    
  } catch (error) {
    console.error('生成语音内容失败:', error)
  } finally {
    isGeneratingVoice.value = false
  }
}

// 选择语音句子插入到文字稿
const selectVoiceSentence = (sentence) => {
  // 将生成的句子作为TTS插入到当前位置
  const newSeg = createTranscriptSegment({
    startTime: currentTime.value,
    endTime: currentTime.value + sentence.duration,
    speaker: 'AI',
    text: '[TTS]' + sentence.text,
    confirmed: false,
    originalText: sentence.text // 保存原文参考
  })
  
  // 找到当前时间对应的插入位置
  const insertIndex = mockTranscript.value.findIndex(seg => seg.startTime > currentTime.value)
  if (insertIndex !== -1) {
    mockTranscript.value.splice(insertIndex, 0, newSeg)
  } else {
    mockTranscript.value.push(newSeg)
  }
  recalculateTranscriptDurationsFromText()
  
  // 标记为已插入
  const task = voiceTasks.value.find(t => t.ttsText === sentence.text)
  if (task) {
    task.inserted = true
  }
  
  // 显示提示
  audioOptimizeMessage.value = `已插入语音内容：${sentence.text.substring(0, 20)}...`
  setTimeout(() => {
    audioOptimizeMessage.value = ''
  }, 3000)
}

// 预览语音句子
const previewVoiceSentence = (sentence) => {
  if (!sentence) return

  if (!previewAudio.value) {
    previewAudio.value = new Audio()
    previewAudio.value.addEventListener('ended', () => {
      if (currentPlayingAsset.value) {
        currentPlayingAsset.value.playing = false
      }
      currentPlayingAsset.value = null
    })
  }

  if (currentPlayingAsset.value) {
    currentPlayingAsset.value.playing = false
    currentPlayingAsset.value = null
  }

  const previewUrl = sentence.audioUrl || supplementAudio
  previewAudio.value.pause()
  previewAudio.value.currentTime = 0
  previewAudio.value.src = previewUrl

  previewAudio.value.onerror = () => {
    if (previewAudio.value && previewAudio.value.src !== supplementAudio) {
      previewAudio.value.src = supplementAudio
      const fallbackPlay = previewAudio.value.play()
      if (fallbackPlay && typeof fallbackPlay.catch === 'function') {
        fallbackPlay.catch(() => {})
      }
    }
  }

  const p = previewAudio.value.play()
  if (p && typeof p.catch === 'function') {
    p.catch(() => {})
  }

  audioOptimizeMessage.value = `正在预览补录音频：${sentence.text.substring(0, 20)}...`
  setTimeout(() => {
    audioOptimizeMessage.value = ''
  }, 2000)
}

// 为生成的句子打开TTS预览编辑
const openTTSPreviewForSentence = (sentence) => {
  // 创建一个临时任务对象用于TTS预览
  const tempTask = {
    id: sentence.id,
    type: 'prompt-generated',
    label: `AI生成语音`,
    status: '已完成',
    ttsText: sentence.text,
    duration: sentence.duration,
    style: sentence.style,
    audioUrl: sentence.audioUrl || supplementAudio
  }
  
  // 打开TTS预览模态框
  currentTTSTask.value = tempTask
  ttsDraftText.value = sentence.text
  showTTSModal.value = true
}

// 更新生成的句子文本
const updateSentenceText = (sentence, event) => {
  const newText = event.target.innerText.trim()
  if (newText) {
    sentence.text = newText
    // 重新计算时长
    sentence.duration = Math.ceil(newText.length / 5)
  }
}

// 删除生成的句子
const deleteGeneratedVoiceSentence = (sentenceId) => {
  generatedVoiceSentences.value = generatedVoiceSentences.value.filter(s => s.id !== sentenceId)
  // 同时从任务列表中删除
  voiceTasks.value = voiceTasks.value.filter(t => t.id !== sentenceId)
}

// 选择音色
const selectVoice = (voice) => {
  selectedVoice.value = voice
}

// 音色克隆
const cloneVoice = async () => {
  if (!lockedTTSSegment.value || !selectedVoice.value) return
  
  isCloningVoice.value = true

    // 👉 模拟进度条加载
  await new Promise(resolve => {
    const timer = setInterval(() => {
      generateProgress.value += 4
      if (generateProgress.value >= 100) {
        clearInterval(timer)
        resolve()
      }
    }, 80)
  })
  
  try {
    // 模拟AI克隆过程
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    // 生成克隆的句子
    const clonedSentence = {
      id: Date.now(),
      text: lockedTTSSegment.value.text,
      duration: Math.ceil(lockedTTSSegment.value.text.length / 5),
      voiceName: selectedVoice.value.name,
      voiceStyle: selectedVoice.value.style,
      voiceId: selectedVoice.value.id
    }
    
    clonedVoiceSentences.value = [clonedSentence]
    
  } catch (error) {
    console.error('音色克隆失败:', error)
  } finally {
    isCloningVoice.value = false
  }
}

// 预览克隆的语音
const previewClonedVoice = (sentence) => {
  audioOptimizeMessage.value = `正在预览${sentence.voiceName}：${sentence.text.substring(0, 20)}...`
  setTimeout(() => {
    audioOptimizeMessage.value = ''
  }, 2000)
}

// 确认插入克隆的语音
const confirmInsertClonedVoice = (sentence) => {
  if (!lockedTTSSegment.value) return
  
  const seg = mockTranscript.value[lockedTTSSegment.value.index]
  if (!seg) return
  
  // 更新文字稿
  seg.text = `[TTS] ${sentence.text}`
  seg.speaker = sentence.voiceName
  seg.voiceStyle = sentence.voiceStyle
  seg.voiceId = sentence.voiceId
  seg.isCloned = true
  seg.audioUrl = sentence.audioUrl || supplementAudio
  recalculateTranscriptDurationsFromText()
  
  // 添加到插入记录
  const record = {
    id: sentence.id,
    text: sentence.text,
    voiceName: sentence.voiceName,
    voiceStyle: sentence.voiceStyle,
    voiceId: sentence.voiceId,
    transcriptIndex: lockedTTSSegment.value.index,
    audioUrl: sentence.audioUrl || supplementAudio,
    createdAt: new Date().toLocaleTimeString('zh-CN', { hour12: false })
  }
  
  insertedVoiceRecords.value.unshift(record)
  
  // 清空克隆的句子
  clonedVoiceSentences.value = []
  
  // 解锁
  lockedTTSSegment.value = null
  selectedVoice.value = null
  
  // 显示提示
  audioOptimizeMessage.value = `已插入${sentence.voiceName}生成的语音`
  setTimeout(() => {
    audioOptimizeMessage.value = ''
  }, 3000)
}

// 删除克隆的语音
const deleteClonedVoice = (sentenceId) => {
  clonedVoiceSentences.value = clonedVoiceSentences.value.filter(s => s.id !== sentenceId)
}

// 编辑插入的语音记录
const editInsertedVoice = (record) => {
  const seg = mockTranscript.value[record.transcriptIndex]
  if (!seg) return
  
  // 锁定到声演实验室，移除[TTS]前缀
  lockedTTSSegment.value = {
    index: record.transcriptIndex,
    text: seg.text.replace('[TTS] ', '')
  }
  
  // 选择原来的音色
  const voice = voiceOptions.value.find(v => v.id === record.voiceId)
  if (voice) {
    selectedVoice.value = voice
  }
  
  // 打开声演实验室
  openRightPanel.value = 'voice'
}


// 点击句子 → 加载到右边
const loadSegmentToVoiceLab = (segment, index) => {
  lockedTTSSegment.value = {
    index: index,
    text: segment.text.replace(/^\[TTS\]\s*/, '')
  }
  editSupplementText.value = lockedTTSSegment.value.text
  openRightPanel.value = 'voice'
}

// 生成并替换回左边
const confirmEditAndGenerate = async () => {
  if (!lockedTTSSegment.value || !editSupplementText.value.trim()) return

  // 开始进度条
  isCloningVoice.value = true
  generateProgress.value = 0

  await new Promise((resolve) => {
    const timer = setInterval(() => {
      generateProgress.value += 5
      if (generateProgress.value >= 100) {
        clearInterval(timer)
        resolve()
      }
    }, 100)
  })

  // 替换回左边
  const idx = lockedTTSSegment.value.index
  mockTranscript.value[idx].text = `[TTS] ${editSupplementText.value}`
  recalculateTranscriptDurationsFromText()

  // 重置
  editSupplementText.value = ''
  lockedTTSSegment.value = null
  isCloningVoice.value = false
}

// 删除插入的语音记录
const deleteInsertedVoice = (recordId) => {
  const record = insertedVoiceRecords.value.find(r => r.id === recordId)
  if (!record) return
  
  // 从文字稿中删除
  mockTranscript.value.splice(record.transcriptIndex, 1)
  recalculateTranscriptDurationsFromText()
  
  // 从记录中删除
  insertedVoiceRecords.value = insertedVoiceRecords.value.filter(r => r.id !== recordId)
  
  // 显示提示
  audioOptimizeMessage.value = '已删除插入的语音'
  setTimeout(() => {
    audioOptimizeMessage.value = ''
  }, 2000)
}

// 编辑克隆的语音段落
const editClonedSegment = (index) => {
  const seg = mockTranscript.value[index]
  if (!seg || !seg.isCloned) return
  
  // 锁定到声演实验室，移除[TTS]前缀
  lockedTTSSegment.value = {
    index: index,
    text: seg.text.replace('[TTS] ', '')
  }
  
  // 选择原来的音色
  const voice = voiceOptions.value.find(v => v.id === seg.voiceId)
  if (voice) {
    selectedVoice.value = voice
  }
  
  // 打开声演实验室
  openRightPanel.value = 'voice'
}

// 语音生成按钮交互：生成一条任务记录
const handleVoiceTool = (type) => {
  const label = type === 'clone' ? '声线克隆' : '语音生成'
  const id = Date.now()
  voiceTasks.value.unshift({
    id,
    type,
    label,
    status: '排队中',
    createdAt: new Date().toLocaleTimeString('zh-CN', { hour12: false }),
    note: type === 'clone'
      ? '会根据当前项目的一段语音生成新的声线配置。'
      : '根据提示词生成符合语境的语音内容。',
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

// 根据克隆的音色生成语音
const generateVoiceFromClonedStyle = async (segment) => {
  if (!segment || !segment.text.trim()) return
  
  isGeneratingVoice.value = true
  
  try {
    // 模拟AI生成过程
    await new Promise(resolve => setTimeout(resolve, 1500))
    
    // 使用克隆的音色生成语音
    const sentences = [
      { 
        id: Date.now(), 
        text: segment.text, 
        duration: Math.ceil(segment.text.length / 5), // 简单估算时长
        style: segment.speaker || 'A',
        speaker: segment.speaker || 'A'
      }
    ]
    
    generatedVoiceSentences.value = sentences
    
    // 同时添加到任务列表
    sentences.forEach((sentence, idx) => {
      voiceTasks.value.unshift({
        id: sentence.id,
        type: 'cloned-voice',
        label: `克隆音色 ${idx + 1}`,
        status: '已完成',
        createdAt: new Date().toLocaleTimeString('zh-CN', { hour12: false }),
        note: sentence.text.substring(0, 30) + '...',
        ttsText: sentence.text,
        duration: sentence.duration,
        style: sentence.style
      })
    })
    
    // 自动插入到文字稿
    const newSeg = createTranscriptSegment({
      startTime: segment.endTime,
      endTime: segment.endTime + sentence.duration,
      speaker: sentence.speaker,
      text: '[TTS]' + sentence.text,
      originalText: segment.text,
      confirmed: false
    })
    
    const insertIndex = mockTranscript.value.findIndex(s => s.startTime === segment.startTime)
    if (insertIndex > -1) {
      mockTranscript.value.splice(insertIndex + 1, 0, newSeg)
      editingSegmentId.value = insertIndex + 1
      recalculateTranscriptDurationsFromText()
    }
    
  } catch (error) {
    console.error('生成语音内容失败:', error)
  } finally {
    isGeneratingVoice.value = false
  }
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
  currentTTSTask.value = {
    ...task,
    audioUrl: task?.audioUrl || supplementAudio
  }
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
  const newSeg = createTranscriptSegment({
    startTime: baseEnd,
    endTime: baseEnd + Math.max(3, Math.min(15, Math.ceil(text.length / 8))), // 简单估时
    speaker: 'AI',
    text: '[TTS]' + text,
    confirmed: true,
    isNew: true
  })
  if (idx >= 0) {
    mockTranscript.value.splice(idx + 1, 0, newSeg)
  } else {
    mockTranscript.value.push(newSeg)
  }
  recalculateTranscriptDurationsFromText()
  // 在时间轴上为 AI 文本插入一个占位槽位
  let aiTrack = tracks.value.find(t => t.name.includes('AI'))
  if (!aiTrack) {
    aiTrack = {
      id: Date.now(),
      name: 'AI 合成',
      type: '音频',
      color: 'bg-[#8B5CF6]',
      muted: false,
      solo: false,
      volume: 80,
      pan: 0,
      collapsed: false,
      locked: false,
      recording: false,
      clips: []
    }
    tracks.value.push(aiTrack)
  }
  aiTrack.clips.push({
    id: Date.now() + 1,
    name: 'AI 补录',
    start: newSeg.startTime,
    end: newSeg.endTime,
    color: 'bg-gradient-to-r from-[#8B5CF6]/80 to-[#A78BFA]/80 border-[#A78BFA]',
    fadeIn: false,
    fadeOut: false
  })
  const ttsAudioUrl = currentTTSTask.value?.audioUrl || supplementAudio
  newSeg.audioUrl = ttsAudioUrl
  const lastClip = aiTrack.clips[aiTrack.clips.length - 1]
  if (lastClip) lastClip.audioUrl = ttsAudioUrl
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
  // 写入作品仓库：记录最近一次导出，供“内容增值/作品仓库”读取
  try {
    const work = {
      id: 'last-' + Date.now(),
      title: currentProject.value?.name ? `${currentProject.value.name} · 最新导出` : '最新导出',
      createdAt: new Date().toISOString(),
      description: '来自剪辑工作台的成品音频',
      tags: ['最新', '成品'],
      audioUrl: editedAudio
    }
    localStorage.setItem('lastExportedWork', JSON.stringify(work))
  } catch (e) {
    console.warn('无法写入本地作品仓库缓存', e)
  }
}

// 脚本优化反馈提示
const scriptOptimizeMessage = ref('')
const lastScriptOptimizationType = ref('')
const scriptOptimizationUndoSnapshot = ref(null)
const audioOptimizeMessage = ref('')
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

const toggleBookmarkForCurrentSegment = () => {
  const idx = getCurrentSegmentIndex()
  if (idx < 0) return
  const seg = mockTranscript.value[idx]
  if (!seg) return
  const existing = markers.value.find(m => m.segmentIndex === idx)
  if (existing) {
    markers.value = markers.value.filter(m => m.id !== existing.id)
    return
  }
  markers.value.push({
    id: Date.now(),
    time: seg.startTime,
    segmentIndex: idx,
    label: (getCleanSegmentText(seg.text) || '对话片段').slice(0, 24)
  })
}

const jumpToBookmark = (marker) => {
  seekToTime(marker.time)
  if (typeof marker.segmentIndex === 'number') {
    const el = segmentRefs.value[marker.segmentIndex]
    if (el && typeof el.scrollIntoView === 'function') {
      el.scrollIntoView({ behavior: 'smooth', block: 'center' })
    }
  }
  showMarkersPanel.value = false
}

const addMarkerAtSentence = (sentence) => {
  markers.value.push({
    id: Date.now(),
    time: sentence.startTime,
    label: `金句: ${sentence.content.substring(0, 10)}...`
  })
  
  // 显示提示
  audioOptimizeMessage.value = `已在 ${formatTime(sentence.startTime)} 添加标记点`
  setTimeout(() => {
    audioOptimizeMessage.value = ''
  }, 3000)
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
const recentProcessedTranscriptIndices = ref([])
const recentProcessedTranscriptMeta = ref({})

const isSegmentHighlighted = (index) => {
  return highlightedTranscriptIndices.value.includes(index)
}

const isRecentlyProcessedSegment = (index) => {
  return recentProcessedTranscriptIndices.value.includes(index)
}

const getRecentProcessedType = (index) => {
  return recentProcessedTranscriptMeta.value?.[index] || null
}

const getDeletionHighlightClass = (index) => {
  if (!isRecentlyProcessedSegment(index)) return ''
  const t = getRecentProcessedType(index) || 'generic'
  if (t === 'filler') return 'bg-yellow-200 text-yellow-900 border border-yellow-300'
  if (t === 'stutter') return 'bg-purple-200 text-purple-900 border border-purple-300'
  if (t === 'pause-abnormal') return 'bg-rose-100 text-rose-800 border border-rose-200'
  if (t === 'logic') return 'bg-green-200 text-green-900 border border-green-300'
  return 'bg-yellow-200 text-yellow-900 border border-yellow-300'
}

// AI 建议相关方法
const hasAIRecommendations = (segment) => {
  const tokens = parseSegmentText(segment.text)
  return tokens.some(token => token.type === 'filler' || token.type === 'stutter')
}

const showAIRecommendations = (segment, event) => {
  // 这里可以实现弹出AI建议的逻辑
  const tokens = parseSegmentText(segment.text)
  const fillers = tokens.filter(token => token.type === 'filler' || token.type === 'stutter')
  
  if (fillers.length > 0) {
    // 模拟AI建议
    const suggestions = fillers.map(token => {
      if (token.type === 'filler') {
        return `建议删除填充词 "${token.text}"`
      } else if (token.type === 'stutter') {
        return `建议修正重复词 "${token.text}"`
      }
      return ''
    }).filter(Boolean)
    
    // 简单的提示显示
    alert('AI 优化建议:\n' + suggestions.join('\n'))
  }
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
  await new Promise(resolve => setTimeout(resolve, 1200))
  
  const suggestions = []
  
  if (cuttingStrategy.value === 'silence') {
    suggestions.push({
      id: `silence-1`,
      label: '建议切除：超长静音',
      previewHtml: '检测到 <span class="text-pink-600 font-bold">5.2s</span> 的无效静音片段 (01:12 - 01:17)',
      tag: '静音',
      type: 'silence',
      action: 'remove'
    })
    suggestions.push({
      id: `silence-2`,
      label: '建议切除：环境噪音片段',
      previewHtml: '检测到 <span class="text-pink-600 font-bold">3.8s</span> 的底噪过大片段 (03:45 - 03:49)',
      tag: '静音',
      type: 'silence',
      action: 'remove'
    })
  } else if (cuttingStrategy.value === 'pause') {
    suggestions.push({
      id: `pause-1`,
      label: '建议切除：卡壳停顿',
      previewHtml: '说话人 A 反复出现“呃、那个”后的异常停顿 (<span class="text-rose-600 font-bold">2.4s</span>)，建议删掉并压缩到 0.5s',
      tag: '异常停顿',
      type: 'pause',
      action: 'remove'
    })
    suggestions.push({
      id: `pause-2`,
      label: '建议保留：情绪沉默',
      previewHtml: '在表达重点后出现的沉默 (<span class="text-emerald-600 font-bold">1.2s</span>) 更像情绪留白，建议保留',
      tag: '正常停顿',
      type: 'pause',
      action: 'keep'
    })
  } else if (cuttingStrategy.value === 'noise') {
    suggestions.push({
      id: `noise-1`,
      label: '建议清理：明显呼吸音',
      previewHtml: '检测到 3 处明显的深呼吸音，建议应用 <span class="text-purple-600 font-bold">AI 降噪滤镜</span>',
      tag: '噪音',
      type: 'noise',
      action: 'filter'
    })
  } else if (cuttingStrategy.value === 'normalize') {
    suggestions.push({
      id: `norm-1`,
      label: '建议优化：响度不均',
      previewHtml: '说话人 B 音量较小（-18 LUFS），建议整体提升 <span class="text-emerald-600 font-bold">+4dB</span> 以匹配说话人 A',
      tag: '均衡',
      type: 'normalize',
      action: 'gain'
    })
  }
  
  cutSuggestions.value = suggestions
  isGenerating.value = false
}

// 应用剪辑建议
const applyCutSuggestion = (suggestion) => {
  // 从建议列表中移除
  cutSuggestions.value = cutSuggestions.value.filter(s => s.id !== suggestion.id)
  
  // 模拟应用后的反馈
  let feedback = ''
  switch (suggestion.type) {
    case 'silence': feedback = '已自动切除静音片段并重新编排时间轴。'; break;
    case 'pause': feedback = suggestion.action === 'keep' ? '已标记为保留停顿，情绪留白会保留下来。' : '已缩减卡壳停顿，衔接更加自然。'; break;
    case 'noise': feedback = '已应用 AI 降噪滤镜，音频更清澈。'; break;
    case 'normalize': feedback = '已均衡响度，整体听感更一致。'; break;
    default: feedback = '已应用剪辑建议。';
  }
  
  audioOptimizeMessage.value = feedback
  transcriptRepairing.value = true
  if (transcriptRepairTimer) {
    clearTimeout(transcriptRepairTimer)
  }
  transcriptRepairTimer = setTimeout(() => {
    transcriptRepairing.value = false
    transcriptRepairTimer = null
  }, 2600)
}

// 应用脚本优化建议
const applyScriptSuggestion = (suggestion) => {
  // 从建议列表中移除
  scriptSuggestions.value = scriptSuggestions.value.filter(s => s.id !== suggestion.id)
  scriptOptimizeMessage.value = `已确认: ${suggestion.label}`
}

const buildSamplePreview = () => {
  const groups = [
    {
      id: 'g-silence',
      strategy: 'silence',
      label: '静音自动切除',
      description: '自动识别并标记无效静音片段',
      entries: [
        { id: 'e1', speaker: '系统', time: '01:12-01:17', type: '静音', content: '此处存在 5.2s 的完全静音，建议移除以保持节奏。', tags: [{ text: '无效静音', type: '静音' }] },
        { id: 'e2', speaker: '系统', time: '03:45-03:49', type: '噪音', content: '背景存在明显的电流噪声，建议静音处理。', tags: [{ text: '环境噪声', type: '静音' }] }
      ]
    },
    {
      id: 'g-pause',
      strategy: 'pause',
      label: '停顿分级识别',
      description: '把卡壳停顿和情绪沉默区分开来',
      entries: [
        { id: 'e3', speaker: '对话', time: '00:25', type: '异常停顿', content: '说话人 A 提问后出现 2.4s 卡壳停顿，前后带有“呃”“那个”等口语信号，建议删除。', tags: [{ text: '建议删除', type: '异常停顿' }] },
        { id: 'e4', speaker: '对话', time: '02:18', type: '正常停顿', content: '一句重点陈述后的 1.2s 沉默属于情绪留白，建议保留。', tags: [{ text: '建议保留', type: '正常停顿' }] }
      ]
    },
    {
      id: 'g-noise',
      strategy: 'noise',
      label: '噪音/呼吸音清理',
      description: '一键提升人声纯净度',
      entries: [
        { id: 'e4', speaker: '说话人 A', time: '00:12', type: '噪音', content: '检测到明显的深呼吸音，已准备好 AI 修复方案。', tags: [{ text: '呼吸音', type: '噪音' }] }
      ]
    }
  ]
  
  // 根据选择的策略过滤并显示对应的示例预览
  switch (cuttingStrategy.value) {
    case 'silence':
      samplePreview.value = groups.filter(g => g.strategy === 'silence')
      break
    case 'pause':
      samplePreview.value = groups.filter(g => g.strategy === 'pause')
      break
    case 'noise':
      samplePreview.value = groups.filter(g => g.strategy === 'noise')
      break
    default:
      samplePreview.value = [groups[0]]
      break
  }
}

const handleFileSelect = (event) => {
  const file = event.target.files[0]
  if (!file) return
  selectedAssetIds.value = []
  const objectUrl = URL.createObjectURL(file)
  assets.value.unshift({
    id: Date.now(),
    name: file.name,
    url: objectUrl,
    type: file.type.startsWith('video') ? 'video' : 'audio',
    duration: '00:00',
    format: file.name.split('.').pop().toUpperCase(),
    category: file.type.startsWith('video') ? '效果音' : '人声',
    used: false,
    playing: false,
    summary: '',
    tags: [],
    editingSummary: false
  })
  hasUploaded.value = false
  showPreprocessModal.value = true
}

const selectAsset = (asset) => {
  if (!asset) return
}

const showAssetMenu = (asset) => {
  console.log('Show menu for:', asset)
  // 可以在这里显示右键菜单
}

// 拖拽相关方法
const draggedAsset = ref(null)

const handleAssetDragStart = (event, asset) => {
  draggedAsset.value = asset
  event.dataTransfer.effectAllowed = 'copy'
  event.dataTransfer.setData('assetId', String(asset.id))
  event.dataTransfer.setData('text/plain', String(asset.id))
}

const handleTimelineDragOver = (event, track) => {
  event.preventDefault()
  event.dataTransfer.dropEffect = 'copy'
}

const handleTimelineDrop = (event, track) => {
  event.preventDefault()
  
  if (draggedAsset.value) {
    // 计算拖放位置对应的时间
    const rect = event.currentTarget.getBoundingClientRect()
    const x = event.clientX - rect.left
    const timelineWidth = rect.width
    const time = (x / timelineWidth) * audioDuration.value
    
    // 创建新的片段
    const newClip = {
      id: Date.now(),
      name: draggedAsset.value.name,
      start: Math.max(0, time),
      end: Math.max(0, time) + 10, // 假设10秒
      color: track.color.replace('bg-', 'bg-gradient-to-r from-') + '/80 to-' + track.color.replace('bg-', '') + '/80 border-' + track.color.replace('bg-', ''),
      fadeIn: false,
      fadeOut: false
    }
    
    // 添加到轨道
    track.clips.push(newClip)
    draggedAsset.value = null
  }
}

const normalizeSearchText = (text = '') => {
  return text
    .replace(/\[TTS\]/g, '')
    .replace(/~~[^~]+~~/g, '')
    .replace(/\+\+([^+]+)\+\+/g, '$1')
    .replace(/\s+/g, ' ')
    .trim()
}

const getQueryKeywords = (query) => {
  const normalized = query.toLowerCase().trim()
  if (!normalized) return []

  // 中英文都做简单分词，覆盖常见检索输入
  const chinesePhrases = normalized.match(/[\u4e00-\u9fa5]{2,}/g) || []
  const englishWords = normalized.match(/[a-z0-9]{2,}/g) || []
  const fallbackSingles = normalized.length <= 2 ? (normalized.match(/[\u4e00-\u9fa5]/g) || []) : []
  return Array.from(new Set([...chinesePhrases, ...englishWords, ...fallbackSingles])).slice(0, 8)
}

const getStableTextSeed = (text = '') => {
  return Array.from(text).reduce((acc, ch) => ((acc * 31) + ch.charCodeAt(0)) % 997, 0)
}

const buildGoldenMetrics = (content = '', meta = {}) => {
  const length = content.length
  const punctuationCount = (content.match(/[，。！？；：,.!?;:]/g) || []).length
  const quoteCount = (content.match(/[“”"'「」]/g) || []).length
  const emphasisHits = (content.match(/(必须|一定|真正|核心|关键|本质|不要|先|再|更|最|值得)/g) || []).length
  const seed = getStableTextSeed(content)
  const jitterA = (seed % 17) - 8
  const jitterB = ((seed * 7) % 19) - 9

  const valueHits = meta.valueHits ?? 0
  const transitionHits = meta.transitionHits ?? 0
  const fillerCount = meta.fillerCount ?? 0
  const hasEnding = !!meta.hasEnding

  const viralPotential = Math.max(48, Math.min(98,
    56
    + valueHits * 11
    + emphasisHits * 6
    + quoteCount * 3
    + (length >= 16 && length <= 42 ? 7 : -4)
    - fillerCount * 7
    + jitterA
  ))

  const logicScore = Math.max(45, Math.min(98,
    52
    + transitionHits * 13
    + punctuationCount * 2
    + (hasEnding ? 11 : -6)
    + (length >= 20 && length <= 75 ? 8 : -5)
    - fillerCount * 6
    + jitterB
  ))

  return { viralPotential, logicScore }
}

const buildTopicHeatmapFromResults = (results = [], query = '') => {
  const topicScoreMap = new Map()
  const normalizedQuery = (query || '').toLowerCase()

  // 过滤掉常见虚词/泛词，避免热度条出现“很多/时候/主要”等不符合常理的词
  const stopWords = new Set([
    '我们', '你们', '他们', '大家', '很多', '时候', '东西', '事情', '一个', '一些', '这种', '那种', '这样', '那样',
    '就是', '其实', '可能', '感觉', '问题', '主题', '核心', '主要', '围绕', '展开', '进行', '因为', '所以', '但是',
    '然后', '如果', '那么', '以及', '还有', '不是', '一定', '必须', '立刻', '重新', '变得', '一个话题', '同一话题'
  ])

  // 简单同义词归一，保证“AI剪辑/智能剪辑”等聚合成更合理的主题
  const normalizeTopic = (word) => {
    if (!word) return ''
    if (/^(ai剪辑|智能剪辑|剪辑ai|ai剪辑内容)$/i.test(word)) return '智能剪辑'
    if (word.includes('停顿')) return '停顿'
    if (word.includes('情绪')) return '情绪'
    if (word.includes('创作')) return '创作'
    if (word.includes('创作者')) return '创作者'
    if (word.includes('焦虑')) return '焦虑'
    if (word.includes('压力')) return '压力'
    if (word.includes('表达')) return '表达'
    return word
  }

  // query 关键词加一点先验权重，确保热度条和用户检索意图一致
  const queryWords = ((query || '').match(/[\u4e00-\u9fa5]{2,}|[a-z0-9]{2,}/gi) || [])
    .map(w => w.trim())
    .filter(Boolean)
    .slice(0, 6)
  queryWords.forEach((w) => {
    const topic = normalizeTopic(w)
    if (!topic || stopWords.has(topic) || topic.length < 2) return
    topicScoreMap.set(topic, (topicScoreMap.get(topic) || 0) + 22)
  })

  results.forEach(result => {
    const text = (result.preview || '').toString()
    const words = (text.match(/[\u4e00-\u9fa5]{2,}/g) || [])
      .map(w => w.trim())
      .filter(w => w.length >= 2 && w.length <= 8 && !stopWords.has(w))

    const localCountMap = new Map()
    words.forEach(w => {
      const topic = normalizeTopic(w)
      if (!topic || stopWords.has(topic) || topic.length < 2) return
      localCountMap.set(topic, (localCountMap.get(topic) || 0) + 1)
    })

    localCountMap.forEach((count, topic) => {
      // 词长适中更像“主题词”，给一点加权；出现次数*相关度决定热度
      const lenBonus = topic.length >= 3 && topic.length <= 6 ? 1.15 : 1
      const scoreAdd = Math.round((result.relevance || 0) * count * lenBonus)
      topicScoreMap.set(topic, (topicScoreMap.get(topic) || 0) + scoreAdd)
    })
  })

  // 兜底：对写死演示搜索，给出更符合常理的主题组合
  if (normalizedQuery.includes('焦虑') || normalizedQuery.includes('anxiety')) {
    const base = [
      ['焦虑', 96],
      ['压力', 82],
      ['行动', 74],
      ['表达', 66],
      ['期待', 58]
    ]
    return base.map(([name, intensity], idx) => ({ id: idx + 1, name, intensity }))
  }
  if (normalizedQuery.includes('直觉') || normalizedQuery.includes('intuition')) {
    const base = [
      ['直觉', 96],
      ['创作者', 84],
      ['算法', 76],
      ['取舍', 68],
      ['表达', 60]
    ]
    return base.map(([name, intensity], idx) => ({ id: idx + 1, name, intensity }))
  }
  if (normalizedQuery.includes('真情流露') || normalizedQuery.includes('情感共鸣')) {
    const base = [
      ['非言语情绪高光', 94],
      ['双人高能语义冲突', 88],
      ['内容社会价值实现', 79],
      ['自我怀疑与心态救赎', 69],
      ['副业心态自救', 55]
    ]
    return base.map(([name, intensity], idx) => ({ id: idx + 1, name, intensity }))
  }

  const sortedTopics = Array.from(topicScoreMap.entries())
    .filter(([word]) => word.length >= 2 && word.length <= 8 && !stopWords.has(word))
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5)

  if (sortedTopics.length === 0) return []

  const maxScore = sortedTopics[0][1] || 1
  return sortedTopics.map(([name, score], index) => ({
    id: index + 1,
    name,
    intensity: Math.max(35, Math.min(98, Math.round((score / maxScore) * 100)))
  }))
}

// 深度语义搜索
const performSemanticSearch = async () => {
  if (!semanticSearchQuery.value.trim() || isSearching.value) return
  
  isSearching.value = true
  try {
    // 轻量延时，保留“搜索中”反馈
    await new Promise(resolve => setTimeout(resolve, 220))

    const query = semanticSearchQuery.value.trim()
    const queryLower = query.toLowerCase()
    const keywords = getQueryKeywords(query)
    const MAX_SEARCH_RESULTS = 3

    const buildFixedResults = (items = [], baseTime = 15) => {
      const results = items.slice(0, 3).map((item, idx) => {
        const result = typeof item === 'string' ? { preview: item } : item
        const preview = result.preview || ''
        const startTime = result.startTime ?? (baseTime + idx * 38)
        const endTime = result.endTime ?? (startTime + 18)
        return {
          id: `fixed-${queryLower}-${idx}-${Date.now()}`,
          title: result.title || preview.slice(0, 18) + (preview.length > 18 ? '...' : ''),
          preview,
          recognitionFeature: result.recognitionFeature || '',
          startTime,
          endTime,
          rawScore: result.rawScore ?? (100 - idx * 6),
          relevance: result.relevance ?? Math.max(78, 96 - idx * 6)
        }
      })
      searchResults.value = results.map((item, idx) => ({
        ...item,
      }))
      topicHeatmap.value = buildTopicHeatmapFromResults(searchResults.value, query)
    }

    // Demo: 写死两组可演示的语义搜索结果
    if (queryLower.includes('真情流露') || queryLower.includes('情感共鸣')) {
      buildFixedResults([
        {
          title: '谈及创作者阵痛与初心的释怀动容',
          preview: '在这些智能技术出现之前，大家完全是在用大量的时间和心血和枯燥的机械劳动死磕。我见过太多满怀理想的年轻人，还没等到属于自己的听众，就被现实折磨得熄灭了……（伴随 4.2 秒极其低沉的声音能量下敛与一声微弱的叹息颤音）',
          recognitionFeature: '系统精准检测到发言人语速骤降 65%、短时能量（Energy）大幅下敛，并伴随长达 4.2 秒因情绪高度沉浸导致的非平稳低沉留白（叹息）。跨模态算法将其直接映射为高维隐空间中的“情感共振低谷”，实现零关键词下的隐式高光召回。',
          // 调整为更短的片段（约 30s），并保持在总时长 32:15 内
          startTime: 24 * 60 + 15,
          endTime: 24 * 60 + 45,
          relevance: 97,
          rawScore: 100
        },
        {
          title: 'AI 哲学激辩修罗场',
          preview: '（连珠炮打断）不，王老师！你把算法想得太善良了！它在批量杀死原创！ → （音量突增对攻）但你忽略了人类灵魂在绝境里的抗性！',
          recognitionFeature: '实时捕获多人对谈强打断抢话（Audio Overlap）以及振幅能量突增 14dB 的冲突特征。系统动态向前回溯 20 秒争论起因、向后包裹 15 秒观点收尾，输出因果极其完整的高能对攻故事链。',
          // 调整为更短的片段（约 30s）
          startTime: 14 * 60 + 20,
          endTime: 14 * 60 + 50,
          relevance: 91,
          rawScore: 94
        },
        {
          title: '听众深夜私信的价值自救',
          preview: '那天晚上十一点，我坐在马路牙子上，看着一个抑郁症听众发来的长私信。她说在无数个失眠的深夜，是我的声音陪她熬过来的。那一刻，我看着满街的霓虹灯，眼泪一下子就下来了……原来我说的那些废话，是真的在拯救生命。',
          recognitionFeature: '依托长序列高维语义泛化能力。虽然文本层面全是一般生活化叙事（霓虹灯、马路牙子），不含显式情绪词，但系统深刻读懂了文字背后的“内容社会价值实现与极度欣慰的灵魂共鸣”，精准打捞。',
          // 原始位置在 38 分钟，超出总时长，改为 28:05 - 28:40，时长约 35s
          startTime: 28 * 60 + 5,
          endTime: 28 * 60 + 40,
          relevance: 86,
          rawScore: 88
        }
      ], 15)
      return
    }

    if (queryLower.includes('焦虑') || queryLower.includes('anxiety')) {
      buildFixedResults([
        { preview: '很多时候你不是做不好，而是被“必须马上变好”的期待拖住了节奏。' },
        { preview: '焦虑感最强的那一刻，先把任务拆到下一步可执行的动作，情绪会立刻下降。' },
        { preview: '当你把注意力从“别人怎么看”拉回到“我在表达什么”，创作会重新变得轻松。' }
      ], 42)
      return
    }

    // 另一个更贴合本次访谈主题：直觉
    if (queryLower.includes('直觉') || queryLower.includes('intuition')) {
      buildFixedResults([
        { preview: '技术越强，越应该把“怎么做”交给工具，把“为什么这么说”留给创作者的直觉。' },
        { preview: '直觉不是玄学，它来自你对听众、节奏和情绪的长期判断与经验积累。' },
        { preview: '算法能帮你省时间，但最后的取舍仍要回到创作者想传达的核心感受。' }
      ], 68)
      return
    }

    const scored = mockTranscript.value
      .map((segment, index) => {
        const text = normalizeSearchText(segment.text)
        if (!text) return null

        const textLower = text.toLowerCase()
        let score = 0
        let matchedKeywordCount = 0
        const hasExactPhrase = queryLower.length >= 2 && textLower.includes(queryLower)
        const queryChars = Array.from(new Set(queryLower.replace(/\s+/g, '').split(''))).filter(ch => /[a-z0-9\u4e00-\u9fa5]/.test(ch))
        const charCoverage = queryChars.length > 0
          ? queryChars.filter(ch => textLower.includes(ch)).length / queryChars.length
          : 0

        // 完整词/短语命中权重更高
        keywords.forEach((keyword) => {
          if (!keyword) return
          const escaped = keyword.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
          const fullMatches = textLower.match(new RegExp(escaped, 'g')) || []
          if (fullMatches.length > 0) matchedKeywordCount += 1
          score += fullMatches.length * (keyword.length >= 2 ? 14 : 6)
        })

        if (hasExactPhrase) score += 24
        score += Math.round(charCoverage * 18)

        // 长句略微加权，避免太短句子全排前面
        score += Math.min(12, Math.floor(text.length / 25))
        // 至少具备明确命中，避免“语义太散”的结果混入
        if (!hasExactPhrase && matchedKeywordCount === 0) return null
        if (!hasExactPhrase && matchedKeywordCount < Math.max(1, Math.ceil(keywords.length * 0.34))) return null
        if (!hasExactPhrase && charCoverage < 0.5) return null

        return score >= 20
          ? {
              id: `search-${index}-${segment.startTime}`,
              title: text.slice(0, 18) + (text.length > 18 ? '...' : ''),
              preview: text.slice(0, 72) + (text.length > 72 ? '...' : ''),
              startTime: segment.startTime,
              endTime: segment.endTime,
              rawScore: score
            }
          : null
      })
      .filter(Boolean)
      .sort((a, b) => b.rawScore - a.rawScore)

    const topResults = scored.slice(0, MAX_SEARCH_RESULTS)
    const maxScore = topResults[0]?.rawScore || 1

    searchResults.value = topResults.map((item) => ({
      ...item,
      relevance: Math.max(58, Math.min(99, Math.round((item.rawScore / maxScore) * 100)))
    })).filter(item => item.relevance >= 65)

    topicHeatmap.value = buildTopicHeatmapFromResults(searchResults.value, query)
  } finally {
    isSearching.value = false
  }
}

// 提取金句
const extractGoldenSentences = async () => {
  if (isExtracting.value) return
  
  isExtracting.value = true
  await new Promise(resolve => setTimeout(resolve, 1500))
  
  // 金句标准（简化版）：
  // 1) 信息完整（有标点收束） 2) 信息密度较高 3) 可传播（含观点/价值词）
  // 4) 口癖少 5) 长度适中（过短无信息，过长不利传播）
  const valueKeywords = ['本质', '关键', '核心', '价值', '方法', '未来', '意义', '趋势', '原则', '策略', '结论', '应该', '希望']
  const transitionKeywords = ['因为', '所以', '但是', '不过', '如果', '那么', '其实', '因此', '首先', '其次', '最后']
  const cleanText = (text = '') => text.replace(/\[TTS\]/g, '').replace(/~~[^~]+~~/g, '').replace(/\+\+([^+]+)\+\+/g, '$1').replace(/\s+/g, ' ').trim()

  const candidates = mockTranscript.value.map((segment, index) => {
    const text = cleanText(segment.text)
    const tokens = parseSegmentText(segment.text)
    const fillerCount = tokens.filter(t => t.type === 'filler' || t.type === 'stutter').length
    const hasEnding = /[。！？!?]$/.test(text)
    const len = text.length
    const valueHits = valueKeywords.filter(k => text.includes(k)).length
    const transitionHits = transitionKeywords.filter(k => text.includes(k)).length

    let score = 0
    // 长度区间打分：22~70最佳
    if (len >= 22 && len <= 70) score += 35
    else if (len >= 16 && len <= 90) score += 20
    else score += 5
    // 观点/价值词
    score += Math.min(25, valueHits * 8)
    // 逻辑连接词
    score += Math.min(15, transitionHits * 5)
    // 完整句加分
    if (hasEnding) score += 10
    // 口癖惩罚
    score -= fillerCount * 8

    return {
      id: `golden-${index}-${Date.now()}`,
      content: text,
      startTime: segment.startTime,
      endTime: segment.endTime,
      segmentIndex: index,
      score,
      fillerCount,
      valueHits,
      transitionHits,
      hasEnding
    }
  })
  .filter(item => item.content.length >= 14)
  .sort((a, b) => b.score - a.score)

  // 自动提取 3-5 句：默认取前 5，若候选不足则至少回退到 3
  let picked = candidates.slice(0, 5)
  if (picked.length < 3) {
    picked = candidates.slice(0, Math.min(3, candidates.length))
  }

  // 若仍不足（极端情况），从原文中按长度兜底补齐到 3
  if (picked.length < 3) {
    const exists = new Set(picked.map(p => p.segmentIndex))
    const fallback = mockTranscript.value
      .map((segment, index) => ({
        id: `golden-fallback-${index}-${Date.now()}`,
        content: cleanText(segment.text),
        startTime: segment.startTime,
        endTime: segment.endTime,
        segmentIndex: index
      }))
      .filter(item => !exists.has(item.segmentIndex) && item.content.length >= 12)
      .slice(0, 3 - picked.length)
      .map(item => ({ ...item, score: 50, fillerCount: 1, valueHits: 1, transitionHits: 1, hasEnding: /[。！？!?]$/.test(item.content) }))
    picked = [...picked, ...fallback]
  }

  // 增量合并：自动提取不会覆盖/取消原本手动标记的金句
  // - 已存在的金句保留
  // - 新提取到的金句追加（去重）
  const existingBySegmentIndex = new Map(
    goldenSentences.value
      .filter(s => s && s.segmentIndex !== undefined && s.segmentIndex !== null)
      .map(s => [s.segmentIndex, s])
  )

  picked.forEach(item => {
    const { viralPotential, logicScore } = buildGoldenMetrics(item.content, {
      valueHits: item.valueHits,
      transitionHits: item.transitionHits,
      fillerCount: item.fillerCount,
      hasEnding: item.hasEnding
    })

    const seg = mockTranscript.value[item.segmentIndex]
    if (seg) seg.isGolden = true

    if (existingBySegmentIndex.has(item.segmentIndex)) {
      // 不覆盖手动编辑内容；仅在缺失时补充指标字段
      const existing = existingBySegmentIndex.get(item.segmentIndex)
      if (existing.viralPotential == null) existing.viralPotential = viralPotential
      if (existing.logicScore == null) existing.logicScore = logicScore
      return
    }

    goldenSentences.value.unshift({
      id: item.id,
      content: item.content,
      startTime: item.startTime,
      endTime: item.endTime,
      segmentIndex: item.segmentIndex,
      viralPotential,
      logicScore,
      editing: false
    })
  })

  isExtracting.value = false
}

// 切换手动标记状态
const toggleManualMark = (sentence) => {
  sentence.manuallyMarked = !sentence.manuallyMarked
  
  // 显示提示
  audioOptimizeMessage.value = sentence.manuallyMarked ? '已标记为手动金句' : '已取消手动标记'
  setTimeout(() => {
    audioOptimizeMessage.value = ''
  }, 2000)
}

const deleteGoldenSentence = (id) => {
  const sentenceToDelete = goldenSentences.value.find(s => s.id === id)
  if (sentenceToDelete && sentenceToDelete.segmentIndex !== undefined) {
    // 取消左侧文字稿的金句标记
    const segment = mockTranscript.value[sentenceToDelete.segmentIndex]
    if (segment) {
      segment.isGolden = false
    }
  }
  goldenSentences.value = goldenSentences.value.filter(s => s.id !== id)
}

const addGoldenSentenceManual = (startAt = currentTime.value) => {
  const endAt = startAt + 8
  const newSentence = {
    id: 'manual-' + Date.now(),
    content: '这里是我手动标记的精彩片段',
    startTime: startAt,
    endTime: endAt,
    segmentIndex: -1,
    ...buildGoldenMetrics('这里是我手动标记的精彩片段', { hasEnding: true }),
    editing: false,
    highlight: true
  }
  goldenSentences.value.unshift(newSentence)
  
  // 高亮效果
  setTimeout(() => {
    newSentence.highlight = false
  }, 2000)
}

// 标记当前选中文本为金句
const markSelectedTextAsGolden = () => {
  if (selectionStart === null || selectionEnd === null) return
  
  // 查找包含当前选中区域的片段
  const segment = mockTranscript.value.find((seg, index) => {
    return seg.startTime <= selectionStart && seg.endTime >= selectionEnd
  })
  
  if (segment) {
    const newSentence = {
      id: 'selected-' + Date.now(),
      content: getCleanSegmentText(segment.text),
      startTime: selectionStart,
      endTime: selectionEnd,
      segmentIndex: mockTranscript.value.indexOf(segment),
      ...buildGoldenMetrics(getCleanSegmentText(segment.text), { hasEnding: /[。！？!?]$/.test(getCleanSegmentText(segment.text)) }),
      editing: false,
      highlight: true
    }
    goldenSentences.value.unshift(newSentence)
    
    // 高亮效果
    setTimeout(() => {
      newSentence.highlight = false
    }, 2000)
  }
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
  currentAudioTime.value = timeInSeconds
  audioProgress.value = (timeInSeconds / totalAudioDuration.value) * 100
  ensureVisibleCurrentTime()
}

// 作品仓库选择
const selectWork = (work) => {
  selectedWork.value = work
  // 更新当前音频信息
  totalAudioDuration.value = parseMediaDuration(work.duration)
  currentAudioTime.value = 0
  audioProgress.value = 0
}

watch(() => currentProjectExport.value.duration, (newDuration) => {
  if (!selectedWork.value) {
    totalAudioDuration.value = parseMediaDuration(newDuration)
  }
})

// 音频播放控制
const toggleAudioPlay = () => {
  isAudioPlaying.value = !isAudioPlaying.value
  if (isAudioPlaying.value) {
    startAudioPlayback()
  } else {
    stopAudioPlayback()
  }
}

const startAudioPlayback = () => {
  if (audioPlayInterval) clearInterval(audioPlayInterval)
  audioPlayInterval = setInterval(() => {
    if (currentAudioTime.value < totalAudioDuration.value) {
      currentAudioTime.value += 1
      audioProgress.value = (currentAudioTime.value / totalAudioDuration.value) * 100
    } else {
      isAudioPlaying.value = false
      clearInterval(audioPlayInterval)
    }
  }, 1000)
}

const stopAudioPlayback = () => {
  if (audioPlayInterval) {
    clearInterval(audioPlayInterval)
    audioPlayInterval = null
  }
}

const seekAudioProgress = (event) => {
  const rect = event.currentTarget.getBoundingClientRect()
  const x = event.clientX - rect.left
  const percentage = Math.max(0, Math.min(1, x / rect.width))
  currentAudioTime.value = Math.floor(totalAudioDuration.value * percentage)
  audioProgress.value = percentage * 100
}

// 模拟发布预览
const generateShareLink = () => {
  showShareLinkModal.value = true
}

const createShareLink = async () => {
  isGeneratingLink.value = true
  await new Promise(resolve => setTimeout(resolve, 1500))
  const linkId = 'share-' + Date.now().toString(36)
  generatedShareLink.value = `https://podpal.ai/preview/${linkId}`
  isGeneratingLink.value = false
}

const copyShareLink = () => {
  navigator.clipboard.writeText(generatedShareLink.value)
    .then(() => {
      alert('链接已复制到剪贴板')
    })
    .catch(() => {
      console.log('复制失败')
    })
}

// 判断当前播放时间是否在某个文字片段内
const isCurrentSegment = (segment) => {
  return false
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
  // 自动生成 AI 总结
  await generateAISummaries()
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
      // 导出预览音频事件绑定
      nextTick(() => {
        const el = exportAudioRef.value
        if (el) {
          el.addEventListener('play', onExportAudioPlay)
          el.addEventListener('pause', onExportAudioPause)
          el.addEventListener('timeupdate', onExportAudioTimeUpdate)
        }
      })
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
  
  // 监听视频时间更新，同步进度条
  if (exportPreviewVideo.value) {
    exportPreviewVideo.value.addEventListener('timeupdate', updateProgressBar)
    exportPreviewVideo.value.addEventListener('play', onExportVideoPlay)
    exportPreviewVideo.value.addEventListener('pause', onExportVideoPause)
  }

  // 顶部自动保存状态：每 5 秒刷新一次并显示刷新时间
  refreshAutoSaveStatus()
  autoSaveInterval = setInterval(() => {
    refreshAutoSaveStatus()
  }, 5000)

  // 导出页的 AI 发布时间分析：默认自动生成一次
  if (!propagationForecast.value && !isGeneratingForecast.value) {
    generatePropagationForecast()
  }

  mockTranscript.value.forEach((segment) => ensureSegmentOriginalText(segment))
  syncSegmentTextLengthSnapshot()
  await nextTick()
  syncStepNavProgress()
  window.addEventListener('resize', syncStepNavProgress)
})

const updateVideoProgress = () => {
  if (!exportPreviewVideo.value || !progressBar.value) return
  const progress = progressBar.value.value
  const duration = exportPreviewVideo.value.duration
  if (duration) {
    exportPreviewVideo.value.currentTime = (progress / 100) * duration
  }
}

const updateProgressBar = () => {
  if (!exportPreviewVideo.value || !progressBar.value) return
  const currentTime = exportPreviewVideo.value.currentTime
  const duration = exportPreviewVideo.value.duration
  if (duration > 0) {
    progressBar.value.value = (currentTime / duration) * 100
  }
}

onUnmounted(() => {
  window.removeEventListener('resize', syncStepNavProgress)
  // 移除事件监听器
  if (exportPreviewVideo.value) {
    exportPreviewVideo.value.removeEventListener('timeupdate', updateProgressBar)
    exportPreviewVideo.value.removeEventListener('play', onExportVideoPlay)
    exportPreviewVideo.value.removeEventListener('pause', onExportVideoPause)
  }
  // 清理音频播放定时器
  if (audioPlayInterval) {
    clearInterval(audioPlayInterval)
    audioPlayInterval = null
  }
  if (autoSaveInterval) {
    clearInterval(autoSaveInterval)
    autoSaveInterval = null
  }
  if (transcriptRepairTimer) {
    clearTimeout(transcriptRepairTimer)
    transcriptRepairTimer = null
  }
  if (scriptOptimizationHighlightTimer) {
    clearTimeout(scriptOptimizationHighlightTimer)
    scriptOptimizationHighlightTimer = null
  }
  // 清理导出预览音频事件
  if (exportAudioRef.value) {
    const el = exportAudioRef.value
    el.removeEventListener('play', onExportAudioPlay)
    el.removeEventListener('pause', onExportAudioPause)
    el.removeEventListener('timeupdate', onExportAudioTimeUpdate)
    try { el.pause(); el.currentTime = 0 } catch (e) {}
  }
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

/* 文稿区滚动条：上粉下白，且白色占比更长 */
.transcript-scroll::-webkit-scrollbar {
  width: 10px;
}
.transcript-scroll::-webkit-scrollbar-track {
  background: #ffffff;
  border-left: 1px solid #ffffff;
}
.transcript-scroll::-webkit-scrollbar-thumb {
  min-height: 140px;
  background: linear-gradient(to bottom, #ff6b9d 0 22%, #ffffff 22% 100%);
  border-radius: 999px;
  border: 1px solid #ffffff;
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
@keyframes highlightNew {
  0% { background-color: rgba(236, 72, 153, 0.2); transform: scale(1.02); }
  100% { background-color: transparent; transform: scale(1); }
}
.animate-highlightNew {
  animation: highlightNew 2s ease-out;
}

.step-orbit-ring {
  padding: 2px;
  background: conic-gradient(
    from 0deg,
    rgba(255, 107, 157, 0) 0deg,
    rgba(255, 107, 157, 0.18) 220deg,
    rgba(255, 107, 157, 0.98) 300deg,
    rgba(192, 132, 252, 0.98) 335deg,
    rgba(255, 107, 157, 0) 360deg
  );
  mask:
    linear-gradient(#fff 0 0) content-box,
    linear-gradient(#fff 0 0);
  -webkit-mask:
    linear-gradient(#fff 0 0) content-box,
    linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  box-shadow: 0 0 16px rgba(255, 107, 157, 0.25);
}

.right-toolbox-scale :deep([class*='text-xs']) {
  font-size: 0.875rem !important;
}

.right-toolbox-scale :deep([class*='text-[10px]']) {
  font-size: 0.8125rem !important;
}

.right-toolbox-scale :deep([class*='text-[11px]']) {
  font-size: 0.875rem !important;
}

.right-toolbox-scale :deep([class*='text-[9px]']) {
  font-size: 0.75rem !important;
}
</style>
