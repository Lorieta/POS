<template>
  <div
    v-if="isOpen"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    @click.self="closeModal"
  >
    <div class="bg-white rounded-xl shadow-xl w-full max-w-md p-6">
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-xl font-bold text-gray-800">Edit Product</h2>
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
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">Product Name</label>
          <input
            v-model="formData.name"
            type="text"
            required
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
          <textarea
            v-model="formData.description"
            rows="3"
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
          ></textarea>
        </div>

        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">Price</label>
          <input
            v-model.number="formData.price"
            type="number"
            step="0.01"
            required
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">Category</label>
          <input
            v-model="formData.category"
            type="text"
            required
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">Product Type</label>
          <select
            v-model="formData.productType"
            required
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="physical">Physical</option>
            <option value="digital">Digital</option>
          </select>
        </div>

        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">Product Image</label>
          <input
            type="file"
            accept="image/*"
            @change="handleFileChange"
            :disabled="isSaving"
            ref="fileInput"
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />

          <div v-if="imagePreview" class="mt-3 relative">
            <img :src="imagePreview" alt="Preview" class="w-full h-48 object-cover rounded-lg" />
            <button
              v-if="selectedFile"
              type="button"
              @click="clearSelectedImage"
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

          <p v-if="isUploadingImage" class="mt-2 text-sm text-gray-500">Uploading image...</p>
        </div>

        <div v-if="error" class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg">
          <p class="text-sm text-red-600">{{ error }}</p>
        </div>

        <div class="flex gap-2">
          <button
            type="button"
            @click="closeModal"
            class="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            type="submit"
            :disabled="isSaving"
            class="flex-1 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:bg-gray-300 disabled:cursor-not-allowed"
          >
            {{ isSaving ? 'Saving...' : 'Save Changes' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'
import { useApolloClient, useMutation } from '@vue/apollo-composable'
import { uploadToCloudinary } from '@/utils/cloudinaryUpload'
import { UPDATE_PRODUCT_MUTATION } from '@/graphql'
import type { ProductItem } from '@/types/product'

const props = defineProps<{
  isOpen: boolean
  product: ProductItem | null
}>()

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'productUpdated', product: ProductItem): void
}>()

const { mutate: updateProduct } = useMutation(UPDATE_PRODUCT_MUTATION)
const { resolveClient } = useApolloClient()

const formData = reactive({
  id: 0,
  name: '',
  description: '',
  price: 0,
  category: '',
  productType: 'physical',
})

const isSaving = ref(false)
const error = ref<string | null>(null)
const selectedFile = ref<File | null>(null)
const imagePreview = ref<string | null>(null)
const originalImage = ref<string | null>(null)
const fileInput = ref<HTMLInputElement | null>(null)
const isUploadingImage = ref(false)

const isFormValid = computed(() => {
  return (
    formData.name.trim().length > 0 &&
    formData.description.trim().length > 0 &&
    formData.price > 0 &&
    formData.category.trim().length > 0 &&
    formData.productType.trim().length > 0
  )
})

watch(
  () => props.product,
  (product) => {
    if (!product) {
      formData.id = 0
      formData.name = ''
      formData.description = ''
      formData.price = 0
      formData.category = ''
      formData.productType = 'physical'
      selectedFile.value = null
      imagePreview.value = null
      originalImage.value = null
      if (fileInput.value) {
        fileInput.value.value = ''
      }
      return
    }

    formData.id = product.id
    formData.name = product.name
    formData.description = product.description
    formData.price = product.price
    formData.category = product.category
    formData.productType = product.productType
    originalImage.value = product.image ?? null
    imagePreview.value = originalImage.value
    selectedFile.value = null
    if (fileInput.value) {
      fileInput.value.value = ''
    }
  },
  { immediate: true },
)

const closeModal = () => {
  if (!isSaving.value) {
    emit('close')
  }
}

const handleFileChange = (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0] ?? null

  if (!file) {
    clearSelectedImage()
    return
  }

  selectedFile.value = file

  const reader = new FileReader()
  reader.onload = (e) => {
    imagePreview.value = (e.target?.result as string) ?? null
  }
  reader.readAsDataURL(file)
}

const clearSelectedImage = () => {
  selectedFile.value = null
  imagePreview.value = originalImage.value
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

const handleSubmit = async () => {
  if (!isFormValid.value || !formData.id) {
    error.value = 'Please complete all required fields.'
    return
  }

  isSaving.value = true
  error.value = null

  try {
    let imageSignedId: string | null = null

    if (selectedFile.value) {
      isUploadingImage.value = true
      try {
        const apolloClient = resolveClient()
        imageSignedId = await uploadToCloudinary(selectedFile.value, apolloClient)
      } finally {
        isUploadingImage.value = false
      }
    }

    const variables: Record<string, unknown> = {
      id: formData.id,
      name: formData.name,
      description: formData.description,
      productPrice: formData.price,
      productType: formData.productType,
      category: formData.category,
    }

    if (imageSignedId) {
      variables.imageSignedId = imageSignedId
    }

    const result = await updateProduct(variables)

    const data = result?.data

    if (data?.updateProduct?.errors?.length) {
      error.value = data.updateProduct.errors.join(', ')
      return
    }

    const updated = data?.updateProduct?.product
    if (!updated) {
      error.value = 'Failed to update product. Please try again.'
      return
    }

    let updatedImage =
      updated.imageUrl ??
      updated.productPhoto ??
      (selectedFile.value ? imagePreview.value : originalImage.value) ??
      null

    emit('productUpdated', {
      id: Number(updated.id),
      name: updated.name ?? formData.name,
      description: updated.description ?? formData.description,
      price: Number(updated.productPrice ?? formData.price),
      category: updated.category ?? formData.category,
      productType: updated.productType ?? formData.productType,
      image: updatedImage ?? '',
    })

    originalImage.value = updatedImage
    imagePreview.value = updatedImage
    selectedFile.value = null
    if (fileInput.value) {
      fileInput.value.value = ''
    }

    emit('close')
  } catch (err) {
    console.error('Update product failed:', err)
    error.value = 'Failed to update product. Please try again.'
  } finally {
    isSaving.value = false
    isUploadingImage.value = false
  }
}
</script>
