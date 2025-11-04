# frozen_string_literal: true

module Types
  class CheckoutTotalsInput < Types::BaseInputObject
    description "Aggregated monetary totals calculated during checkout"

    argument :subtotal, Float, required: false
    argument :vat, Float, required: false
    argument :delivery_fee, Float, required: false
    argument :convenience_fee, Float, required: false
    argument :grand_total, Float, required: false
    argument :coupon_code, String, required: false
  end
end
