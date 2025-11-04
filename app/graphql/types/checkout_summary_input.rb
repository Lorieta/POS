# frozen_string_literal: true

module Types
  class CheckoutSummaryInput < Types::BaseInputObject
    description "Full checkout context used for order placement and confirmations"

    argument :payment_method, String, required: false
    argument :coupon_code, String, required: false
    argument :customer, Types::CheckoutCustomerInput, required: false
    argument :address, Types::CheckoutAddressInput, required: false
    argument :totals, Types::CheckoutTotalsInput, required: false
  end
end
