<template>
  <div class="space-y-6">
    <div class="flex items-center text-sm text-blue-500 gap-2">
  <button class="flex items-center gap-1" @click="handleBack">
        <span class="text-lg">&larr;</span>
        <span>Back</span>
      </button>
      <span class="text-gray-400">|</span>
      <span class="text-gray-500">Order Manager</span>
    </div>

    <div class="flex flex-wrap items-start justify-between gap-4">
      <div>
        <h1 class="text-2xl font-semibold text-gray-900">Order Tracker</h1>
        <p class="text-sm text-gray-500">View and track all your orders here.</p>
      </div>

      <div class="flex flex-wrap items-center gap-3 text-sm">
        
     
        <button
          class="bg-orange-100 text-orange-600 px-4 py-2 rounded-lg font-medium"
          @click="handleCreateOrder"
        >
          Create Order
        </button>
    
      </div>
    </div>

    <div class="grid grid-cols-1 xl:grid-cols-[2fr_1fr] gap-6">
      <section class="bg-white rounded-2xl shadow-sm">
        <header class="flex items-end justify-between px-6 pt-6 pb-4 border-b">
          <div>
            <h2 class="text-lg font-semibold text-gray-900">Pending Orders</h2>
            <p class="text-sm text-gray-500">
              <span class="text-orange-500 font-semibold text-lg">{{ filteredOrders.length }}</span>
              orders awaiting fulfilment
            </p>
          </div>
          <div class="flex flex-wrap gap-2 text-sm">
            <button
              v-for="status in statusTabs"
              :key="status"
              @click="activeStatus = status"
              :class="[
                'px-3 py-2 rounded-full border',
                activeStatus === status
                  ? 'border-blue-500 text-blue-600 bg-blue-50'
                  : 'border-transparent text-gray-500 hover:bg-gray-100',
              ]"
            >
              {{ status }}
            </button>
          </div>
        </header>

        <div class="overflow-x-auto">
          <table class="min-w-full text-sm text-gray-700">
            <thead class="bg-gray-50 text-xs uppercase text-gray-500">
              <tr>
                <th v-for="column in tableHeaders" :key="column" class="px-6 py-3 text-left font-medium">
                  {{ column }}
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="ordersLoading">
                <td :colspan="tableHeaders.length" class="px-6 py-6 text-center text-sm text-gray-500">
                  Loading orders...
                </td>
              </tr>
              <tr v-else-if="ordersError">
                <td :colspan="tableHeaders.length" class="px-6 py-6 text-center text-sm text-red-500">
                  Unable to load orders: {{ ordersError.message || 'Unknown error' }}
                </td>
              </tr>
              <template v-else>
                <tr
                  v-for="order in filteredOrders"
                  :key="order.referenceId"
                  @click="openEdit(order)"
                  :class="[
                    'border-t hover:bg-blue-50 cursor-pointer transition-colors',
                    selectedOrder?.referenceId === order.referenceId ? 'bg-blue-50' : 'bg-white',
                  ]"
                >
                  <td class="px-6 py-4 font-medium text-gray-900">{{ order.referenceId }}</td>
                  <td class="px-6 py-4">{{ order.productName }}</td>
                  <td class="px-6 py-4">{{ order.customerName }}</td>
                  <td class="px-6 py-4 font-semibold">₱{{ formatCurrency(order.totalAmount) }}</td>
                  <td class="px-6 py-4">
                    <span class="inline-flex items-center gap-1 px-2 py-1 rounded-full bg-gray-100 text-xs font-medium">
                      <span>{{ order.salesChannelIcon }}</span>
                      <span>{{ order.salesChannel }}</span>
                    </span>
                  </td>
                  <td class="px-6 py-4">{{ order.paymentMethod }}</td>
                  <td class="px-6 py-4">{{ order.orderDate }}</td>
                </tr>
              </template>
            </tbody>
          </table>
        </div>

        <!-- Edit Order Modal -->
        <div v-if="isEditModalOpen" class="fixed inset-0 z-40 flex items-center justify-center">
          <div class="absolute inset-0 bg-black/40" @click="closeEdit"></div>
          <div class="relative bg-white rounded-lg shadow-lg w-full max-w-2xl p-6 z-50">
            <h3 class="text-lg font-semibold mb-4">Edit Order {{ editingOrder?.referenceId }}</h3>

            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="text-xs text-gray-500">Product Name</label>
                <input v-model="editingOrder!.productName" class="w-full mt-1 border rounded px-3 py-2 text-sm" />
              </div>

              <div>
                <label class="text-xs text-gray-500">Customer Name</label>
                <input v-model="editingOrder!.customerName" class="w-full mt-1 border rounded px-3 py-2 text-sm" />
              </div>

              <div>
                <label class="text-xs text-gray-500">Total Amount</label>
                <input v-model.number="editingOrder!.totalAmount" type="number" step="0.01" class="w-full mt-1 border rounded px-3 py-2 text-sm" />
              </div>

              <div>
                <label class="text-xs text-gray-500">Payment Method</label>
                <input v-model="editingOrder!.paymentMethod" class="w-full mt-1 border rounded px-3 py-2 text-sm" />
              </div>

              <div>
                <label class="text-xs text-gray-500">Status</label>
                <select v-model="editingOrder!.status" class="w-full mt-1 border rounded px-3 py-2 text-sm">
                  <option v-for="s in statusTabs" :key="s" :value="s">{{ s }}</option>
                </select>
              </div>

              <div>
                <label class="text-xs text-gray-500">Order Date</label>
                <input v-model="editingOrder!.orderDateIso" type="date" class="w-full mt-1 border rounded px-3 py-2 text-sm" />
              </div>
            </div>

            <p v-if="saveError" class="mt-4 text-sm text-red-500">{{ saveError }}</p>

            <div class="mt-6 flex justify-end gap-3">
              <button @click="closeEdit" class="px-4 py-2 rounded border text-sm">Cancel</button>
              <button
                @click="saveEdit"
                :disabled="savingEdit"
                class="px-4 py-2 rounded bg-blue-600 text-white text-sm"
                :class="savingEdit ? 'opacity-60 cursor-not-allowed' : ''"
              >
                {{ savingEdit ? 'Saving...' : 'Save' }}
              </button>
            </div>
          </div>
        </div>

        <footer class="flex items-center justify-between px-6 py-4 border-t text-sm text-gray-500">
          <div class="flex items-center gap-2">
            <button class="w-9 h-9 border rounded-lg flex items-center justify-center">⟨</button>
            <span>1 of 12</span>
            <button class="w-9 h-9 border rounded-lg flex items-center justify-center">⟩</button>
          </div>
          <div class="flex items-center gap-2">
          </div>
        </footer>
      </section>

      <aside class="bg-white rounded-2xl shadow-sm p-6 space-y-4">
        <div class="flex items-start gap-3">
          <div class="w-16 h-16 rounded-lg bg-blue-100 flex items-center justify-center text-3xl">📘</div>
          <div>
            <p class="text-sm text-gray-500">{{ selectedOrder?.productName }}</p>
            <p class="text-sm text-gray-500">Size: {{ selectedOrder?.size }}</p>
            <p class="text-sm text-gray-500">Quantity {{ selectedOrder?.quantity }}</p>
            <p class="text-base font-semibold text-gray-900">₱{{ formatCurrency(selectedOrder?.unitPrice || 0) }}</p>
          </div>
        </div>

        <div class="space-y-2 text-sm text-gray-600">
          <div class="flex justify-between">
            <span>Status</span>
            <span class="text-green-500 font-semibold">{{ selectedOrder?.status }}</span>
          </div>
          <div class="flex justify-between">
           
          </div>
          <div class="flex justify-between">
            <span>Reference Number</span>
            <span>{{ selectedOrder?.referenceNumber }}</span>
          </div>
          <div class="flex justify-between">
            <span>Ordered On</span>
            <span>{{ selectedOrder?.orderedOn }}</span>
          </div>
          <div class="flex justify-between">
            <span>Sales Channel</span>
            <span>{{ selectedOrder?.salesChannel }}</span>
          </div>
          <div class="flex justify-between">
            <span>Paid With</span>
            <span>{{ selectedOrder?.paymentMethod }}</span>
          </div>
          <div class="flex justify-between">
            <span>Shipping Method</span>
            <span>{{ selectedOrder?.shippingMethod }}</span>
          </div>
        </div>

        <!-- Confirm / Complete actions -->
        <div>
          <button
            v-if="selectedOrder?.status === 'Pending'"
            @click="handleConfirmSelectedOrder"
            :disabled="confirming"
            class="w-full mb-2 border bg-green-50 border-green-400 text-green-700 rounded-lg py-2 text-sm font-medium"
          >
            <span v-if="!confirming">Confirm Order</span>
            <span v-else>Confirming...</span>
          </button>

          <button
            v-if="selectedOrder && selectedOrder.status === 'For Delivery'"
            @click="handleMarkCompletedSelectedOrder"
            :disabled="completing"
            class="w-full mb-2 border bg-blue-50 border-blue-400 text-blue-700 rounded-lg py-2 text-sm font-medium"
          >
            <span v-if="!completing">Mark as Completed</span>
            <span v-else>Completing...</span>
          </button>

                    <button
                      class="w-full border border-orange-400 text-orange-500 rounded-lg py-2 text-sm font-medium disabled:opacity-60 disabled:cursor-not-allowed"
                      @click="handleSendPaymentInvoice"
                      :disabled="!selectedOrder || sendingInvoice"
                    >
                      <span v-if="sendingInvoice">Sending...</span>
                      <span v-else>Send Messenger Payment Invoice</span>
                    </button>
                    <p v-if="sendInvoiceError" class="mt-2 text-xs text-red-500">{{ sendInvoiceError }}</p>
                    <p v-else-if="sendInvoiceSuccess" class="mt-2 text-xs text-green-600">
                      Payment confirmation email queued successfully.
                    </p>
        </div>

        <div class="grid grid-cols-2 gap-3 text-xs text-gray-500">
          <div>
            
            
          </div>
          <div>
            <p class="uppercase text-gray-400 font-semibold">Proof of Order Delivery</p>
           
          </div>
        </div>

        <div class="text-xs text-gray-400">
          Link updated: {{ lastUpdated }}
        </div>
      </aside>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useMutation, useQuery } from '@vue/apollo-composable'
import { GET_ORDERS_QUERY, SEND_ORDER_EMAILS_MUTATION, UPDATE_ORDER_MUTATION } from '@/graphql'

const props = defineProps<{
  initialOrders?: any[]
}>()

const emit = defineEmits<{
  (event: 'back'): void
  (event: 'create-order'): void
}>()

type OrderStatus = 'Pending' | 'For Delivery' | 'Completed' | 'Cancelled' | 'Refund'

interface OrderSummary {
  id: string // actual order ID for API calls
  referenceId: string // display ID (groupId or order ID)
  groupId: string | null // group ID for grouped orders
  productName: string
  customerName: string
  customerEmail: string | null
  customerFirstName: string
  customerLastName: string
  totalAmount: number
  salesChannel: string
  salesChannelIcon: string
  paymentMethod: string
  orderDate: string
  orderDateIso: string
  status: OrderStatus
  quantity: number
  size: string
  unitPrice: number
  paymentStatus: string
  referenceNumber: string
  orderedOn: string
  shippingMethod: string
}

const statusTabs: OrderStatus[] = ['Pending', 'For Delivery', 'Completed', 'Cancelled', 'Refund']
const activeStatus = ref<OrderStatus>('Pending')

// Server-driven orders
const orders = ref<OrderSummary[]>([])
const savingEdit = ref(false)
const saveError = ref<string | null>(null)
const confirming = ref(false)
const completing = ref(false)
const sendingInvoice = ref(false)
const sendInvoiceError = ref<string | null>(null)
const sendInvoiceSuccess = ref(false)

// GraphQL query to fetch orders and poll periodically
const { result: ordersResult, loading: ordersLoading, error: ordersError } = useQuery(
  GET_ORDERS_QUERY,
  {},
  { fetchPolicy: 'network-only', pollInterval: 5000 },
)

const { mutate: updateOrderMutation } = useMutation(UPDATE_ORDER_MUTATION)
const { mutate: sendOrderEmailsMutation } = useMutation(SEND_ORDER_EMAILS_MUTATION)

const mapStatusBackendToFrontend = (raw: string | null | undefined) => {
  if (!raw) return 'Pending'
  const v = raw.toString().toLowerCase()
  switch (v) {
    case 'pending':
      return 'Pending'
    case 'for_delivery':
    case 'for-delivery':
    case 'for delivery':
      return 'For Delivery'
    case 'completed':
      return 'Completed'
    case 'cancelled':
    case 'canceled':
      return 'Cancelled'
    case 'refund':
    case 'refunded':
      return 'Refund'
    default:
      // Fallback to capitalized
      return v.charAt(0).toUpperCase() + v.slice(1)
  }
}

const mapStatusFrontendToBackend = (status: OrderStatus) => {
  switch (status) {
    case 'Pending':
      return 'PENDING'
    case 'For Delivery':
      return 'FOR_DELIVERY'
    case 'Completed':
      return 'COMPLETED'
    case 'Cancelled':
      return 'CANCELLED'
    case 'Refund':
      return 'REFUND'
    default:
      return (status as string).toUpperCase().replace(/\s+/g, '_')
  }
}

const parseNumberIfValid = (value: unknown) => {
  if (value === null || value === undefined || value === '') return undefined
  const numeric = Number(value)
  return Number.isFinite(numeric) ? numeric : undefined
}

const orderIdFromReference = (referenceId: string) => referenceId.replace(/^#/, '')

const mapServerOrder = (o: any): OrderSummary => {
  const productName = o.product?.name ?? 'Product'
  const firstName = o.user?.firstName ?? ''
  const lastName = o.user?.lastName ?? ''
  const customerName = `${firstName} ${lastName}`.trim() || 'Customer'
  const totalAmount = Number(o.totalAmount ?? 0)
  const paymentMethod = o.paymentMethod ?? 'Unknown'
  const orderDateSource = o.createdAt || o.orderDate
  const orderDateObject = orderDateSource ? new Date(orderDateSource) : null
  const orderDateDisplay = orderDateObject ? orderDateObject.toLocaleString() : ''
  const orderDateIso = orderDateObject ? orderDateObject.toISOString().slice(0, 10) : ''
  const status = mapStatusBackendToFrontend(o.status)

  return {
    id: String(o.id), // actual order ID for API calls
    referenceId: o.groupId ? `${o.groupId}` : `#${o.id}`, // display ID
    groupId: o.groupId ?? null, // store group ID
    productName,
    customerName,
    customerEmail: o.user?.email ?? null,
    customerFirstName: firstName,
    customerLastName: lastName,
    totalAmount,
    salesChannel: 'POS',
    salesChannelIcon: '�',
    paymentMethod,
    orderDate: orderDateDisplay,
    orderDateIso,
    status: (status as any),
    quantity: o.orderQuantity ?? 1,
    size: '',
    unitPrice: Number((totalAmount / (o.orderQuantity || 1)) || 0),
      paymentStatus: o.paymentStatus ?? 'Pay Success',
    referenceNumber: `#${o.id}`,
    orderedOn: orderDateDisplay,
    shippingMethod: 'Delivery',
  }
}

// Watch for server result changes and map into local orders list
watch(ordersResult, (val) => {
  const list = val?.orders ?? []
  orders.value = list.map(mapServerOrder)
})
if (props.initialOrders && props.initialOrders.length) {
  const mapped = props.initialOrders.map(mapServerOrder)
  // Prepend created orders so they show first
  orders.value = [...mapped, ...orders.value]
}

const selectedOrder = ref<OrderSummary | null>(orders.value[0] ?? null)

const filteredOrders = computed(() => orders.value.filter((order) => order.status === activeStatus.value))

watch(filteredOrders, (list) => {
  if (!list.length) {
    selectedOrder.value = null
    return
  }
  if (!selectedOrder.value || !list.some((order) => order.referenceId === selectedOrder.value?.referenceId)) {
    selectedOrder.value = list[0] ?? null
  }
})

const tableHeaders = [
  'Group ID',
  'Product Name',
  'Customer Name',
  'Total Amount',
  'Sales Channel',
  'Payment Method',
  'Order Date',
]

const resetInvoiceFeedback = () => {
  sendInvoiceSuccess.value = false
  sendInvoiceError.value = null
}

watch(selectedOrder, resetInvoiceFeedback)

const grabCredit = 5000
const creditApprovedOn = '11-12-21'
const currentFees = 0
const previousFees = 10000
const lastUpdated = 'Jul 11, 2023, 7:07 PM'

const selectOrder = (order: OrderSummary) => {
  selectedOrder.value = order
}

const handleBack = () => {
  emit('back')
}

const handleCreateOrder = () => {
  emit('create-order')
}

const formatCurrency = (amount: number | undefined | null) => {
  if (!amount) return '0.00'
  return amount.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

// Edit modal state and handlers
const isEditModalOpen = ref(false)
const editingOrder = ref<OrderSummary | null>(null)

/**
 * Open the edit modal for a given order.
 * We clone the order into `editingOrder` so changes are local until saved.
 */
const openEdit = (order: OrderSummary) => {
  // set selected preview
  selectedOrder.value = order
  // shallow clone is enough for this form
  editingOrder.value = { ...order }
  saveError.value = null
  savingEdit.value = false
  isEditModalOpen.value = true
}

const closeEdit = () => {
  isEditModalOpen.value = false
  editingOrder.value = null
  saveError.value = null
  savingEdit.value = false
}

const buildInvoiceSummary = (order: OrderSummary) => {
  const summary: Record<string, unknown> = {}

  if (order.paymentMethod) {
    summary.paymentMethod = order.paymentMethod
  }

  const customer: Record<string, string> = {}
  if (order.customerEmail) customer.email = order.customerEmail
  if (order.customerFirstName) customer.firstName = order.customerFirstName
  if (order.customerLastName) customer.lastName = order.customerLastName
  if (Object.keys(customer).length) {
    summary.customer = customer
  }

  const totals: Record<string, number> = {}
  const totalAmount = Number(order.totalAmount)
  if (!Number.isNaN(totalAmount)) {
    totals.grandTotal = totalAmount
  }
  if (Object.keys(totals).length) {
    summary.totals = totals
  }

  return summary
}

const handleSendPaymentInvoice = async () => {
  if (!selectedOrder.value) return

  sendingInvoice.value = true
  sendInvoiceError.value = null
  sendInvoiceSuccess.value = false

  try {
    const orderId = selectedOrder.value.id
    const summary = buildInvoiceSummary(selectedOrder.value)
    const variables: Record<string, unknown> = {
      orderIds: [orderId],
    }

    if (selectedOrder.value.customerEmail) {
      variables.recipientEmail = selectedOrder.value.customerEmail
    }

    if (Object.keys(summary).length) {
      variables.summary = summary
    }

    const response = await sendOrderEmailsMutation(variables)
    const result = response?.data?.sendOrderEmails

    if (result?.success) {
      sendInvoiceSuccess.value = true
    } else {
      sendInvoiceError.value = result?.errors?.join(', ') || 'Unable to send payment invoice.'
    }
  } catch (error) {
    console.error('Failed to send payment confirmation email', error)
    sendInvoiceError.value = 'Unexpected error sending payment invoice.'
  } finally {
    sendingInvoice.value = false
  }
}

/**
 * Persist changes to the server and update the local cache on success.
 */
const saveEdit = async () => {
  if (!editingOrder.value) return

  const current = editingOrder.value
  const variables: Record<string, unknown> = {
    id: current.id,
  }

  const quantity = parseNumberIfValid(current.quantity)
  if (quantity !== undefined) {
    if (quantity <= 0) {
      saveError.value = 'Order quantity must be greater than zero.'
      return
    }
    variables.orderQuantity = Math.round(quantity)
  }

  const total = parseNumberIfValid(current.totalAmount)
  if (total !== undefined) {
    if (total < 0) {
      saveError.value = 'Total amount must be zero or positive.'
      return
    }
    variables.totalAmount = Math.round(total * 100) / 100
  }

  if (current.paymentMethod?.trim()) {
    variables.paymentMethod = current.paymentMethod.trim()
  }

  if (current.status) {
    variables.status = mapStatusFrontendToBackend(current.status)
  }

  const isoDate = current.orderDateIso?.trim()
  if (isoDate) {
    variables.orderDate = isoDate
  }

  savingEdit.value = true
  saveError.value = null

  try {
    const result = await updateOrderMutation(variables)
    const payload = result?.data?.updateOrder
    const errors = payload?.errors ?? []
    if (errors.length) {
      saveError.value = errors.join(', ')
      return
    }

    const updatedOrder = payload?.order
    if (!updatedOrder) {
      saveError.value = 'Update did not return an order record.'
      return
    }

    const mapped = mapServerOrder(updatedOrder)
    const idx = orders.value.findIndex((o) => o.referenceId === mapped.referenceId)
    if (idx !== -1) {
      orders.value.splice(idx, 1, mapped)
    } else {
      orders.value.push(mapped)
    }

    selectedOrder.value = mapped
    closeEdit()
  } catch (error) {
    console.error('Failed to update order', error)
    saveError.value = 'Failed to update order.'
  } finally {
    savingEdit.value = false
  }
}

/**
 * Confirm the currently selected order (Pending -> For Delivery)
 */
const handleConfirmSelectedOrder = async () => {
  if (!selectedOrder.value) return

  confirming.value = true
  try {
    const variables: Record<string, unknown> = {
      id: selectedOrder.value.id,
      status: 'FOR_DELIVERY',
    }

    const result = await updateOrderMutation(variables)
    const payload = result?.data?.updateOrder
    const errors = payload?.errors ?? []
    if (errors.length) {
      console.error('Confirm order errors', errors)
      return
    }

    const updatedOrder = payload?.order
    if (!updatedOrder) {
      console.error('Confirm did not return an order')
      return
    }

    const mapped = mapServerOrder(updatedOrder)
    const idx = orders.value.findIndex((o) => o.referenceId === mapped.referenceId)
    if (idx !== -1) {
      orders.value.splice(idx, 1, mapped)
    } else {
      orders.value.push(mapped)
    }

    selectedOrder.value = mapped
  } catch (err) {
    console.error('Failed to confirm order', err)
  } finally {
    confirming.value = false
  }
}

/**
 * Mark the currently selected order as Completed (For Delivery -> Completed)
 */
const handleMarkCompletedSelectedOrder = async () => {
  if (!selectedOrder.value) return

  completing.value = true
  try {
    const variables: Record<string, unknown> = {
      id: selectedOrder.value.id,
      status: 'COMPLETED',
    }

    const result = await updateOrderMutation(variables)
    const payload = result?.data?.updateOrder
    const errors = payload?.errors ?? []
    if (errors.length) {
      console.error('Mark completed errors', errors)
      return
    }

    const updatedOrder = payload?.order
    if (!updatedOrder) {
      console.error('Complete did not return an order')
      return
    }

    const mapped = mapServerOrder(updatedOrder)
    const idx = orders.value.findIndex((o) => o.referenceId === mapped.referenceId)
    if (idx !== -1) {
      orders.value.splice(idx, 1, mapped)
    } else {
      orders.value.push(mapped)
    }

    selectedOrder.value = mapped
  } catch (err) {
    console.error('Failed to mark order completed', err)
  } finally {
    completing.value = false
  }
}
</script>
