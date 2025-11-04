<template>
  <div class="space-y-6">
    <!-- Top Nav -->
    <div class="flex items-center text-sm text-blue-500 gap-2">
      <button class="flex items-center gap-1" @click="emit('back')">
        <span class="text-lg">&larr;</span>
        <span>Back</span>
      </button>
      <span class="text-gray-400">|</span>
      <span class="text-gray-500">Checkout Details</span>
    </div>

    <div class="grid grid-cols-1 xl:grid-cols-[2fr_1fr] gap-6">
      <!-- Left: Customer and Address Form -->
      <section class="bg-white rounded-2xl shadow-sm p-6 space-y-6">
        <h2 class="text-lg font-semibold text-gray-900">Customer Information</h2>

        <div class="grid sm:grid-cols-2 gap-4">
          <div>
            <label class="block text-xs text-gray-500 mb-1">Email</label>
            <select
              v-if="hasCustomerList"
              v-model="selectedCustomerId"
              :disabled="customersLoading"
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
            >
              <option :value="null" disabled>Select customer email</option>
              <option
                v-for="record in customers"
                :key="`email-${record.id}`"
                :value="record.id"
              >
                {{ record.email || 'No email on file' }}
              </option>
            </select>
            <input
              v-else
              v-model="customer.email"
              type="email"
              placeholder="name@example.com"
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
            />
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Mobile Number</label>
            <select
              v-if="hasCustomerList"
              v-model="selectedCustomerId"
              :disabled="customersLoading"
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
            >
              <option :value="null" disabled>Select customer mobile</option>
              <option
                v-for="record in customers"
                :key="`mobile-${record.id}`"
                :value="record.id"
              >
                {{ record.phoneNumber || 'No mobile on file' }}
              </option>
            </select>
            <input
              v-else
              v-model="customer.mobile"
              type="tel"
              placeholder="+63 9xx xxx xxxx"
              class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"
            />
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">First Name</label>
            <input v-model="customer.firstName" type="text" placeholder="First Name" class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"/>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Last Name</label>
            <input v-model="customer.lastName" type="text" placeholder="Last Name" class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"/>
          </div>
        </div>

        <div>
          <h3 class="text-base font-semibold text-gray-900">Payment Method</h3>
          <p class="text-sm text-gray-500">Choose how the customer will pay for this order.</p>
          <div class="mt-4 grid gap-3 sm:grid-cols-3">
            <label
              v-for="option in paymentOptions"
              :key="option"
              class="flex items-center gap-2 border rounded-lg px-3 py-2 cursor-pointer hover:border-orange-300"
              :class="paymentMethod === option ? 'border-orange-400 bg-orange-50 text-orange-600' : 'border-gray-200 text-gray-700'"
            >
              <input
                v-model="paymentMethod"
                type="radio"
                :value="option"
                class="text-orange-500 focus:ring-orange-400"
              />
              <span class="text-sm font-medium">{{ option }}</span>
            </label>
          </div>
        </div>

        <h2 class="text-lg font-semibold text-gray-900">Delivery & Billing Information</h2>

        <div class="grid sm:grid-cols-2 gap-4">
          <div>
            <label class="block text-xs text-gray-500 mb-1">Country</label>
            <input v-model="address.country" class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200">
              <option value="Philippines">Philippines</option>
          </input>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Province</label>
            <input v-model="address.province" type="text" placeholder="NCR" class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"/>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">City</label>
            <input v-model="address.city" type="text" placeholder="City/Municipality" class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"/>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Street</label>
            <input v-model="address.street" type="text" placeholder="Street" class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"/>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Barangay</label>
            <input v-model="address.barangay" type="text" placeholder="Barangay" class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"/>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Room / Unit</label>
            <input v-model="address.roomUnit" type="text" placeholder="Unit" class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"/>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Floor</label>
            <input v-model="address.floor" type="text" placeholder="Floor" class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"/>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Building</label>
            <input v-model="address.building" type="text" placeholder="Building" class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"/>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Nearest Landmark</label>
            <input v-model="address.landmark" type="text" placeholder="Landmark" class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"/>
          </div>
          <div>
            <label class="block text-xs text-gray-500 mb-1">Remarks</label>
            <input v-model="address.remarks" type="text" placeholder="Optional" class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"/>
          </div>
        </div>

        <div class="grid sm:grid-cols-2 gap-4 pt-2">
          <div>
            <label class="block text-xs text-gray-500 mb-1">Coupon or Promo Code</label>
            <input v-model="coupon" type="text" placeholder="Type here" class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-200"/>
          </div>
        </div>

        <div v-if="errorMessage" class="mt-4 text-sm text-red-500 bg-red-50 border border-red-100 rounded-lg px-3 py-2">
          {{ errorMessage }}
        </div>

        <div class="mt-6 flex gap-3">
          <button class="bg-gray-100 text-gray-700 py-2 px-4 rounded-lg font-medium" @click="emit('cancel')">Cancel</button>
          <button
            class="bg-orange-500 text-white py-2 px-4 rounded-lg font-medium disabled:opacity-60 disabled:cursor-not-allowed"
            :disabled="!hasItems"
            @click="placeOrder"
          >
            Place Order
          </button>
        </div>
      </section>

      <!-- Right: Order Summary -->
      <aside class="bg-white rounded-2xl shadow-sm p-6 flex flex-col">
        <div class="space-y-4 flex-1 overflow-y-auto pr-1">
          <article v-for="item in items" :key="item.product.id" class="flex items-start gap-3 border rounded-xl p-3">
            <div class="w-14 h-14 rounded-lg flex items-center justify-center text-2xl bg-blue-50 text-blue-500">
              {{ item.product.icon }}
            </div>
            <div class="flex-1">
              <p class="text-sm font-semibold text-gray-900">{{ item.product.name }}</p>
              <p class="text-xs text-gray-500">Qty: {{ item.quantity }}</p>
              <p class="text-xs text-gray-500">₱{{ formatCurrency(item.product.price) }}</p>
            </div>
          </article>

          <div v-if="!items.length" class="text-sm text-gray-400 text-center py-10 border rounded-xl">
            No items in order.
          </div>
        </div>

        <div class="mt-4 border-t pt-4 text-sm text-gray-600 space-y-2">
          <div class="flex justify-between"><span>Total</span><span>₱{{ formatCurrency(totals.subtotal) }}</span></div>
          <div class="flex justify-between"><span>VAT</span><span>₱{{ formatCurrency(totals.vat) }}</span></div>
          <div class="flex justify-between"><span>Delivery Fee</span><span>₱{{ formatCurrency(totals.deliveryFee) }}</span></div>
          <div class="flex justify-between"><span>Convenience Fee</span><span>₱{{ formatCurrency(totals.convenienceFee) }}</span></div>
          <div class="flex justify-between font-semibold text-gray-900 text-base pt-2 border-t">
            <span>Grand Total</span>
            <span>₱{{ formatCurrency(totals.grandTotal) }}</span>
          </div>
        </div>
      </aside>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import { GET_CUSTOMERS_QUERY } from '@/graphql'

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

const props = defineProps<{
  items: CartEntry[]
  totals: { subtotal: number; vat: number; deliveryFee: number; convenienceFee: number; grandTotal: number }
  couponCode?: string
}>()

const emit = defineEmits<{
  (e: 'place-order', payload: {
    couponCode: string
    customer: CustomerInfo
    address: AddressInfo
    paymentMethod: PaymentOption
    customerId?: number
  }): void
  (e: 'cancel'): void
  (e: 'back'): void
}>()

interface CustomerInfo {
  email: string
  mobile: string
  firstName: string
  lastName: string
}

interface AddressInfo {
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

interface CustomerRecord {
  id: number
  email: string
  firstName: string
  lastName: string
  phoneNumber: string
}

const customer = ref<CustomerInfo>({ email: '', mobile: '', firstName: '', lastName: '' })
const address = ref<AddressInfo>({
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

const paymentOptions = ['GCash', 'Cash on Delivery', 'Bank Transfer'] as const
type PaymentOption = (typeof paymentOptions)[number]
const paymentMethod = ref<PaymentOption>('GCash')

const customers = ref<CustomerRecord[]>([])
const selectedCustomerId = ref<number | null>(null)

const { result: customersResult, loading: customersLoading, error: customersError } = useQuery(GET_CUSTOMERS_QUERY)

const applySelectedCustomer = (record?: CustomerRecord) => {
  if (!record) return

  customer.value = {
    email: record.email,
    mobile: record.phoneNumber,
    firstName: record.firstName,
    lastName: record.lastName,
  }
}

watch(
  customersResult,
  (value) => {
    const incoming = value?.users ?? []
    customers.value = incoming.map((user: any) => ({
      id: Number(user.id),
      email: user.email ?? '',
      firstName: user.firstName ?? '',
      lastName: user.lastName ?? '',
      phoneNumber: user.phoneNumber ?? '',
    }))

    if (!customers.value.length) {
      selectedCustomerId.value = null
      return
    }

    if (!selectedCustomerId.value) {
      const firstCustomer = customers.value[0]
      if (!firstCustomer) return
      selectedCustomerId.value = firstCustomer.id
      applySelectedCustomer(firstCustomer)
      return
    }

    const current = customers.value.find((customerRecord) => customerRecord.id === selectedCustomerId.value)
    if (current) {
      applySelectedCustomer(current)
    }
  },
  { immediate: true },
)
watch(selectedCustomerId, (newId) => {
  const normalizedId = typeof newId === 'string' ? Number(newId) : newId
  if (!normalizedId) {
    selectedCustomerId.value = null
    return
  }

  if (normalizedId !== newId) {
    selectedCustomerId.value = normalizedId
    return
  }

  const match = customers.value.find((record) => record.id === normalizedId)
  applySelectedCustomer(match)
})

const coupon = ref(props.couponCode ?? '')
const errorMessage = ref('')

const hasCustomerList = computed(() => customers.value.length > 0)
const customersErrorMessage = computed(() => customersError.value?.message ?? 'Unable to load customers.')

watch(
  () => props.couponCode,
  (value) => {
    if (value !== undefined) {
      coupon.value = value
    }
  },
)

const hasItems = computed(() => props.items.length > 0)

const formatCurrency = (amount: number) => {
  if (!Number.isFinite(amount)) return '0.00'
  return amount.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const validatePayload = () => {
  if (!hasItems.value) {
    errorMessage.value = 'Add at least one item to the cart before placing an order.'
    return false
  }
  if (!customer.value.firstName.trim() || !customer.value.lastName.trim()) {
    errorMessage.value = 'Customer first and last name are required.'
    return false
  }
  if (!customer.value.mobile.trim()) {
    errorMessage.value = 'A contact number is required.'
    return false
  }
  if (hasCustomerList.value && !selectedCustomerId.value) {
    errorMessage.value = 'Select a customer before continuing.'
    return false
  }
  if (!address.value.city.trim() || !address.value.street.trim() || !address.value.barangay.trim()) {
    errorMessage.value = 'City, street, and barangay are required for delivery.'
    return false
  }
  if (!paymentMethod.value) {
    errorMessage.value = 'Select a payment method before continuing.'
    return false
  }
  errorMessage.value = ''
  return true
}

const placeOrder = () => {
  if (!validatePayload()) return

  emit('place-order', {
    couponCode: coupon.value.trim(),
    customerId: selectedCustomerId.value ?? undefined,
    customer: {
      email: customer.value.email.trim(),
      mobile: customer.value.mobile.trim(),
      firstName: customer.value.firstName.trim(),
      lastName: customer.value.lastName.trim(),
    },
    address: {
      ...address.value,
      province: address.value.province.trim(),
      city: address.value.city.trim(),
      street: address.value.street.trim(),
      barangay: address.value.barangay.trim(),
      roomUnit: address.value.roomUnit.trim(),
      floor: address.value.floor.trim(),
      building: address.value.building.trim(),
      landmark: address.value.landmark.trim(),
      remarks: address.value.remarks.trim(),
    },
    paymentMethod: paymentMethod.value,
  })
}
</script>
