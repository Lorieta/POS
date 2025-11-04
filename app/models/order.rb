require 'bigdecimal'

class Order < ApplicationRecord
  belongs_to :product
  belongs_to :user

  before_validation :compute_total_amount
  before_validation :ensure_order_date

  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }

  attr_accessor :total_amount_provided

  private

  def ensure_order_date
    return unless order_date.blank?

    timestamp = created_at || Time.current
    self.order_date = timestamp.to_date
  end

  def compute_total_amount
    return if total_amount_provided && total_amount.present?
    return self.total_amount = 0 unless order_quantity.present? && product.present?

    price = BigDecimal(product.product_price.to_s)
    quantity = BigDecimal(order_quantity.to_s)

    self.total_amount = (price * quantity).round(2)
  rescue ArgumentError
    self.total_amount = 0
  end
end
