<script setup>
import { RouterLink } from 'vue-router'
// 导航栏目前没有交互逻辑
</script>

<template>
  <nav class="fixed w-full z-50 px-8 py-6 flex justify-between items-center backdrop-blur-sm">
    <div class="text-2xl font-black tracking-widest text-white">PodPal</div>
    <div class="hidden md:flex gap-8 text-sm font-medium text-[#9DACCC]">
      <RouterLink to="/" class="hover:text-white transition">首页</RouterLink>
      <a href="#" class="hover:text-white transition">解决方案</a>
      <a href="#" class="hover:text-white transition">核心技术</a>
      <a href="#" class="hover:text-white transition">关于我们</a>
      <RouterLink to="/profile" class="hover:text-white transition">个人中心</RouterLink>
    </div>
    <button
      class="px-6 py-2 bg-[#485F88] text-white rounded-full text-sm font-bold hover:bg-[#9DACCC] transition-all duration-300"
    >
      立即开始
    </button>
  </nav>
</template>
