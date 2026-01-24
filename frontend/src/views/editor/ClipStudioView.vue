<template>
  <div class="min-h-screen bg-[#0B0D14] flex flex-col">
    <!-- 1. 顶部导航 & 用户管理 (Feature 1, 6) -->
    <header class="h-16 border-b border-[#485F88]/30 bg-[#121524] px-6 flex items-center justify-between sticky top-0 z-50">
      <div class="flex items-center gap-4">
        <h1 class="text-xl font-bold text-white tracking-tight">PodPal Studio</h1>
        <div class="h-6 w-px bg-[#485F88]/30 mx-2"></div>
        <div class="flex items-center gap-2 text-sm text-[#9DACCC] hover:text-white cursor-pointer transition">
          <span>{{ currentProject.name || '未命名项目' }}</span>
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" /></svg>
        </div>
        <span class="text-xs px-2 py-0.5 rounded bg-blue-900/50 text-blue-300 border border-blue-800">自动保存</span>
      </div>
      
      <div class="flex items-center gap-6">
        <!-- 团队协作 (Feature 6) -->
        <div class="flex -space-x-2">
          <div class="w-8 h-8 rounded-full bg-indigo-500 flex items-center justify-center text-xs text-white border-2 border-[#121524]" title="Team Member A">A</div>
          <div class="w-8 h-8 rounded-full bg-emerald-500 flex items-center justify-center text-xs text-white border-2 border-[#121524]" title="Team Member B">B</div>
          <button class="w-8 h-8 rounded-full bg-[#1a1f35]/50 flex items-center justify-center text-[#9DACCC] border-2 border-dashed border-[#485F88]/50 hover:text-white hover:border-[#9DACCC] transition">+</button>
        </div>
        
        <!-- 用户菜单 (Feature 1) -->
        <div class="flex items-center gap-3 pl-6 border-l border-[#485F88]/30">
          <div class="text-right hidden md:block">
            <div class="text-sm text-white">Alex (Pro)</div>
            <div class="text-xs text-[#9DACCC]/80">Team Admin</div>
          </div>
          <div class="w-9 h-9 rounded-full bg-gradient-to-br from-blue-500 to-purple-600"></div>
        </div>
      </div>
    </header>

    <div class="flex-1 flex overflow-hidden">
      <!-- 2. 左侧：素材与资产管理 (Feature 2) -->
      <aside class="w-80 bg-[#121524] border-r border-[#485F88]/30 flex flex-col">
        <div class="p-4 border-b border-[#485F88]/30">
          <h2 class="text-sm font-semibold text-[#9DACCC] uppercase tracking-wider mb-4">素材库</h2>
          <!-- 上传/导入 -->
          <div class="grid grid-cols-2 gap-2 mb-4">
            <button @click="triggerFileUpload" class="flex flex-col items-center justify-center p-4 bg-[#1a1f35]/50 rounded-lg hover:bg-[#1a1f35]/70 transition border border-dashed border-[#485F88]/30 hover:border-blue-500 group">
              <svg class="w-6 h-6 text-[#9DACCC] group-hover:text-blue-400 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" /></svg>
              <span class="text-xs text-[#9DACCC] group-hover:text-white">本地上传</span>
            </button>
            <button @click="showLinkModal = true" class="flex flex-col items-center justify-center p-4 bg-[#1a1f35]/50 rounded-lg hover:bg-[#1a1f35]/70 transition border border-dashed border-[#485F88]/30 hover:border-purple-500 group">
              <svg class="w-6 h-6 text-[#9DACCC] group-hover:text-purple-400 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1" /></svg>
              <span class="text-xs text-[#9DACCC] group-hover:text-white">链接导入</span>
            </button>
          </div>
          <input ref="fileInput" type="file" accept="audio/*,video/*" class="hidden" @change="handleFileSelect">
        </div>

        <!-- 素材列表 -->
        <div class="flex-1 overflow-y-auto p-4 space-y-2">
          <div 
            v-for="asset in assets" 
            :key="asset.id" 
            class="p-3 bg-[#1a1f35]/40 rounded-lg border border-[#485F88]/20 hover:border-[#485F88]/50 hover:bg-[#1a1f35]/60 cursor-pointer group transition-all duration-200"
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
                  <div class="text-sm text-white font-medium truncate">{{ asset.name }}</div>
                  <div class="text-xs text-[#9DACCC]/70 mt-0.5">{{ asset.duration }}</div>
                </div>
              </div>
              <button 
                class="p-1.5 text-[#9DACCC]/60 hover:text-white hover:bg-[#485F88]/30 rounded opacity-0 group-hover:opacity-100 transition"
                @click.stop="showAssetMenu(asset)"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
                </svg>
              </button>
            </div>
            <div class="flex items-center justify-between text-xs mt-2 pt-2 border-t border-[#485F88]/10">
              <span class="text-[#9DACCC]/70">{{ asset.duration }}</span>
              <span class="bg-[#485F88]/20 px-2 py-0.5 rounded text-[#9DACCC] border border-[#485F88]/30">{{ asset.format }}</span>
            </div>
          </div>
        </div>
      </aside>

      <!-- 3. 中间：工作区 (Feature 3, 9) -->
      <main class="flex-1 flex flex-col bg-[#0B0D14] overflow-hidden relative">
        <!-- 播放器预览 -->
        <div class="h-1/2 border-b border-[#485F88]/30 p-8 flex items-center justify-center relative bg-gradient-to-b from-[#0B0D14] via-[#121524] to-[#0B0D14]">
          <div class="text-center w-full max-w-3xl">
             <!-- 可视化波形 (Mock) -->
            <div class="h-40 flex items-end justify-center gap-0.5 mb-6 px-4">
               <div 
                 v-for="i in 60" 
                 :key="i" 
                 class="w-1 bg-gradient-to-t from-[#485F88] via-[#9DACCC] to-[#485F88] rounded-t transition-all duration-300 hover:from-blue-400 hover:via-blue-300 hover:to-blue-400" 
                 :style="{ 
                   height: (Math.sin(i * 0.2) * 30 + 50) + '%',
                   animationDelay: i * 0.03 + 's',
                   animation: isPlaying ? `wave ${0.5 + Math.random() * 0.5}s ease-in-out infinite` : 'none'
                 }"
               ></div>
            </div>
            
            <!-- 时间显示和进度条 -->
            <div class="mb-6">
              <div class="flex items-center justify-between text-sm text-[#9DACCC] mb-2 px-2">
                <span class="font-mono">{{ formatTime(currentTime) }}</span>
                <span class="font-mono">{{ formatTime(audioDuration) }}</span>
              </div>
              <div class="relative h-2 bg-[#1a1f35]/50 rounded-full overflow-hidden cursor-pointer group" @click="seekTo">
                <div 
                  class="absolute inset-y-0 left-0 bg-gradient-to-r from-[#485F88] to-[#9DACCC] rounded-full transition-all duration-100"
                  :style="{ width: (currentTime / audioDuration * 100) + '%' }"
                ></div>
                <div 
                  class="absolute top-1/2 -translate-y-1/2 w-4 h-4 bg-white rounded-full shadow-lg opacity-0 group-hover:opacity-100 transition-opacity"
                  :style="{ left: `calc(${currentTime / audioDuration * 100}% - 8px)` }"
                ></div>
              </div>
            </div>
            
            <!-- 播放控制 -->
            <div class="flex items-center justify-center gap-6">
               <button class="p-2 text-[#9DACCC] hover:text-white hover:bg-[#485F88]/30 rounded-lg transition" title="快退">
                 <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                   <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12.066 11.2a1 1 0 000 1.6l5.334 4A1 1 0 0019 16V8a1 1 0 00-1.6-.8l-5.333 4zM4.066 11.2a1 1 0 000 1.6l5.334 4A1 1 0 0011 16V8a1 1 0 00-1.6-.8l-5.334 4z" />
                 </svg>
               </button>
               <button 
                 @click="togglePlay" 
                 class="w-20 h-20 rounded-full bg-gradient-to-br from-[#485F88] to-[#9DACCC] text-white flex items-center justify-center hover:from-[#9DACCC] hover:to-[#485F88] transition-all duration-300 shadow-xl shadow-[#485F88]/30 hover:scale-110 hover:shadow-2xl hover:shadow-[#485F88]/50"
               >
                 <svg v-if="!isPlaying" class="w-8 h-8 ml-1" fill="currentColor" viewBox="0 0 20 20">
                   <path d="M6.3 2.841A1.5 1.5 0 004 4.11V15.89a1.5 1.5 0 002.3 1.269l9.344-5.89a1.5 1.5 0 000-2.538L6.3 2.84z" />
                 </svg>
                 <svg v-else class="w-8 h-8" fill="currentColor" viewBox="0 0 20 20">
                   <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zM7 8a1 1 0 012 0v4a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v4a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
                 </svg>
               </button>
               <button class="p-2 text-[#9DACCC] hover:text-white hover:bg-[#485F88]/30 rounded-lg transition" title="快进">
                 <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                   <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.933 12.8a1 1 0 000-1.6L6.6 7.2A1 1 0 005 8v8a1 1 0 001.6.8l5.333-4zM19.933 12.8a1 1 0 000-1.6l-5.333-4A1 1 0 0013 8v8a1 1 0 001.6.8l5.333-4z" />
                 </svg>
               </button>
            </div>
          </div>
        </div>

        <!-- 底部：轨道/编辑器 (Feature 7) -->
        <div class="flex-1 bg-[#0F111A] flex flex-col border-t border-[#485F88]/30">
          <!-- 工具栏 -->
          <div class="flex items-center justify-between p-4 border-b border-[#485F88]/20 bg-[#121524]/50">
            <div class="flex items-center gap-3">
              <button class="text-xs font-medium text-white bg-gradient-to-r from-[#485F88] to-[#9DACCC] px-4 py-2 rounded-lg hover:from-[#9DACCC] hover:to-[#485F88] transition flex items-center gap-2 shadow-lg shadow-[#485F88]/20">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                </svg>
                添加轨道
              </button>
              <div class="h-5 w-px bg-[#485F88]/30"></div>
              <div class="flex items-center gap-2">
                <button class="p-2 text-[#9DACCC] hover:text-white hover:bg-[#485F88]/30 rounded transition" title="剪切">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.121 14.121L19 19m-7-7l7-7m-7 7l-2.879 2.879M12 12L9.121 9.121m0 5.758a3 3 0 10-4.243 4.243 3 3 0 004.243-4.243zm0-5.758a3 3 0 10-4.243-4.243 3 3 0 004.243 4.243z" />
                  </svg>
                </button>
                <button class="p-2 text-[#9DACCC] hover:text-white hover:bg-[#485F88]/30 rounded transition" title="复制">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                  </svg>
                </button>
                <button class="p-2 text-[#9DACCC] hover:text-white hover:bg-[#485F88]/30 rounded transition" title="撤销">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6" />
                  </svg>
                </button>
              </div>
            </div>
            <div class="flex items-center gap-2 text-xs text-[#9DACCC]">
              <span>缩放:</span>
              <button class="px-2 py-1 bg-[#1a1f35]/50 rounded hover:bg-[#485F88]/30">-</button>
              <span class="w-12 text-center">100%</span>
              <button class="px-2 py-1 bg-[#1a1f35]/50 rounded hover:bg-[#485F88]/30">+</button>
            </div>
          </div>
          
          <!-- 时间轴和轨道 -->
          <div class="flex-1 overflow-auto p-4">
            <!-- 时间轴标尺 -->
            <div class="h-8 mb-2 flex items-center border-b border-[#485F88]/30 relative">
              <div class="absolute inset-0 flex">
                <div v-for="i in 20" :key="i" class="flex-1 border-l border-[#485F88]/20 relative">
                  <span class="absolute -top-5 left-0 text-[10px] text-[#9DACCC]/60 transform -translate-x-1/2">{{ i * 5 }}s</span>
                </div>
              </div>
            </div>
            
            <!-- 轨道列表 -->
            <div class="space-y-3">
              <div class="h-20 bg-[#1a1f35]/30 rounded-lg border border-[#485F88]/20 flex items-center px-4 relative group hover:border-[#485F88]/50 transition">
                <div class="w-28 text-xs text-[#9DACCC] border-r border-[#485F88]/20 mr-4 flex items-center gap-2">
                  <div class="w-2 h-2 rounded-full bg-blue-500"></div>
                  <span class="font-medium">主人声 A</span>
                </div>
                <div class="flex-1 h-12 rounded overflow-hidden relative cursor-pointer">
                  <div class="absolute inset-y-0 left-0 bg-gradient-to-r from-blue-500/30 to-blue-400/20 w-1/3 border-r-2 border-blue-400 flex items-center justify-center">
                    <div class="text-[10px] text-blue-300 font-mono">00:00-20:00</div>
                  </div>
                  <div class="absolute inset-y-0 left-1/3 bg-transparent w-12 border-l border-r border-dashed border-[#485F88]/40 flex items-center justify-center">
                    <span class="text-[9px] text-[#9DACCC]/50">静音</span>
                  </div>
                  <div class="absolute inset-y-0 left-[calc(33.33%+3rem)] right-0 bg-gradient-to-r from-blue-500/30 to-blue-400/20 flex items-center justify-center">
                    <div class="text-[10px] text-blue-300 font-mono">20:12-60:00</div>
                  </div>
                </div>
              </div>
              
              <div class="h-20 bg-[#1a1f35]/30 rounded-lg border border-[#485F88]/20 flex items-center px-4 relative group hover:border-[#485F88]/50 transition">
                <div class="w-28 text-xs text-[#9DACCC] border-r border-[#485F88]/20 mr-4 flex items-center gap-2">
                  <div class="w-2 h-2 rounded-full bg-orange-500"></div>
                  <span class="font-medium">背景音乐</span>
                </div>
                <div class="flex-1 h-12 rounded overflow-hidden relative cursor-pointer">
                  <div class="absolute inset-0 bg-gradient-to-r from-orange-500/20 via-orange-400/15 to-orange-500/20 flex items-center justify-center">
                    <div class="text-[10px] text-orange-300 font-mono">00:00-60:00</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>

      <!-- 4. 右侧：AI 智能工具箱 (Feature 3, 4, 5) -->
      <aside class="w-96 bg-[#121524] border-l border-[#485F88]/30 flex flex-col">
        <!-- 工具导航 Tabs -->
        <div class="flex border-b border-[#485F88]/30">
          <button 
            v-for="tab in toolTabs" 
            :key="tab.id"
            @click="activeToolTab = tab.id"
            class="flex-1 py-3 text-sm font-medium transition relative"
            :class="activeToolTab === tab.id ? 'text-white' : 'text-[#9DACCC] hover:text-white'"
          >
            {{ tab.name }}
            <div v-if="activeToolTab === tab.id" class="absolute bottom-0 left-0 right-0 h-0.5 bg-blue-500"></div>
          </button>
        </div>

        <div class="flex-1 overflow-y-auto p-6 space-y-8">
          
          <!-- Tab 1: 智能剪辑 (Feature 3) -->
          <div v-if="activeToolTab === 'edit'" class="space-y-6 animate-fadeIn">
            <!-- 语音分析 -->
            <section>
              <h3 class="text-sm font-bold text-white mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-purple-500 rounded-full"></span>
                语音转写与分析
              </h3>
              <div class="space-y-3">
                <div class="flex items-center justify-between p-3 bg-[#1a1f35]/50 rounded-lg">
                  <span class="text-sm text-white">说话人分离</span>
                  <button class="w-10 h-5 bg-blue-600 rounded-full relative transition"><div class="w-3 h-3 bg-white rounded-full absolute right-1 top-1"></div></button>
                </div>
                <div class="flex items-center justify-between p-3 bg-[#1a1f35]/50 rounded-lg">
                  <span class="text-sm text-white">智能情绪提取</span>
                  <button class="w-10 h-5 bg-gray-600 rounded-full relative transition"><div class="w-3 h-3 bg-white rounded-full absolute left-1 top-1"></div></button>
                </div>
                <!-- 新增：转写语言选择 -->
                <div class="flex items-center justify-between p-3 bg-[#1a1f35]/50 rounded-lg">
                  <span class="text-sm text-white">转写语言</span>
                  <select class="bg-[#1a1f35] text-xs text-white rounded px-2 py-1 border border-[#485F88]/30 focus:ring-1 focus:ring-[#485F88]">
                     <option>自动识别</option>
                     <option>中文</option>
                     <option>English</option>
                     <option>中英混合</option>
                  </select>
                </div>
                <button class="w-full py-2 bg-gradient-to-r from-[#485F88] to-[#9DACCC] hover:from-[#9DACCC] hover:to-[#9DACCC] text-sm text-white rounded transition">开始转写</button>
              </div>
            </section>

            <!-- 脚本优化 -->
            <section>
              <h3 class="text-sm font-bold text-white mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-blue-500 rounded-full"></span>
                脚本优化
              </h3>
              <div class="grid grid-cols-2 gap-2">
                <button class="p-2 bg-[#1a1f35]/50 border border-[#485F88]/30 rounded text-xs text-white hover:border-[#9DACCC] hover:text-[#9DACCC] transition" title="自动修正错别字、剔除口语化冗余">去口语冗余</button>
                <button class="p-2 bg-[#1a1f35]/50 border border-[#485F88]/30 rounded text-xs text-white hover:border-[#9DACCC] hover:text-[#9DACCC] transition" title="检测逻辑断层，推荐衔接句">逻辑纠错</button>
                <button class="p-2 bg-[#1a1f35]/50 border border-[#485F88]/30 rounded text-xs text-white hover:border-[#9DACCC] hover:text-[#9DACCC] transition" title="提取核心片段生成精华版">一键精华提取</button>
                <button class="p-2 bg-[#1a1f35]/50 border border-[#485F88]/30 rounded text-xs text-white hover:border-[#9DACCC] hover:text-[#9DACCC] transition" title="根据内容推荐背景音乐">BGM智能匹配</button>
              </div>
            </section>

             <!-- TTS 生成 (Feature 3.5) -->
             <section>
              <h3 class="text-sm font-bold text-white mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-pink-500 rounded-full"></span>
                TTS 语音生成
              </h3>
               <div class="space-y-3">
                 <div class="grid grid-cols-2 gap-2">
                    <button class="p-2 bg-[#1a1f35]/50 border border-[#485F88]/30 rounded text-xs text-white hover:border-pink-500 hover:text-pink-400 transition flex items-center justify-center gap-1">
                      <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" /></svg>
                      声线克隆
                    </button>
                     <button class="p-2 bg-[#1a1f35]/50 border border-[#485F88]/30 rounded text-xs text-white hover:border-pink-500 hover:text-pink-400 transition">多角色生成</button>
                 </div>
               </div>
            </section>
            
            <!-- 音频优化 -->
             <section>
              <h3 class="text-sm font-bold text-white mb-3 flex items-center gap-2">
                <span class="w-1 h-4 bg-green-500 rounded-full"></span>
                音频画质增强
              </h3>
              <div class="space-y-4">
                <div class="space-y-1">
                  <div class="flex justify-between text-xs text-[#9DACCC]"><span>智能降噪</span><span>80%</span></div>
                  <div class="h-1 bg-[#1a1f35]/50 rounded-full overflow-hidden"><div class="w-[80%] h-full bg-green-500"></div></div>
                </div>
                <div class="space-y-1">
                  <div class="flex justify-between text-xs text-[#9DACCC]"><span>音量均衡</span><span>On</span></div>
                   <div class="flex items-center gap-2">
                      <button class="text-[10px] px-2 py-0.5 rounded bg-[#1a1f35]/50 text-white hover:bg-[#485F88]/30">人声增强</button>
                      <button class="text-[10px] px-2 py-0.5 rounded bg-[#1a1f35]/50 text-white hover:bg-[#485F88]/30">去回声</button>
                   </div>
                </div>
              </div>
            </section>
          </div>

          <!-- Tab 2: 内容增值 (Feature 4) -->
          <div v-if="activeToolTab === 'enhance'" class="space-y-6 animate-fadeIn">
            <div class="p-4 bg-gradient-to-br from-purple-900/20 to-blue-900/20 border border-purple-500/30 rounded-lg">
              <h4 class="text-sm font-bold text-white mb-2">AI 文案生成</h4>
               <div class="grid grid-cols-2 gap-2 mb-3">
                  <label class="flex items-center gap-2 text-xs text-white cursor-pointer">
                    <input type="checkbox" checked class="rounded bg-[#1a1f35] border-[#485F88]/30 text-purple-600 focus:ring-purple-500">
                    Show Notes
                  </label>
                  <label class="flex items-center gap-2 text-xs text-white cursor-pointer">
                    <input type="checkbox" class="rounded bg-[#1a1f35] border-[#485F88]/30 text-purple-600 focus:ring-purple-500">
                    小红书文案
                  </label>
                   <label class="flex items-center gap-2 text-xs text-white cursor-pointer">
                    <input type="checkbox" class="rounded bg-[#1a1f35] border-[#485F88]/30 text-purple-600 focus:ring-purple-500">
                    公众号文章
                  </label>
                   <label class="flex items-center gap-2 text-xs text-white cursor-pointer">
                    <input type="checkbox" class="rounded bg-[#1a1f35] border-[#485F88]/30 text-purple-600 focus:ring-purple-500">
                    视频字幕
                  </label>
               </div>
              <button class="w-full py-2 bg-purple-600 hover:bg-purple-700 text-white text-xs rounded transition shadow-lg shadow-purple-500/20">一键生成</button>
            </div>

            <!-- 交互式播客 (Feature 4.3) -->
            <section>
               <h4 class="text-sm font-bold text-white mb-2">交互式播客生成</h4>
               <div class="space-y-2">
                  <button class="w-full p-3 bg-[#1a1f35]/50 border border-[#485F88]/30 rounded text-left hover:border-[#9DACCC] transition group">
                     <div class="text-xs text-white group-hover:text-[#9DACCC] font-medium mb-1">实时问答配置</div>
                     <div class="text-[10px] text-[#9DACCC]/80">集成大模型API，设置互动节点</div>
                  </button>
                   <button class="w-full p-3 bg-[#1a1f35]/50 border border-[#485F88]/30 rounded text-left hover:border-[#9DACCC] transition group">
                     <div class="text-xs text-white group-hover:text-[#9DACCC] font-medium mb-1">分支剧情设计</div>
                     <div class="text-[10px] text-[#9DACCC]/80">预设2-3个主题分支，听众选择后无缝衔接</div>
                  </button>
               </div>
            </section>

            <div class="space-y-2">
              <h4 class="text-sm font-bold text-white">视频化转化</h4>
              <div class="grid grid-cols-3 gap-2">
                 <div class="aspect-[9/16] bg-[#1a1f35]/50 rounded border border-[#485F88]/30 hover:border-[#9DACCC] cursor-pointer flex items-center justify-center text-xs text-[#9DACCC] flex-col gap-1">
                    <span>9:16</span>
                    <span class="text-[8px] text-[#9DACCC]/70">抖音/Shorts</span>
                 </div>
                 <div class="aspect-[16/9] bg-[#1a1f35]/50 rounded border border-[#485F88]/30 hover:border-[#9DACCC] cursor-pointer flex items-center justify-center text-xs text-[#9DACCC] flex-col gap-1">
                    <span>16:9</span>
                    <span class="text-[8px] text-[#9DACCC]/70">B站/YT</span>
                 </div>
                 <div class="aspect-square bg-[#1a1f35]/50 rounded border border-[#485F88]/30 hover:border-[#9DACCC] cursor-pointer flex items-center justify-center text-xs text-[#9DACCC]">1:1</div>
              </div>
              <button class="w-full py-2 mt-2 bg-[#1a1f35]/50 border border-[#485F88]/30 hover:border-[#9DACCC] hover:text-white text-[#9DACCC] text-xs rounded transition">添加可视化波形/字幕模板</button>
            </div>
          </div>

          <!-- Tab 3: 导出分发 (Feature 5) -->
          <div v-if="activeToolTab === 'export'" class="space-y-6 animate-fadeIn">
            <div class="space-y-3">
              <label class="block text-sm text-[#9DACCC]">导出格式</label>
              <select class="w-full bg-[#1a1f35] border border-[#485F88]/30 text-white text-sm rounded p-2 focus:ring-2 focus:ring-[#485F88] outline-none">
                <option>MP3 (320kbps)</option>
                <option>WAV (无损)</option>
                <option>MP4 (1080P)</option>
              </select>
            </div>
             <div class="space-y-3">
              <label class="block text-sm text-[#9DACCC]">分发平台</label>
              <div class="grid grid-cols-4 gap-2">
                <div class="w-10 h-10 rounded bg-white flex items-center justify-center cursor-pointer opacity-50 hover:opacity-100 transition" title="Apple Podcast">🍎</div>
                <div class="w-10 h-10 rounded bg-green-500 flex items-center justify-center cursor-pointer opacity-50 hover:opacity-100 transition" title="Spotify">🟢</div>
                <div class="w-10 h-10 rounded bg-red-500 flex items-center justify-center cursor-pointer opacity-50 hover:opacity-100 transition" title="YouTube">▶️</div>
                <div class="w-10 h-10 rounded bg-orange-500 flex items-center justify-center cursor-pointer opacity-50 hover:opacity-100 transition" title="小宇宙">🪐</div>
              </div>
            </div>
            <button class="w-full py-3 bg-gradient-to-r from-[#485F88] to-[#9DACCC] hover:from-[#9DACCC] hover:to-[#9DACCC] text-white font-bold rounded-lg shadow-lg shadow-[#485F88]/30 transition transform hover:-translate-y-0.5">
              导出并分发
            </button>
          </div>

        </div>
      </aside>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

// 状态管理
const currentProject = ref({ name: 'Vol.24 科技创业新风向', id: 1 })
const isPlaying = ref(false)
const currentTime = ref(45)
const audioDuration = ref(3600)

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
  const percentage = x / rect.width
  currentTime.value = Math.floor(audioDuration.value * percentage)
}

const triggerFileUpload = () => {
  fileInput.value?.click()
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

onMounted(() => {
  if (route.params.id) {
    // Load project data
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
  width: 6px;
  height: 6px;
}
::-webkit-scrollbar-track {
  background: transparent;
}
::-webkit-scrollbar-thumb {
  background: #485F88;
  border-radius: 3px;
}
::-webkit-scrollbar-thumb:hover {
  background: #9DACCC;
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
</style>

