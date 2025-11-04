import { gql } from '@apollo/client/core'

export const SIGN_IN_USER_MUTATION = gql`
  mutation SignInUser($email: String!, $password: String!) {
    login: signInUser(email: $email, password: $password) {
      token
      user {
        id
        email
        firstName
        lastName
        phoneNumber
        status
      }
    }
  }
`

export const CREATE_USER_MUTATION = gql`
  mutation CreateUser($credentials: AUTH_PROVIDER_CREDENTIALS!) {
    signup: createUser(credentials: $credentials) {
      id
      email
      firstName
      lastName
      phoneNumber
      status
    }
  }
`

export const LOGOUT_MUTATION = gql`
  mutation LogoutUser {
    logoutUser {
      success
    }
  }
`
