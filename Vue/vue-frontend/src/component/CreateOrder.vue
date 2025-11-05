<template>
  <div class="space-y-6">
    <div class="flex items-center text-sm text-blue-500 gap-2">
      <button class="flex items-center gap-1" @click="emit('back')">
        <span class="text-lg">&larr;</span>
        <span>Back</span>
      </button>
      <span class="text-gray-400">|</span>
      <span class="text-gray-500">Order Manager</span>
    </div>

    <div class="flex flex-wrap items-start justify-between gap-4">
      <div>
        <h1 class="text-2xl font-semibold text-gray-900">Create Order</h1>
        <div class="mt-3 flex items-center gap-4 text-sm">
          <button
            v-for="tab in tabs"
            :key="tab"
            @click="activeTab = tab"
            :class="[
              'pb-2 border-b-2 font-medium transition-colors',
              activeTab === tab ? 'border-orange-500 text-orange-500' : 'border-transparent text-gray-400 hover:text-gray-600',
            ]"
          >
            {{ tab }}
          </button>
        </div>
      </div>

      <div class="flex flex-wrap items-center gap-3 text-sm">
       
       
      </div>
    </div>

  <div v-if="activeTab === 'Products'" class="grid grid-cols-1 xl:grid-cols-[2fr_1fr] gap-6">
      <section class="bg-white rounded-2xl shadow-sm p-6 space-y-6">
        <header class="flex flex-wrap items-center justify-between gap-4">
          <div class="flex flex-wrap gap-2">
            <button
              v-for="category in categories"
              :key="category"
              @click="activeCategory = category"
              :class="[
                'px-4 py-2 rounded-full border transition-colors text-sm font-medium',
                activeCategory === category
                  ? 'bg-blue-500 border-blue-500 text-white'
                  : 'bg-blue-50 text-blue-500 border-transparent hover:bg-blue-100',
              ]"
            >
              {{ category }}
            </button>
          </div>
          <div class="flex flex-wrap items-center gap-3 text-sm">
            <div class="relative">
              <input
                v-model="searchTerm"
                type="text"
                placeholder="Search"
                class="pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-200"
              />
              <span class="absolute inset-y-0 left-3 flex items-center text-gray-400">🔍</span>
            </div>
        
          </div>
        </header>

        <template v-if="productsLoading">
          <div class="py-10 text-center text-sm text-gray-500">Loading products...</div>
        </template>
        <template v-else-if="productsError">
          <div class="py-10 text-center text-sm text-red-500">
            {{ productsErrorMessage }}
          </div>
        </template>
        <template v-else>
          <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
            <article
              v-for="product in filteredProducts"
              :key="product.id"
              class="border rounded-2xl p-4 shadow-sm hover:shadow-md transition-shadow bg-white"
            >
              <div
                class="h-32 rounded-xl flex items-center justify-center text-4xl mb-4 text-gray-700 overflow-hidden"
                :class="product.image ? 'bg-gray-50' : product.accent"
              >
                <img
                  v-if="product.image"
                  :src="product.image"
                  :alt="product.name"
                  class="h-full w-full object-cover"
                />
                <span v-else>{{ product.icon }}</span>
              </div>
              <h3 class="text-base font-semibold text-gray-900">{{ product.name }}</h3>
              <p class="text-sm text-gray-500 leading-snug">{{ product.description }}</p>
              <p class="mt-3 text-lg font-semibold text-gray-900">₱{{ formatCurrency(product.price) }}</p>
              <button
                class="mt-4 w-full flex items-center justify-center gap-2 bg-blue-500 text-white py-2 rounded-lg text-sm font-medium hover:bg-blue-600"
                @click="addToCart(product)"
              >
                <span>🛒</span>
                <span>{{ cart[product.id] ? 'Add Another' : 'Add to Cart' }}</span>
              </button>
            </article>
          </div>

          <p v-if="!filteredProducts.length" class="text-center text-sm text-gray-500 pt-6">
            No products match your search.
          </p>
        </template>
      </section>

      <aside class="bg-white rounded-2xl shadow-sm p-6 flex flex-col">
        <div class="flex items-center justify-between">
          <h2 class="text-lg font-semibold text-gray-900">Cart</h2>
          <span class="text-sm text-gray-500">{{ cartCount }} item{{ cartCount === 1 ? '' : 's' }}</span>
        </div>

        <div class="mt-4 space-y-4 flex-1 overflow-y-auto pr-1">
          <div
            v-for="item in cartItems"
            :key="item.product.id"
            class="flex items-start gap-3 border rounded-xl p-3"
          >
            <div class="w-14 h-14 rounded-lg overflow-hidden flex-shrink-0">
              <img
                v-if="item.product.image"
                :src="item.product.image"
                :alt="item.product.name"
                class="w-full h-full object-cover"
              />
              <div v-else class="w-full h-full flex items-center justify-center text-2xl bg-blue-50 text-blue-500">
                {{ item.product.icon }}
              </div>
            </div>
            <div class="flex-1">
              <p class="text-sm font-semibold text-gray-900">{{ item.product.name }}</p>
              <p class="text-xs text-gray-500">₱{{ formatCurrency(item.product.price) }}</p>
              <div class="mt-2 inline-flex items-center gap-3 text-sm">
                <button
                  class="w-7 h-7 border rounded-full flex items-center justify-center text-gray-600 hover:bg-gray-100"
                  @click="decrementItem(item.product.id)"
                  aria-label="Decrease quantity"
                >
                  -
                </button>
                <span class="w-6 text-center font-medium">{{ item.quantity }}</span>
                <button
                  class="w-7 h-7 border rounded-full flex items-center justify-center text-gray-600 hover:bg-gray-100"
                  @click="incrementItem(item.product.id)"
                  aria-label="Increase quantity"
                >
                  +
                </button>
              </div>
            </div>
            <button class="text-xs text-red-500 hover:text-red-600" @click="removeItem(item.product.id)">
              Remove
            </button>
          </div>

          <div v-if="!cartItems.length" class="text-sm text-gray-400 text-center py-10 border rounded-xl">
            Your cart is empty.
          </div>
        </div>

        <div class="mt-4">
          <input
            v-model="couponCode"
            type="text"
            placeholder="Coupon or Promo Code"
            class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
          />
        </div>

        <div class="mt-4 border-t pt-4 text-sm text-gray-600 space-y-2">
          <div class="flex justify-between">
            <span>Total</span>
            <span>₱{{ formatCurrency(subtotal) }}</span>
          </div>
          <div class="flex justify-between">
            <span>VAT</span>
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

        <div class="mt-6 grid grid-cols-2 gap-3">
          <button
            class="bg-orange-500 text-white py-2 rounded-lg font-medium disabled:opacity-60 disabled:cursor-not-allowed"
            :disabled="!cartItems.length || props.creating"
            @click="handleCheckout"
            :aria-busy="props.creating ? 'true' : 'false'"
          >
            <span v-if="props.creating">Creating...</span>
            <span v-else>Checkout</span>
          </button>
          <button class="bg-gray-100 text-gray-700 py-2 rounded-lg font-medium" @click="handleCancel">
            Cancel
          </button>
        </div>
      </aside>
    </div>

    <!-- Checkout Details View -->
    <div v-else>
      <CheckoutDetails
        :items="cartItems"
        :totals="totals"
        :coupon-code="couponCode"
        @place-order="onPlaceOrder"
        @cancel="handleCancel"
        @back="activeTab = 'Products'"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watchEffect } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import { GET_ALL_PRODUCTS_QUERY } from '@/graphql'
import CheckoutDetails from './CheckoutDetails.vue'

const emit = defineEmits<{
  (event: 'back'): void
  (event: 'cancel'): void
  (event: 'checkout', summary: CheckoutSummary): void
}>()

const props = defineProps<{
  creating?: boolean
}>()

const tabs = ['Products', 'Checkout Details'] as const

const activeTab = ref<(typeof tabs)[number]>('Products')
const activeCategory = ref<string>('All')
const searchTerm = ref('')
const couponCode = ref('')

interface Product {
  id: number
  name: string
  description: string
  price: number
  category: string
  productType: string | null
  icon: string
  accent: string
  image: string | null
}

interface CartEntry {
  product: Product
  quantity: number
}

interface CheckoutSummary {
  items: CartEntry[]
  totals: {
    subtotal: number
    vat: number
    deliveryFee: number
    convenienceFee: number
    grandTotal: number
    couponCode: string
  }
  customer?: CustomerDetails
  address?: AddressDetails
  paymentMethod?: string
  customerId?: number
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

const { result: productsResult, loading: productsLoading, error: productsError } = useQuery(GET_ALL_PRODUCTS_QUERY)

const productsErrorMessage = computed(() => productsError.value?.message ?? 'Unable to load products.')

const categoryVisuals: Record<string, { icon: string; accent: string }> = {
  Books: { icon: '�', accent: 'bg-gradient-to-br from-green-100 to-green-200' },
  Comics: { icon: '�', accent: 'bg-gradient-to-br from-purple-100 to-purple-200' },
}

const defaultVisuals = { icon: '�', accent: 'bg-gradient-to-br from-slate-100 to-slate-200' }

const productCatalog = ref<Product[]>([])

watchEffect(() => {
  const products = productsResult.value?.allProducts ?? []

  productCatalog.value = products.map((product: any) => {
    const category = product.category ?? product.productType ?? 'Uncategorized'
    const visuals = categoryVisuals[category] ?? defaultVisuals

    return {
      id: Number(product.id),
      name: product.name ?? 'Untitled Product',
      description: product.description ?? '',
      price: Number(product.productPrice ?? 0),
      category,
      productType: product.productType ?? null,
      icon: visuals.icon,
      accent: visuals.accent,
      image: product.imageUrl ?? product.productPhoto ?? null,
    }
  })
})

const categories = computed(() => {
  const unique = new Set(productCatalog.value.map((product) => product.category))
  return ['All', ...Array.from(unique)]
})

watchEffect(() => {
  if (!categories.value.includes(activeCategory.value)) {
    activeCategory.value = 'All'
  }
})

const cart = ref<Record<number, CartEntry>>({})

const filteredProducts = computed(() => {
  const query = searchTerm.value.trim().toLowerCase()
  return productCatalog.value.filter((product) => {
    const matchesCategory = activeCategory.value === 'All' || product.category === activeCategory.value
    const matchesQuery = !query || product.name.toLowerCase().includes(query) || product.description.toLowerCase().includes(query)
    return matchesCategory && matchesQuery
  })
})

const cartItems = computed<CartEntry[]>(() => Object.values(cart.value))
const cartCount = computed(() => cartItems.value.reduce((total, entry) => total + entry.quantity, 0))

const subtotal = computed(() => cartItems.value.reduce((total, entry) => total + entry.product.price * entry.quantity, 0))
const vatRate = 0.12
const vat = computed(() => subtotal.value * vatRate)
const deliveryFee = computed(() => (cartItems.value.length ? 50 : 0))
const convenienceFee = computed(() => (cartItems.value.length ? 10 : 0))
const grandTotal = computed(
  () => subtotal.value + vat.value + deliveryFee.value + convenienceFee.value,
)

const totals = computed(() => ({
  subtotal: subtotal.value,
  vat: vat.value,
  deliveryFee: deliveryFee.value,
  convenienceFee: convenienceFee.value,
  grandTotal: grandTotal.value,
}))

const addToCart = (product: Product) => {
  const current = cart.value[product.id]
  if (current) {
    current.quantity += 1
    return
  }
  cart.value[product.id] = { product, quantity: 1 }
}

const incrementItem = (productId: number) => {
  const entry = cart.value[productId]
  if (!entry) return
  entry.quantity += 1
}

const decrementItem = (productId: number) => {
  const entry = cart.value[productId]
  if (!entry) return
  if (entry.quantity === 1) {
    delete cart.value[productId]
    return
  }
  entry.quantity -= 1
}

const removeItem = (productId: number) => {
  if (cart.value[productId]) {
    delete cart.value[productId]
  }
}

const formatCurrency = (amount: number) => {
  if (!Number.isFinite(amount)) return '0.00'
  return amount.toLocaleString('en-PH', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })
}

const resetCart = () => {
  cart.value = {}
  couponCode.value = ''
}

const handleCheckout = () => {
  if (!cartItems.value.length) return
  // Navigate to Checkout Details tab
  activeTab.value = 'Checkout Details'
}

const handleCancel = () => {
  resetCart()
  emit('cancel')
}

const onPlaceOrder = (payload: {
  couponCode?: string
  customer?: CustomerDetails
  address?: AddressDetails
  paymentMethod?: string
  customerId?: number
}) => {
  if (payload.couponCode !== undefined) {
    couponCode.value = payload.couponCode
  }
  // Merge payload coupon with computed totals/items and emit unified checkout summary
  emit('checkout', {
    items: cartItems.value,
    totals: {
      subtotal: subtotal.value,
      vat: vat.value,
      deliveryFee: deliveryFee.value,
      convenienceFee: convenienceFee.value,
      grandTotal: grandTotal.value,
      couponCode: payload.couponCode ?? couponCode.value.trim(),
    },
    customer: payload.customer,
    address: payload.address,
    paymentMethod: payload.paymentMethod,
    customerId: payload.customerId,
  })
}

const grabCredit = 5000
const creditApprovedOn = '01-12-21'
const currentFees = 0
const previousFees = 10000
</script>
