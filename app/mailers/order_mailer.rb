class OrderMailer < ApplicationMailer
  def payment_confirmation(orders:, summary:, recipient:)
    @orders = Array(orders)
    @summary = normalize_summary(summary)
    @recipient = recipient

    mail(
      to: recipient,
      subject: "Order Placed Successfully - #{order_reference_line}"
    )
  end

  private

  def normalize_summary(summary)
    return {} unless summary.present?

    deep_transform_keys(summary) { |key| key.to_s.underscore.to_sym }
  end

  def order_reference_line
    @orders.map { |order| "##{order.id}" }.join(', ')
  end

  def deep_transform_keys(object, &block)
    case object
    when Hash
      object.each_with_object({}) do |(key, value), result|
        result[block.call(key)] = deep_transform_keys(value, &block)
      end
    when Array
      object.map { |value| deep_transform_keys(value, &block) }
    else
      object
    end
  end
end
