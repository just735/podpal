import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '../services/api'

export const useUserStore = defineStore('user', () => {
  // 从localStorage恢复用户信息
  const savedUser = localStorage.getItem('user')
  const user = ref(savedUser ? JSON.parse(savedUser) : null)
  const token = ref(localStorage.getItem('token') || null)
  const isAuthenticated = computed(() => !!token.value)

  // 登录（模拟模式：直接设置用户状态，无需API调用）
  async function login(credentials) {
    // 模拟登录：直接设置用户状态
    const mockToken = 'mock_token_' + Date.now()
    // 从邮箱提取用户名，如果没有则使用默认值
    const email = credentials.email || 'user@example.com'
    const username = email.split('@')[0] || '用户'
    const mockUser = {
      id: 1,
      username: username,
      email: email,
      phone: credentials.phone || '',
      membershipType: '免费版',
      createdAt: new Date().toISOString()
    }
    
    token.value = mockToken
    user.value = mockUser
    localStorage.setItem('token', token.value)
    localStorage.setItem('user', JSON.stringify(mockUser))
    return { success: true }
    
    // 真实API调用（已注释，需要时取消注释）
    // try {
    //   const response = await api.post('/auth/login', credentials)
    //   token.value = response.data.token
    //   user.value = response.data.user
    //   localStorage.setItem('token', token.value)
    //   return { success: true }
    // } catch (error) {
    //   return { success: false, error: error.response?.data?.message || '登录失败' }
    // }
  }

  // 注册（模拟模式：直接设置用户状态，无需API调用）
  async function register(userData) {
    // 模拟注册：直接设置用户状态
    const mockToken = 'mock_token_' + Date.now()
    const mockUser = {
      id: 1,
      username: userData.username || '新用户',
      email: userData.email || 'user@example.com',
      phone: userData.phone || '',
      membershipType: '免费版',
      createdAt: new Date().toISOString()
    }
    
    token.value = mockToken
    user.value = mockUser
    localStorage.setItem('token', token.value)
    localStorage.setItem('user', JSON.stringify(mockUser))
    return { success: true }
    
    // 真实API调用（已注释，需要时取消注释）
    // try {
    //   const response = await api.post('/auth/register', userData)
    //   token.value = response.data.token
    //   user.value = response.data.user
    //   localStorage.setItem('token', token.value)
    //   return { success: true }
    // } catch (error) {
    //   return { success: false, error: error.response?.data?.message || '注册失败' }
    // }
  }

  // 登出
  function logout() {
    token.value = null
    user.value = null
    localStorage.removeItem('token')
    localStorage.removeItem('user')
  }

  // 获取用户信息
  async function fetchUserInfo() {
    // 模拟获取用户信息，直接返回当前user状态
    if (user.value) {
      return { success: true, data: user.value }
    }
    return { success: false, error: '用户未登录' }
  }

  return {
    user,
    token,
    isAuthenticated,
    login,
    register,
    logout,
    fetchUserInfo
  }
})
