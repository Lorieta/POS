# frozen_string_literal: true

module Mutations
  class SendOrderEmails < BaseMutation
    argument :order_ids, [ID], required: true
    argument :recipient_email, String, required: false
    argument :summary, GraphQL::Types::JSON, required: false

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(order_ids:, recipient_email: nil, summary: nil)
      orders = Order.where(id: order_ids).to_a
      if orders.empty?
        return { success: false, errors: ["No orders found for provided IDs"] }
      end

      recipient = recipient_email.presence || orders.first.user&.email || summary&.dig('customer')&.fetch('email', nil)
      if recipient.blank?
        return { success: false, errors: ["Recipient email is required"] }
      end

      begin
        # Enqueue mailer (uses ActiveJob)
        OrderMailer.payment_confirmation(orders: orders, summary: summary || {}, recipient: recipient).deliver_later
        { success: true, errors: [] }
      rescue StandardError => e
        Rails.logger.error("SendOrderEmails failed: #{e.message}")
        { success: false, errors: ["Failed to enqueue email"] }
      end
    end
  end
end
