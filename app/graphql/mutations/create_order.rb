# frozen_string_literal: true

require "bigdecimal"

module Mutations
  class CreateOrder < BaseMutation
    argument :product_id, ID, required: true
    argument :order_quantity, Integer, required: true
    argument :payment_method, String, required: false
    argument :user_id, ID, required: false
    argument :total_amount, Float, required: false
  argument :group_id, String, required: false

    # Delivery information arguments
    argument :country, String, required: false
    argument :province, String, required: false
    argument :city, String, required: false
    argument :street, String, required: false
    argument :branggay, String, required: false
    argument :unit, String, required: false
    argument :floor, String, required: false
    argument :building, String, required: false
    argument :landmark, String, required: false
    argument :remarks, String, required: false

    field :order, Types::OrderType, null: true
    field :errors, [ String ], null: false

    def resolve(
      product_id:,
      order_quantity:,
      payment_method: nil,
      user_id: nil,
      total_amount: nil,
      country: nil,
      province: nil,
      city: nil,
      street: nil,
      branggay: nil,
      unit: nil,
      floor: nil,
      building: nil,
      landmark: nil,
      remarks: nil,
      group_id: nil
    )
      return invalid_quantity unless order_quantity.positive?

      user = resolve_user(user_id)
      return { order: nil, errors: [ "User not found" ] } unless user

      product = Product.find_by(id: product_id)
      return { order: nil, errors: [ "Product not found" ] } unless product

      order = Order.new(
        user: user,
        product: product,
        order_quantity: order_quantity,
        payment_method: payment_method.presence,
        group_id: group_id.presence,
      )

      explicit_total = normalize_total_amount(total_amount)

      if explicit_total
        order.total_amount_provided = true
        order.total_amount = explicit_total
      else
        order.total_amount = calculate_total(product, order_quantity)
      end

      # Use a transaction to ensure both order and delivery are saved together
      ActiveRecord::Base.transaction do
        unless order.save
          return { order: nil, errors: order.errors.full_messages }
        end

        # Create delivery record if any delivery information is provided
        if has_delivery_info?(country, province, city, street, branggay, unit, floor, building, landmark, remarks)
          delivery = Delivery.new(
            order: order,
            user: user,
            country: country.presence,
            province: province.presence,
            city: city.presence,
            street: street.presence,
            branggay: branggay.presence,
            unit: unit.presence,
            floor: floor.presence,
            building: building.presence,
            landmark: landmark.presence,
            remarks: remarks.presence
          )

          unless delivery.save
            raise ActiveRecord::Rollback
            return { order: nil, errors: delivery.errors.full_messages }
          end
        end
      end

      { order: order, errors: [] }
    end

    private

    def resolve_user(user_id)
      current_user = context[:current_user]
      return current_user if current_user.present?
      return User.find_by(id: user_id) if user_id.present?

      nil
    end

    def calculate_total(product, order_quantity)
      price = BigDecimal(product.product_price.to_s)
      quantity = BigDecimal(order_quantity.to_s)

      (price * quantity).round(2)
    rescue ArgumentError
      BigDecimal("0")
    end

    def normalize_total_amount(total_amount)
      return nil if total_amount.nil?

      amount = BigDecimal(total_amount.to_s)
      return nil if amount.negative?

      amount.round(2)
    rescue ArgumentError
      nil
    end

    def invalid_quantity
      { order: nil, errors: [ "Order quantity must be greater than zero" ] }
    end

    def has_delivery_info?(*fields)
      fields.any?(&:present?)
    end
  end
end
