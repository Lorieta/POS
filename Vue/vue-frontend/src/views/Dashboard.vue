<template>
  <div class="flex h-screen bg-gray-100">
    <!-- Sidebar -->
    <aside class="w-64 bg-white border-r shadow-sm flex flex-col">
      <div class="flex items-center justify-center py-4 border-b">
        <h1 class="text-xl font-bold text-blue-600">ChatGenie</h1>
        <span class="ml-1 text-xs text-gray-500 font-semibold">BETA</span>
      </div>

      <nav class="flex-1 overflow-y-auto mt-4">
        <ul class="text-gray-700 text-sm space-y-1">
          <li
            class="px-6 py-2 hover:bg-blue-50 cursor-pointer"
            :class="{
              'bg-blue-100 text-blue-600 font-semibold rounded-r-full':
                activeSection === sections.CATALOGUE,
            }"
            @click="activeSection = sections.CATALOGUE"
          >
            Catalogue
          </li>
          <li
            class="px-6 py-2 hover:bg-blue-50 cursor-pointer"
            :class="{
              'bg-blue-100 text-blue-600 font-semibold rounded-r-full':
                activeSection === sections.CATEGORIES,
            }"
            @click="activeSection = sections.CATEGORIES"
          >
            Merchant Products
          </li>
         

          <li
            class="px-6 py-2 hover:bg-blue-50 cursor-pointer"
            :class="{
              'bg-blue-100 text-blue-600 font-semibold rounded-r-full':
                activeSection === sections.ORDER_MANAGER || activeSection === sections.ORDER_TRACKER,
            }"
            @click="activeSection = sections.ORDER_MANAGER"
          >
            Order Manager
          </li>
          <ul class="ml-6 text-gray-600 text-sm space-y-1">
            <li>
              <button
                class="text-left w-full hover:text-blue-600"
                :class="{
                  'text-blue-600 font-semibold': activeSection === sections.ORDER_TRACKER,
                  'text-gray-700': activeSection !== sections.ORDER_TRACKER,
                }"
                @click="activeSection = sections.ORDER_TRACKER"
              >
                Order Tracker
              </button>
            </li>
          </ul>
          <li class="px-6 py-2 hover:bg-blue-50 cursor-pointer">Shipping Manager</li>
        </ul>
      </nav>

      <footer class="text-xs text-center text-gray-400 py-4 border-t">
    
      </footer>
    </aside>

    <!-- Main Content -->
    <div class="flex-1 flex flex-col">
      <!-- Top Bar -->
      <Navbar
        :title="navbarState.title"
        :subtitle="navbarState.subtitle"
        :status-text="navbarState.statusText"
        :notifications="navbarState.notifications"
        :cart-items-count="cartItemsCount"
        @view-cart="isCartModalOpen = true"
      />

      <!-- Page Content -->
      <main class="flex-1 p-8 overflow-y-auto">
        <CreateOrder
          v-if="activeSection === sections.ORDER_MANAGER"
          :creating="creatingOrder"
          @back="activeSection = sections.ORDER_TRACKER"
          @cancel="activeSection = sections.ORDER_TRACKER"
          @checkout="handleCheckout"
        />
        <OrderTracker
          v-else-if="activeSection === sections.ORDER_TRACKER"
          :initial-orders="recentOrders"
          @back="activeSection = sections.ORDER_MANAGER"
          @create-order="activeSection = sections.ORDER_MANAGER"
        />

        <ProductsGrid v-else-if="activeSection === sections.CATEGORIES" />
        <Catalogue 
          v-else-if="activeSection === sections.CATALOGUE"
          v-model:cart="catalogueCart"
        />
        <UserCheckout
          v-else-if="activeSection === sections.USER_CHECKOUT"
          :cart-items="catalogueCart"
          @place-order="handleUserCheckoutPlaceOrder"
          @cancel="handleUserCheckoutCancel"
          @back="activeSection = sections.CATALOGUE"
        />
        <!-- Order Placed Success Modal (extracted component) -->
        <OrderPlacedModal
          :show="showOrderPlacedModal"
          :orders="placedOrders"
          :summary="placedSummary"
          @close="showOrderPlacedModal = false"
        />
        
        <!-- Cart Modal -->
        <CartModal
          :is-open="isCartModalOpen"
          :cart="catalogueCart"
          @close="isCartModalOpen = false"
          @update-quantity="updateCartQuantity"
          @remove-item="removeCartItem"
          @checkout="handleCartCheckout"
        />
      </main>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { computed, ref } from 'vue'
import { useMutation } from '@vue/apollo-composable'
import Navbar from '../component/Navbar.vue'
import ProductsGrid from '../component/ProductsGrid.vue'
import OrderTracker from '../component/OrderTracker.vue'
import CreateOrder from '../component/CreateOrder.vue'
import OrderPlacedModal from '../component/OrderPlacedModal.vue'
import Catalogue from '../component/Catalogue.vue'
import CartModal from '../component/CartModal.vue'
import UserCheckout from '../component/UserCheckout.vue'
import { CREATE_ORDER_MUTATION } from '@/graphql'

const sections = {
  ORDER_MANAGER: 'order-manager',
  CATEGORIES: 'categories',
  ORDER_TRACKER: 'order-tracker',
  CATALOGUE: 'catalogue',
  USER_CHECKOUT: 'user-checkout',
} as const

type SectionKey = (typeof sections)[keyof typeof sections]

const activeSection = ref<SectionKey>(sections.ORDER_TRACKER)
const catalogueCart = ref<Array<any>>([])
const isCartModalOpen = ref(false)
const isUserCheckoutOpen = ref(false)

interface NavbarState {
  title: string
  subtitle: string
  statusText: string
  notifications: number
}

interface CheckoutProduct {
  id: number
  name: string
  price: number
}

interface CheckoutItem {
  product: CheckoutProduct
  quantity: number
}

interface CheckoutTotals {
  subtotal: number
  vat: number
  deliveryFee: number
  convenienceFee: number
  grandTotal: number
  couponCode: string
}

interface CheckoutCustomer {
  email?: string
  mobile?: string
  firstName?: string
  lastName?: string
}

interface CheckoutAddress {
  country?: string
  province?: string
  city?: string
  street?: string
  barangay?: string
  roomUnit?: string
  floor?: string
  building?: string
  landmark?: string
  remarks?: string
}

interface CheckoutSummary {
  items: CheckoutItem[]
  totals: CheckoutTotals
  customer?: CheckoutCustomer
  address?: CheckoutAddress
  paymentMethod?: string
}

const { mutate: createOrderMutation } = useMutation(CREATE_ORDER_MUTATION)
const recentOrders = ref<any[]>([])
const creatingOrder = ref(false)

// Order placed modal state
const showOrderPlacedModal = ref(false)
const placedOrders = ref<any[]>([])
const placedSummary = ref<CheckoutSummary | null>(null)

const generatePaymentLink = (order: any) => {
  // Client-side helper: construct a payment URL for the order.
  // If the backend later returns an explicit payment link, prefer that.
  const base = window.location.origin.replace(/\/$/, '')
  return `${base}/pay/${order.id}`
}

const copyToClipboard = async (text: string) => {
  try {
    await navigator.clipboard.writeText(text)
    // A minimal UX feedback could be added here (toast), but keep it lightweight.
    // console.info('Copied to clipboard')
  } catch (e) {
    console.warn('Unable to copy to clipboard', e)
  }
}

const cartItemsCount = computed(() => {
  return catalogueCart.value.reduce((total, item) => total + (item.quantity || 0), 0)
})

const updateCartQuantity = (productId: number, quantity: number) => {
  const item = catalogueCart.value.find(i => i.id === productId)
  if (item) {
    item.quantity = quantity
  }
}

const removeCartItem = (productId: number) => {
  catalogueCart.value = catalogueCart.value.filter(i => i.id !== productId)
}

const handleCartCheckout = () => {
  // Close cart modal and open user checkout
  isCartModalOpen.value = false
  activeSection.value = sections.USER_CHECKOUT
}

const handleUserCheckoutPlaceOrder = async (payload: any) => {
  const userId = localStorage.getItem('userId') ?? undefined

  try {
    creatingOrder.value = true
    recentOrders.value = []
    
    // Generate a single group id for this checkout so all created orders are associated
    const groupId = `grp_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`
    
    for (const item of payload.items) {
      const totalAmount = Number((item.price * item.quantity).toFixed(2))
      const variables: Record<string, unknown> = {
        productId: item.id,
        orderQuantity: item.quantity,
        paymentMethod: payload.paymentMethod,
        totalAmount,
        groupId,
      }

      if (userId) {
        variables.userId = userId
      }

      // Add delivery information from payload.address
      if (payload.address) {
        if (payload.address.country) variables.country = payload.address.country
        if (payload.address.province) variables.province = payload.address.province
        if (payload.address.city) variables.city = payload.address.city
        if (payload.address.street) variables.street = payload.address.street
        if (payload.address.barangay) variables.branggay = payload.address.barangay
        if (payload.address.roomUnit) variables.unit = payload.address.roomUnit
        if (payload.address.floor) variables.floor = payload.address.floor
        if (payload.address.building) variables.building = payload.address.building
        if (payload.address.landmark) variables.landmark = payload.address.landmark
        if (payload.address.remarks) variables.remarks = payload.address.remarks
      }

      const result = await createOrderMutation(variables)
      const errors = result?.data?.createOrder?.errors
      const created = result?.data?.createOrder?.order

      if (errors && errors.length > 0) {
        console.error('Order creation failed', errors)
        return
      }
      if (created) {
        recentOrders.value.push(created)
      }
    }

    // Clear the cart after successful order
    catalogueCart.value = []
    
    // Store created orders and the checkout summary for the success modal
    placedOrders.value = [...recentOrders.value]
    placedSummary.value = {
      items: payload.items.map((item: any) => ({
        product: {
          id: item.id,
          name: item.name,
          price: item.price,
        },
        quantity: item.quantity,
      })),
      totals: payload.totals,
      customer: payload.customer,
      address: payload.address,
      paymentMethod: payload.paymentMethod,
    }

    // Show the modal and navigate to the order tracker
    activeSection.value = sections.ORDER_TRACKER
    showOrderPlacedModal.value = true
  } catch (error) {
    console.error('Unexpected error creating order', error)
  } finally {
    creatingOrder.value = false
  }
}

const handleUserCheckoutCancel = () => {
  activeSection.value = sections.CATALOGUE
}

const navbarState = computed<NavbarState>(() => {
  if (activeSection.value === sections.CATALOGUE) {
    return {
      title: 'Product Catalogue',
      subtitle: 'Browse all products from all merchants',
      statusText: '',
      notifications: 0,
    }
  }

  if (activeSection.value === sections.CATEGORIES) {
    return {
      title: 'Categories & Products',
      subtitle: 'Browse inventory',
      statusText: '',
      notifications: 0,
    }
  }

  if (activeSection.value === sections.ORDER_TRACKER) {
    return {
      title: 'Order Manager',
      subtitle: 'Order Tracker',
      statusText: 'Active',
      notifications: 23,
    }
  }

  return {
    title: 'Order Manager',
    subtitle: 'Create Order',
    statusText: 'Active',
    notifications: 13,
  }
})

const handleCheckout = async (summary: CheckoutSummary) => {
  if (!summary.items.length) {
    console.warn('Skipping order creation: no items in checkout summary.')
    return
  }

  const userId = localStorage.getItem('userId') ?? undefined
  const paymentMethod = summary.paymentMethod ?? 'Cash'

  try {
    creatingOrder.value = true
    recentOrders.value = []
    // Generate a single group id for this checkout so all created orders are associated
    const groupId = `grp_${Date.now()}_${Math.random().toString(36).slice(2,8)}`
    for (const entry of summary.items) {
      const totalAmount = Number((entry.product.price * entry.quantity).toFixed(2))
      const variables: Record<string, unknown> = {
        productId: entry.product.id,
        orderQuantity: entry.quantity,
        paymentMethod,
        totalAmount,
      }

      if (userId) {
        variables.userId = userId
      }

      // include the checkout-level group id so orders created in this loop are grouped
      variables.groupId = groupId

      // Add delivery information from summary.address if available
      if (summary.address) {
        if (summary.address.country) variables.country = summary.address.country
        if (summary.address.province) variables.province = summary.address.province
        if (summary.address.city) variables.city = summary.address.city
        if (summary.address.street) variables.street = summary.address.street
        if (summary.address.barangay) variables.branggay = summary.address.barangay
        if (summary.address.roomUnit) variables.unit = summary.address.roomUnit
        if (summary.address.floor) variables.floor = summary.address.floor
        if (summary.address.building) variables.building = summary.address.building
        if (summary.address.landmark) variables.landmark = summary.address.landmark
        if (summary.address.remarks) variables.remarks = summary.address.remarks
      }

      const result = await createOrderMutation(variables)
      const errors = result?.data?.createOrder?.errors
      const created = result?.data?.createOrder?.order

      if (errors && errors.length > 0) {
        console.error('Order creation failed', errors)
        return
      }
      if (created) {
        // Push the created order into recentOrders for display in OrderTracker
        recentOrders.value.push(created)
      }
    }
  } catch (error) {
    console.error('Unexpected error creating order', error)
    return
  } finally {
    creatingOrder.value = false
  }

  // Store created orders and the checkout summary for the success modal
  placedOrders.value = [...recentOrders.value]
  placedSummary.value = summary

  // Show the modal and navigate to the order tracker behind it so the user can
  // optionally inspect the created orders immediately.
  activeSection.value = sections.ORDER_TRACKER
  showOrderPlacedModal.value = true
}

// Logic and data integration will be added later
</script>
