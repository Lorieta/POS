<template>
  <div class="relative flex min-h-screen items-center justify-center overflow-hidden m-4">
    <!-- Background elements (already good) -->
    <div class="absolute inset-0 -z-10">
      <div class="absolute -left-32 top-10 h-72 w-72 rounded-full bg-blue-600/30 blur-3xl" />
      <div class="absolute -right-24 bottom-10 h-80 w-80 rounded-full bg-indigo-500/30 blur-3xl" />
    </div>

    <!-- Login Card -->
    <div
      class="w-full  max-w-sm rounded-3xl bg-white/95 p-10 shadow-[0_25px_60px_-15px_rgba(8,36,111,0.35)] backdrop-blur"
    >
      <div class="text-center">
        <h2 class="text-3xl font-semibold text-slate-900">Login</h2>
        <p class="mt-2 text-sm text-slate-500">Welcome back! Please enter your details.</p>
      </div>

      <!-- Error Message Box -->
      <div
        v-if="errorMessage"
        class="mt-6 rounded-lg bg-red-100 p-3 text-sm text-red-700 shadow-sm"
      >
        {{ errorMessage }}
      </div>

      <form @submit.prevent="loginUser" class="mt-6 space-y-5">
        <!-- Email/Username Input -->
        <div class="relative">
          <label for="email" class="sr-only">Username or Email</label>
          <span
            class="pointer-events-none absolute inset-y-0 left-4 flex items-center text-base text-slate-400"
            aria-hidden="true"
          >
            <!-- User Icon -->
            <svg class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
              <path
                d="M4 5a6 6 0 1 1 12 0 6 6 0 0 1-12 0Zm6 8c-3.314 0-6 2.239-6 5v.5a.5.5 0 0 0 .5.5h11a.5.5 0 0 0 .5-.5V18c0-2.761-2.686-5-6-5Z"
              />
            </svg>
          </span>
          <input
            id="email"
            v-model="email"
            type="email"
            placeholder="Username or Email"
            class="w-full rounded-full border bg-slate-50/60 px-5 py-3 pl-11 text-sm text-slate-700 shadow-inner focus:outline-none focus:ring-2 placeholder:text-slate-400 transition"
            :class="[
              errorMessage
                ? 'border-red-400 focus:border-red-400 focus:ring-red-200'
                : 'border-slate-200 focus:border-blue-400 focus:ring-blue-200',
            ]"
          />
        </div>

        <!-- Password Input -->
        <div class="relative">
          <label for="password" class="sr-only">Password</label>
          <span
            class="pointer-events-none absolute inset-y-0 left-4 flex items-center text-base text-slate-400"
            aria-hidden="true"
          >
            <!-- Lock Icon -->
            <svg class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
              <path
                d="M14 8h1a1 1 0 0 1 1 1v8a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1h1V7a4 4 0 1 1 8 0v1Zm-6 0h4V7a2 2 0 1 0-4 0v1Z"
              />
            </svg>
          </span>
          <input
            id="password"
            v-model="password"
            :type="isPasswordVisible ? 'text' : 'password'"
            placeholder="Password"
            class="w-full rounded-full border bg-slate-50/60 px-5 py-3 pl-11 pr-11 text-sm text-slate-700 shadow-inner focus:outline-none focus:ring-2 placeholder:text-slate-400 transition"
            :class="[
              errorMessage
                ? 'border-red-400 focus:border-red-400 focus:ring-red-200'
                : 'border-slate-200 focus:border-blue-400 focus:ring-blue-200',
            ]"
          />
          <!-- Show/Hide Password Toggle -->
          <button
            type="button"
            @click="togglePasswordVisibility"
            class="absolute inset-y-0 right-4 flex items-center text-slate-400 hover:text-slate-600 transition"
            :aria-label="isPasswordVisible ? 'Hide password' : 'Show password'"
          >
            <!-- Eye Icon (simple placeholer here) -->
            <svg
              v-if="isPasswordVisible"
              class="h-4 w-4"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395m-2.863.395a4.5 4.5 0 0 0 0-9m0 9a4.5 4.5 0 0 1-4.5-4.5M19.5 12c-1.232 4.356-5.234 7.5-10.475 7.5M19.5 12c.132-.52.24-1.045.325-1.571m-3.49-2.433a4.5 4.5 0 0 0-4.5-4.5"
              />
            </svg>
            <svg
              v-else
              class="h-4 w-4"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.422 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z"
              />
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"
              />
            </svg>
          </button>
        </div>

        <!-- Checkbox and Forgot Password -->
        <div class="flex items-center justify-between text-xs">
          <label class="flex items-center gap-2 text-slate-500">
            <input
              type="checkbox"
              class="h-4 w-4 rounded border-slate-300 text-orange-500 focus:ring-orange-400"
            />
            <span>Remember me</span>
          </label>
        </div>

        <!-- Submit Button -->
        <button
          type="submit"
          class="w-full rounded-full bg-linear-to-r from-[#FFA63D] via-[#FF7A4B] to-[#F64F6A] py-3 text-sm font-semibold uppercase tracking-wide text-white shadow-[0_10px_25px_-10px_rgba(246,79,106,0.7)] transition hover:opacity-95 disabled:opacity-50"
          :disabled="isLoggingIn"
        >
          {{ isLoggingIn ? 'Logging in...' : 'Log In' }}
        </button>
      </form>

      <!-- Sign Up Link -->
      <p class="mt-6 text-center text-xs text-slate-400">
        Not a member?
        <RouterLink to="/signup" class="font-medium text-blue-500 hover:underline">
          Sign up now
        </RouterLink>
      </p>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref } from 'vue'
import { useMutation } from '@vue/apollo-composable'
import { RouterLink, useRouter } from 'vue-router'
import { SIGN_IN_USER_MUTATION } from '@/graphql'

const email = ref('')
const password = ref('')
const errorMessage = ref('')
const isPasswordVisible = ref(false)
const isLoggingIn = ref(false)
const router = useRouter()

const { mutate: login, onDone, onError } = useMutation(SIGN_IN_USER_MUTATION)

const togglePasswordVisibility = () => {
  isPasswordVisible.value = !isPasswordVisible.value
}

onDone(({ data }) => {
  isLoggingIn.value = false
  const payload = data?.login
  if (!payload) {
    errorMessage.value = 'Login response missing credentials. Please try again.'
    return
  }
  const { token, user } = payload
  if (token) {
    localStorage.setItem('token', token)
  }
  if (user?.id) {
    localStorage.setItem('userId', String(user.id))
  } else {
    localStorage.removeItem('userId')
  }
  if (user?.firstName) {
    localStorage.setItem('userFirstName', user.firstName)
  } else {
    localStorage.removeItem('userFirstName')
  }
  if (user?.lastName) {
    localStorage.setItem('userLastName', user.lastName)
  } else {
    localStorage.removeItem('userLastName')
  }
  // Redirect to original target (if present) or dashboard
  const redirectTo = (router.currentRoute.value.query.redirect as string) || '/dashboard'
  router.push(redirectTo)
})

onError((error) => {
  isLoggingIn.value = false
  // Use a friendlier message for common auth errors
  if (error.message.includes('Incorrect username or password')) {
    errorMessage.value = 'Incorrect username or password. Please check your details.'
  } else {
    errorMessage.value = error.message
  }
})

async function loginUser() {
  errorMessage.value = '' // Clear previous errors
  isLoggingIn.value = true
  await login({
    email: email.value,
    password: password.value,
  })
}
</script>
