<script setup>
import { RouterView } from 'vue-router'
import VoxNavbar from './components/VoxNavbar.vue'
</script>

<template>
  <div class="min-h-screen">
    <VoxNavbar />
    <main>
      <RouterView />
    </main>
  </div>
</template>
