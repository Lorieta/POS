<template>
  <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
    <div class="bg-white rounded-lg shadow-xl p-6 w-full max-w-sm mx-auto">
      <h3 class="text-lg font-semibold text-gray-900 mb-4">{{ title }}</h3>
      <p class="text-sm text-gray-600 mb-6">{{ message }}</p>
      <div class="flex justify-end gap-2">
        <button
          v-if="isConfirm"
          @click="cancel"
          class="px-4 py-2 bg-gray-300 text-gray-800 rounded-md hover:bg-gray-400 focus:outline-none focus:ring-2 focus:ring-gray-300 focus:ring-opacity-50"
        >
          Cancel
        </button>
        <button
          @click="confirm"
          :class="[
            'px-4 py-2 rounded-md focus:outline-none focus:ring-2 focus:ring-opacity-50',
            isConfirm
              ? 'bg-red-500 text-white hover:bg-red-600 focus:ring-red-500'
              : 'bg-blue-500 text-white hover:bg-blue-600 focus:ring-blue-500',
          ]"
        >
          {{ isConfirm ? 'Delete' : 'OK' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { defineProps, defineEmits } from 'vue'

const props = defineProps<{
  isOpen: boolean
  title: string
  message: string
  isConfirm?: boolean // New prop to determine if it's a confirmation dialog
}>()

const emit = defineEmits(['close', 'confirm', 'cancel'])

const confirm = () => {
  emit('confirm')
  emit('close') // Also close on confirm
}

const cancel = () => {
  emit('cancel')
  emit('close') // Also close on cancel
}
</script>

<style scoped>
/* Add any specific styles for the alert dialog here if needed */
</style>
