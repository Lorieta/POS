<template>
  <div
    v-if="isOpen"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    @click.self="closeModal"
  >
    <div class="bg-white rounded-xl shadow-xl w-full max-w-md p-6">
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-xl font-bold text-gray-800">Add New Product</h2>
        <button @click="closeModal" class="text-gray-400 hover:text-gray-600">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M6 18L18 6M6 6l12 12"
            />
          </svg>
        </button>
      </div>

      <form @submit.prevent="handleSubmit">
        <!-- Product Name -->
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">Product Name</label>
          <input
            v-model="formData.name"
            type="text"
            required
            placeholder="Enter product name"
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <!-- Description -->
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
          <textarea
            v-model="formData.description"
            rows="2"
            placeholder="Enter product description"
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
          ></textarea>
        </div>

        <!-- Price -->
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">Price</label>
          <input
            v-model.number="formData.price"
            type="number"
            step="0.01"
            required
            placeholder="0.00"
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <!-- Category -->
        <div class="mb-4">
          <div class="flex items-center justify-between mb-2">
            <label class="block text-sm font-medium text-gray-700">Category</label>
            <label class="flex items-center gap-2 text-xs text-gray-600">
              <input
                id="custom-category-toggle"
                v-model="useCustomCategory"
                type="checkbox"
                class="rounded border-gray-300 text-blue-500 focus:ring-blue-500"
              />
              Enter custom
            </label>
          </div>

          <select
            v-if="!useCustomCategory"
            v-model="formData.category"
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="">Select category</option>
            <option v-for="option in categoryOptions" :key="option" :value="option">
              {{ option }}
            </option>
          </select>

          <input
            v-else
            v-model="formData.category"
            type="text"
            placeholder="Enter category"
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <!-- Product Type -->
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">Product Type</label>
          <select
            v-model="formData.productType"
            required
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="">Select type</option>
            <option value="physical">Physical</option>
            <option value="digital">Digital</option>
          </select>
        </div>

        <!-- Image Upload -->
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">Product Image</label>
          <input
            type="file"
            @change="handleFileChange"
            accept="image/*"
            ref="fileInput"
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />

          <!-- Image Preview -->
          <div v-if="imagePreview" class="mt-3 relative">
            <img :src="imagePreview" alt="Preview" class="w-full h-48 object-cover rounded-lg" />
            <button
              type="button"
              @click="clearImage"
              class="absolute top-2 right-2 bg-red-500 text-white rounded-full p-1 hover:bg-red-600"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </div>
        </div>

        <!-- Progress Bar -->
        <div v-if="uploading" class="mb-4">
          <div class="flex items-center justify-between mb-1">
            <span class="text-sm text-gray-600">Uploading...</span>
            <span class="text-sm font-medium text-blue-600">{{ uploadProgress }}%</span>
          </div>
          <div class="w-full bg-gray-200 rounded-full h-2">
            <div
              class="bg-blue-500 h-2 rounded-full transition-all duration-300"
              :style="{ width: uploadProgress + '%' }"
            ></div>
          </div>
        </div>

        <!-- Error Message -->
        <div v-if="error" class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg">
          <p class="text-sm text-red-600">{{ error }}</p>
        </div>

        <!-- Submit Button -->
        <div class="flex gap-2">
          <button
            type="button"
            @click="closeModal"
            class="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"
            :disabled="uploading"
          >
            Cancel
          </button>
          <button
            type="submit"
            :disabled="uploading || !isFormValid"
            class="flex-1 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:bg-gray-300 disabled:cursor-not-allowed"
          >
            {{ uploading ? 'Uploading...' : 'Add Product' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useMutation, useApolloClient } from '@vue/apollo-composable'
import { uploadToCloudinary } from '@/utils/cloudinaryUpload'
import { CREATE_PRODUCT_MUTATION } from '@/graphql'
import type { ProductItem } from '@/types/product'

interface Props {
  isOpen: boolean
}

interface Emits {
  (e: 'close'): void
  (e: 'productAdded', product: ProductItem): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const { resolveClient } = useApolloClient()

const { mutate: createProduct } = useMutation(CREATE_PRODUCT_MUTATION)

const PLACEHOLDER_IMAGE = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=='

const categoryOptions = ['Books', 'Comics', 'Magazines', 'Other']
const useCustomCategory = ref(false)

const formData = ref({
  name: '',
  description: '',
  price: 0,
  category: '',
  productType: '',
})

const selectedFile = ref<File | null>(null)
const imagePreview = ref<string | null>(null)
const uploading = ref(false)
const uploadProgress = ref(0)
const error = ref<string | null>(null)
const fileInput = ref<HTMLInputElement | null>(null)

const isFormValid = computed(() => {
  const trimmedCategory = formData.value.category.trim()
  return (
    formData.value.name &&
    formData.value.price > 0 &&
    trimmedCategory &&
    formData.value.productType
  )
})

watch(useCustomCategory, () => {
  formData.value.category = ''
})

const handleFileChange = (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  if (file) {
    selectedFile.value = file

    // Create image preview
    const reader = new FileReader()
    reader.onload = (e) => {
      imagePreview.value = e.target?.result as string
    }
    reader.readAsDataURL(file)
  }
}

const clearImage = () => {
  selectedFile.value = null
  imagePreview.value = null
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

const handleSubmit = async () => {
  try {
    uploading.value = true
    error.value = null
    uploadProgress.value = 0

    let imageSignedId = null

    // Upload image if selected
    if (selectedFile.value) {
      uploadProgress.value = 25
      const apolloClient = resolveClient()
      imageSignedId = await uploadToCloudinary(selectedFile.value, apolloClient)
      uploadProgress.value = 60
    }

    // Create product
    uploadProgress.value = 75
    const variables: Record<string, any> = {
      name: formData.value.name,
      productPrice: parseFloat(formData.value.price.toString()),
      productType: formData.value.productType,
      category: formData.value.category,
      description: formData.value.description,
      imageSignedId: imageSignedId,
    }

    const storedUserId = localStorage.getItem('userId')
    if (storedUserId) {
      variables.userId = storedUserId
    }

  const result = await createProduct(variables)
  const data = result?.data

    uploadProgress.value = 100

    if (data?.createProduct?.errors && data.createProduct.errors.length > 0) {
      error.value = data.createProduct.errors.join(', ')
      return
    }

    const createdProduct = data?.createProduct?.product
    if (!createdProduct) {
      error.value = 'Failed to create product. Please try again.'
      return
    }

    // Emit the new product
  const newProduct: ProductItem = {
      id: Number(createdProduct.id),
      name: createdProduct.name ?? formData.value.name,
      description: createdProduct.description ?? formData.value.description,
      price: Number(createdProduct.productPrice ?? formData.value.price),
      image: createdProduct.imageUrl || createdProduct.productPhoto || PLACEHOLDER_IMAGE,
      category: createdProduct.category ?? formData.value.category,
      productType: createdProduct.productType ?? formData.value.productType,
      user: createdProduct.user
        ? {
            id: Number(createdProduct.user.id),
            firstName: createdProduct.user.firstName,
            lastName: createdProduct.user.lastName,
            email: createdProduct.user.email,
          }
        : null,
    }

    emit('productAdded', newProduct)
    resetForm()
    closeModal()
  } catch (err) {
    console.error('Error creating product:', err)
    error.value = 'Failed to create product. Please try again.'
  } finally {
    uploading.value = false
    uploadProgress.value = 0
  }
}

const resetForm = () => {
  formData.value = {
    name: '',
    description: '',
    price: 0,
    category: '',
    productType: '',
  }
  useCustomCategory.value = false
  clearImage()
  error.value = null
}

const closeModal = () => {
  if (!uploading.value) {
    resetForm()
    emit('close')
  }
}
</script>
