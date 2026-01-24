import { defineStore } from 'pinia'
import { ref } from 'vue'
import api from '../services/api'

export const useMaterialStore = defineStore('material', () => {
  const materials = ref([])
  const loading = ref(false)
  const uploadProgress = ref(0)

  // 获取素材列表
  async function fetchMaterials(params = {}) {
    loading.value = true
    try {
      const response = await api.get('/materials', { params })
      materials.value = response.data
      return { success: true }
    } catch (error) {
      return { success: false, error: error.response?.data?.message || '获取素材列表失败' }
    } finally {
      loading.value = false
    }
  }

  // 上传素材
  async function uploadMaterial(file, onProgress) {
    loading.value = true
    uploadProgress.value = 0
    try {
      const formData = new FormData()
      formData.append('file', file)
      
      const response = await api.post('/materials/upload', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
        onUploadProgress: (progressEvent) => {
          const percentCompleted = Math.round(
            (progressEvent.loaded * 100) / progressEvent.total
          )
          uploadProgress.value = percentCompleted
          if (onProgress) onProgress(percentCompleted)
        }
      })
      materials.value.unshift(response.data)
      return { success: true, data: response.data }
    } catch (error) {
      return { success: false, error: error.response?.data?.message || '上传失败' }
    } finally {
      loading.value = false
      uploadProgress.value = 0
    }
  }

  // 删除素材
  async function deleteMaterial(id) {
    try {
      await api.delete(`/materials/${id}`)
      materials.value = materials.value.filter(m => m.id !== id)
      return { success: true }
    } catch (error) {
      return { success: false, error: error.response?.data?.message || '删除素材失败' }
    }
  }

  // 获取素材详情
  async function fetchMaterial(id) {
    try {
      const response = await api.get(`/materials/${id}`)
      return { success: true, data: response.data }
    } catch (error) {
      return { success: false, error: error.response?.data?.message || '获取素材详情失败' }
    }
  }

  return {
    materials,
    loading,
    uploadProgress,
    fetchMaterials,
    uploadMaterial,
    deleteMaterial,
    fetchMaterial
  }
})

