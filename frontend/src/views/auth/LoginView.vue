<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#121524] via-[#1a1f35] to-[#121524] px-4">
    <div class="w-full max-w-md">
      <div class="glass-card rounded-2xl p-8 shadow-2xl">
        <div class="text-center mb-8">
          <h1 class="text-3xl font-bold text-white mb-2">PodPal</h1>
          <p class="text-[#9DACCC]">播客深度剪辑系统</p>
        </div>

        <form @submit.prevent="handleLogin" class="space-y-6">
          <div>
            <label class="block text-sm font-medium text-[#C0C9DB] mb-2">邮箱或手机号</label>
            <input
              v-model="form.email"
              type="text"
              required
              class="w-full px-4 py-3 bg-[#1a1f35] border border-[#485F88] rounded-lg text-white placeholder-[#9DACCC]/60 focus:outline-none focus:ring-2 focus:ring-[#485F88] transition"
              placeholder="请输入邮箱或手机号"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-[#C0C9DB] mb-2">密码</label> 
            <input
              v-model="form.password"
              type="password"
              required
              class="w-full px-4 py-3 bg-[#1a1f35] border border-[#485F88] rounded-lg text-white placeholder-[#9DACCC]/60 focus:outline-none focus:ring-2 focus:ring-[#485F88] transition"
              placeholder="请输入密码"
            />
          </div>

          <div class="flex items-center justify-between">
            <label class="flex items-center">
              <input type="checkbox" v-model="form.remember" class="mr-2" />
              <span class="text-sm text-[#9DACCC]">记住我</span>
            </label>
            <a href="#" class="text-sm text-white hover:text-[#9DACCC] transition">忘记密码</a>
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full py-3 bg-gradient-to-r from-[#485F88] to-[#9DACCC] text-white rounded-lg font-bold hover:from-[#9DACCC] hover:to-[#9DACCC] transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ loading ? '跳转中...' : '登录' }}
          </button>
        </form>

        <div class="mt-6 text-center">
          <p class="text-sm text-[#9DACCC]">
            还没有账号，
            <RouterLink to="/register" class="text-white hover:text-[#9DACCC] transition">立即注册</RouterLink>
          </p>
        </div>

        <div class="mt-6 pt-6 border-t border-[#485F88]">
          <p class="text-center text-sm text-[#9DACCC] mb-4">第三方登录</p>
          <div class="flex justify-center gap-4">
            <button
              @click="handleThirdPartyLogin('wechat')"
              class="px-4 py-2 bg-[#1a1f35] border border-[#485F88] rounded-lg text-[#9DACCC] hover:bg-gradient-to-r from-[#485F88] to-[#9DACCC] transition"
            >
              微信
            </button>
            <button
              @click="handleThirdPartyLogin('google')"
              class="px-4 py-2 bg-[#1a1f35] border border-[#485F88] rounded-lg text-[#9DACCC] hover:bg-gradient-to-r from-[#485F88] to-[#9DACCC] transition"
            >
              Google
            </button>
            <button
              @click="handleThirdPartyLogin('apple')"
              class="px-4 py-2 bg-[#1a1f35] border border-[#485F88] rounded-lg text-[#9DACCC] hover:bg-gradient-to-r from-[#485F88] to-[#9DACCC] transition"
            >
              Apple
            </button>
          </div>
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
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '../../stores/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const form = ref({
  email: '',
  password: '',
  remember: false
})
const loading = ref(false)
const error = ref('')

async function handleLogin() {
  loading.value = true
  await userStore.login(form.value)
  const redirect = route.query.redirect || '/dashboard'
  router.push(redirect)
  loading.value = false
}

async function handleThirdPartyLogin(provider) {
  loading.value = true
  await userStore.login({
    email: `${provider}@example.com`,
    password: 'mock'
  })
  const redirect = route.query.redirect || '/dashboard'
  router.push(redirect)
  loading.value = false
}
</script>

