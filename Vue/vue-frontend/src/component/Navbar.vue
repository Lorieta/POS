<template>
  <header class="bg-white shadow-sm flex justify-between items-center px-6 py-3">
    <div>
      <h2 class="text-lg font-semibold">{{ props.title }}</h2>
      <p v-if="props.subtitle" class="text-sm text-gray-500">{{ props.subtitle }}</p>
    </div>

    <div class="flex items-center space-x-4">
      <div
        v-if="props.statusText"
        class="flex items-center bg-green-100 text-green-700 px-3 py-1 rounded-full text-sm"
      >
        <span class="w-2 h-2 bg-green-500 rounded-full mr-2"></span>
        {{ props.statusText }}
      </div>

      <!-- Cart Icon -->
      <button
        @click="emit('viewCart')"
        class="relative p-2 text-gray-600 hover:text-blue-600 hover:bg-blue-50 rounded-full transition-colors"
        title="View Cart"
      >
        <svg
          class="w-6 h-6"
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
        <!-- Cart Badge -->
        <span
          v-if="props.cartItemsCount > 0"
          class="absolute -top-1 -right-1 bg-red-500 text-white text-xs font-bold rounded-full w-5 h-5 flex items-center justify-center"
        >
          {{ props.cartItemsCount > 99 ? '99+' : props.cartItemsCount }}
        </span>
      </button>

      <div class="relative" @click.outside="closeDropdown">
        <button
          class="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center focus:outline-none focus:ring-2 focus:ring-blue-400"
          @click="toggleDropdown"
        >
          <span class="text-sm font-semibold text-gray-600">
            {{ userInitials }}
          </span>
        </button>

        <transition name="fade">
          <div
            v-if="isDropdownOpen"
            class="absolute right-0 mt-2 w-48 bg-white border border-gray-200 rounded-lg shadow-lg py-2 z-10"
          >
            <div class="px-4 py-2 text-xs text-gray-500 uppercase tracking-wide">
              Signed in as
            </div>
            <div class="px-4 pb-2 text-sm text-gray-700">
              {{ displayName }}
            </div>
            <div class="border-t border-gray-100 my-2"></div>
            <button
              class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
              @click="handleLogout"
            >
              Log out
            </button>
          </div>
        </transition>
      </div>
    </div>
  </header>
</template>

<script lang="ts" setup>
import { computed, onMounted, ref } from 'vue'
import { useMutation } from '@vue/apollo-composable'
import { useRouter } from 'vue-router'
import { LOGOUT_MUTATION } from '@/graphql'

const props = withDefaults(
  defineProps<{
    title: string
    subtitle?: string
    statusText?: string
    notifications?: number
    userName?: string
    cartItemsCount?: number
  }>(),
  {
    subtitle: '',
    statusText: '',
    notifications: 0,
    userName: '',
    cartItemsCount: 0,
  },
)

const emit = defineEmits<{
  viewCart: []
}>()

const router = useRouter()
const isDropdownOpen = ref(false)

const { mutate: logout } = useMutation(LOGOUT_MUTATION)

const storedFirstName = ref('')
const storedLastName = ref('')

const refreshStoredUser = () => {
  storedFirstName.value = localStorage.getItem('userFirstName') || ''
  storedLastName.value = localStorage.getItem('userLastName') || ''
}

onMounted(() => {
  refreshStoredUser()
})

const displayName = computed(() => {
  if (props.userName) return props.userName
  const parts = [storedFirstName.value, storedLastName.value].filter((part) => part && part.length > 0)
  if (parts.length > 0) return parts.join(' ')
  return 'Unknown User'
})

const userInitials = computed(() => {
  const name = displayName.value.trim()
  if (!name) return 'U'
  const parts = name.split(/\s+/)
  const initials = parts.map((part) => part[0]?.toUpperCase()).join('')
  return initials.slice(0, 2) || 'U'
})

const toggleDropdown = (event: Event) => {
  event.stopPropagation()
  isDropdownOpen.value = !isDropdownOpen.value
}

const closeDropdown = () => {
  isDropdownOpen.value = false
}

const handleLogout = async () => {
  try {
    await logout()
  } catch (error) {
    console.error('Logout mutation failed:', error)
  }

  localStorage.removeItem('token')
  localStorage.removeItem('userId')
  localStorage.removeItem('userFirstName')
  localStorage.removeItem('userLastName')
  refreshStoredUser()
  isDropdownOpen.value = false
  router.push('/login')
}
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.15s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
