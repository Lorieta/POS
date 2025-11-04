# frozen_string_literal: true

module Types
  class CheckoutCustomerInput < Types::BaseInputObject
    description "Customer details captured during checkout"

    argument :email, String, required: false
    argument :mobile, String, required: false
    argument :first_name, String, required: false
    argument :last_name, String, required: false
  end
end
