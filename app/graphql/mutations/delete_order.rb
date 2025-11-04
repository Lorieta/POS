# frozen_string_literal: true

module Mutations
  class DeleteOrder < BaseMutation
    argument :id, ID, required: false
    argument :group_id, String, required: false

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(id: nil, group_id: nil)
      orders = resolve_orders(id, group_id)
      return orders if orders.is_a?(Hash)

      begin
        Order.transaction do
          orders.each(&:destroy!)
        end
        { success: true, errors: [] }
      rescue ActiveRecord::RecordNotDestroyed => e
        errors = orders.flat_map { |order| order.errors.full_messages }.presence || [e.message]
        { success: false, errors: errors }
      rescue ActiveRecord::InvalidForeignKey
        { success: false, errors: ["Unable to delete order because related records exist."] }
      end
    end

    private

    def resolve_orders(id, group_id)
      if group_id.present?
        orders = Order.where(group_id: group_id)
        return { success: false, errors: ["No orders found for the provided group id."] } if orders.blank?
        return orders
      end

      if id.present?
        order = Order.find_by(id: id)
        return { success: false, errors: ["Order not found"] } unless order
        return [order]
      end

      { success: false, errors: ["Either id or groupId must be provided."] }
    end
  end
end
