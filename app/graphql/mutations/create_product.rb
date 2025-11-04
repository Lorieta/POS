# frozen_string_literal: true

module Mutations
  class CreateProduct < BaseMutation
    argument :name, String, required: true
    argument :product_price, Float, required: true
  argument :product_type, String, required: true
  argument :category, String, required: false
  argument :description, String, required: false
  argument :user_id, ID, required: false
  argument :image_signed_id, String, required: false

    field :product, Types::ProductType, null: true
    field :errors, [String], null: false

    def resolve(name:, product_price:, product_type:, category: nil, description: nil, user_id: nil, image_signed_id: nil)
      product = Product.new(
        name:,
        product_price:,
        product_type:,
        category: category.presence,
        description: description.presence
      )

      if (current_user = context[:current_user]).present?
        product.user = current_user
      elsif user_id.present?
        user = User.find_by(id: user_id)
        return { product: nil, errors: ["User not found"] } unless user

        product.user = user
      end

      product.image.attach(image_signed_id) if image_signed_id.present?

      if product.save
        { product:, errors: [] }
      else
        { product: nil, errors: product.errors.full_messages }
      end
    end
  end
end
