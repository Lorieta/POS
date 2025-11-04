# frozen_string_literal: true

module Mutations
  class CreateDirectUpload < BaseMutation
    argument :filename, String, required: true
    argument :byte_size, Integer, required: true
    argument :checksum, String, required: true
    argument :content_type, String, required: false

    field :direct_upload, Types::DirectUploadType, null: true
    field :errors, [ String ], null: false

    def resolve(filename:, byte_size:, checksum:, content_type: nil)
      blob = ActiveStorage::Blob.create_before_direct_upload!(
        filename:,
        byte_size:,
        checksum:,
        content_type:
      )

      direct_upload = {
        signed_id: blob.signed_id,
        url: blob.service_url_for_direct_upload,
        headers: blob.service_headers_for_direct_upload,
        blob_id: blob.id,
        filename: blob.filename.to_s,
        byte_size: blob.byte_size,
        checksum: blob.checksum,
        content_type: blob.content_type
      }

      { direct_upload:, errors: [] }
    rescue StandardError => e
      Rails.logger.error("Direct upload setup failed: #{e.message}")
      { direct_upload: nil, errors: [ "Direct upload setup failed" ] }
    end
  end
end
