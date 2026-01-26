<script setup>
import { RouterView, useRoute } from 'vue-router'
import { computed } from 'vue'
import VoxNavbar from './components/VoxNavbar.vue'
import Sidebar from './components/Sidebar.vue'

const route = useRoute()
const hideNavbar = computed(() => route.meta.hideNavbar)
const showSidebar = computed(() => route.path.startsWith('/clip-studio') || route.query.from === 'clip')
const isHomePage = computed(() => route.path === '/')
</script>

<template>
  <div class="min-h-screen bg-[#121524]">
    <VoxNavbar v-if="!hideNavbar" />
    <Sidebar v-if="showSidebar" />
    <main :class="showSidebar ? 'ml-16' : ''">
      <RouterView />
    </main>
  </div>
</template>
