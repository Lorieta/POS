<script setup lang="ts">
import { computed } from 'vue'
import type { ProductItem } from '@/types/product'

const props = defineProps<{
  isOpen: boolean
  cart: Array<ProductItem & { quantity: number }>
}>()

const emit = defineEmits<{
  close: []
  updateQuantity: [productId: number, quantity: number]
  removeItem: [productId: number]
  checkout: []
}>()

const PLACEHOLDER_IMAGE = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=='

const subtotal = computed(() => {
  return props.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0)
})

const totalItems = computed(() => {
  return props.cart.reduce((sum, item) => sum + item.quantity, 0)
})

const incrementQuantity = (productId: number) => {
  const item = props.cart.find(i => i.id === productId)
  if (item) {
    emit('updateQuantity', productId, item.quantity + 1)
  }
}

const decrementQuantity = (productId: number) => {
  const item = props.cart.find(i => i.id === productId)
  if (item && item.quantity > 1) {
    emit('updateQuantity', productId, item.quantity - 1)
  }
}

const removeItem = (productId: number) => {
  emit('removeItem', productId)
}

const handleCheckout = () => {
  emit('checkout')
}
</script>

<template>
  <Transition name="modal">
    <div
      v-if="isOpen"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 p-4"
      @click.self="emit('close')"
    >
      <div class="bg-white rounded-2xl shadow-2xl max-w-2xl w-full max-h-[90vh] flex flex-col overflow-hidden">
        <!-- Header -->
        <div class="flex justify-between items-center p-6 border-b">
          <div>
            <h2 class="text-2xl font-bold text-gray-800">Shopping Cart</h2>
            <p class="text-sm text-gray-500 mt-1">{{ totalItems }} item{{ totalItems !== 1 ? 's' : '' }}</p>
          </div>
          <button
            @click="emit('close')"
            class="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <!-- Cart Items -->
        <div class="flex-1 overflow-y-auto p-6">
          <div v-if="cart.length === 0" class="text-center py-12">
            <svg class="w-16 h-16 mx-auto text-gray-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
            </svg>
            <p class="text-gray-500 text-lg">Your cart is empty</p>
            <p class="text-gray-400 text-sm mt-2">Add some products to get started</p>
          </div>

          <div v-else class="space-y-4">
            <div
              v-for="item in cart"
              :key="item.id"
              class="flex gap-4 p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <!-- Product Image -->
              <img
                :src="item.image ?? PLACEHOLDER_IMAGE"
                :alt="item.name"
                class="w-20 h-20 object-cover rounded-lg flex-shrink-0"
              />

              <!-- Product Details -->
              <div class="flex-1 min-w-0">
                <h3 class="font-semibold text-gray-800 truncate">{{ item.name }}</h3>
                <p class="text-sm text-gray-500 truncate">{{ item.category }}</p>
                <p class="text-lg font-bold text-blue-600 mt-1">₱ {{ item.price.toFixed(2) }}</p>
              </div>

              <!-- Quantity Controls -->
              <div class="flex flex-col items-end justify-between">
                <button
                  @click="removeItem(item.id)"
                  class="text-red-500 hover:text-red-700 p-1"
                  title="Remove item"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                  </svg>
                </button>

                <div class="flex items-center border border-gray-300 rounded-lg">
                  <button
                    @click="decrementQuantity(item.id)"
                    class="px-3 py-1 text-gray-600 hover:bg-gray-200 transition-colors"
                    :disabled="item.quantity <= 1"
                    :class="{ 'opacity-50 cursor-not-allowed': item.quantity <= 1 }"
                  >
                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4" />
                    </svg>
                  </button>
                  <span class="px-3 py-1 font-semibold text-gray-900 min-w-[2rem] text-center">{{ item.quantity }}</span>
                  <button
                    @click="incrementQuantity(item.id)"
                    class="px-3 py-1 text-gray-600 hover:bg-gray-200 transition-colors"
                  >
                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                    </svg>
                  </button>
                </div>

                <p class="text-sm font-semibold text-gray-700">
                  ₱ {{ (item.price * item.quantity).toFixed(2) }}
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Footer -->
        <div v-if="cart.length > 0" class="border-t bg-gray-50 p-6">
          <div class="flex items-center justify-between mb-4">
            <span class="text-lg font-semibold text-gray-700">Subtotal:</span>
            <span class="text-2xl font-bold text-blue-600">₱ {{ subtotal.toFixed(2) }}</span>
          </div>
          
          <div class="flex gap-3">
            <button
              @click="emit('close')"
              class="flex-1 px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-100 transition-colors font-medium"
            >
              Continue Shopping
            </button>
            <button
              @click="handleCheckout"
              class="flex-1 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
            >
              Checkout
            </button>
          </div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-active .bg-white,
.modal-leave-active .bg-white {
  transition: transform 0.3s ease;
}

.modal-enter-from .bg-white,
.modal-leave-to .bg-white {
  transform: scale(0.95);
}
</style>
