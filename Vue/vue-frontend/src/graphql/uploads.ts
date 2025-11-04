import { gql } from '@apollo/client/core'

export const CREATE_DIRECT_UPLOAD_MUTATION = gql`
  mutation CreateDirectUpload(
    $filename: String!
    $byteSize: Int!
    $checksum: String!
    $contentType: String
  ) {
    createDirectUpload(
      filename: $filename
      byteSize: $byteSize
      checksum: $checksum
      contentType: $contentType
    ) {
      directUpload {
        signedId
        url
        headers
        blobId
      }
      errors
    }
  }
`
