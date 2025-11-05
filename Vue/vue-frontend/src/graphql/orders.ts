import { gql } from '@apollo/client/core'

export const CREATE_ORDER_MUTATION = gql`
  mutation CreateOrder(
    $productId: ID!
    $orderQuantity: Int!
    $paymentMethod: String
    $customerId: ID!
    $totalAmount: Float
    $groupId: String
    $country: String
    $province: String
    $city: String
    $street: String
    $branggay: String
    $unit: String
    $floor: String
    $building: String
    $landmark: String
    $remarks: String
  ) {
    createOrder(
      productId: $productId
      orderQuantity: $orderQuantity
      paymentMethod: $paymentMethod
  customerId: $customerId
      totalAmount: $totalAmount
      groupId: $groupId
      country: $country
      province: $province
      city: $city
      street: $street
      branggay: $branggay
      unit: $unit
      floor: $floor
      building: $building
      landmark: $landmark
      remarks: $remarks
    ) {
      order {
        id
        groupId
        orderDate
        orderQuantity
        paymentMethod
        status
        totalAmount
        product {
          id
          name
          productPrice
        }
        customer {
          id
          email
          firstName
          lastName
          phoneNumber
        }
        createdAt
        updatedAt
      }
      errors
    }
  }
`

export const GET_ORDERS_QUERY = gql`
  query GetOrders {
    orders {
      id
      groupId
      orderDate
      orderQuantity
      paymentMethod
      status
      totalAmount
      product {
        id
        name
        productPrice
      }
      customer {
        id
        email
        firstName
        lastName
        phoneNumber
      }
      createdAt
      updatedAt
    }
  }
`

export const UPDATE_ORDER_MUTATION = gql`
  mutation UpdateOrder(
    $id: ID!
    $orderQuantity: Int
    $paymentMethod: String
    $status: OrderStatusEnum
    $orderDate: ISO8601Date
    $totalAmount: Float
  ) {
    updateOrder(
      id: $id
      orderQuantity: $orderQuantity
      paymentMethod: $paymentMethod
      status: $status
      orderDate: $orderDate
      totalAmount: $totalAmount
    ) {
      order {
        id
        orderDate
        orderQuantity
        paymentMethod
        status
        totalAmount
        product {
          id
          name
          productPrice
        }
        customer {
          id
          email
          firstName
          lastName
          phoneNumber
        }
        createdAt
        updatedAt
      }
      errors
    }
  }
`

export const DELETE_ORDER_MUTATION = gql`
  mutation DeleteOrder($id: ID, $groupId: String) {
    deleteOrder(id: $id, groupId: $groupId) {
      success
      errors
    }
  }
`

export const SEND_ORDER_EMAILS_MUTATION = gql`
    mutation SendOrderEmails($orderIds: [ID!]!, $recipientEmail: String, $summary: JSON) {
      sendOrderEmails(orderIds: $orderIds, recipientEmail: $recipientEmail, summary: $summary) {
        success
        errors
      }
    }
  `
