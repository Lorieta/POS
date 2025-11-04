<template>
  <div class="relative flex min-h-screen items-center justify-center overflow-hidden">
    <div class="absolute inset-0 -z-10">
      <div class="absolute -left-32 top-10 h-72 w-72 rounded-full bg-blue-600/30 blur-3xl" />
      <div class="absolute -right-24 bottom-10 h-80 w-80 rounded-full bg-indigo-500/30 blur-3xl" />
    </div>

    <div
      class="w-full max-w-md rounded-3xl bg-white/95 p-10 shadow-[0_25px_60px_-15px_rgba(8,36,111,0.35)] backdrop-blur"
    >
      <div class="text-center">
        <h2 class="text-3xl font-semibold text-slate-900">Create Account</h2>
        <p class="mt-2 text-sm text-slate-500">Join us by filling out the information below.</p>
      </div>

      <div
        v-if="errorMessage"
        class="mt-6 rounded-lg bg-red-100 p-3 text-sm text-red-700 shadow-sm"
      >
        {{ errorMessage }}
      </div>

      <form @submit.prevent="signupUser" class="mt-6 space-y-5">
        <div class="grid gap-4 sm:grid-cols-2">
          <div class="relative">
            <label for="first-name" class="sr-only">First Name</label>
            <input
              id="first-name"
              v-model="firstName"
              type="text"
              placeholder="First Name"
              class="w-full rounded-full border bg-slate-50/60 px-5 py-3 text-sm text-slate-700 shadow-inner placeholder:text-slate-400 transition focus:outline-none focus:ring-2"
              :class="inputVariant"
            />
          </div>
          <div class="relative">
            <label for="last-name" class="sr-only">Last Name</label>
            <input
              id="last-name"
              v-model="lastName"
              type="text"
              placeholder="Last Name"
              class="w-full rounded-full border bg-slate-50/60 px-5 py-3 text-sm text-slate-700 shadow-inner placeholder:text-slate-400 transition focus:outline-none focus:ring-2"
              :class="inputVariant"
            />
          </div>
        </div>

        <div class="relative">
          <label for="signup-email" class="sr-only">Email</label>
          <input
            id="signup-email"
            v-model="email"
            type="email"
            placeholder="Email"
            class="w-full rounded-full border bg-slate-50/60 px-5 py-3 text-sm text-slate-700 shadow-inner placeholder:text-slate-400 transition focus:outline-none focus:ring-2"
            :class="inputVariant"
          />
        </div>

        <div class="relative">
          <label for="phone" class="sr-only">Phone Number</label>
          <input
            id="phone"
            v-model="phone"
            type="tel"
            placeholder="Phone Number"
            class="w-full rounded-full border bg-slate-50/60 px-5 py-3 text-sm text-slate-700 shadow-inner placeholder:text-slate-400 transition focus:outline-none focus:ring-2"
            :class="inputVariant"
          />
        </div>

        <div class="relative">
          <label for="signup-password" class="sr-only">Password</label>
          <input
            id="signup-password"
            v-model="password"
            type="password"
            placeholder="Password"
            class="w-full rounded-full border bg-slate-50/60 px-5 py-3 text-sm text-slate-700 shadow-inner placeholder:text-slate-400 transition focus:outline-none focus:ring-2"
            :class="inputVariant"
          />
        </div>

        <div class="relative">
          <label for="signup-password-confirmation" class="sr-only">Confirm Password</label>
          <input
            id="signup-password-confirmation"
            v-model="passwordConfirmation"
            type="password"
            placeholder="Confirm Password"
            class="w-full rounded-full border bg-slate-50/60 px-5 py-3 text-sm text-slate-700 shadow-inner placeholder:text-slate-400 transition focus:outline-none focus:ring-2"
            :class="inputVariant"
          />
        </div>

        <button
          type="submit"
          class="w-full rounded-full bg-linear-to-r from-[#FFA63D] via-[#FF7A4B] to-[#F64F6A] py-3 text-sm font-semibold uppercase tracking-wide text-white shadow-[0_10px_25px_-10px_rgba(246,79,106,0.7)] transition hover:opacity-95 disabled:opacity-50"
          :disabled="isSubmitting"
        >
          {{ isSubmitting ? 'Creating Account...' : 'Sign Up' }}
        </button>
      </form>

      <p class="mt-6 text-center text-xs text-slate-400">
        Already have an account?
        <RouterLink to="/login" class="font-medium text-blue-500 hover:underline"
          >Log in</RouterLink
        >
      </p>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed } from 'vue'
import { useMutation } from '@vue/apollo-composable'
import { RouterLink, useRouter } from 'vue-router'
import { CREATE_USER_MUTATION } from '@/graphql'

const firstName = ref('')
const lastName = ref('')
const email = ref('')
const phone = ref('')
const password = ref('')
const passwordConfirmation = ref('')
const errorMessage = ref('')
const isSubmitting = ref(false)

const router = useRouter()

const { mutate: signup, onDone, onError } = useMutation(CREATE_USER_MUTATION)

const inputVariant = computed(() =>
  errorMessage.value
    ? 'border-red-400 focus:border-red-400 focus:ring-red-200'
    : 'border-slate-200 focus:border-blue-400 focus:ring-blue-200',
)

onDone(({ data }) => {
  isSubmitting.value = false
  const newUser = data?.signup
  if (!newUser) {
    errorMessage.value = 'Signup response missing account details. Please try again.'
    return
  }
  alert(`Registered ${newUser.email}`)
  router.push('/login')
})

onError((error) => {
  isSubmitting.value = false
  errorMessage.value = error.message
})

async function signupUser() {
  errorMessage.value = ''
  isSubmitting.value = true

  await signup({
    credentials: {
      firstName: firstName.value,
      lastName: lastName.value,
      email: email.value,
      phoneNumber: phone.value,
      password: password.value,
      passwordConfirmation: passwordConfirmation.value,
    },
  })
}
</script>
