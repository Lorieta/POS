import { gql } from '@apollo/client/core'

export const CREATE_CUSTOMER_MUTATION = gql`
  mutation CreateCustomer(
    $firstName: String!
    $lastName: String!
    $email: String!
    $phoneNumber: String
  ) {
    createCustomer(
      firstName: $firstName
      lastName: $lastName
      email: $email
      phoneNumber: $phoneNumber
    ) {
      customer {
        id
        firstName
        lastName
        email
        phoneNumber
      }
      errors
    }
  }
`

export const GET_CUSTOMERS_QUERY = gql`
  query GetCustomers {
    customers {
      id
      email
      firstName
      lastName
      phoneNumber
    }
  }
`
