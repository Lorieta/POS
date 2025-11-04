<template>
  <div class="space-y-6">
    <!-- Top Nav -->
    <div class="flex items-center text-sm text-blue-500 gap-2">
      <button class="flex items-center gap-1" @click="emit('back')">
        <span class="text-lg">&larr;</span>
        <span>Back to Cart</span>
      </button>
      <span class="text-gray-400">|</span>
      <span class="text-gray-500">Checkout</span>
    </div>

    <h1 class="text-2xl font-semibold text-gray-900">Checkout</h1>

    <div class="grid grid-cols-1 xl:grid-cols-[2fr_1fr] gap-6">
      <!-- Left: Customer and Address Form -->
      <section class="bg-white rounded-2xl shadow-sm p-6 space-y-6">
        <h2 class="text-lg font-semibold text-gray-900">Customer Information</h2>

        <div class="grid sm:grid-cols-2 gap-4">
          <div>
            <label class="block text-xs text-gray-500 mb-1">Email *</label>
            <input
              v-model="customer.email"
              type="email"
              placeholder="name@example.com"
              required
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
              :class="{ 'border-red-300': errors.email }"
            />
            <span v-if="errors.email" class="text-xs text-red-500">{{ errors.email }}</span>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Mobile Number *</label>
            <input
              v-model="customer.mobile"
              type="tel"
              placeholder="+63 9xx xxx xxxx"
              required
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
              :class="{ 'border-red-300': errors.mobile }"
            />
            <span v-if="errors.mobile" class="text-xs text-red-500">{{ errors.mobile }}</span>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">First Name *</label>
            <input
              v-model="customer.firstName"
              type="text"
              placeholder="First Name"
              required
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
              :class="{ 'border-red-300': errors.firstName }"
            />
            <span v-if="errors.firstName" class="text-xs text-red-500">{{ errors.firstName }}</span>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Last Name *</label>
            <input
              v-model="customer.lastName"
              type="text"
              placeholder="Last Name"
              required
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
              :class="{ 'border-red-300': errors.lastName }"
            />
            <span v-if="errors.lastName" class="text-xs text-red-500">{{ errors.lastName }}</span>
          </div>
        </div>

        <div>
          <h3 class="text-base font-semibold text-gray-900">Payment Method</h3>
          <p class="text-sm text-gray-500">Choose how you will pay for this order.</p>
          <div class="mt-4 grid gap-3 sm:grid-cols-3">
            <label
              v-for="option in paymentOptions"
              :key="option"
              class="flex items-center gap-2 border rounded-lg px-3 py-2 cursor-pointer hover:border-blue-300 transition-colors"
              :class="paymentMethod === option ? 'border-blue-500 bg-blue-50 text-blue-600' : 'border-gray-200 text-gray-700'"
            >
              <input
                v-model="paymentMethod"
                type="radio"
                :value="option"
                class="text-blue-500 focus:ring-blue-400"
              />
              <span class="text-sm font-medium">{{ option }}</span>
            </label>
          </div>
        </div>

        <h2 class="text-lg font-semibold text-gray-900">Delivery Information</h2>

        <div class="grid sm:grid-cols-2 gap-4">
          <div>
            <label class="block text-xs text-gray-500 mb-1">Country *</label>
            <input
              v-model="address.country"
              type="text"
              placeholder="Philippines"
              required
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
              :class="{ 'border-red-300': errors.country }"
            />
            <span v-if="errors.country" class="text-xs text-red-500">{{ errors.country }}</span>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Province *</label>
            <input
              v-model="address.province"
              type="text"
              placeholder="NCR"
              required
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
              :class="{ 'border-red-300': errors.province }"
            />
            <span v-if="errors.province" class="text-xs text-red-500">{{ errors.province }}</span>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">City *</label>
            <input
              v-model="address.city"
              type="text"
              placeholder="City/Municipality"
              required
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
              :class="{ 'border-red-300': errors.city }"
            />
            <span v-if="errors.city" class="text-xs text-red-500">{{ errors.city }}</span>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Street *</label>
            <input
              v-model="address.street"
              type="text"
              placeholder="Street"
              required
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
              :class="{ 'border-red-300': errors.street }"
            />
            <span v-if="errors.street" class="text-xs text-red-500">{{ errors.street }}</span>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Barangay *</label>
            <input
              v-model="address.barangay"
              type="text"
              placeholder="Barangay"
              required
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
              :class="{ 'border-red-300': errors.barangay }"
            />
            <span v-if="errors.barangay" class="text-xs text-red-500">{{ errors.barangay }}</span>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Room / Unit</label>
            <input
              v-model="address.roomUnit"
              type="text"
              placeholder="Unit"
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
            />
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Floor</label>
            <input
              v-model="address.floor"
              type="text"
              placeholder="Floor"
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
            />
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Building</label>
            <input
              v-model="address.building"
              type="text"
              placeholder="Building"
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
            />
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Nearest Landmark</label>
            <input
              v-model="address.landmark"
              type="text"
              placeholder="Landmark"
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
            />
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Remarks</label>
            <input
              v-model="address.remarks"
              type="text"
              placeholder="Optional"
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
            />
          </div>
        </div>

        <div class="grid sm:grid-cols-2 gap-4 pt-2">
          <div>
            <label class="block text-xs text-gray-500 mb-1">Coupon or Promo Code</label>
            <input
              v-model="couponCode"
              type="text"
              placeholder="Type here"
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
            />
          </div>
        </div>

        <div v-if="errorMessage" class="mt-4 text-sm text-red-500 bg-red-50 border border-red-100 rounded-lg px-3 py-2">
          {{ errorMessage }}
        </div>

        <div class="mt-6 flex gap-3">
          <button
            class="bg-gray-100 text-gray-700 py-2 px-6 rounded-lg font-medium hover:bg-gray-200 transition-colors"
            @click="emit('cancel')"
          >
            Cancel
          </button>
          <button
            class="flex-1 bg-blue-600 text-white py-2 px-6 rounded-lg font-medium disabled:opacity-60 disabled:cursor-not-allowed hover:bg-blue-700 transition-colors"
            :disabled="!hasItems || isPlacingOrder"
            @click="placeOrder"
          >
            <span v-if="isPlacingOrder">Placing Order...</span>
            <span v-else>Place Order</span>
          </button>
        </div>
      </section>

      <!-- Right: Order Summary -->
      <aside class="bg-white rounded-2xl shadow-sm p-6 flex flex-col sticky top-6 self-start">
        <h2 class="text-lg font-semibold text-gray-900 mb-4">Order Summary</h2>
        
        <div class="space-y-3 flex-1 overflow-y-auto pr-1 max-h-[400px]">
          <article
            v-for="item in cartItems"
            :key="item.id"
            class="flex items-start gap-3 border rounded-xl p-3"
          >
            <img
              :src="item.image ?? PLACEHOLDER_IMAGE"
              :alt="item.name"
              class="w-14 h-14 rounded-lg object-cover"
            />
            <div class="flex-1 min-w-0">
              <p class="text-sm font-semibold text-gray-900 truncate">{{ item.name }}</p>
              <p class="text-xs text-gray-500">Qty: {{ item.quantity }}</p>
              <p class="text-xs text-gray-500">₱{{ formatCurrency(item.price) }}</p>
            </div>
            <p class="text-sm font-semibold text-gray-900">
              ₱{{ formatCurrency(item.price * item.quantity) }}
            </p>
          </article>

          <div v-if="!cartItems.length" class="text-sm text-gray-400 text-center py-10 border rounded-xl">
            No items in cart.
          </div>
        </div>

        <div class="mt-4 border-t pt-4 text-sm text-gray-600 space-y-2">
          <div class="flex justify-between">
            <span>Subtotal</span>
            <span>₱{{ formatCurrency(subtotal) }}</span>
          </div>
          <div class="flex justify-between">
            <span>VAT (12%)</span>
            <span>₱{{ formatCurrency(vat) }}</span>
          </div>
          <div class="flex justify-between">
            <span>Delivery Fee</span>
            <span>₱{{ formatCurrency(deliveryFee) }}</span>
          </div>
          <div class="flex justify-between">
            <span>Convenience Fee</span>
            <span>₱{{ formatCurrency(convenienceFee) }}</span>
          </div>
          <div class="flex justify-between font-semibold text-gray-900 text-base pt-2 border-t">
            <span>Grand Total</span>
            <span>₱{{ formatCurrency(grandTotal) }}</span>
          </div>
        </div>
      </aside>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import type { ProductItem } from '@/types/product'

const PLACEHOLDER_IMAGE = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=='

interface CartItem extends ProductItem {
  quantity: number
}

const props = defineProps<{
  cartItems: CartItem[]
}>()

const emit = defineEmits<{
  back: []
  cancel: []
  placeOrder: [payload: CheckoutPayload]
}>()

interface CheckoutPayload {
  items: CartItem[]
  customer: CustomerDetails
  address: AddressDetails
  paymentMethod: string
  couponCode: string
  totals: {
    subtotal: number
    vat: number
    deliveryFee: number
    convenienceFee: number
    grandTotal: number
  }
}

interface CustomerDetails {
  email: string
  mobile: string
  firstName: string
  lastName: string
}

interface AddressDetails {
  country: string
  province: string
  city: string
  street: string
  barangay: string
  roomUnit: string
  floor: string
  building: string
  landmark: string
  remarks: string
}

const customer = reactive<CustomerDetails>({
  email: '',
  mobile: '',
  firstName: '',
  lastName: '',
})

const address = reactive<AddressDetails>({
  country: 'Philippines',
  province: '',
  city: '',
  street: '',
  barangay: '',
  roomUnit: '',
  floor: '',
  building: '',
  landmark: '',
  remarks: '',
})

const paymentOptions = ['Cash', 'GCash', 'Card'] as const
const paymentMethod = ref<string>('Cash')
const couponCode = ref('')
const errorMessage = ref('')
const isPlacingOrder = ref(false)

const errors = reactive<Record<string, string>>({
  email: '',
  mobile: '',
  firstName: '',
  lastName: '',
  country: '',
  province: '',
  city: '',
  street: '',
  barangay: '',
})

const hasItems = computed(() => props.cartItems.length > 0)

const subtotal = computed(() => {
  return props.cartItems.reduce((sum, item) => sum + item.price * item.quantity, 0)
})

const vatRate = 0.12
const vat = computed(() => subtotal.value * vatRate)
const deliveryFee = computed(() => (hasItems.value ? 50 : 0))
const convenienceFee = computed(() => (hasItems.value ? 10 : 0))
const grandTotal = computed(() => subtotal.value + vat.value + deliveryFee.value + convenienceFee.value)

const formatCurrency = (amount: number) => {
  if (!Number.isFinite(amount)) return '0.00'
  return amount.toLocaleString('en-PH', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })
}

const validateForm = (): boolean => {
  let isValid = true
  
  // Clear previous errors
  Object.keys(errors).forEach(key => {
    errors[key] = ''
  })
  errorMessage.value = ''

  // Validate customer information
  if (!customer.email.trim()) {
    errors.email = 'Email is required'
    isValid = false
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(customer.email)) {
    errors.email = 'Invalid email format'
    isValid = false
  }

  if (!customer.mobile.trim()) {
    errors.mobile = 'Mobile number is required'
    isValid = false
  }

  if (!customer.firstName.trim()) {
    errors.firstName = 'First name is required'
    isValid = false
  }

  if (!customer.lastName.trim()) {
    errors.lastName = 'Last name is required'
    isValid = false
  }

  // Validate address
  if (!address.country.trim()) {
    errors.country = 'Country is required'
    isValid = false
  }

  if (!address.province.trim()) {
    errors.province = 'Province is required'
    isValid = false
  }

  if (!address.city.trim()) {
    errors.city = 'City is required'
    isValid = false
  }

  if (!address.street.trim()) {
    errors.street = 'Street is required'
    isValid = false
  }

  if (!address.barangay.trim()) {
    errors.barangay = 'Barangay is required'
    isValid = false
  }

  if (!isValid) {
    errorMessage.value = 'Please fill in all required fields.'
  }

  return isValid
}

const placeOrder = async () => {
  if (!validateForm()) {
    return
  }

  if (!hasItems.value) {
    errorMessage.value = 'Your cart is empty.'
    return
  }

  isPlacingOrder.value = true

  try {
    const payload: CheckoutPayload = {
      items: props.cartItems,
      customer: { ...customer },
      address: { ...address },
      paymentMethod: paymentMethod.value,
      couponCode: couponCode.value.trim(),
      totals: {
        subtotal: subtotal.value,
        vat: vat.value,
        deliveryFee: deliveryFee.value,
        convenienceFee: convenienceFee.value,
        grandTotal: grandTotal.value,
      },
    }

    emit('placeOrder', payload)
  } catch (error) {
    console.error('Error placing order:', error)
    errorMessage.value = 'Failed to place order. Please try again.'
  } finally {
    isPlacingOrder.value = false
  }
}
</script>

<style scoped>
/* Smooth scrolling for order summary */
.overflow-y-auto {
  scrollbar-width: thin;
  scrollbar-color: #cbd5e0 #f7fafc;
}

.overflow-y-auto::-webkit-scrollbar {
  width: 6px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: #f7fafc;
  border-radius: 10px;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background: #cbd5e0;
  border-radius: 10px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: #a0aec0;
}
</style>
