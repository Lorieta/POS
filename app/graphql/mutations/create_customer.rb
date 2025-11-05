# app/graphql/mutations/create_customer.rb
module Mutations
  class CreateCustomer < BaseMutation
    # Define input arguments
  argument :first_name, String, required: true
  argument :last_name, String, required: true
  argument :email, String, required: true
  argument :phone_number, String, required: false
  argument :delivery_id, ID, required: false

    # Define what the mutation returns
    field :customer, Types::CustomerType, null: true
    field :errors, [String], null: false

    def resolve(first_name:, last_name:, email:, phone_number: nil, delivery_id: nil)
      customer = Customer.new(
        first_name: first_name,
        last_name: last_name,
        email: email,
        phone_number: phone_number,
        delivery_id: delivery_id
      )

      if customer.save
        {
          customer: customer,
          errors: []
        }
      else
        {
          customer: nil,
          errors: customer.errors.full_messages
        }
      end
    end
  end
end
