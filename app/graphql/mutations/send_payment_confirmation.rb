# frozen_string_literal: true

module Mutations
  class SendPaymentConfirmation < BaseMutation
    argument :order_ids, [ID], required: true
    argument :recipient, String, required: true
    argument :summary, Types::CheckoutSummaryInput, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(order_ids:, recipient:, summary:)
      orders = Order.where(id: order_ids).to_a

      if orders.empty?
        return { success: false, errors: ["No matching orders found"] }
      end

      if recipient.blank?
        return { success: false, errors: ["Recipient email is required"] }
      end

      summary_payload = summary.to_h

      OrderMailer
        .payment_confirmation(orders: orders, summary: summary_payload, recipient: recipient)
        .deliver_later

      { success: true, errors: [] }
    rescue StandardError => e
      Rails.logger.error("SendPaymentConfirmation failed: #{e.message}")
      { success: false, errors: ["Failed to send payment confirmation email"] }
    end
  end
end
