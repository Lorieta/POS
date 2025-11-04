import { gql } from '@apollo/client/core'

export const GET_PRODUCTS_QUERY = gql`
  query GetProducts {
    products {
      id
      name
      description
      productPrice
      productType
      category
      imageUrl
      productPhoto
      userId
      user {
        id
        firstName
        lastName
        email
      }
    }
  }
`

export const GET_ALL_PRODUCTS_QUERY = gql`
  query GetAllProducts {
    allProducts {
      id
      name
      description
      productPrice
      productType
      category
      imageUrl
      productPhoto
    }
  }
`

export const CREATE_PRODUCT_MUTATION = gql`
  mutation CreateProduct(
    $name: String!
    $productPrice: Float!
    $productType: String!
    $imageSignedId: String
    $category: String
    $description: String
    $userId: ID
  ) {
    createProduct(
      name: $name
      productPrice: $productPrice
      productType: $productType
      category: $category
      description: $description
      userId: $userId
      imageSignedId: $imageSignedId
    ) {
      product {
        id
        name
        description
        productPrice
        productType
        category
        userId
        user {
          id
          firstName
          lastName
          email
        }
        imageUrl
        productPhoto
      }
      errors
    }
  }
`

export const UPDATE_PRODUCT_MUTATION = gql`
  mutation UpdateProduct(
    $id: ID!
    $name: String!
    $description: String
    $productPrice: Float!
    $productType: String!
    $category: String
    $imageSignedId: String
  ) {
    updateProduct(
      id: $id
      name: $name
      description: $description
      productPrice: $productPrice
      productType: $productType
      category: $category
      imageSignedId: $imageSignedId
    ) {
      product {
        id
        name
        description
        productPrice
        productType
        category
        imageUrl
        productPhoto
      }
      errors
    }
  }
`

export const DELETE_PRODUCT_MUTATION = gql`
  mutation DeleteProduct($id: ID!) {
    deleteProduct(id: $id) {
      success
      errors
    }
  }
`
