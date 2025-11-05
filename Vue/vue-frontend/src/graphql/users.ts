import { gql } from '@apollo/client/core'

export const GET_USERS_QUERY = gql`
  query GetUsers {
    users {
      id
      email
      firstName
      lastName
      phoneNumber
    }
  }
`
