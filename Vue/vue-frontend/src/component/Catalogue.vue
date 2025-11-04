<script setup lang="ts">
import { ref, computed, watchEffect } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import { GET_ALL_PRODUCTS_QUERY } from '@/graphql'
import AddToCartComponent from './AddToCartComponent.vue'
import type { ProductItem } from '@/types/product'

const PLACEHOLDER_IMAGE = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=='

const props = defineProps<{
  cart?: Array<ProductItem & { quantity: number }>
}>()

const emit = defineEmits<{
  'update:cart': [cart: Array<ProductItem & { quantity: number }>]
}>()

const normalizeProduct = (product: ProductItem): ProductItem => ({
  ...product,
  image: product.image ?? PLACEHOLDER_IMAGE,
  category: product.category || 'Uncategorized',
  productType: product.productType || 'Unspecified',
})

const selectedCategory = ref('All')
const searchQuery = ref('')
const rawProducts = ref<ProductItem[]>([])
const selectedProduct = ref<ProductItem | null>(null)
const isCartModalOpen = ref(false)

const { result, loading: productsLoading, error: productsError, refetch } = useQuery(GET_ALL_PRODUCTS_QUERY)

watchEffect(() => {
  if (!result.value?.allProducts) return

  rawProducts.value = result.value.allProducts.map((product: any) => normalizeProduct({
    id: Number(product.id),
    name: product.name ?? 'Untitled Product',
    description: product.description ?? '',
    price: Number(product.productPrice ?? 0),
    image: product.imageUrl ?? product.productPhoto ?? undefined,
    category: product.category ?? product.productType ?? undefined,
    productType: product.productType ?? undefined,
  }))
})

const categories = computed(() => {
  const unique = new Set(
    rawProducts.value.map((product) => product.category || 'Uncategorized'),
  )
  return ['All', ...Array.from(unique)]
})

const filteredProducts = computed(() => {
  return rawProducts.value.filter((product) => {
    const matchesCategory =
      selectedCategory.value === 'All' || product.category === selectedCategory.value
    const lowerSearch = searchQuery.value.toLowerCase()
    const matchesSearch =
      product.name.toLowerCase().includes(lowerSearch) ||
      (product.description || '').toLowerCase().includes(lowerSearch)
    return matchesCategory && matchesSearch
  })
})

const openCartModal = (product: ProductItem) => {
  selectedProduct.value = { ...product }
  isCartModalOpen.value = true
}

const closeCartModal = () => {
  isCartModalOpen.value = false
  selectedProduct.value = null
}

const handleAddedToCart = (product: ProductItem, quantity: number) => {
  const currentCart = props.cart || []
  const existingItem = currentCart.find((item) => item.id === product.id)
  
  if (existingItem) {
    existingItem.quantity += quantity
    emit('update:cart', [...currentCart])
  } else {
    emit('update:cart', [...currentCart, { ...product, quantity }])
  }
  
  // Optional: Show a toast notification or feedback
  console.log(`Added ${quantity}x ${product.name} to cart`)
}
</script>

<template>
  <div class="container mx-auto px-4 py-6">
    <!-- Header Section -->
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold text-gray-800">Product Catalogue</h1>
      
      <div class="flex items-center gap-2">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Search"
          class="border rounded-lg px-4 py-2 w-64 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <button class="p-2 text-gray-500 hover:text-gray-700">
          <svg
            class="w-5 h-5"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"
            />
          </svg>
        </button>
      </div>
    </div>

    <!-- Category Filter -->
    <div class="flex gap-2 mb-6 overflow-x-auto pb-2">
      <button
        v-for="category in categories"
        :key="category"
        @click="selectedCategory = category"
        :class="[
          'px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all',
          selectedCategory === category
            ? 'bg-blue-500 text-white'
            : 'bg-gray-100 text-gray-700 hover:bg-gray-200',
        ]"
      >
        {{ category }}
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="productsLoading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
      <p class="mt-4 text-gray-500">Loading products...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="productsError" class="text-center py-12">
      <div class="text-red-500 mb-4">
        <svg class="w-16 h-16 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      </div>
      <p class="text-red-600 font-semibold">Failed to load products</p>
      <button 
        @click="refetch()"
        class="mt-4 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600"
      >
        Retry
      </button>
    </div>

    <!-- Products Grid -->
    <div v-else-if="filteredProducts.length > 0" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
      <div
        v-for="product in filteredProducts"
        :key="product.id"
        class="bg-white rounded-xl shadow-sm hover:shadow-lg transition-shadow duration-300 overflow-hidden group cursor-pointer"
        @click="openCartModal(product)"
      >
        <!-- Product Image -->
        <div class="relative h-48 overflow-hidden bg-gray-100">
          <img
            :src="product.image ?? PLACEHOLDER_IMAGE"
            :alt="product.name"
            class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300"
          />
          <div class="absolute top-2 right-2 bg-white rounded-full p-2 shadow-md opacity-0 group-hover:opacity-100 transition-opacity">
            <svg
              class="w-5 h-5 text-blue-500"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"
              />
            </svg>
          </div>
        </div>

        <!-- Product Details -->
        <div class="p-4">
          <h3 class="font-semibold text-gray-800 text-lg truncate mb-1">{{ product.name }}</h3>
          <p class="text-sm text-gray-500 line-clamp-2 mb-2 h-10">{{ product.description }}</p>
          
          <div class="flex items-center justify-between mb-2">
            <span class="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded-full">
              {{ product.category }}
            </span>
            <span class="text-xs text-gray-400">
              {{ product.productType }}
            </span>
          </div>

          <div class="flex items-center justify-between pt-2 border-t">
            <p class="font-bold text-xl text-gray-900">₱ {{ product.price.toFixed(2) }}</p>
            <button
              @click.stop="openCartModal(product)"
              class="bg-blue-500 text-white p-2 rounded-lg hover:bg-blue-600 transition-colors"
              title="Add to cart"
            >
              <svg
                class="w-5 h-5"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"
                />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <div class="text-gray-400 mb-4">
        <svg class="w-16 h-16 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
        </svg>
      </div>
      <p class="text-gray-500 text-lg">No products found</p>
      <p class="text-gray-400 text-sm mt-2">Try adjusting your search or filter criteria</p>
    </div>

    <!-- Add to Cart Modal -->
    <AddToCartComponent
      v-if="selectedProduct"
      :is-open="isCartModalOpen"
      :product="selectedProduct"
      @close="closeCartModal"
      @added-to-cart="handleAddedToCart"
    />
  </div>
</template>

<style scoped>
button {
  transition: all 0.2s ease;
}

/* Custom scrollbar for category filter */
.overflow-x-auto::-webkit-scrollbar {
  height: 6px;
}

.overflow-x-auto::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 10px;
}

.overflow-x-auto::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 10px;
}

.overflow-x-auto::-webkit-scrollbar-thumb:hover {
  background: #555;
}

/* Line clamp utility */
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
