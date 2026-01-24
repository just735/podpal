<template>
  <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm" @click.self="$emit('close')">
    <div class="glass-card rounded-2xl p-8 max-w-lg w-full mx-4">
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-2xl font-bold text-white">新建项目</h2>
        <button
          @click="$emit('close')"
          class="p-2 hover:bg-[#485F88]/30 rounded-lg transition"
        >
          <svg class="w-6 h-6 text-[#9DACCC]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <form @submit.prevent="handleCreate" class="space-y-6">
        <div>
          <label class="block text-sm font-medium text-[#C0C9DB] mb-2">项目名称 *</label>
          <input
            v-model="form.name"
            type="text"
            required
            class="w-full px-4 py-3 bg-[#1a1f35] border border-[#485F88] rounded-lg text-white placeholder-[#9DACCC] focus:outline-none focus:ring-2 focus:ring-[#485F88] transition"
            placeholder="请输入项目名称"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-[#C0C9DB] mb-2">项目描述</label>
          <textarea
            v-model="form.description"
            rows="3"
            class="w-full px-4 py-3 bg-[#1a1f35] border border-[#485F88] rounded-lg text-white placeholder-[#9DACCC] focus:outline-none focus:ring-2 focus:ring-[#485F88] transition resize-none"
            placeholder="请输入项目描述（可选）"
          ></textarea>
        </div>

        <div>
          <label class="block text-sm font-medium text-[#C0C9DB] mb-2">播客类型</label>
          <select
            v-model="form.podcastType"
            class="w-full px-4 py-3 bg-[#1a1f35] border border-[#485F88] rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-[#485F88] transition"
          >
            <option value="knowledge">知识类</option>
            <option value="companion">陪伴类</option>
            <option value="interview">访谈类</option>
            <option value="other">其他</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-[#C0C9DB] mb-2">关联素材（可选）</label>
          <select
            v-model="form.materialId"
            class="w-full px-4 py-3 bg-[#1a1f35] border border-[#485F88] rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-[#485F88] transition"
          >
            <option value="">不关联素材</option>
            <option v-for="material in materials" :key="material.id" :value="material.id">
              {{ material.name }}
            </option>
          </select>
        </div>

        <div class="flex justify-end gap-4">
          <button
            type="button"
            @click="$emit('close')"
            class="px-6 py-2 border border-[#485F88] text-[#9DACCC] rounded-lg hover:bg-[#485F88]/30 transition"
          >
            取消
          </button>
          <button
            type="submit"
            :disabled="loading"
            class="px-6 py-2 bg-[#485F88] text-white rounded-lg hover:bg-[#9DACCC] transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ loading ? '创建中...' : '创建项目' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useProjectStore } from '../stores/project'
import { useMaterialStore } from '../stores/material'

const emit = defineEmits(['close', 'created'])

const projectStore = useProjectStore()
const materialStore = useMaterialStore()
const materials = ref([])

const form = ref({
  name: '',
  description: '',
  podcastType: 'knowledge',
  materialId: ''
})
const loading = ref(false)

const handleCreate = async () => {
  loading.value = true
  
  const result = await projectStore.createProject({
    name: form.value.name,
    description: form.value.description,
    podcastType: form.value.podcastType,
    materialId: form.value.materialId || null,
    status: 'draft'
  })
  
  if (result.success) {
    emit('created', result.data)
  }
  
  loading.value = false
}

onMounted(async () => {
  await materialStore.fetchMaterials()
  materials.value = materialStore.materials
})
</script>
