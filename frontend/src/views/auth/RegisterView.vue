<template>
  <div class="min-h-screen flex items-center justify-center bg-white px-4 py-8">
    <div class="w-full max-w-md">
      <div class="glass-card rounded-2xl p-8 shadow-2xl bg-gradient-to-br from-pink-50/50 to-purple-50/50 border-2 border-pink-200/60">
        <div class="text-center mb-8">
          <h1 class="text-3xl font-bold bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] bg-clip-text text-transparent mb-2">创建账号</h1>
          <p class="text-gray-600">加入 PodPal，开启播客创作之旅</p>
        </div>

        <form @submit.prevent="handleRegister" class="space-y-6">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">用户名</label>
            <input
              v-model="form.username"
              type="text"
              required
              class="w-full px-4 py-3 bg-white border border-pink-200 rounded-lg text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-pink-300 focus:border-pink-300 transition"
              placeholder="请输入用户名"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">邮箱</label>
            <input
              v-model="form.email"
              type="email"
              required
              class="w-full px-4 py-3 bg-white border border-pink-200 rounded-lg text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-pink-300 focus:border-pink-300 transition"
              placeholder="请输入邮箱"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">手机号（可选）</label>
            <input
              v-model="form.phone"
              type="tel"
              class="w-full px-4 py-3 bg-white border border-pink-200 rounded-lg text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-pink-300 focus:border-pink-300 transition"
              placeholder="请输入手机号"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">密码</label>
            <input
              v-model="form.password"
              type="password"
              required
              minlength="6"
              class="w-full px-4 py-3 bg-white border border-pink-200 rounded-lg text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-pink-300 focus:border-pink-300 transition"
              placeholder="至少6位字符"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">确认密码</label>
            <input
              v-model="form.confirmPassword"
              type="password"
              required
              class="w-full px-4 py-3 bg-white border border-pink-200 rounded-lg text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-pink-300 focus:border-pink-300 transition"
              placeholder="请再次输入密码"
            />
          </div>

          <div>
            <label class="flex items-center">
              <input type="checkbox" v-model="form.agree" required class="mr-2" />
              <span class="text-sm text-gray-600">我已阅读并同意</span>
              <a href="#" class="text-sm text-pink-600 hover:text-pink-700 transition ml-1">《用户协议》</a>
              <span class="text-sm text-gray-600">和</span>
              <a href="#" class="text-sm text-pink-600 hover:text-pink-700 transition ml-1">《隐私政策》</a>
            </label>
          </div>

          <button
            type="submit"
            :disabled="loading || form.password !== form.confirmPassword"
            class="w-full py-3 bg-gradient-to-r from-[#FF6B9D] to-[#C084FC] text-white rounded-lg font-bold hover:shadow-lg hover:scale-105 transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ loading ? '跳转中...' : '注册' }}
          </button>
        </form>

        <div class="mt-6 text-center">
          <p class="text-sm text-gray-600">
            已有账号，
            <RouterLink to="/login" class="text-pink-600 hover:text-pink-700 font-medium transition">立即登录</RouterLink>
          </p>
        </div>

        <div v-if="error" class="mt-4 p-3 bg-red-500/20 border border-red-500/50 rounded-lg text-red-300 text-sm">
          {{ error }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../../stores/user'

const router = useRouter()
const userStore = useUserStore()

const form = ref({
  username: '',
  email: '',
  phone: '',
  password: '',
  confirmPassword: '',
  agree: false
})
const loading = ref(false)
const error = ref('')

async function handleRegister() {
  if (form.value.password !== form.value.confirmPassword) {
    error.value = '两次输入的密码不一致'
    return
  }

  loading.value = true
  error.value = ''
  
  await userStore.register({
    username: form.value.username,
    email: form.value.email,
    phone: form.value.phone,
    password: form.value.password
  })
  
  router.push('/dashboard')
  
  loading.value = false
}
</script>
