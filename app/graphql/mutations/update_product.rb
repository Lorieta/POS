# frozen_string_literal: true

module Mutations
  class UpdateProduct < BaseMutation
    argument :id, ID, required: true
    argument :name, String, required: false
    argument :description, String, required: false
    argument :product_price, Float, required: false
    argument :product_type, String, required: false
  argument :category, String, required: false
  argument :image_signed_id, String, required: false

    field :product, Types::ProductType, null: true
    field :errors, [ String ], null: false

    def resolve(id:, **attributes)
      product = Product.find_by(id: id)
      return { product: nil, errors: [ "Product not found" ] } unless product

      image_signed_id = attributes.delete(:image_signed_id)

      permitted = attributes.compact

      ActiveRecord::Base.transaction do
        product.assign_attributes(permitted)
        product.image.attach(image_signed_id) if image_signed_id.present?

        if product.save
          { product:, errors: [] }
        else
          raise ActiveRecord::Rollback
        end
      end

      unless product.errors.empty?
        return { product: nil, errors: product.errors.full_messages }
      end

      { product:, errors: [] }
    rescue StandardError => e
      Rails.logger.error("Update product failed: #{e.message}")
      { product: nil, errors: [ "Failed to update product" ] }
    end
  end
end
