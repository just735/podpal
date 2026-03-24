<template>
  <div class="h-screen bg-white flex flex-col overflow-auto">
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

    <div class="flex-1 flex overflow-auto">
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

      <!-- 2. 左侧：根据当前标签页显示不同内容 -->
      <aside class="w-80 flex-none border-r border-pink-200 flex flex-col overflow-hidden">
        <!-- 素材库 (上传素材和智能剪辑标签页显示) -->
        <div v-show="activeToolTab === 'upload' || activeToolTab === 'edit'" class="h-full bg-gradient-to-b from-pink-50 to-purple-50 flex flex-col overflow-hidden">
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
        <div v-show="activeToolTab === 'enhance' || activeToolTab === 'export'" class="h-full bg-white flex flex-col overflow-hidden">
          <div class="p-4 border-b border-pink-200 bg-gradient-to-r from-pink-50 to-purple-50">
            <h2 class="text-sm font-semibold text-gray-700 uppercase tracking-wider flex items-center gap-2">
              <svg class="w-4 h-4 text-pink-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
              </svg>
              作品仓库
            </h2>
            <p class="text-xs text-gray-500 mt-1">剪辑工作台导出的成品音频</p>
          </div>
          
          <!-- 作品列表 -->
          <div class="flex-1 overflow-y-auto p-4 space-y-3">
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
                  <div class="text-xs text-gray-500 mt-0.5">{{ currentProjectExport.duration }}</div>
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
      <main class="flex-1 min-w-0 flex flex-col bg-white overflow-auto relative">
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
              
              <!-- 文本引擎 / 智能转写（前置配置） -->
              <section v-if="hasUploaded" class="bg-white rounded-xl border border-pink-200 shadow-sm overflow-hidden p-6">
                <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                  <span class="w-1 h-4 bg-purple-500 rounded-full"></span>
                  文本引擎 / 智能转写
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

              <!-- 声效修复 / 音质重塑（前置配置） -->
              <section v-if="hasUploaded" class="bg-white rounded-xl border border-pink-200 shadow-sm overflow-hidden p-6">
                <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                  <span class="w-1 h-4 bg-green-500 rounded-full"></span>
                  声效修复 / 音质重塑
                </h3>
                <div class="space-y-4">
                  <div class="space-y-1">
                    <div class="flex justify-between text-xs text-gray-600"><span>智能降噪</span><span>80%</span></div>
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
           
           <!-- 预处理小弹窗 -->
           <div v-if="showPreprocessModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
             <div class="bg-white rounded-xl shadow-2xl w-[560px] p-6 border border-pink-200">
               <div class="flex items-center justify-between mb-3">
                 <h3 class="text-lg font-bold text-gray-900">上传完成 · 前置预处理</h3>
                 <button class="text-gray-400 hover:text-gray-600" @click="showPreprocessModal = false">
                   <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
                 </button>
               </div>
               <div class="space-y-3">
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
                 <button class="px-3 py-1.5 text-sm rounded border border-gray-200 hover:bg-gray-50 text-gray-700" @click="showPreprocessModal=false">跳过</button>
                 <button class="px-4 py-1.5 text-sm rounded bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white hover:shadow-lg" @click="startPreprocess">开始处理</button>
               </div>
             </div>
           </div>
        </div>
        <!-- Editor View -->
        <div v-show="activeToolTab === 'edit'" class="flex-none flex flex-col overflow-visible relative" :style="{ height: 'auto' }" ref="editorColumn">
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
            <!-- AI 总结按钮 -->
            <button
              v-if="!showWaveform"
              @click="generateAISummaries"
              :disabled="isGeneratingAiSummary || mockTranscript.length === 0"
              class="px-3 py-1.5 text-sm rounded-lg transition flex items-center gap-2"
              :class="isGeneratingAiSummary ? 'bg-gray-200 text-gray-500 cursor-not-allowed' : 'bg-blue-500 text-white hover:bg-blue-600'"
            >
              <svg v-if="isGeneratingAiSummary" class="animate-spin h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              <svg v-else class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
              </svg>
              {{ isGeneratingAiSummary ? '生成中...' : '生成AI总结' }}
            </button>
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
                  class="group relative"
                >
                <!-- AI 总结卡片 -->
                <div v-if="isSummaryStart(index)" class="p-3 rounded-lg bg-gradient-to-r from-blue-50 to-cyan-50 border border-blue-200 shadow-sm mb-3">
                  <div class="flex items-start gap-3">
                    <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-500 to-cyan-400 flex items-center justify-center flex-shrink-0">
                      <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
                      </svg>
                    </div>
                    <div class="flex-1">
                      <div class="flex items-center gap-2 mb-1">
                        <span class="text-xs font-bold text-blue-700 bg-blue-100 px-2 py-0.5 rounded-full">AI 总结</span>
                        <span class="text-xs text-gray-500">第 {{ getAISummaryForSegment(index).sectionNumber }} 部分</span>
                        <span class="text-xs text-gray-400 font-mono">{{ formatTime(getAISummaryForSegment(index).timestamp) }}</span>
                      </div>
                      <p class="text-sm text-gray-700 leading-relaxed">
                        {{ getAISummaryForSegment(index).summary }}
                      </p>
                    </div>
                  </div>
                </div>
                
                <div 
                  class="p-3 rounded-lg cursor-pointer transition-all duration-200"
                  :class="[
                    isCurrentSegment(segment) ? 'bg-gradient-to-r from-pink-100 to-purple-100 border-l-4 border-pink-500' : getSpeakerBgColor(segment.speaker),
                    isSegmentHighlighted(index) ? 'ring-2 ring-pink-400 ring-inset' : '',
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
                    <!-- 修正后的 Token -->
                    <span 
                      v-else-if="token.type === 'corrected'"
                      @click.stop="toggleTokenDelete(segment, tIndex)"
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
        <div class="flex-none bg-white flex flex-col border-t border-pink-200 overflow-visible pb-16">
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
          <div class="flex-1 flex flex-col overflow-visible border-t border-pink-200" :style="{ minHeight: fixedTimelineHeightPx + 'px' }">
            <!-- 轨道区域（可滚动，与标尺垂直对齐） -->
            <div class="flex-1 overflow-visible relative flex flex-col pb-4">
              <!-- 时间轴标尺（固定在顶部） -->
              <div 
                class="h-20 border-b-2 border-pink-300 bg-gradient-to-b from-pink-50 to-white flex-shrink-0 relative overflow-x-auto overflow-y-hidden"
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
              
              <!-- 轨道内容区域（可滚动） -->
              <div class="flex-1 overflow-auto relative" ref="timelineContainer" @scroll="onTimelineScroll">
                <div class="flex flex-row" :style="{ height: timelineContentHeightPx + 'px' }">
                  <!-- 固定左侧轨道控制栏 -->
                  <div class="sticky left-0 z-10 bg-white border-r-2 border-pink-300 flex-shrink-0" style="width: 240px;">
                    <!-- 轨道列表 -->
                    <div class="space-y-0">
                      <div 
                        v-for="(track, index) in sortedTracks" 
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
                  <div class="flex-1 relative z-0" :style="{ width: `calc(100% - 240px)` }">
                    <div class="relative" :style="{ width: timelineWidth + 'px' }">
                      <!-- 轨道内容列表 -->
                      <div class="space-y-0">
                        <div 
                          v-for="(track, index) in sortedTracks" 
                          :key="'content-' + track.id"
                          class="h-[104px] box-border border-b border-pink-200 bg-white relative"
                          :class="{ 'bg-pink-50/30': selectedTrackId === track.id }"
                          @dragover="handleTimelineDragOver($event, track)"
                          @drop="handleTimelineDrop($event, track)"
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
                                <div class="text-[9px] text-white/80 font-mono mt-1">
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
        </div>

        <!-- Content Enhancement View -->
        <div v-if="activeToolTab === 'enhance'" class="flex-1 bg-gray-50 flex flex-col">
          <!-- 右侧：内容增值工作台 -->
          <div class="flex-1 p-3">
            <div class="max-w-6xl mx-auto space-y-3">
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
                   class="flex-1 px-3 py-1.5 text-xs rounded border transition"
                   :class="openEnhancePanel==='shownotes' ? 'bg-white border-pink-300 text-pink-600 shadow-sm' : 'border-transparent text-gray-600 hover:bg-pink-50'"
                   @click="openEnhancePanel='shownotes'"
                 >
                   智能 Shownotes
                 </button>
                 <button 
                   class="flex-1 px-3 py-1.5 text-xs rounded border transition"
                   :class="openEnhancePanel==='video' ? 'bg-white border-pink-300 text-pink-600 shadow-sm' : 'border-transparent text-gray-600 hover:bg-pink-50'"
                   @click="openEnhancePanel='video'"
                 >
                   视频播客生成
                 </button>
                 <button 
                   class="flex-1 px-3 py-1.5 text-xs rounded border transition"
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
                      <h3 class="text-sm font-bold text-gray-900">智能 Shownotes</h3>
                      <p class="text-xs text-gray-500">一键生成标题、摘要、时间戳和思维导图</p>
                    </div>
                  </div>
                  
                  <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                     <!-- 生成选项 -->
                     <div class="space-y-2">
                        <div>
                          <label class="block text-sm font-medium text-gray-700 mb-1">播客类型</label>
                          <select v-model="podcastType" class="w-full rounded-lg border-gray-300 border p-2 text-sm focus:ring-2 focus:ring-pink-300 focus:border-pink-300">
                            <option value="knowledge">知识分享类 (干货提取)</option>
                            <option value="companion">情感陪伴类 (氛围描述)</option>
                            <option value="interview">访谈对话类 (观点碰撞)</option>
                            <option value="story">故事叙述类 (情节梳理)</option>
                          </select>
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
                          class="w-full py-2 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-lg hover:shadow-lg transition font-medium disabled:opacity-50 flex items-center justify-center gap-2 text-sm"
                        >
                           <svg v-if="isGeneratingShownotes" class="animate-spin h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                             <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                             <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                           </svg>
                           {{ isGeneratingShownotes ? 'AI 正在生成...' : '立即生成 Shownotes' }}
                        </button>
                     </div>

                     <!-- 结果预览 -->
                     <div class="bg-gray-50 rounded-lg border border-gray-200 p-2 min-h-[350px]">
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
                                   <span>{{ formatTime(totalAudioDuration) }}</span>
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
                         <h3 class="text-sm font-bold text-gray-900">视频播客生成</h3>
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
                         <div class="text-xs text-gray-500 mb-1.5">选择金句片段</div>
                         <div class="flex flex-wrap gap-1.5">
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
                      <div v-if="generatedVideos.length" class="space-y-1.5 pt-2 border-t border-gray-100">
                        <div class="text-xs font-medium text-gray-900">已生成视频</div>
                        <div v-for="(video, idx) in generatedVideos" :key="video.id" class="flex gap-2 p-2 bg-gray-50 rounded border border-gray-200 hover:border-pink-200 transition group">
                           <div class="w-16 h-12 bg-gray-300 rounded overflow-hidden flex-shrink-0 relative cursor-pointer" @click="previewVideo(video)">
                             <img :src="video.thumbnail" class="w-full h-full object-cover">
                             <div class="absolute bottom-0.5 right-0.5 px-1 py-0.5 bg-black/50 text-[8px] text-white rounded">{{ video.duration }}</div>
                             <div class="absolute inset-0 bg-black/30 hidden group-hover:flex items-center justify-center transition">
                                <svg class="w-5 h-5 text-white opacity-80 hover:opacity-100" fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
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
                <section v-show="openEnhancePanel==='social'" class="bg-white rounded-xl border border-pink-200 shadow-sm p-2">
                   <div class="flex items-center gap-2 mb-1.5">
                      <div class="w-6 h-6 rounded-full bg-green-100 flex items-center justify-center text-green-600">
                         <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" /></svg>
                      </div>
                      <div>
                         <h3 class="text-sm font-bold text-gray-900">多平台文案</h3>
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
                          v-model="socialCopyContent"
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
                           {{ socialCopyContent ? '重新生成' : '立即生成' }}
                         </button>
                         <button 
                           @click="copySocialCopy"
                           :disabled="!socialCopyContent"
                           class="px-3 py-1.5 text-xs bg-green-500 text-white rounded hover:bg-green-600 disabled:opacity-50 disabled:bg-gray-300"
                         >
                           复制文案
                         </button>
                         <button 
                           @click="showPublishPreview = true"
                           :disabled="!socialCopyContent"
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
                           <button 
                              @click="toggleVideoPlay"
                              class="w-16 h-16 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center cursor-pointer hover:scale-110 transition"
                           >
                              <svg v-if="!isVideoPlaying" class="w-8 h-8 text-white ml-1" fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
                              <svg v-else class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24"><path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/></svg>
                           </button>
                        </div>
                        <!-- 音频播放进度条 -->
                        <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 to-transparent p-4">
                           <div class="flex items-center gap-3 mb-2">
                              <button @click="toggleVideoPlay" class="text-white hover:text-pink-400 transition">
                                 <svg v-if="!isVideoPlaying" class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
                                 <svg v-else class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/></svg>
                              </button>
                              <span class="text-white text-xs font-mono">{{ formatVideoTime(videoCurrentTime) }}</span>
                              <div 
                                 class="flex-1 h-1.5 bg-white/30 rounded-full overflow-hidden cursor-pointer"
                                 @click="seekVideoProgress"
                              >
                                 <div 
                                    class="h-full bg-gradient-to-r from-pink-500 to-purple-500 rounded-full transition-all duration-100"
                                    :style="{ width: videoProgressPercent + '%' }"
                                 ></div>
                              </div>
                              <span class="text-white text-xs font-mono">{{ currentVideo?.duration || '00:00' }}</span>
                           </div>
                           <!-- 波形可视化 -->
                           <div class="flex items-center gap-0.5 h-6 opacity-60">
                              <div 
                                 v-for="(bar, idx) in videoWaveformBars" 
                                 :key="idx"
                                 class="w-1 bg-gradient-to-t from-pink-400 to-purple-400 rounded-full transition-all duration-75"
                                 :style="{ 
                                    height: isVideoPlaying ? (bar * 100) + '%' : (bar * 40) + '%',
                                    opacity: idx / videoWaveformBars.length < videoProgressPercent / 100 ? 1 : 0.3
                                 }"
                              ></div>
                           </div>
                        </div>
                     </div>
                     <div class="p-4 border-t border-gray-100 flex justify-end gap-2 bg-gray-50">
                        <button class="px-4 py-2 text-sm text-gray-600 hover:bg-gray-200 rounded-lg">下载视频</button>
                        <button class="px-4 py-2 text-sm bg-pink-500 text-white rounded-lg hover:bg-pink-600 shadow-sm">分享</button>
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
                           <div class="w-full h-48 bg-gradient-to-br from-pink-400 via-purple-500 to-indigo-600 relative">
                              <div class="absolute bottom-4 left-4 right-4">
                                 <h4 class="text-white text-lg font-bold drop-shadow-md">{{ shownotesData?.titles?.[0] || 'AI 时代的播客创作：从灵感到分发的全流程解析' }}</h4>
                              </div>
                           </div>
                           
                           <div class="p-4">
                              <!-- 节目信息 -->
                              <div class="flex items-center gap-3 mb-3">
                                 <div class="w-10 h-10 rounded-full bg-gradient-to-br from-[#FF6B9D] to-[#C084FC]"></div>
                                 <div class="flex-1">
                                    <p class="text-sm font-medium text-gray-900">PodPal Studio</p>
                                    <div class="flex items-center gap-2 text-xs text-gray-500">
                                       <span>{{ formatTime(totalAudioDuration) }}</span>
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
                                 <p class="text-sm text-gray-700 leading-relaxed mb-3">
                                    {{ socialCopyContent || shownotesData?.summary || '本期节目我们深入探讨了人工智能在播客创作领域的应用。从早期的语音转写到如今的智能剪辑、内容生成，AI 正在重塑音频内容的生产流程。我们邀请了资深播客制作人，分享他们使用 PodPal 提升效率的实战经验，并展望了未来播客行业的发展趋势。' }}
                                 </p>
                                 
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
                                    <div class="flex items-start gap-2">
                                       <span class="text-xs text-gray-500 min-w-[60px]">00:00</span>
                                       <span class="text-xs text-gray-700">开场：AI 播客创作时代的到来</span>
                                    </div>
                                    <div class="flex items-start gap-2">
                                       <span class="text-xs text-gray-500 min-w-[60px]">03:15</span>
                                       <span class="text-xs text-gray-700">前期策划：如何用 AI 找灵感</span>
                                    </div>
                                    <div class="flex items-start gap-2">
                                       <span class="text-xs text-gray-500 min-w-[60px]">12:30</span>
                                       <span class="text-xs text-gray-700">中期制作：智能录音与剪辑</span>
                                    </div>
                                    <div class="flex items-start gap-2">
                                       <span class="text-xs text-gray-500 min-w-[60px]">25:45</span>
                                       <span class="text-xs text-gray-700">后期分发：Shownotes 与视频化</span>
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
                              <div class="w-full h-48 bg-gradient-to-br from-pink-400 via-purple-500 to-indigo-600 rounded-lg mb-4 relative">
                                 <div class="absolute inset-0 flex items-center justify-center">
                                    <div class="text-center text-white">
                                       <div class="w-16 h-16 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center mx-auto mb-2">
                                          <svg class="w-8 h-8" fill="currentColor" viewBox="0 0 24 24">
                                             <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
                                          </svg>
                                       </div>
                                       <p class="text-sm font-medium">点击播放</p>
                                    </div>
                                 </div>
                              </div>
                              
                              <!-- 内容 -->
                              <div class="prose prose-sm text-gray-700 mb-4">
                                 <p class="mb-3">
                                    {{ socialCopyContent || shownotesData?.summary || '本期节目我们深入探讨了人工智能在播客创作领域的应用。从早期的语音转写到如今的智能剪辑、内容生成，AI 正在重塑音频内容的生产流程。' }}
                                 </p>
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
                                       <p class="text-xs text-gray-500">时长：{{ formatTime(totalAudioDuration) }}</p>
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
                           <div class="aspect-square bg-gradient-to-br from-pink-400 via-purple-500 to-indigo-600 relative">
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
                                 <p class="text-sm text-gray-800 leading-relaxed mb-3">
                                    {{ socialCopyContent || shownotesData?.summary || '姐妹们！发现了一个超级好用的播客制作神器 PodPal！以前剪辑要花好几个小时，现在 AI 一键搞定！真的太香了！' }}
                                 </p>
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
                                 <p class="text-sm text-gray-800 leading-relaxed mb-3">
                                    🎧 新一期播客上线！
                                    <br/><br/>
                                    {{ socialCopyContent || shownotesData?.summary?.substring(0, 100) || 'AI 时代的播客创作：从灵感到分发的全流程解析。本期节目深入探讨了人工智能在播客创作领域的应用，从语音转写到智能剪辑，AI 正在重塑音频内容的生产流程。' }}
                                    <br/><br/>
                                    点击链接收听完整内容 👇
                                 </p>
                                 
                                 <!-- 卡片 -->
                                 <div class="mt-3 rounded-lg overflow-hidden border border-gray-200">
                                    <div class="h-32 bg-gradient-to-br from-pink-400 via-purple-500 to-indigo-600 relative">
                                       <div class="absolute inset-0 flex items-center justify-center">
                                          <div class="w-12 h-12 rounded-full bg-white/30 backdrop-blur-sm flex items-center justify-center">
                                             <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                             </svg>
                                          </div>
                                       </div>
                                    </div>
                                    <div class="p-3 bg-gray-50">
                                       <div class="text-sm font-medium text-gray-900 mb-1">{{ shownotesData?.titles?.[0] || 'AI 时代的播客创作：从灵感到分发的全流程解析' }}</div>
                                       <div class="text-xs text-gray-500 flex items-center gap-2">
                                          <span>PodPal Studio</span>
                                          <span>·</span>
                                          <span>{{ formatTime(totalAudioDuration) }}</span>
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
        <div v-if="activeToolTab === 'export'" class="flex-1 overflow-hidden bg-gray-50 flex">
          <!-- 中间：预览界面 -->
          <div class="flex-1 overflow-y-auto p-6">
            <div class="max-w-3xl mx-auto space-y-6">
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
                <div class="h-48 bg-gradient-to-br from-pink-400 via-purple-500 to-indigo-600 relative flex items-center justify-center">
                  <div class="text-center text-white">
                    <div class="text-3xl font-bold mb-2">{{ shownotesData?.titles?.[0] || currentProject.name || '播客封面' }}</div>
                    <div class="text-sm opacity-80">PodPal Studio</div>
                  </div>
                  <div class="absolute bottom-3 right-3 px-3 py-1 bg-black/30 rounded-full text-white text-xs backdrop-blur-sm">
                    {{ formatTime(audioDuration) }}
                  </div>
                </div>
                
                <!-- 内容预览 -->
                <div class="p-6 space-y-6">
                  <!-- Shownotes 预览 -->
                  <div v-if="shownotesData">
                    <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                      <span class="w-1 h-4 bg-purple-500 rounded-full"></span>
                      Shownotes
                    </h3>
                    <div class="bg-gray-50 rounded-lg p-4 space-y-3">
                      <div>
                        <div class="text-xs text-gray-500 mb-1">标题</div>
                        <div class="text-sm font-medium text-gray-900">{{ shownotesData.titles?.[0] }}</div>
                      </div>
                      <div>
                        <div class="text-xs text-gray-500 mb-1">摘要</div>
                        <div class="text-sm text-gray-700">{{ shownotesData.summary }}</div>
                      </div>
                      <div v-if="shownotesData.timeline && shownotesData.timeline.length > 0">
                        <div class="text-xs text-gray-500 mb-2">时间轴</div>
                        <div class="space-y-1">
                          <div v-for="(item, idx) in shownotesData.timeline.slice(0, 3)" :key="idx" class="flex items-center gap-2 text-sm">
                            <span class="text-pink-600 font-mono text-xs">{{ item.timestamp }}</span>
                            <span class="text-gray-700">{{ item.topic }}</span>
                          </div>
                          <div v-if="shownotesData.timeline.length > 3" class="text-xs text-gray-400">+{{ shownotesData.timeline.length - 3 }} 更多...</div>
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  <!-- 金句视频预览 -->
                  <div v-if="generatedVideos.length > 0">
                    <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                      <span class="w-1 h-4 bg-blue-500 rounded-full"></span>
                      金句视频 ({{ generatedVideos.length }}个)
                    </h3>
                    <div class="grid grid-cols-3 gap-3">
                      <div v-for="video in generatedVideos.slice(0, 3)" :key="video.id" class="aspect-video bg-gray-100 rounded-lg overflow-hidden relative group cursor-pointer">
                        <img :src="video.thumbnail" class="w-full h-full object-cover" />
                        <div class="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition flex items-center justify-center">
                          <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
                        </div>
                        <div class="absolute bottom-1 right-1 px-1.5 py-0.5 bg-black/60 text-white text-[10px] rounded">{{ video.duration }}</div>
                      </div>
                    </div>
                  </div>
                  
                  <!-- 社交媒体文案预览 -->
                  <div v-if="socialCopyContent">
                    <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                      <span class="w-1 h-4 bg-green-500 rounded-full"></span>
                      {{ platformNames[socialPlatform] }} 推广文案
                    </h3>
                    <div class="bg-green-50 rounded-lg p-4 border border-green-100">
                      <div class="text-sm text-gray-700 whitespace-pre-line">{{ socialCopyContent }}</div>
                    </div>
                  </div>
                  
                  <!-- 导出设置 -->
                  <div class="pt-4 border-t border-gray-100">
                    <h3 class="text-sm font-bold text-gray-900 mb-3">导出设置</h3>
                    <div class="flex items-center gap-6">
                      <div class="flex items-center gap-2">
                        <input type="radio" name="exportFormat" value="mp3" checked class="text-pink-600 focus:ring-pink-500" />
                        <span class="text-sm text-gray-700">MP3 (推荐)</span>
                      </div>
                      <div class="flex items-center gap-2">
                        <input type="radio" name="exportFormat" value="wav" class="text-pink-600 focus:ring-pink-500" />
                        <span class="text-sm text-gray-700">WAV (无损)</span>
                      </div>
                      <select class="rounded border-gray-300 text-sm py-1">
                        <option>192 kbps</option>
                        <option>320 kbps</option>
                      </select>
                    </div>
                  </div>
                </div>
              </div>
              
              <!-- AI 传播预测 -->
              <div class="bg-white rounded-xl border border-pink-200 shadow-sm p-6">
                <div class="flex items-center justify-between mb-4">
                  <h3 class="text-lg font-bold text-gray-900 flex items-center gap-2">
                    <svg class="w-5 h-5 text-pink-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
                    </svg>
                    AI 传播预测
                  </h3>
                  <button @click="generatePropagationForecast" :disabled="isGeneratingForecast" class="text-sm text-pink-600 hover:text-pink-700 flex items-center gap-1">
                    <svg v-if="isGeneratingForecast" class="animate-spin h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    </svg>
                    <span>{{ isGeneratingForecast ? '分析中...' : '重新分析' }}</span>
                  </button>
                </div>
                
                <div v-if="propagationForecast" class="space-y-4">
                  <!-- 预测数据卡片 -->
                  <div class="grid grid-cols-4 gap-4">
                    <div class="bg-gradient-to-br from-pink-50 to-purple-50 rounded-lg p-4 text-center">
                      <div class="text-2xl font-bold text-pink-600">{{ propagationForecast.expectedPlays }}</div>
                      <div class="text-xs text-gray-500 mt-1">预计播放量</div>
                    </div>
                    <div class="bg-gradient-to-br from-blue-50 to-cyan-50 rounded-lg p-4 text-center">
                      <div class="text-2xl font-bold text-blue-600">{{ propagationForecast.expectedLikes }}</div>
                      <div class="text-xs text-gray-500 mt-1">预计点赞</div>
                    </div>
                    <div class="bg-gradient-to-br from-green-50 to-emerald-50 rounded-lg p-4 text-center">
                      <div class="text-2xl font-bold text-green-600">{{ propagationForecast.expectedShares }}</div>
                      <div class="text-xs text-gray-500 mt-1">预计分享</div>
                    </div>
                    <div class="bg-gradient-to-br from-orange-50 to-yellow-50 rounded-lg p-4 text-center">
                      <div class="text-2xl font-bold text-orange-600">{{ propagationForecast.viralScore }}</div>
                      <div class="text-xs text-gray-500 mt-1">传播指数</div>
                    </div>
                  </div>
                  
                  <!-- 平台表现预测 -->
                  <div class="bg-gray-50 rounded-lg p-4">
                    <div class="text-sm font-semibold text-gray-700 mb-3">各平台表现预测</div>
                    <div class="space-y-2">
                      <div v-for="platform in propagationForecast.platformPredictions" :key="platform.name" class="flex items-center gap-3">
                        <span class="text-xs text-gray-600 w-16">{{ platform.name }}</span>
                        <div class="flex-1 h-2 bg-gray-200 rounded-full overflow-hidden">
                          <div class="h-full rounded-full" :style="{ width: platform.score + '%', backgroundColor: platform.color }"></div>
                        </div>
                        <span class="text-xs font-medium text-gray-700 w-12 text-right">{{ platform.score }}分</span>
                      </div>
                    </div>
                  </div>
                  
                  <!-- AI 建议 -->
                  <div class="bg-pink-50 rounded-lg p-4 border border-pink-100">
                    <div class="text-sm font-semibold text-pink-700 mb-2">💡 AI 优化建议</div>
                    <ul class="space-y-1">
                      <li v-for="(tip, idx) in propagationForecast.tips" :key="idx" class="text-sm text-gray-700 flex items-start gap-2">
                        <span class="text-pink-500 mt-0.5">•</span>
                        {{ tip }}
                      </li>
                    </ul>
                  </div>
                </div>
                
                <div v-else class="text-center py-8 text-gray-400">
                  <svg class="w-12 h-12 mx-auto mb-2 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                  </svg>
                  <p class="text-sm">点击"重新分析"获取 AI 传播预测</p>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 右侧：智能分发建议 -->
          <aside class="w-80 flex-none bg-white border-l border-pink-200 flex flex-col overflow-hidden">
            <div class="p-4 border-b border-pink-200 bg-gradient-to-r from-pink-50 to-purple-50">
              <h2 class="text-sm font-semibold text-gray-700 uppercase tracking-wider flex items-center gap-2">
                <svg class="w-4 h-4 text-pink-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                智能分发建议
              </h2>
              <p class="text-xs text-gray-500 mt-1">AI 推荐的最佳发布策略</p>
            </div>
            
            <div class="flex-1 overflow-y-auto p-4 space-y-4">
              <!-- 最佳发布时间 -->
              <div class="bg-gradient-to-br from-pink-50 to-purple-50 rounded-lg p-4 border border-pink-200">
                <div class="flex items-center gap-2 mb-3">
                  <div class="w-8 h-8 rounded-full bg-pink-100 flex items-center justify-center">
                    <svg class="w-4 h-4 text-pink-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                  </div>
                  <div>
                    <div class="text-sm font-semibold text-gray-900">最佳发布时间</div>
                    <div class="text-xs text-gray-500">基于听众活跃度分析</div>
                  </div>
                </div>
                <div class="space-y-2">
                  <div v-for="(time, idx) in distributionSuggestions.bestTimes" :key="idx" class="flex items-center justify-between p-2 bg-white rounded-lg">
                    <div class="flex items-center gap-2">
                      <span class="text-lg">{{ time.icon }}</span>
                      <span class="text-sm font-medium text-gray-900">{{ time.time }}</span>
                    </div>
                    <span class="text-xs px-2 py-0.5 rounded-full" :class="time.score >= 90 ? 'bg-green-100 text-green-700' : time.score >= 70 ? 'bg-yellow-100 text-yellow-700' : 'bg-gray-100 text-gray-600'">{{ time.score }}分</span>
                  </div>
                </div>
              </div>
              
              <!-- 平台推荐 -->
              <div class="bg-white rounded-lg border border-gray-200 p-4">
                <div class="text-sm font-semibold text-gray-900 mb-3 flex items-center gap-2">
                  <svg class="w-4 h-4 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                  </svg>
                  平台推荐排序
                </div>
                <div class="space-y-2">
                  <div v-for="(platform, idx) in distributionSuggestions.platformRanking" :key="platform.id" class="flex items-center gap-3 p-2 rounded-lg hover:bg-gray-50 transition cursor-pointer" @click="togglePlatform(platform.id)">
                    <div class="w-6 h-6 rounded-full bg-gray-100 flex items-center justify-center text-xs font-bold" :class="idx < 3 ? 'text-pink-600' : 'text-gray-500'">{{ idx + 1 }}</div>
                    <img :src="platform.icon" class="w-6 h-6 rounded" />
                    <div class="flex-1">
                      <div class="text-sm font-medium text-gray-900">{{ platform.name }}</div>
                      <div class="text-xs text-gray-500">{{ platform.reason }}</div>
                    </div>
                    <div v-if="selectedPlatforms.includes(platform.id)" class="text-pink-600">
                      <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
                    </div>
                  </div>
                </div>
              </div>
              
              <!-- 一键分发按钮 -->
              <button @click="distributeToPlatforms" class="w-full py-3 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg transition font-medium flex items-center justify-center gap-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" />
                </svg>
                一键分发 ({{ selectedPlatforms.length }}个平台)
              </button>
            </div>
          </aside>
        </div>

      </main>

      <!-- 4. 右侧：AI 智能工具箱 (Feature 3, 4, 5) -->
      <aside v-show="activeToolTab === 'edit'" class="w-96 flex-none bg-gradient-to-b from-pink-50 to-purple-50 border-l border-pink-200 flex flex-col overflow-auto" :style="rightPanelStyle">
        <div class="p-6 space-y-8 overflow-y-auto">
          
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

             <!-- 语音生成（示例交互） -->
             <section v-show="openRightPanel==='voice'">
              <h3 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-pink-500 rounded-full"></span>
                声演实验室
              </h3>
               <div class="space-y-3">
                 <!-- 提示词输入区域 -->
                 <div class="p-3 bg-gradient-to-r from-pink-50 to-purple-50 border border-pink-200 rounded-lg">
                   <div class="text-xs font-medium text-gray-700 mb-2">输入提示词生成语音内容</div>
                   <textarea
                     v-model="voicePrompt"
                     placeholder="例如：用轻松友好的语气介绍播客开场，时长约10秒..."
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
                     {{ isGeneratingVoice ? '生成中...' : '生成语音内容' }}
                   </button>
                   <!-- 生成进度显示 -->
                   <div v-if="isGeneratingVoice" class="mt-2">
                     <div class="text-[10px] text-gray-600 mb-1">生成进度</div>
                     <div class="h-1.5 bg-gray-200 rounded-full overflow-hidden">
                       <div class="h-full bg-gradient-to-r from-pink-400 to-purple-400 rounded-full transition-all duration-300 animate-pulse" style="width: 70%"></div>
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
                     class="p-3 bg-white border border-pink-200 rounded-lg hover:border-pink-400 transition cursor-pointer group shadow-sm"
                     @click="selectVoiceSentence(sentence)"
                   >
                     <div class="flex items-start gap-2">
                       <div class="w-5 h-5 rounded-full bg-gradient-to-br from-pink-400 to-purple-400 flex items-center justify-center text-[10px] text-white flex-shrink-0">
                         {{ idx + 1 }}
                       </div>
                       <div class="flex-1 min-w-0">
                         <p class="text-xs text-gray-800 leading-relaxed">{{ sentence.text }}</p>
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
                           @click.stop="openTTSPreviewForSentence(sentence)"
                           class="p-1.5 text-blue-500 hover:bg-blue-100 rounded transition"
                           title="编辑"
                         >
                           <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                             <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 4H7a2 2 0 00-2 2v4m0 0h4m-4 0l9 9m4-13a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
                           </svg>
                         </button>
                       </div>
                     </div>
                   </div>
                 </div>

                 <!-- 声线克隆按钮 -->
                 <div class="pt-2 border-t border-pink-100">
                   <button
                     class="w-full p-2 bg-white border border-pink-200 rounded text-xs text-gray-900 hover:border-pink-400 hover:text-pink-600 transition flex items-center justify-center gap-1"
                     @click="handleVoiceTool('clone')"
                   >
                     <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" /></svg>
                     声线克隆
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
                            'bg-purple-100 text-purple-800 border-purple-200': entry.type === '停顿',
                            'bg-amber-100 text-amber-800 border-amber-200': entry.type === '噪音',
                            'bg-cyan-100 text-cyan-800 border-cyan-200': entry.type !== '静音' && entry.type !== '停顿' && entry.type !== '噪音'
                          }">{{ entry.type }}</span>
                      </div>
                      <div class="mt-1 text-xs text-gray-900">{{ entry.content }}</div>
                      <div class="mt-1 flex flex-wrap gap-1">
                        <span v-for="tag in entry.tags" :key="tag.text" class="text-[10px] px-2 py-0.5 rounded border"
                          :class="{
                            'bg-pink-50 text-pink-700 border-pink-100': tag.type === '静音',
                            'bg-purple-50 text-purple-700 border-purple-100': tag.type === '停顿',
                            'bg-amber-50 text-amber-700 border-amber-100': tag.type === '噪音',
                            'bg-cyan-50 text-cyan-700 border-cyan-100': tag.type !== '静音' && tag.type !== '停顿' && tag.type !== '噪音'
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
                  <div v-for="sentence in goldenSentences" :key="sentence.id" class="p-3 bg-gradient-to-r from-yellow-50 to-orange-50 border border-yellow-200 rounded-lg hover:shadow-md transition">
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
                    <div v-if="!sentence.editing" class="text-xs text-gray-900 font-medium cursor-pointer" @click="scrollToGoldenSentence(sentence)">{{ sentence.content }}</div>
                    <div v-else class="flex items-center gap-2">
                      <input v-model="sentence.content" class="flex-1 text-xs border border-yellow-300 rounded px-2 py-1" />
                      <button class="text-[10px] px-2 py-0.5 bg-yellow-400 text-white rounded" @click="sentence.editing=false">保存</button>
                      <button class="text-[10px] px-2 py-0.5 bg-white border border-gray-200 rounded" @click="sentence.editing=false">取消</button>
                    </div>
                    <div class="mt-2">
                      <!-- 标记点功能 -->
                      <div class="flex items-center gap-2">
                        <button 
                          class="text-[10px] px-3 py-1 rounded bg-gradient-to-r from-emerald-500 to-teal-500 text-white hover:shadow-md transition flex items-center gap-1"
                          @click.stop="addMarkerAtSentence(sentence)"
                        >
                          <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                          </svg>
                          添加标记点
                        </button>
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
import { ref, onMounted, onUnmounted, computed } from 'vue'
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
const scriptSuggestions = ref([])
const scriptPreview = ref([])
const isGenerating = ref(false)
const openRightPanel = ref('content_post')
const openEnhancePanel = ref('shownotes')

// 文本编辑与同步相关状态
const editingSegmentId = ref(null)

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
  const mainRegex = new RegExp(`(~~.*?~~|\\+\\+.*?\\+\\+|${fillerRegex})`, 'g')
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
    const wordRegex = /(\s+|[，。！？、；：,.!?…—-])/g
                const subs = part.split(wordRegex)
                // 改进的口吃匹配：匹配连续重复的单字，如“我我我”、“这这”
                const stutterPattern = /([\u4e00-\u9fa5A-Za-z])\1+/g
                
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

// AI 总结生成函数
const generateAISummaries = async () => {
  if (mockTranscript.value.length === 0) return
  
  isGeneratingAiSummary.value = true
  
  try {
    // 分段逻辑：每3-5个片段为一段
    const segmentsPerSection = Math.min(5, Math.max(3, Math.ceil(mockTranscript.value.length / 3)))
    const sections = []
    
    for (let i = 0; i < mockTranscript.value.length; i += segmentsPerSection) {
      const endIndex = Math.min(i + segmentsPerSection, mockTranscript.value.length)
      sections.push({
        startIndex: i,
        endIndex: endIndex - 1,
        segments: mockTranscript.value.slice(i, endIndex)
      })
    }
    
    // 生成每个段落的总结
    const summaries = await Promise.all(sections.map(async (section, index) => {
      // 模拟AI总结生成
      await new Promise(resolve => setTimeout(resolve, 400))
      
      const textContent = section.segments.map(s => s.text.replace(/\[TTS\]/g, '').replace(/~~[^~]+~~/g, '').replace(/\+\+[^+]+\+\+/g, '$1')).join(' ')
      
      // 基于内容长度和关键词生成更自然的总结
      const contentLength = textContent.length
      const hasQuestion = textContent.includes('？') || textContent.includes('?')
      const hasExplanation = textContent.includes('因为') || textContent.includes('所以') || textContent.includes('因此')
      const hasExample = textContent.includes('比如') || textContent.includes('例如') || textContent.includes('像')
      const hasOpinion = textContent.includes('认为') || textContent.includes('觉得') || textContent.includes('看法')
      
      // 提取关键主题词（简单提取前几个实词）
      const keywords = extractKeywords(textContent)
      const keywordPhrase = keywords.slice(0, 2).join('和') || '相关内容'
      
      // 根据内容特征生成自然流畅的总结
      let summary = ''
      
      if (hasQuestion && hasExplanation) {
        const templates = [
          `围绕${keywordPhrase}展开探讨，分析了问题的来龙去脉，并给出了清晰的解释和思路`,
          `针对${keywordPhrase}提出了深入的问题，从多个角度进行了分析，并阐述了背后的原因`,
          `以${keywordPhrase}为切入点，通过问答的形式层层深入，帮助理解核心要点`
        ]
        summary = templates[index % templates.length]
      } else if (hasExample) {
        const templates = [
          `通过具体案例讲解${keywordPhrase}，用生动的例子帮助理解抽象概念，内容详实易懂`,
          `以${keywordPhrase}为主题，结合实例进行说明，让复杂的概念变得直观清晰`,
          `围绕${keywordPhrase}展开，穿插多个实际案例，理论与实践相结合，具有很强的参考性`
        ]
        summary = templates[index % templates.length]
      } else if (hasOpinion) {
        const templates = [
          `就${keywordPhrase}表达了独到见解，观点鲜明，论证充分，值得深入思考`,
          `对${keywordPhrase}进行了深入剖析，提出了有建设性的看法和建议`,
          `围绕${keywordPhrase}分享了个人观点，分析透彻，为听众提供了新的思考角度`
        ]
        summary = templates[index % templates.length]
      } else if (contentLength > 100) {
        const templates = [
          `系统性地介绍了${keywordPhrase}的核心内容，条理清晰，信息量丰富`,
          `全面梳理了${keywordPhrase}的相关知识，内容扎实，逻辑严密`,
          `深入讲解了${keywordPhrase}的方方面面，层次分明，重点突出`
        ]
        summary = templates[index % templates.length]
      } else {
        const templates = [
          `简要介绍了${keywordPhrase}的基本情况，内容精炼，要点明确`,
          `对${keywordPhrase}进行了概括性说明，言简意赅，易于理解`,
          `聚焦${keywordPhrase}，快速传达了核心信息，适合快速了解`
        ]
        summary = templates[index % templates.length]
      }
      
      return {
        id: `summary_${index + 1}`,
        sectionNumber: index + 1,
        startIndex: section.startIndex,
        endIndex: section.endIndex,
        summary: summary,
        timestamp: section.segments[0].startTime,
        duration: section.segments[section.segments.length - 1].endTime - section.segments[0].startTime
      }
    }))
    
    aiSummaries.value = summaries
  } catch (error) {
    console.error('生成AI总结失败:', error)
  } finally {
    isGeneratingAiSummary.value = false
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
  maxHeight: 'calc(100vh - 100px)',
  overflowY: 'auto'
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

const loadSampleGoldenSentences = () => {
  goldenSentences.value = [
    { id: 101, content: '我觉得最核心的优势在于，AI能够帮助创作者从繁琐的机械劳动中解放出来。这就是播客创作的未来，让技术服务于创意。', startTime: 512, endTime: 535, segmentIndex: 5, viralPotential: 92, logicScore: 88, editing: false, highlight: false },
    { id: 102, content: '其实，创作的本质在于真实性的表达，这才是真正能打动听众的关键所在。', startTime: 780, endTime: 805, segmentIndex: 7, viralPotential: 95, logicScore: 94, editing: false, highlight: false },
    { id: 103, content: '技术只是工具，创意才是播客的灵魂所在。', startTime: 1050, endTime: 1075, segmentIndex: 9, viralPotential: 89, logicScore: 91, editing: false, highlight: false }
  ]
}

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
const generateVideoPreview = async () => {
  if (isGeneratingVideo.value) return
  if (selectedSentences.value.length === 0) {
    alert('请至少选择一个金句片段')
    return
  }
  
  isGeneratingVideo.value = true
  
  try {
    // 获取选中的金句内容
    const selectedGoldenSentences = goldenSentences.value.filter(s => selectedSentences.value.includes(s.id))
    const videoPrompt = selectedGoldenSentences.map(s => s.text).join(' ')
    
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
        duration: 15, // 默认15秒
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
    
    // 模拟：实际项目中使用 API 返回的数据
    // 这里使用模拟数据展示效果
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    generatedVideos.value.push({
      id: Date.now(),
      url: result.video_url || '#',
      thumbnail: result.thumbnail_url || `https://placehold.co/320x180/FF6B9D/ffffff?text=${encodeURIComponent(selectedGoldenSentences[0]?.text?.substring(0, 20) || 'Video')}`,
      duration: result.duration || '00:15',
      template: videoTemplate.value,
      sentences: [...selectedSentences.value],
      seedance_id: result.id // 保存 Seedance 视频 ID
    })
    
    alert('视频生成成功！')
  } catch (error) {
    console.error('视频生成失败:', error)
    // 降级处理：使用模拟数据
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    const selectedGoldenSentences = goldenSentences.value.filter(s => selectedSentences.value.includes(s.id))
    generatedVideos.value.push({
      id: Date.now(),
      url: '#',
      thumbnail: `https://placehold.co/320x180/FF6B9D/ffffff?text=${encodeURIComponent(selectedGoldenSentences[0]?.text?.substring(0, 15) || 'Video')}`,
      duration: '00:15',
      template: videoTemplate.value,
      sentences: [...selectedSentences.value]
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
const socialCopyContent = ref('')
const isGeneratingCopy = ref(false)

// AI 传播预测
const propagationForecast = ref(null)
const isGeneratingForecast = ref(false)

// 智能分发建议
const distributionSuggestions = ref({
  bestTimes: [
    { icon: '🌅', time: '早上 7:30', score: 85 },
    { icon: '🌞', time: '中午 12:00', score: 92 },
    { icon: '🌆', time: '晚上 20:00', score: 95 },
  ],
  platformRanking: [
    { id: 'xiaoyuzhou', name: '小宇宙', icon: xiaoyuzhouIcon, reason: '播客用户活跃度高', score: 95 },
    { id: 'weixin', name: '微信听书', icon: weixinIcon, reason: '知识类内容受欢迎', score: 88 },
    { id: 'xiaohongshu', name: '小红书', icon: xiaohongshuIcon, reason: '年轻用户群体匹配', score: 82 },
    { id: 'apple', name: 'Apple 播客', icon: appleIcon, reason: '专业播客平台', score: 78 },
    { id: 'qq', name: 'QQ 音乐', icon: qqIcon, reason: '音乐用户转化', score: 72 },
    { id: 'douyin', name: '抖音', icon: douyinIcon, reason: '短视频引流', score: 68 },
  ]
})

const generateSocialCopy = async () => {
  if (isGeneratingCopy.value) return
  isGeneratingCopy.value = true
  socialCopyContent.value = ''
  
  await new Promise(resolve => setTimeout(resolve, 1500))
  
  const title = shownotesData.value?.titles?.[0] || '播客标题'
  const summary = shownotesData.value?.summary || '播客内容摘要'
  
  const copies = {
    wechat: `【${title}】\n\n${summary.substring(0, 150)}...\n\n🎧 本期亮点：\n${shownotesData.value?.timeline?.slice(0, 3).map(item => `${item.timestamp} ${item.topic}`).join('\n') || '精彩内容等你来听'}\n\n#播客 #AI #内容创作`,
    xiaohongshu: `宝藏播客推荐！✨ ${title}\n\n宝子们！发现了一期超有料的播客！🎤\n\n${summary.substring(0, 100)}...\n\n真的学到了很多，强烈推荐给所有想做内容的小伙伴！\n\n#播客 #AI工具 #内容创作 #知识分享`,
    weibo: `🎙️ 新一期播客上线：${title}\n\n${summary.substring(0, 80)}...\n\n点击链接收听完整内容 👇\n\n${shownotesData.value?.timeline?.slice(0, 2).map(item => `${item.timestamp} ${item.topic}`).join('\n') || ''}\n\n#播客 #科技 #AI`
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

// AI 传播预测生成
const generatePropagationForecast = async () => {
  if (isGeneratingForecast.value) return
  isGeneratingForecast.value = true
  
  await new Promise(resolve => setTimeout(resolve, 2000))
  
  propagationForecast.value = {
    expectedPlays: '2.5k-5k',
    expectedLikes: '150-300',
    expectedShares: '50-100',
    viralScore: 78,
    platformPredictions: [
      { name: '小宇宙', score: 92, color: '#FFD700' },
      { name: '微信', score: 85, color: '#07C160' },
      { name: '小红书', score: 78, color: '#FF2442' },
      { name: 'Apple', score: 72, color: '#FF9500' },
      { name: 'QQ音乐', score: 65, color: '#31C27C' },
    ],
    tips: [
      '建议在晚上 20:00 发布，此时用户活跃度最高',
      '标题中包含"AI"关键词可提升 15% 点击率',
      '配合金句视频在短视频平台同步发布效果更佳',
      'Shownotes 中的时间戳有助于提升完播率',
    ]
  }
  
  isGeneratingForecast.value = false
}

// 一键分发
const distributeToPlatforms = async () => {
  if (selectedPlatforms.value.length === 0) {
    alert('请至少选择一个平台')
    return
  }
  
  const platformNames = selectedPlatforms.value.map(id => {
    const map = { weixin: '微信听书', douyin: '抖音', qq: 'QQ音乐', xiaohongshu: '小红书', apple: 'Apple播客', xiaoyuzhou: '小宇宙' }
    return map[id]
  }).join('、')
  
  alert(`正在分发到：${platformNames}...\n\n（模拟：实际项目中会调用各平台 API）`)
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
const fillerWords = ['就是', '然后', '那个', '嗯', '啊', '你知道', '其实', '对吧', '可以说', '怎么说呢']

// 音频增强开关
const voiceEnhanceEnabled = ref(false)
const echoRemovalEnabled = ref(false)

// 模拟转写文本数据
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
    text: '诶，你好 Claire。其实我一直有在关注你们这个 PodPal 的进展。'
  },
  {
    startTime: 30,
    endTime: 45,
    speaker: 'A',
    text: '真的吗？那咱们直奔主题。现在 AI 剪辑挺火的，但很多人担心……呃，就是说，AI 剪出来的东西太冷冰冰了，没那个……人情味。'
  },
  {
    startTime: 45,
    endTime: 60,
    speaker: 'B',
    text: '嗯，其实这确实是个普遍的……那个，误区。传统的 AI 剪辑逻辑比较机械，它只会盯着波形看，哪里没声音了它就直接剪掉。'
  },
  {
    startTime: 60,
    endTime: 75,
    speaker: 'B',
    text: '但我们要知道，人类聊天时的"停顿"是有灵魂的。有些沉默是因为思考，有些沉默是因为情绪到了。'
  },
  {
    startTime: 75,
    endTime: 90,
    speaker: 'A',
    text: '没错！有时候那个……就是说，沉默反而比说话更有力量。我之前用传统软件剪辑，最怕的就是把嘉宾这种有温度的瞬间给切碎了。'
  },
  {
    startTime: 90,
    endTime: 105,
    speaker: 'B',
    text: '对。所以真正的智能不该只做物理意义上的"减法"，而是要做逻辑上的"筛选"。'
  },
  {
    startTime: 105,
    endTime: 120,
    speaker: 'B',
    text: '好的工具不应该替代人的思考，而应该延长人的感官。'
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
    text: '意味着……呃，创作权力的下放吧。以前你得学三个月软件才能剪出一档像样的播客，把时间都花在对齐音轨这种机械劳动上。'
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
    text: '明白了。就像 PodPal 做的，把复杂留给算法，把直觉留给作者。'
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
])

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
    { name: '上传音频指纹...', duration: 800, progress: 15 },
    { name: 'AI 引擎初始化...', duration: 600, progress: 30 },
    { name: '正在识别说话人 (Diarization)...', duration: 1200, progress: 55 },
    { name: '文本转写与标点纠偏...', duration: 1500, progress: 85 },
    { name: '结果最终校对中...', duration: 800, progress: 100 }
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

  setTimeout(() => {
    isTranscribing.value = false
    // 转写结果现在侧边栏展示，主区域滚动逻辑移除
  }, 1000)
}

// 场景自适应设置
const podcastType = ref('knowledge') // 'knowledge' | 'companion'

// Shownotes 生成
const shownotesData = ref(null)
const isGeneratingShownotes = ref(false)
const showMindMap = ref(false)

// 作品仓库
const workRepository = ref([
  { id: 'work-1', name: 'AI播客创作指南_最终版.mp3', duration: '32:15', exportTime: '2024-03-08 14:30' },
  { id: 'work-2', name: '职场焦虑与应对_剪辑版.mp3', duration: '28:45', exportTime: '2024-03-07 09:15' },
  { id: 'work-3', name: '科技趋势解读_第15期.mp3', duration: '45:20', exportTime: '2024-03-05 16:45' },
])
const currentProjectExport = ref({
  id: 'current',
  name: '当前项目_待导出.mp3',
  duration: '30:00',
  exportTime: '刚刚'
})
const selectedWork = ref(null)

// 音频播放器状态
const isAudioPlaying = ref(false)
const audioProgress = ref(0)
const currentAudioTime = ref(0)
const totalAudioDuration = ref(1800) // 30分钟
let audioPlayInterval = null

// 模拟发布预览
const showPublishPreview = ref(false)
const currentPreviewPlatform = ref('xiaoyuzhou')
const previewPlatforms = [
  { id: 'xiaoyuzhou', name: '小宇宙', icon: 'https://img.icons8.com/color/48/000000/radio.png' },
  { id: 'wechat', name: '微信公众号', icon: 'https://img.icons8.com/color/48/000000/weixing.png' },
  { id: 'xiaohongshu', name: '小红书', icon: 'https://img.icons8.com/color/48/000000/xiaohongshu.png' },
  { id: 'weibo', name: '微博', icon: 'https://img.icons8.com/color/48/000000/sina-weibo.png' },
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
  { id: 1, name: '原始录音_Track1.wav', type: 'audio', duration: '45:20', format: 'WAV', category: '人声', used: false, playing: false, summary: '嘉宾与主持围绕 AI 剪辑展开的长对话录音。', tags: ['访谈', 'AI', '剪辑'], editingSummary: false },
  { id: 2, name: '背景音乐_Jazz.mp3', type: 'audio', duration: '03:15', format: 'MP3', category: '背景音', used: false, playing: false, summary: '轻柔爵士 BGM，适合对话段落的低侵入背景。', tags: ['轻柔', '爵士', '低侵入'], editingSummary: false },
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
// 上传后预处理弹窗
const showPreprocessModal = ref(false)
const preTranscribe = ref(true)
const preVoiceEnhance = ref(true)
const preEchoRemoval = ref(false)
// 素材多选
const selectedAssetIds = ref([])
const toggleAssetSelect = (asset) => {
  const idx = selectedAssetIds.value.indexOf(asset.id)
  if (idx >= 0) selectedAssetIds.value.splice(idx, 1)
  else selectedAssetIds.value.push(asset.id)
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
const playAsset = (asset) => {
  if (currentPlayingAsset.value === asset) {
    asset.playing = !asset.playing
    if (!asset.playing) {
      currentPlayingAsset.value = null
    }
  } else {
    if (currentPlayingAsset.value) {
      currentPlayingAsset.value.playing = false
    }
    asset.playing = true
    currentPlayingAsset.value = asset
    // 模拟播放，实际应该使用 Web Audio API
    console.log('播放音频:', asset.name)
    // 3秒后自动停止（模拟）
    setTimeout(() => {
      if (asset.playing) {
        asset.playing = false
        currentPlayingAsset.value = null
      }
    }, 3000)
  }
}
// 开始预处理
const startPreprocess = () => {
  voiceEnhanceEnabled.value = !!preVoiceEnhance.value
  echoRemovalEnabled.value = !!preEchoRemoval.value
  if (preTranscribe.value) {
    startTranscription()
  }
  showPreprocessModal.value = false
  activeToolTab.value = 'edit'
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
      format: f.name.split('.').pop().toUpperCase(),
      category: f.type.startsWith('video') ? '效果音' : '人声',
      used: false,
      playing: false,
      summary: '',
      tags: [],
      editingSummary: false
    })
    hasUploaded.value = true
    inlineUploading.value = false
    showPreprocessModal.value = true
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
      asset.used = true
      hasUploaded.value = true
      inlineUploading.value = false
      showPreprocessModal.value = true
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
    format: f.name.split('.').pop().toUpperCase(),
    category: f.type.startsWith('video') ? '效果音' : '人声',
    used: false,
    playing: false,
    summary: '',
    tags: [],
    editingSummary: false
  })
  hasUploaded.value = true
  inlineUploading.value = false
  showPreprocessModal.value = true
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
    format: 'MP3',
    category: '人声',
    used: false,
    playing: false,
    summary: '',
    tags: [],
    editingSummary: false
  })
  hasUploaded.value = true
  inlineUploading.value = false
  showPreprocessModal.value = true
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
  // 去口语冗余：自动删除所有片段里的口癖（留痕模式）
  if (type === 'filler') {
    let hasChanges = false
    mockTranscript.value.forEach(seg => {
      const tokens = parseSegmentText(seg.text)
      let changed = false
      const newTokens = tokens.map(token => {
        // 针对识别出的“口癖”和“口吃” Token 进行留痕删除，清理口语冗余
        if ((token.type === 'filler' || token.type === 'stutter') && token.type !== 'deleted') {
          changed = true
          hasChanges = true
          return { ...token, type: 'deleted' }
        }
        return token
      })
      
      if (changed) {
        let prefix = seg.text.startsWith('[TTS]') ? '[TTS]' : ''
        seg.text = prefix + newTokens.map(t => {
          if (t.type === 'deleted') return `~~${t.text}~~`
          return t.text
        }).join('')
      }
    })

    if (hasChanges) {
      // 同时给脚本优化建议里追加一条说明
      scriptSuggestions.value.unshift({
        id: Date.now(),
        label: '已应用口语冗余清理',
        preview: '自动识别并留痕删除了常见口癖（嗯、然后、就是等）以及重复口吃。',
        tag: '口癖优化'
      })
      scriptOptimizeMessage.value = '已对文字稿中的冗余口癖和重复口吃进行留痕删除，提升内容精炼度。'
    } else {
      scriptOptimizeMessage.value = '未检测到明显的口语冗余或口吃，文稿保持原样。'
    }
    return
  }

  // 逻辑纠错：对文稿中的逻辑断层或病句进行修正（留痕模式）
  if (type === 'logic') {
    let hasChanges = false
    // 示例：修正第 3 个片段（索引为 2）的逻辑连贯性
    if (mockTranscript.value[2] && !mockTranscript.value[2].text.includes('++')) {
      const seg = mockTranscript.value[2]
      const originalText = seg.text
      // 模拟纠错 1：增加过渡词，使句子更连贯
      seg.text = originalText.replace('自动生成剪辑建议', '++极大提高了工作效率，并++自动生成剪辑建议')
      hasChanges = true
    }

    // 示例：修正第 6 个片段（索引为 5）的病句
    if (mockTranscript.value[5] && !mockTranscript.value[5].text.includes('++')) {
      const seg = mockTranscript.value[5]
      const originalText = seg.text
      // 模拟纠错 2：修正表达
      seg.text = originalText.replace('主要体现在哪些方面呢', '++具体的竞争优势++主要体现在哪些方面呢')
      hasChanges = true
    }

    if (hasChanges) {
      scriptSuggestions.value.unshift({
        id: Date.now(),
        label: '已应用逻辑纠错建议',
        preview: '识别到话语逻辑较为生硬，已自动添加补位过渡词。如果不满意，可直接点击文字稿中的绿色高亮部分撤回。',
        tag: '逻辑优化'
      })
      scriptOptimizeMessage.value = '已在文稿中应用逻辑纠错建议，新增内容已用绿色高亮标注。点击高亮内容可一键撤回。'
    } else {
      scriptOptimizeMessage.value = '未检测到明显的逻辑断层，文稿逻辑基本通顺。'
    }
    return
  }

  // 一键精华提取：直接复用已有 scriptPreview 中「高光合集」分组
  if (type === 'highlights') {
    // 确保已有示例预览数据
    if (!scriptPreview.value.length) {
      // 模拟生成脚本预览数据
      scriptPreview.value = [
        {
          id: 'g-highlights',
          strategy: 'highlights',
          label: '高光合集提取',
          description: '从全文中提取出的金句与核心论点。',
          entries: [
            { id: 'h1', speaker: '嘉宾 A', time: '02:15', type: '高光', content: '播客不仅仅是音频，它是深度社交的一种新形态。', tags: [{ text: '金句', type: '高光' }] },
            { id: 'h2', speaker: '嘉宾 B', time: '15:40', type: '高光', content: '未来的内容竞争，本质上是注意力的精准分配。', tags: [{ text: '核心论点', type: '高光' }] }
          ]
        }
      ]
    }
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

// 根据提示词生成语音内容
const generateVoiceFromPrompt = async () => {
  if (!voicePrompt.value.trim()) return
  
  isGeneratingVoice.value = true
  
  try {
    // 模拟AI生成过程
    await new Promise(resolve => setTimeout(resolve, 1500))
    
    // 根据提示词内容智能生成符合语境的句子
    const prompt = voicePrompt.value.toLowerCase()
    const sentences = []
    
    // 检测提示词中的场景和意图
    const isOpening = prompt.includes('开场') || prompt.includes('开头') || prompt.includes('开始')
    const isEnding = prompt.includes('结尾') || prompt.includes('结束') || prompt.includes('收场')
    const isTransition = prompt.includes('过渡') || prompt.includes('转场') || prompt.includes('衔接')
    const isIntroduction = prompt.includes('介绍') || prompt.includes('引入')
    const isCasual = prompt.includes('轻松') || prompt.includes('随意') || prompt.includes('休闲')
    const isProfessional = prompt.includes('专业') || prompt.includes('正式') || prompt.includes('严肃')
    const isWarm = prompt.includes('温暖') || prompt.includes('亲切') || prompt.includes('友好')
    
    if (isOpening) {
      if (isCasual) {
        sentences.push(
          { id: Date.now() + 1, text: '哈喽大家好，欢迎来到今天的节目，我是你们的主持人，今天我们要聊一个特别有意思的话题。', duration: 8, style: '轻松开场' },
          { id: Date.now() + 2, text: '嘿，各位听众朋友，又见面啦！今天咱们不聊别的，就聊聊最近特别火的那些事儿。', duration: 7, style: '亲切开场' },
          { id: Date.now() + 3, text: '大家好呀，欢迎来到这期节目，今天准备了一些新鲜内容，希望能给大家带来不一样的体验。', duration: 9, style: '自然开场' }
        )
      } else if (isProfessional) {
        sentences.push(
          { id: Date.now() + 1, text: '各位听众大家好，欢迎收听本期节目。今天我们将深入探讨行业发展趋势，为您带来专业的分析和见解。', duration: 10, style: '专业开场' },
          { id: Date.now() + 2, text: '大家好，欢迎准时收听。本期节目我们邀请到了行业专家，一起解读最新的市场动态。', duration: 9, style: '正式开场' }
        )
      } else {
        sentences.push(
          { id: Date.now() + 1, text: '大家好，欢迎收听今天的节目。今天我们要和大家聊聊一个很多人都关心的话题。', duration: 8, style: '标准开场' },
          { id: Date.now() + 2, text: '哈喽，各位好！欢迎来到这期节目，今天的内容很精彩，大家可要认真听哦。', duration: 7, style: '活泼开场' }
        )
      }
    } else if (isEnding) {
      sentences.push(
        { id: Date.now() + 1, text: '好了，今天的节目就到这里了，感谢大家的收听，我们下期再见！', duration: 6, style: '简洁收尾' },
        { id: Date.now() + 2, text: '感谢各位的陪伴，希望今天的内容对你有所帮助。记得点赞订阅，我们下期节目不见不散！', duration: 9, style: '互动收尾' },
        { id: Date.now() + 3, text: '今天的分享就到这里，如果你有什么想法，欢迎在评论区留言。感谢收听，拜拜！', duration: 8, style: '轻松收尾' }
      )
    } else if (isTransition) {
      sentences.push(
        { id: Date.now() + 1, text: '说完了这个，咱们再来聊聊另一个有意思的话题。', duration: 5, style: '自然过渡' },
        { id: Date.now() + 2, text: '刚才我们谈到了问题的表面，接下来让我们深入看看背后的原因。', duration: 7, style: '深入过渡' },
        { id: Date.now() + 3, text: '这个话题就先聊到这里，下面我们来听听嘉宾有什么看法。', duration: 6, style: '转场过渡' }
      )
    } else if (isIntroduction) {
      sentences.push(
        { id: Date.now() + 1, text: '在开始之前，我先简单介绍一下今天的嘉宾背景。', duration: 5, style: '介绍过渡' },
        { id: Date.now() + 2, text: '可能有些听众对这个话题不太熟悉，我先给大家做个简单的背景说明。', duration: 7, style: '背景介绍' }
      )
    } else {
      // 通用回复
      if (isWarm) {
        sentences.push(
          { id: Date.now() + 1, text: '其实这个问题挺有意思的，我觉得可以从几个不同的角度来看。', duration: 6, style: '温和表达' },
          { id: Date.now() + 2, text: '听到这里，不知道大家有没有同感？我自己是觉得挺有道理的。', duration: 6, style: '亲切互动' }
        )
      } else if (isProfessional) {
        sentences.push(
          { id: Date.now() + 1, text: '从专业角度分析，这个现象背后有几个关键因素值得我们关注。', duration: 7, style: '专业分析' },
          { id: Date.now() + 2, text: '基于现有数据和行业经验，我们可以得出以下结论。', duration: 6, style: '严谨表达' }
        )
      } else {
        sentences.push(
          { id: Date.now() + 1, text: '这个问题确实值得好好聊聊，我个人的看法是这样的。', duration: 5, style: '自然表达' },
          { id: Date.now() + 2, text: '不知道大家有没有注意到，最近这个现象越来越普遍了。', duration: 6, style: '引导思考' },
          { id: Date.now() + 3, text: '说到这儿，我突然想到一个相关的例子，特别能说明问题。', duration: 6, style: '举例引入' }
        )
      }
    }
    
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
  const newSeg = {
    startTime: currentTime.value,
    endTime: currentTime.value + sentence.duration,
    speaker: 'AI',
    text: '[TTS]' + sentence.text,
    confirmed: false,
    originalText: sentence.text // 保存原文参考
  }
  
  // 找到当前时间对应的插入位置
  const insertIndex = mockTranscript.value.findIndex(seg => seg.startTime > currentTime.value)
  if (insertIndex !== -1) {
    mockTranscript.value.splice(insertIndex, 0, newSeg)
  } else {
    mockTranscript.value.push(newSeg)
  }
  
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
  // 模拟预览功能
  audioOptimizeMessage.value = `正在预览：${sentence.text.substring(0, 20)}...`
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
    style: sentence.style
  }
  
  // 打开TTS预览模态框
  currentTTSTask.value = tempTask
  ttsDraftText.value = sentence.text
  showTTSModal.value = true
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
    confirmed: true,
    isNew: true
  }
  if (idx >= 0) {
    mockTranscript.value.splice(idx + 1, 0, newSeg)
  } else {
    mockTranscript.value.push(newSeg)
  }
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
      audioUrl: '' // 可在后端接入真实地址
    }
    localStorage.setItem('lastExportedWork', JSON.stringify(work))
  } catch (e) {
    console.warn('无法写入本地作品仓库缓存', e)
  }
}

// 脚本优化反馈提示
const scriptOptimizeMessage = ref('')
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

const isSegmentHighlighted = (index) => {
  return highlightedTranscriptIndices.value.includes(index)
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
      label: '建议缩减：尴尬停顿',
      previewHtml: '说话人 A 与 B 之间的停顿过长 (<span class="text-blue-600 font-bold">2.5s</span>)，建议缩减至 0.6s',
      tag: '停顿',
      type: 'pause',
      action: 'shorten'
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
    case 'pause': feedback = '已缩减语气停顿，衔接更加自然。'; break;
    case 'noise': feedback = '已应用 AI 降噪滤镜，音频更清澈。'; break;
    case 'normalize': feedback = '已均衡响度，整体听感更一致。'; break;
    default: feedback = '已应用剪辑建议。';
  }
  
  audioOptimizeMessage.value = feedback
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
      label: '长停顿缩减',
      description: '智能优化说话间的尴尬停顿',
      entries: [
        { id: 'e3', speaker: '对话', time: '00:25', type: '停顿', content: '说话人 A 提问后存在 2.5s 停顿，建议缩减至 0.6s。', tags: [{ text: '尴尬停顿', type: '停顿' }] }
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
  assets.value.unshift({
    id: Date.now(),
    name: file.name,
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
  hasUploaded.value = true
  showPreprocessModal.value = true
}

const selectAsset = (asset) => {
  console.log('Selected asset:', asset)
  // 可以在这里添加将素材添加到轨道的逻辑
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
          content: segment.text, // 直接使用原始文本
          startTime: segment.startTime,
          endTime: segment.endTime,
          segmentIndex: index, // 记录原始片段索引
          viralPotential: Math.floor(Math.random() * 15) + 80, // 80-95
          logicScore: Math.floor(Math.random() * 10) + 85 // 85-95
        })
      }
    }
  })
  
  goldenSentences.value = results.slice(0, 5) // 最多展示 5 条
  isExtracting.value = false
}

const deleteGoldenSentence = (id) => {
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
    viralPotential: 80 + Math.floor(Math.random() * 15),
    logicScore: 85 + Math.floor(Math.random() * 10),
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
      content: segment.text.replace(/\[TTS\]/g, '').trim(),
      startTime: selectionStart,
      endTime: selectionEnd,
      segmentIndex: mockTranscript.value.indexOf(segment),
      viralPotential: 80 + Math.floor(Math.random() * 15),
      logicScore: 85 + Math.floor(Math.random() * 10),
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
  totalAudioDuration.value = parseDuration(work.duration)
  currentAudioTime.value = 0
  audioProgress.value = 0
}

// 解析时长字符串为秒数
const parseDuration = (durationStr) => {
  const parts = durationStr.split(':').map(Number)
  if (parts.length === 2) {
    return parts[0] * 60 + parts[1]
  } else if (parts.length === 3) {
    return parts[0] * 3600 + parts[1] * 60 + parts[2]
  }
  return 1800
}

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

onUnmounted(() => {
  // 清理音频播放定时器
  if (audioPlayInterval) {
    clearInterval(audioPlayInterval)
    audioPlayInterval = null
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
</style>
