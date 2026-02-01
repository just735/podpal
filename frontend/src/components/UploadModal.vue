﻿<template>
  <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm" @click.self="$emit('close')">
    <div class="glass-card rounded-2xl p-8 max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto bg-gradient-to-br from-pink-50/95 to-purple-50/95 border-2 border-pink-200/60 backdrop-blur-xl">
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-2xl font-bold bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent">上传素材</h2>
        <button
          @click="$emit('close')"
          class="p-2 hover:bg-pink-100 rounded-lg transition"
        >
          <svg class="w-6 h-6 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <!-- 拖拽上传区域 -->
      <div
        @drop="handleDrop"
        @dragover.prevent
        @dragenter.prevent
        class="border-2 border-dashed border-pink-200 rounded-xl p-12 text-center mb-6 hover:border-pink-400 transition bg-white"
        :class="{ 'border-pink-400 bg-pink-50': isDragging }"
      >
        <input
          ref="fileInput"
          type="file"
          multiple
          accept="audio/*,video/*"
          @change="handleFileSelect"
          class="hidden"
        />
        <svg class="w-16 h-16 text-pink-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
        </svg>
        <p class="text-gray-900 mb-2">拖拽文件到此处或</p>
        <button
          @click="fileInput?.click()"
          class="px-6 py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition"
        >
          选择文件
        </button>
        <p class="text-sm text-gray-600 mt-4">支持 MP3, WAV, M4A, FLAC, MP4, MOV 等格式</p>
        <p class="text-xs text-gray-600 mt-2">最大文件大小 300MB</p>
      </div>

      <!-- 文件列表 -->
      <div v-if="files.length > 0" class="space-y-2 mb-6">
        <div
          v-for="(file, index) in files"
          :key="index"
          class="flex items-center justify-between p-4 bg-white border border-pink-200 rounded-lg"
        >
          <div class="flex-1">
            <p class="text-gray-900 font-medium">{{ file.name }}</p>
            <p class="text-sm text-gray-600">{{ formatFileSize(file.size) }}</p>
          </div>
          <div class="flex items-center gap-4">
            <div v-if="uploadProgress[index] > 0" class="w-32">
              <div class="h-2 bg-pink-100 rounded-full overflow-hidden">
                <div
                  class="h-full bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] transition-all"
                  :style="{ width: uploadProgress[index] + '%' }"
                ></div>
              </div>
              <p class="text-xs text-gray-600 mt-1">{{ uploadProgress[index] }}%</p>
            </div>
            <button
              @click="removeFile(index)"
              class="p-2 hover:bg-red-500/30 rounded-lg transition"
            >
              <svg class="w-5 h-5 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>
      </div>

      <!-- 操作按钮 -->
      <div class="flex justify-end gap-4">
        <button
          @click="$emit('close')"
          class="px-6 py-2 border border-pink-200 text-gray-600 rounded-lg hover:bg-pink-50 hover:border-pink-300 hover:text-pink-600 transition"
        >
          取消
        </button>
        <button
          @click="handleUpload"
          :disabled="files.length === 0 || uploading"
          class="px-6 py-2 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg hover:shadow-lg hover:scale-105 transition disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ uploading ? '上传中...' : '开始上传' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useMaterialStore } from '../stores/material'

const emit = defineEmits(['close', 'uploaded'])

const materialStore = useMaterialStore()
const fileInput = ref(null)
const files = ref([])
const uploadProgress = ref({})
const isDragging = ref(false)
const uploading = ref(false)

const handleDrop = (e) => {
  isDragging.value = false
  const droppedFiles = Array.from(e.dataTransfer.files)
  addFiles(droppedFiles)
}

const handleFileSelect = (e) => {
  const selectedFiles = Array.from(e.target.files)
  addFiles(selectedFiles)
}

const addFiles = (newFiles) => {
  const validFiles = newFiles.filter(file => {
    const validTypes = ['audio/', 'video/']
    return validTypes.some(type => file.type.startsWith(type)) && file.size <= 300 * 1024 * 1024
  })
  files.value.push(...validFiles)
  validFiles.forEach((_, index) => {
    uploadProgress.value[files.value.length - validFiles.length + index] = 0
  })
}

const removeFile = (index) => {
  files.value.splice(index, 1)
  delete uploadProgress.value[index]
}

const formatFileSize = (bytes) => {
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
}

const handleUpload = async () => {
  uploading.value = true
  
  for (let i = 0; i < files.value.length; i++) {
    const file = files.value[i]
    uploadProgress.value[i] = 0
    
    const result = await materialStore.uploadMaterial(file, (progress) => {
      uploadProgress.value[i] = progress
    })
    
    if (result.success) {
      uploadProgress.value[i] = 100
    }
  }
  
  uploading.value = false
  emit('uploaded')
}
</script>
