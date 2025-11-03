# frozen_string_literal: true

module Types
  class DirectUploadType < Types::BaseObject
    field :signed_id, String, null: false
    field :url, String, null: false
    field :headers, GraphQL::Types::JSON, null: false
    field :blob_id, ID, null: false
    field :filename, String, null: false
    field :byte_size, Integer, null: false
    field :checksum, String, null: false
    field :content_type, String, null: true
  end
end
