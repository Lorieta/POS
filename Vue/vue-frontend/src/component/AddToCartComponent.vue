<script setup lang="ts">
import { ref, computed } from 'vue'
import type { ProductItem } from '@/types/product'

const props = defineProps<{
  isOpen: boolean
  product: ProductItem | null
}>()

const emit = defineEmits<{
  close: []
  addedToCart: [product: ProductItem, quantity: number]
}>()

const quantity = ref(1)

const PLACEHOLDER_IMAGE = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=='

const totalPrice = computed(() => {
  if (!props.product) return 0
  return props.product.price * quantity.value
})

const incrementQuantity = () => {
  quantity.value++
}

const decrementQuantity = () => {
  if (quantity.value > 1) {
    quantity.value--
  }
}

const handleAddToCart = () => {
  if (props.product) {
    emit('addedToCart', props.product, quantity.value)
    quantity.value = 1
    emit('close')
  }
}

const handleClose = () => {
  quantity.value = 1
  emit('close')
}
</script>

<template>
  <Transition name="modal">
    <div
      v-if="isOpen && product"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50"
      @click.self="handleClose"
    >
      <div class="bg-white rounded-2xl shadow-2xl max-w-2xl w-full mx-4 overflow-hidden">
        <!-- Header -->
        <div class="flex justify-between items-center p-6 border-b">
          <h2 class="text-2xl font-bold text-gray-800">Add to Cart</h2>
          <button
            @click="handleClose"
            class="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <!-- Content -->
        <div class="p-6">
          <div class="flex gap-6">
            <!-- Product Image -->
            <div class="flex-shrink-0">
              <img
                :src="product.image ?? PLACEHOLDER_IMAGE"
                :alt="product.name"
                class="w-48 h-48 object-cover rounded-lg"
              />
            </div>

            <!-- Product Details -->
            <div class="flex-1 flex flex-col">
              <h3 class="text-xl font-semibold text-gray-800 mb-2">{{ product.name }}</h3>
              <p class="text-gray-600 text-sm mb-3">{{ product.description }}</p>
              
              <div class="flex gap-2 mb-4">
                <span class="bg-blue-100 text-blue-800 text-xs font-medium px-2.5 py-0.5 rounded">
                  {{ product.category }}
                </span>
                <span class="bg-gray-100 text-gray-800 text-xs font-medium px-2.5 py-0.5 rounded">
                  {{ product.productType }}
                </span>
              </div>

              <div class="text-3xl font-bold text-gray-900 mb-4">
                ₱ {{ product.price.toFixed(2) }}
              </div>

              <!-- Quantity Selector -->
              <div class="flex items-center gap-4 mb-6">
                <span class="text-gray-700 font-medium">Quantity:</span>
                <div class="flex items-center border border-gray-300 rounded-lg">
                  <button
                    @click="decrementQuantity"
                    class="px-4 py-2 text-gray-600 hover:bg-gray-100 transition-colors"
                    :disabled="quantity <= 1"
                    :class="{ 'opacity-50 cursor-not-allowed': quantity <= 1 }"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4" />
                    </svg>
                  </button>
                  <span class="px-6 py-2 font-semibold text-gray-900">{{ quantity }}</span>
                  <button
                    @click="incrementQuantity"
                    class="px-4 py-2 text-gray-600 hover:bg-gray-100 transition-colors"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                    </svg>
                  </button>
                </div>
              </div>

              <!-- Total Price -->
              <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg mb-4">
                <span class="text-gray-700 font-medium">Total:</span>
                <span class="text-2xl font-bold text-blue-600">₱ {{ totalPrice.toFixed(2) }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Footer -->
        <div class="flex gap-3 p-6 bg-gray-50 border-t">
          <button
            @click="handleClose"
            class="flex-1 px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-100 transition-colors font-medium"
          >
            Cancel
          </button>
          <button
            @click="handleAddToCart"
            class="flex-1 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium flex items-center justify-center gap-2"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
            </svg>
            Add to Cart
          </button>
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
