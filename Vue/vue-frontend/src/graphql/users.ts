import { gql } from '@apollo/client/core'

export const GET_CUSTOMERS_QUERY = gql`
  query GetCustomers {
    users {
      id
      email
      firstName
      lastName
      phoneNumber
    }
  }
`
