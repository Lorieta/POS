<template>
  <div
    v-if="show"
    class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4"
    role="dialog"
    aria-modal="true"
  >
    <div class="w-full max-w-3xl bg-white rounded-2xl shadow-lg p-6 space-y-6">
      <header class="flex items-start justify-between">
        <div>
          <h2 class="text-xl font-semibold text-gray-900">Order Placed Successfully</h2>
          <p class="text-sm text-gray-500">Here is a complete summary of the order and payment details.</p>
        </div>
        <button class="text-gray-400 hover:text-gray-600" @click="handleClose" aria-label="Close modal">
          ✕
        </button>
      </header>

      <section class="space-y-3">
        <h3 class="text-sm font-medium text-gray-900 uppercase">Order References</h3>
        <div class="grid gap-3">
          <article
            v-for="order in orders"
            :key="order.id"
            class="border rounded-xl p-4 bg-gray-50"
          >
            <div class="flex flex-wrap items-center justify-between gap-3">
              <div>
                <p class="text-xs text-gray-400">{{ order.groupId ? 'Group ID' : 'Reference' }}</p>
                <p class="font-semibold">{{ order.groupId || `ORD-${order.id}` }}</p>
              </div>
              <div class="text-sm text-gray-600">
                <p>{{ order.product?.name ?? 'Product' }} × {{ order.orderQuantity }}</p>
                <p class="font-semibold">
                  ₱{{ formatCurrency(Number(order.totalAmount ?? 0)) }}
                </p>
              </div>
            </div>
            <div class="mt-3 flex flex-wrap items-center gap-3 text-xs text-gray-500">
              <button class="underline" @click.prevent="copyToClipboard(paymentLink(order))">Copy Payment Link</button>
              <a :href="paymentLink(order)" target="_blank" rel="noreferrer" class="underline text-blue-600">
                Open payment link
              </a>
            </div>
          </article>
        </div>
      </section>

      <section class="grid grid-cols-1 md:grid-cols-2 gap-6 text-sm text-gray-700">
        <div class="space-y-3">
          <h3 class="text-sm font-medium text-gray-900 uppercase">Customer</h3>
          <p class="text-sm">
            <span class="text-gray-500 block text-xs uppercase">Name</span>
            {{ customerName || '—' }}
          </p>
          <p class="text-sm">
            <span class="text-gray-500 block text-xs uppercase">Email</span>
            {{ customerEmail || primaryRecipient || '—' }}
          </p>
          <p class="text-sm">
            <span class="text-gray-500 block text-xs uppercase">Contact</span>
            {{ summary?.customer?.mobile || '—' }}
          </p>
          <p class="text-sm">
            <span class="text-gray-500 block text-xs uppercase">Payment Method</span>
            {{ paymentMethod }}
          </p>
        </div>
        <div class="space-y-3">
          <h3 class="text-sm font-medium text-gray-900 uppercase">Delivery / Shipping</h3>
          <p class="leading-relaxed">
            <span class="text-gray-500 block text-xs uppercase">Address</span>
            <span>
              {{ summary?.address?.street || '—' }}
              <template v-if="summary?.address?.barangay">
                , {{ summary.address.barangay }}
              </template>
              <template v-if="summary?.address?.city || summary?.address?.province">
                <br />
                {{ summary?.address?.city || '' }} {{ summary?.address?.province || '' }}
              </template>
              <template v-if="summary?.address?.country">
                <br />
                {{ summary.address.country }}
              </template>
            </span>
          </p>
          <div class="grid grid-cols-2 gap-2 text-xs text-gray-500">
            <div>
              <p class="uppercase">Building</p>
              <p class="text-gray-700">{{ summary?.address?.building || '—' }}</p>
            </div>
            <div>
              <p class="uppercase">Unit / Floor</p>
              <p class="text-gray-700">
                {{ summary?.address?.roomUnit || '—' }}
                <template v-if="summary?.address?.floor"> / {{ summary.address.floor }}</template>
              </p>
            </div>
            <div>
              <p class="uppercase">Landmark</p>
              <p class="text-gray-700">{{ summary?.address?.landmark || '—' }}</p>
            </div>
            <div>
              <p class="uppercase">Remarks</p>
              <p class="text-gray-700">{{ summary?.address?.remarks || '—' }}</p>
            </div>
          </div>
        </div>
      </section>

      <section class="space-y-3">
        <h3 class="text-sm font-medium text-gray-900 uppercase">Payment Summary</h3>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 text-sm text-gray-700">
          <div class="flex justify-between">
            <span>Subtotal</span>
            <span>₱{{ formatCurrency(summary?.totals?.subtotal ?? 0) }}</span>
          </div>
          <div class="flex justify-between">
            <span>VAT</span>
            <span>₱{{ formatCurrency(summary?.totals?.vat ?? 0) }}</span>
          </div>
          <div class="flex justify-between">
            <span>Delivery Fee</span>
            <span>₱{{ formatCurrency(summary?.totals?.deliveryFee ?? 0) }}</span>
          </div>
          <div class="flex justify-between">
            <span>Convenience Fee</span>
            <span>₱{{ formatCurrency(summary?.totals?.convenienceFee ?? 0) }}</span>
          </div>
          <div class="flex justify-between">
            <span>Coupon Code</span>
            <span>{{ summary?.totals?.couponCode || summary?.couponCode || '—' }}</span>
          </div>
          <div class="flex justify-between font-semibold text-gray-900">
            <span>Grand Total</span>
            <span>₱{{ formatCurrency(summary?.totals?.grandTotal ?? 0) }}</span>
          </div>
        </div>
      </section>

      <section v-if="isOnlinePayment" class="space-y-3">
        <div class="flex items-center gap-2">
          <h3 class="text-sm font-medium text-gray-900 uppercase">Payment Email</h3>
          <span
            class="text-xs px-2 py-1 rounded-full"
            :class="statusPillClass"
          >
            {{ statusLabel }}
          </span>
        </div>
        <p class="text-sm text-gray-600">
          Click the button below to send a payment confirmation email to <strong>{{ primaryRecipient || 'the customer email on file' }}</strong>.
        </p>
        <div class="flex flex-wrap gap-3">
          <button
            class="bg-blue-600 text-white px-4 py-2 rounded-lg text-sm font-medium disabled:opacity-60 disabled:cursor-not-allowed"
            @click="sendEmail"
            :disabled="sendInFlight || !primaryRecipient"
          >
            <span v-if="sendInFlight">Sending...</span>
            <span v-else>Send Payment Email</span>
          </button>
          <p v-if="statusMessage" class="text-sm text-gray-500">{{ statusMessage }}</p>
        </div>
      </section>

      <footer class="flex justify-end">
        <button class="bg-gray-100 text-gray-700 py-2 px-4 rounded-lg" @click="handleClose">Close</button>
      </footer>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useMutation } from '@vue/apollo-composable'
import { SEND_ORDER_EMAILS_MUTATION } from '@/graphql/orders'

type OrderRecord = {
  id: string | number
  groupId?: string | null
  orderQuantity?: number
  totalAmount?: number
  paymentMethod?: string | null
  product?: { name?: string | null }
  user?: { email?: string | null }
}

type CheckoutSummary = {
  paymentMethod?: string
  couponCode?: string | null
  customer?: {
    email?: string | null
    mobile?: string | null
    firstName?: string | null
    lastName?: string | null
  } | null
  address?: {
    country?: string | null
    province?: string | null
    city?: string | null
    street?: string | null
    barangay?: string | null
    roomUnit?: string | null
    floor?: string | null
    building?: string | null
    landmark?: string | null
    remarks?: string | null
  } | null
  totals?: {
    subtotal?: number | null
    vat?: number | null
    deliveryFee?: number | null
    convenienceFee?: number | null
    grandTotal?: number | null
    couponCode?: string | null
  } | null
}

const props = defineProps<{
  show: boolean
  orders: OrderRecord[]
  summary: CheckoutSummary | null
}>()

const emit = defineEmits<{ (event: 'close'): void }>()

const sendStatus = ref<'idle' | 'pending' | 'sent' | 'error' | 'not_applicable'>('idle')
const statusMessage = ref('')
const sendInFlight = ref(false)
const hasAutoSent = ref(false)

const { mutate: triggerSendPayment } = useMutation(SEND_ORDER_EMAILS_MUTATION)

const paymentMethod = computed(() => props.summary?.paymentMethod ?? props.orders[0]?.paymentMethod ?? '—')

const isOnlinePayment = computed(() => {
  const method = (paymentMethod.value || '').toLowerCase()
  return method.length > 0 && !['cash', 'cash on delivery', 'cod'].includes(method)
})

const primaryRecipient = computed(() => {
  return props.summary?.customer?.email || props.orders[0]?.user?.email || ''
})

const customerName = computed(() => {
  const first = props.summary?.customer?.firstName || ''
  const last = props.summary?.customer?.lastName || ''
  const full = `${first} ${last}`.trim()
  return full || null
})

const customerEmail = computed(() => props.summary?.customer?.email || null)

const statusLabel = computed(() => {
  switch (sendStatus.value) {
    case 'pending':
      return 'Sending'
    case 'sent':
      return 'Sent'
    case 'error':
      return 'Error'
    case 'not_applicable':
      return 'Not Required'
    default:
      return 'Idle'
  }
})

const statusPillClass = computed(() => {
  switch (sendStatus.value) {
    case 'pending':
      return 'bg-yellow-100 text-yellow-700'
    case 'sent':
      return 'bg-green-100 text-green-700'
    case 'error':
      return 'bg-red-100 text-red-600'
    case 'not_applicable':
      return 'bg-gray-100 text-gray-500'
    default:
      return 'bg-gray-100 text-gray-500'
  }
})

const resetEmailState = () => {
  sendStatus.value = isOnlinePayment.value ? 'idle' : 'not_applicable'
  statusMessage.value = ''
  sendInFlight.value = false
  hasAutoSent.value = false
}

const buildMutationVariables = () => {
  return {
    orderIds: props.orders.map((order) => order.id),
    recipientEmail: primaryRecipient.value,
    summary: props.summary ?? {},
  }
}

const sendEmail = async () => {
  if (!isOnlinePayment.value) {
    sendStatus.value = 'not_applicable'
    return
  }

  if (!primaryRecipient.value) {
    sendStatus.value = 'error'
    statusMessage.value = 'No recipient email available.'
    return
  }

  sendInFlight.value = true
  sendStatus.value = 'pending'
  statusMessage.value = 'Sending payment confirmation email...'

  try {
    const response = await triggerSendPayment(buildMutationVariables())
    const result = response?.data?.sendOrderEmails

    if (result?.success) {
      sendStatus.value = 'sent'
      statusMessage.value = 'Payment confirmation email sent successfully.'
    } else {
      sendStatus.value = 'error'
      statusMessage.value = result?.errors?.join(', ') || 'Unable to send email.'
    }
  } catch (error) {
    console.error('Failed to send payment confirmation email', error)
    sendStatus.value = 'error'
    statusMessage.value = 'Unexpected error sending email.'
  } finally {
    sendInFlight.value = false
  }
}

const maybeAutoSend = () => {
  if (!props.show || hasAutoSent.value || !isOnlinePayment.value) {
    return
  }
  if (!primaryRecipient.value) {
    sendStatus.value = 'error'
    statusMessage.value = 'No recipient email available.'
    hasAutoSent.value = true
    return
  }
  hasAutoSent.value = true
  void sendEmail()
}

watch(
  () => props.show,
  (visible) => {
    if (visible) {
      resetEmailState()
      // Auto-send disabled - user must manually click "Resend Payment Email"
      // setTimeout(maybeAutoSend, 0)
    } else {
      resetEmailState()
    }
  }
)

watch(
  () => [props.summary, props.orders.length],
  () => {
    if (!props.show) return
    // Auto-send disabled - user must manually click "Resend Payment Email"
    // setTimeout(maybeAutoSend, 0)
  }
)

const handleClose = () => {
  emit('close')
}

const formatCurrency = (value: number) => {
  if (!Number.isFinite(value)) return '0.00'
  return Number(value).toLocaleString('en-PH', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })
}

const paymentLink = (order: OrderRecord) => {
  const base = window.location.origin.replace(/\/$/, '')
  return `${base}/pay/${order.id}`
}

const copyToClipboard = async (value: string) => {
  try {
    await navigator.clipboard.writeText(value)
    statusMessage.value = 'Payment link copied to clipboard.'
  } catch (error) {
    console.warn('Unable to copy to clipboard', error)
    statusMessage.value = 'Unable to copy link. Please copy manually.'
  }
}
</script>
