<template>
  <div class="min-h-screen bg-white pt-24 pb-12 px-6">
    <div class="container mx-auto max-w-7xl">
      <div class="mb-10 text-center">
        <h1 class="text-4xl md:text-5xl font-bold mb-3 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">解决方案</h1>
        <p class="text-gray-600">面向播客与内容创作者的全流程智能化工具链</p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
        <div class="glass-card rounded-2xl p-6 bg-gradient-to-br from-pink-50/50 to-purple-50/50 border-2 border-pink-200/60">
          <div class="flex items-center justify-between mb-3">
            <h3 class="text-lg font-semibold text-gray-900">博客/文章 → 短视频</h3>
            <span class="text-xs px-2 py-1 rounded bg-pink-100 text-pink-700 border border-pink-200/60">自动化</span>
          </div>
          <p class="text-sm text-gray-600 mb-4">从长篇文本自动生成口播与视觉素材，生成多平台格式的短视频。</p>
          <div class="flex items-center gap-2 text-xs text-gray-600">
            <span class="px-2 py-1 rounded bg-white border border-pink-200/60">文本转语音</span>
            <span class="px-2 py-1 rounded bg-white border border-pink-200/60">智能剪辑</span>
            <span class="px-2 py-1 rounded bg-white border border-pink-200/60">多平台导出</span>
          </div>
        </div>
        <div class="glass-card rounded-2xl p-6 bg-gradient-to-br from-orange-50/50 to-pink-50/50 border-2 border-orange-200/60">
          <div class="flex items-center justify-between mb-3">
            <h3 class="text-lg font-semibold text-gray-900">播客 → 多平台分发</h3>
            <span class="text-xs px-2 py-1 rounded bg-orange-100 text-orange-700 border border-orange-200/60">一键</span>
          </div>
          <p class="text-sm text-gray-600 mb-4">从整期播客中提取高光片段，自动生成文案与封面，适配各平台比例。</p>
          <div class="flex items-center gap-2 text-xs text-gray-600">
            <span class="px-2 py-1 rounded bg-white border border-orange-200/60">转写/字幕</span>
            <span class="px-2 py-1 rounded bg-white border border-orange-200/60">内容增值</span>
            <span class="px-2 py-1 rounded bg-white border border-orange-200/60">导出分发</span>
          </div>
        </div>
        <div class="glass-card rounded-2xl p-6 bg-gradient-to-br from-cyan-50/50 to-blue-50/50 border-2 border-cyan-200/60">
          <div class="flex items-center justify-between mb-3">
            <h3 class="text-lg font-semibold text-gray-900">企业培训 → 片段库</h3>
            <span class="text-xs px-2 py-1 rounded bg-cyan-100 text-cyan-700 border border-cyan-200/60">沉淀</span>
          </div>
          <p class="text-sm text-gray-600 mb-4">把长视频培训内容切片成可检索的知识点，支持标签与权限管理。</p>
          <div class="flex items-center gap-2 text-xs text-gray-600">
            <span class="px-2 py-1 rounded bg-white border border-cyan-200/60">智能切片</span>
            <span class="px-2 py-1 rounded bg-white border border-cyan-200/60">标签检索</span>
            <span class="px-2 py-1 rounded bg-white border border-cyan-200/60">团队协作</span>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-12">
        <div class="glass-card rounded-2xl p-6 bg-gradient-to-br from-pink-50/50 to-purple-50/50 border-2 border-pink-200/60">
          <h3 class="text-xl font-bold text-gray-900 mb-3">核心能力</h3>
          <ul class="space-y-2 text-gray-700 text-sm">
            <li class="flex items-center gap-2"><span class="text-green-500">✔</span> 多语言转写与字幕生成</li>
            <li class="flex items-center gap-2"><span class="text-green-500">✔</span> 智能剪辑与高光提取</li>
            <li class="flex items-center gap-2"><span class="text-green-500">✔</span> 音频优化（降噪/均衡）</li>
            <li class="flex items-center gap-2"><span class="text-green-500">✔</span> AI 文案与多平台内容模板</li>
            <li class="flex items-center gap-2"><span class="text-green-500">✔</span> 批量导出与平台映射</li>
          </ul>
        </div>
        <div class="glass-card rounded-2xl p-6 bg-gradient-to-br from-blue-50/50 to-cyan-50/50 border-2 border-cyan-200/60">
          <h3 class="text-xl font-bold text-gray-900 mb-3">典型流程</h3>
          <ol class="space-y-2 text-gray-700 text-sm list-decimal ml-5">
            <li>导入素材或链接</li>
            <li>转写与校对</li>
            <li>智能剪辑提取片段</li>
            <li>内容增值与模板生成</li>
            <li>导出分发到目标平台</li>
          </ol>
        </div>
      </div>

      <div class="text-center space-y-4">
        <div class="flex flex-wrap items-center justify-center gap-4">
          <RouterLink to="/clip-studio" class="px-8 py-3 rounded-xl bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white hover:shadow-lg hover:scale-105 transition inline-flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            开始使用剪辑工作台
          </RouterLink>
          <span class="text-gray-600">或</span>
          <RouterLink to="/materials" class="px-8 py-3 rounded-xl border-2 border-pink-200/60 text-pink-700 bg-white hover:bg-pink-50 transition inline-flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
            </svg>
            上传你的素材
          </RouterLink>
          <span class="text-gray-600">或</span>
          <RouterLink to="/projects" class="px-8 py-3 rounded-xl border-2 border-purple-200/60 text-purple-700 bg-white hover:bg-purple-50 transition inline-flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            创建新项目
          </RouterLink>
        </div>
        <div class="text-sm text-gray-500 mt-4">
          <p>💡 提示：你可以从任意页面快速访问这些功能</p>
        </div>
      </div>
    </div>
  </div>
  </template>

<script setup>
import { RouterLink } from 'vue-router'
</script>
