# frozen_string_literal: true

module Types
  class CheckoutAddressInput < Types::BaseInputObject
    description "Delivery or shipping address supplied during checkout"

    argument :country, String, required: false
    argument :province, String, required: false
    argument :city, String, required: false
    argument :street, String, required: false
    argument :barangay, String, required: false
    argument :room_unit, String, required: false
    argument :floor, String, required: false
    argument :building, String, required: false
    argument :landmark, String, required: false
    argument :remarks, String, required: false
  end
end
