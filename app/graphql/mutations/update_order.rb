# frozen_string_literal: true

require "bigdecimal"

module Mutations
  class UpdateOrder < BaseMutation
    argument :id, ID, required: true
    argument :order_quantity, Integer, required: false
    argument :payment_method, String, required: false
    argument :status, Types::OrderStatusEnum, required: false
    argument :order_date, GraphQL::Types::ISO8601Date, required: false
    argument :total_amount, Float, required: false

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

    def resolve(id:, **attributes)
      order = Order.find_by(id: id)
      return { order: nil, errors: [ "Order not found" ] } unless order

      # Extract delivery attributes
      delivery_attrs = extract_delivery_attributes(attributes)

      permitted = attributes.compact

      if permitted[:order_quantity]&.<= 0
        return { order: nil, errors: [ "Order quantity must be greater than zero" ] }
      end

      normalize_order_date!(permitted)

      total_amount = permitted.delete(:total_amount)

      ActiveRecord::Base.transaction do
        assign_total_amount(order, total_amount, permitted[:order_quantity])
        order.assign_attributes(permitted)

        unless order.save
          raise ActiveRecord::Rollback
        end

        # Update or create delivery information if provided
        if delivery_attrs.any?
          update_delivery(order, delivery_attrs)
        end

        return { order:, errors: [] }
      end

      { order: nil, errors: order.errors.full_messages }
    rescue ArgumentError => e
      Rails.logger.warn("Update order validation failed: #{e.message}")
      { order: nil, errors: [ e.message ] }
    rescue StandardError => e
      Rails.logger.error("Update order failed: #{e.message}")
      { order: nil, errors: [ "Failed to update order" ] }
    end

    private

    def normalize_order_date!(attrs)
      return unless attrs.key?(:order_date)

      value = attrs[:order_date]
      attrs[:order_date] = value.present? ? Date.parse(value.to_s) : nil
    rescue ArgumentError
      raise ArgumentError, "Invalid order date"
    end

    def assign_total_amount(order, explicit_total, new_quantity)
      if explicit_total.present?
        amount = BigDecimal(explicit_total.to_s)
        raise ArgumentError, "Total amount must be zero or positive" if amount.negative?

        order.total_amount_provided = true
        order.total_amount = amount.round(2)
      elsif new_quantity.present?
        order.total_amount_provided = false
        order.total_amount = calculate_total(order.product, new_quantity)
      end
    end

    def calculate_total(product, quantity)
      price = BigDecimal(product.product_price.to_s)
      qty = BigDecimal(quantity.to_s)

      (price * qty).round(2)
    rescue ArgumentError
      BigDecimal("0")
    end

    def extract_delivery_attributes(attributes)
      delivery_fields = [ :country, :province, :city, :street, :branggay, :unit, :floor, :building, :landmark, :remarks ]
      attributes.slice(*delivery_fields).compact
    end

    def update_delivery(order, delivery_attrs)
      delivery = Delivery.find_or_initialize_by(order: order)
      delivery.user = order.user
      delivery.assign_attributes(delivery_attrs)

      unless delivery.save
        raise ActiveRecord::Rollback
      end
    end
  end
end
