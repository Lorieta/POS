# frozen_string_literal: true

module Mutations
  class CreateOrder < BaseMutation
    argument :product_id, ID, required: true
    argument :order_quantity, Integer, required: true
    argument :payment_method, String, required: false
    argument :order_date, GraphQL::Types::ISO8601Date, required: false
    argument :user_id, ID, required: false

    field :order, Types::OrderType, null: true
    field :errors, [ String ], null: false

    def resolve(product_id:, order_quantity:, payment_method: nil, order_date: nil, user_id: nil)
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
        order_date: order_date || Date.current,
      )

      if order.save
        { order: order, errors: [] }
      else
        { order: nil, errors: order.errors.full_messages }
      end
    end

    private

    def resolve_user(user_id)
      current_user = context[:current_user]
      return current_user if current_user.present?
      return User.find_by(id: user_id) if user_id.present?

      nil
    end

    def invalid_quantity
      { order: nil, errors: [ "Order quantity must be greater than zero" ] }
    end
  end
end
