module Types
  class ProductType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :product_photo, String, null: true
    field :product_price, Float, null: true
    field :product_type, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :image_url, String, null: true

    def product_photo
      object.product_photo.presence || image_url
    end

    def image_url
      return unless object.image.attached?

      request = context[:request]
      host = request&.base_url || Rails.application.routes.default_url_options[:host]
      return unless host

      Rails.application.routes.url_helpers.rails_blob_url(object.image, host: host)
    end
  end
end
