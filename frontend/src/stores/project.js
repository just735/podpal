import { defineStore } from 'pinia'
import { ref } from 'vue'
import api from '../services/api'

// 示例项目数据
const sampleProjects = [
  {
    id: 1,
    name: '科技创业新风向',
    description: '探讨当前科技创业领域的最新趋势和机会',
    status: 'processing',
    podcastType: 'knowledge',
    duration: 3600,
    createdAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
    updatedAt: new Date(Date.now() - 1 * 60 * 60 * 1000).toISOString(),
    transcript: [],
    clips: []
  },
  {
    id: 2,
    name: '深夜陪伴电台',
    description: '温暖的声音陪伴你度过每一个夜晚',
    status: 'completed',
    podcastType: 'companion',
    duration: 2400,
    createdAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString(),
    updatedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
    transcript: [],
    clips: []
  },
  {
    id: 3,
    name: '创业故事访谈录',
    description: '与成功创业者深度对话，分享创业路上的经验与思考',
    status: 'draft',
    podcastType: 'interview',
    duration: 5400,
    createdAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString(),
    updatedAt: new Date(Date.now() - 30 * 60 * 1000).toISOString(),
    transcript: [],
    clips: []
  },
  {
    id: 4,
    name: '每日新闻速递',
    description: '快速了解今日重要新闻和热点话题',
    status: 'processing',
    podcastType: 'knowledge',
    duration: 1800,
    createdAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString(),
    updatedAt: new Date(Date.now() - 3 * 60 * 60 * 1000).toISOString(),
    transcript: [],
    clips: []
  },
  {
    id: 5,
    name: '音乐心情分享',
    description: '分享好音乐，聊聊心情故事',
    status: 'draft',
    podcastType: 'companion',
    duration: 3000,
    createdAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString(),
    updatedAt: new Date(Date.now() - 6 * 24 * 60 * 60 * 1000).toISOString(),
    transcript: [],
    clips: []
  }
]

export const useProjectStore = defineStore('project', () => {
  const projects = ref([])
  const currentProject = ref(null)
  const loading = ref(false)

  // 获取项目列表
  async function fetchProjects() {
    loading.value = true
    try {
      const response = await api.get('/projects')
      projects.value = response.data && response.data.length > 0 ? response.data : sampleProjects
      return { success: true }
    } catch (error) {
      // 如果 API 调用失败，使用示例数据
      projects.value = sampleProjects
      return { success: true }
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
      // 如果 API 调用失败，从示例数据中查找
      const project = sampleProjects.find(p => p.id === parseInt(id))
      if (project) {
        currentProject.value = project
        return { success: true }
      }
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
      // 如果 API 调用失败，仍然从本地删除（适用于示例数据）
      projects.value = projects.value.filter(p => p.id !== id)
      if (currentProject.value?.id === id) {
        currentProject.value = null
      }
      return { success: true }
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

