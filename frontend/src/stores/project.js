import { defineStore } from 'pinia'
import { ref } from 'vue'
import api from '../services/api'

export const useProjectStore = defineStore('project', () => {
  const projects = ref([])
  const currentProject = ref(null)
  const loading = ref(false)

  // 获取项目列表
  async function fetchProjects() {
    loading.value = true
    try {
      const response = await api.get('/projects')
      projects.value = response.data
      return { success: true }
    } catch (error) {
      return { success: false, error: error.response?.data?.message || '获取项目列表失败' }
    } finally {
      loading.value = false
    }
  }

  // 创建项目
  async function createProject(projectData) {
    loading.value = true
    try {
      const response = await api.post('/projects', projectData)
      projects.value.unshift(response.data)
      return { success: true, data: response.data }
    } catch (error) {
      return { success: false, error: error.response?.data?.message || '创建项目失败' }
    } finally {
      loading.value = false
    }
  }

  // 获取项目详情
  async function fetchProject(id) {
    loading.value = true
    try {
      const response = await api.get(`/projects/${id}`)
      currentProject.value = response.data
      return { success: true }
    } catch (error) {
      return { success: false, error: error.response?.data?.message || '获取项目详情失败' }
    } finally {
      loading.value = false
    }
  }

  // 更新项目
  async function updateProject(id, projectData) {
    try {
      const response = await api.put(`/projects/${id}`, projectData)
      const index = projects.value.findIndex(p => p.id === id)
      if (index !== -1) {
        projects.value[index] = response.data
      }
      if (currentProject.value?.id === id) {
        currentProject.value = response.data
      }
      return { success: true, data: response.data }
    } catch (error) {
      return { success: false, error: error.response?.data?.message || '更新项目失败' }
    }
  }

  // 删除项目
  async function deleteProject(id) {
    try {
      await api.delete(`/projects/${id}`)
      projects.value = projects.value.filter(p => p.id !== id)
      if (currentProject.value?.id === id) {
        currentProject.value = null
      }
      return { success: true }
    } catch (error) {
      return { success: false, error: error.response?.data?.message || '删除项目失败' }
    }
  }

  return {
    projects,
    currentProject,
    loading,
    fetchProjects,
    createProject,
    fetchProject,
    updateProject,
    deleteProject
  }
})

