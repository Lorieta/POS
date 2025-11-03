# frozen_string_literal: true

module Mutations
  class CreateProduct < BaseMutation
    argument :name, String, required: true
    argument :product_price, Float, required: true
    argument :product_type, String, required: true
    argument :image_signed_id, String, required: false

    field :product, Types::ProductType, null: true
    field :errors, [String], null: false

    def resolve(name:, product_price:, product_type:, image_signed_id: nil)
      product = Product.new(name:, product_price:, product_type:)
      product.image.attach(image_signed_id) if image_signed_id.present?

      if product.save
        { product:, errors: [] }
      else
        { product: nil, errors: product.errors.full_messages }
      end
    end
  end
end
