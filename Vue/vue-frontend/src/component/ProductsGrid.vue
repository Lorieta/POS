<script setup lang="ts">
import { ref, computed, watchEffect } from 'vue'
import { useQuery, useMutation } from '@vue/apollo-composable'
import { GET_PRODUCTS_QUERY, DELETE_PRODUCT_MUTATION } from '@/graphql'
import AddProductModal from './AddProductModal.vue'
import EditProductModal from './EditProductModal.vue'
import AlertDialog from './AlertDialog.vue' // Import the new AlertDialog component
import type { ProductItem } from '@/types/product'

const PLACEHOLDER_IMAGE = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=='

const normalizeProduct = (product: ProductItem): ProductItem => ({
  ...product,
  image: product.image ?? PLACEHOLDER_IMAGE,
  category: product.category || 'Uncategorized',
  productType: product.productType || 'Unspecified',
})

const selectedCategory = ref('All')
const searchQuery = ref('')
const isAddProductModalOpen = ref(false)
const isEditModalOpen = ref(false)
const selectedProduct = ref<ProductItem | null>(null)

// State for AlertDialog
const isAlertDialogOpen = ref(false)
const alertDialogTitle = ref('')
const alertDialogMessage = ref('')

// State for Delete Confirmation Dialog
const isConfirmDialogOpen = ref(false)
const confirmDialogTitle = ref('Confirm Deletion')
const confirmDialogMessage = ref('')
const productToDelete = ref<ProductItem | null>(null)

const rawProducts = ref<ProductItem[]>([])
const cart = ref<ProductItem[]>([])

const { result, loading: productsLoading, error: productsError, refetch } = useQuery(GET_PRODUCTS_QUERY)
const { mutate: deleteProduct } = useMutation(DELETE_PRODUCT_MUTATION)

watchEffect(() => {
  if (!result.value?.products) return

  rawProducts.value = result.value.products.map((product: any) => normalizeProduct({
    id: Number(product.id),
    name: product.name ?? 'Untitled Product',
    description: product.description ?? '',
    price: Number(product.productPrice ?? 0),
    image: product.imageUrl ?? product.productPhoto ?? undefined,
    category: product.category ?? product.productType ?? undefined,
    productType: product.productType ?? undefined,
    user: product.user
      ? {
          id: Number(product.user.id),
          firstName: product.user.firstName,
          lastName: product.user.lastName,
          email: product.user.email,
        }
      : null,
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

const formatUserName = (user: ProductItem['user']) => {
  if (!user) return 'Unknown user'

  const parts = [user.firstName, user.lastName].filter((part): part is string => Boolean(part))
  return parts.length > 0 ? parts.join(' ') : user.email
}

const addToCart = (product: ProductItem) => {
  const existing = cart.value.find((item) => item.id === product.id)
  if (existing) {
    existing.quantity = (existing.quantity || 1) + 1
  } else {
    cart.value.push({ ...product, quantity: 1 })
  }
}

const openEditModal = (product: ProductItem) => {
  selectedProduct.value = { ...product }
  isEditModalOpen.value = true
}

const closeEditModal = () => {
  isEditModalOpen.value = false
  selectedProduct.value = null
}

const handleProductUpdated = async (updatedProduct: ProductItem) => {
  const normalized = normalizeProduct(updatedProduct)
  rawProducts.value = rawProducts.value.map((product) =>
    product.id === normalized.id ? normalizeProduct({ ...product, ...normalized }) : product,
  )

  try {
    await refetch()
  } catch (error) {
    console.error('Failed to refetch products:', error)
  } finally {
    closeEditModal()
  }
}

const increment = (item: ProductItem) => {
  item.quantity = (item.quantity || 1) + 1
}

const decrement = (item: ProductItem) => {
  if ((item.quantity || 1) > 1) {
    item.quantity = (item.quantity || 1) - 1
  } else {
    cart.value = cart.value.filter((p) => p.id !== item.id)
  }
}

const total = computed(() =>
  cart.value.reduce((sum, item) => sum + item.price * (item.quantity || 1), 0),
)

const handleProductAdded = async (newProduct: ProductItem) => {
  rawProducts.value = [...rawProducts.value, normalizeProduct(newProduct)]

  try {
    await refetch()
  } catch (error) {
    console.error('Failed to refetch products:', error)
  }
}

const handleDeleteProduct = async (event: Event, product: ProductItem) => {
  event.stopPropagation() // Prevent opening the edit modal

  productToDelete.value = product
  confirmDialogMessage.value = `Are you sure you want to delete "${product.name}"?`
  isConfirmDialogOpen.value = true
}

const confirmDeleteProduct = async () => {
  if (!productToDelete.value) return

  try {
    const result = await deleteProduct({ id: productToDelete.value.id.toString() })

    if (result?.data?.deleteProduct?.success) {
      rawProducts.value = rawProducts.value.filter((p) => p.id !== productToDelete.value?.id)
      await refetch()
    } else {
      const errors = result?.data?.deleteProduct?.errors || ['Failed to delete product']
      alertDialogTitle.value = 'Deletion Error'
      alertDialogMessage.value = `Error: ${errors.join(', ')}`
      isAlertDialogOpen.value = true
    }
  } catch (error) {
    console.error('Failed to delete product:', error)
    alertDialogTitle.value = 'Deletion Error'
    alertDialogMessage.value = 'Failed to delete product. Please try again.'
    isAlertDialogOpen.value = true
  } finally {
    closeConfirmDialog()
  }
}

const closeAlertDialog = () => {
  isAlertDialogOpen.value = false
  alertDialogTitle.value = ''
  alertDialogMessage.value = ''
}

const closeConfirmDialog = () => {
  isConfirmDialogOpen.value = false
  productToDelete.value = null
  confirmDialogMessage.value = ''
}
</script>

<template>
  <div class="flex gap-6">
    <!-- Product List -->
    <div class="flex-1">
      <div class="flex justify-between items-center mb-4">
        <div class="flex gap-2">
          <button
            v-for="category in categories"
            :key="category"
            @click="selectedCategory = category"
            :class="[
              'px-4 py-2 rounded-full text-sm font-medium',
              selectedCategory === category
                ? 'bg-blue-500 text-white'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200',
            ]"
          >
            {{ category }}
          </button>
        </div>

        <div class="flex items-center gap-2">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Search"
            class="border rounded-lg px-3 py-2 w-48"
          />
        
          <button
            @click="isAddProductModalOpen = true"
            class="bg-blue-500 text-white rounded-lg px-4 py-2 hover:bg-blue-600 flex items-center gap-2"
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
                d="M12 4v16m8-8H4"
              />
            </svg>
            Add Product
          </button>
        </div>
      </div>

      <!-- Add Product Modal -->
      <AddProductModal
        :is-open="isAddProductModalOpen"
        @close="isAddProductModalOpen = false"
        @product-added="handleProductAdded"
      />
      <EditProductModal
        :is-open="isEditModalOpen"
        :product="selectedProduct"
        @close="closeEditModal"
        @product-updated="handleProductUpdated"
      />

      <div v-if="productsLoading" class="text-gray-500">Loading products...</div>
      <div v-else-if="productsError" class="text-red-500">Failed to load products.</div>
      <div v-else class="grid grid-cols-3 gap-4">
        <div
          v-for="product in filteredProducts"
          :key="product.id"
          class="bg-white rounded-xl shadow-sm p-4 relative cursor-pointer transition-shadow hover:shadow-lg h-[380px] flex flex-col"
          @click="openEditModal(product)"
        >
          <img
            :src="product.image ?? PLACEHOLDER_IMAGE"
            alt="Product Image"
            class="h-40 w-full object-cover rounded-md flex-shrink-0"
          />
          <div class="mt-2 flex-1 flex flex-col min-h-0">
            <h3 class="font-semibold text-gray-800 truncate">{{ product.name }}</h3>
            <p class="text-sm text-gray-500 line-clamp-2">{{ product.description }}</p>
            <p class="text-xs text-gray-400 truncate">Category: {{ product.category }}</p>
            <p class="text-xs text-gray-400 truncate">Type: {{ product.productType }}</p>
            <p v-if="product.user" class="text-xs text-gray-400 truncate">
              Created by: {{ formatUserName(product.user) }}
            </p>
            <p class="font-bold text-gray-900 mt-auto pt-1">₱ {{ product.price }}</p>
          </div>
          <button
            @click="handleDeleteProduct($event, product)"
            class="absolute bottom-4 right-4 bg-red-500 text-white p-2 rounded-full shadow hover:bg-red-600"
            title="Delete product"
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
                d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
              />
            </svg>
          </button>
        </div>
      </div>
    </div>

    <!-- Cart Summary -->

    <div v-for="item in cart" :key="item.id" class="flex justify-between items-center mb-2">
      <div class="flex items-center gap-3">
  <img :src="item.image ?? PLACEHOLDER_IMAGE" class="w-12 h-12 object-cover rounded" />
      </div>
    </div>
  </div>

  <!-- AlertDialog Component for general errors -->
  <AlertDialog
    :is-open="isAlertDialogOpen"
    :title="alertDialogTitle"
    :message="alertDialogMessage"
    @close="closeAlertDialog"
  />

  <!-- AlertDialog Component for delete confirmation -->
  <AlertDialog
    :is-open="isConfirmDialogOpen"
    :title="confirmDialogTitle"
    :message="confirmDialogMessage"
    :is-confirm="true"
    @cancel="closeConfirmDialog"
    @confirm="confirmDeleteProduct"
  />
</template>

<style scoped>
button {
  transition: all 0.2s ease;
}
</style>
