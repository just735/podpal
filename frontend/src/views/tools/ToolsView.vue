<template>
  <div class="min-h-screen bg-gradient-to-br from-[#121524] via-[#1a1f35] to-[#121524] pt-24 pb-12 px-6">
    <div class="container mx-auto max-w-7xl">
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-white mb-2">工具箱</h1>
        <p class="text-[#9DACCC]">使用辅助工具提升创作效率</p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- 音频裁剪 -->
        <div class="glass-card rounded-xl p-6 cursor-pointer hover:scale-105 transition-transform hover:shadow-lg">
          <div class="flex items-center gap-4 mb-4">
            <div class="w-12 h-12 bg-[#1a1f35]/50 rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-[#9DACCC]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.121 14.121L19 19m-7-7l7-7m-7 7l-2.879 2.879M12 12L9.121 9.121m0 5.758a3 3 0 10-4.243 4.243 3 3 0 004.243-4.243zm0-5.758a3 3 0 10-4.243-4.243 3 3 0 004.243 4.243z" />
              </svg>
            </div>
            <h3 class="text-lg font-semibold text-white">音频裁剪</h3>
          </div>
          <p class="text-sm text-[#9DACCC]">快速裁剪和拼接音频文件</p>
        </div>

        <!-- 格式转换 -->
        <div class="glass-card rounded-xl p-6 cursor-pointer hover:scale-105 transition-transform hover:shadow-lg">
          <div class="flex items-center gap-4 mb-4">
            <div class="w-12 h-12 bg-[#1a1f35]/50 rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-[#9DACCC]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
            </div>
            <h3 class="text-lg font-semibold text-white">格式转换</h3>
          </div>
          <p class="text-sm text-[#9DACCC]">转换音频和视频格式</p>
        </div>

        <!-- 字幕编辑 -->
        <div class="glass-card rounded-xl p-6 cursor-pointer hover:scale-105 transition-transform hover:shadow-lg">
          <div class="flex items-center gap-4 mb-4">
            <div class="w-12 h-12 bg-[#1a1f35]/50 rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-[#9DACCC]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
            </div>
            <h3 class="text-lg font-semibold text-white">字幕编辑</h3>
          </div>
          <p class="text-sm text-[#9DACCC]">手动修改和调整字幕/</p>
        </div>

        <!-- 背景音乐�?-->
        <div class="glass-card rounded-xl p-6 cursor-pointer hover:scale-105 transition-transform hover:shadow-lg">
          <div class="flex items-center gap-4 mb-4">
            <div class="w-12 h-12 bg-[#1a1f35]/50 rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-[#9DACCC]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" />
              </svg>
            </div>
            <h3 class="text-lg font-semibold text-white">背景音乐</h3>
          </div>
          <p class="text-sm text-[#9DACCC]">免费商用背景音乐资源</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
// 工具箱页面，展示各种辅助工具
</script>

